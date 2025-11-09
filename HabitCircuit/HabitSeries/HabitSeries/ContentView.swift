//
//  ContentView.swift
//  HabitSeries
//
//  Created by jihong on 10/25/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: RoutineViewModel
    @State private var showEditScreen = false
    @State private var isLoading = true
    @Binding var pendingFileURL: URL?
    @State private var showImportAlert = false
    @State private var importMessage = ""
    @State private var showReplaceConfirmation = false
    @State private var pendingImportURL: URL?

    init(pendingFileURL: Binding<URL?> = .constant(nil)) {
        _viewModel = StateObject(wrappedValue: RoutineViewModel(context: PersistenceController.shared.container.viewContext))
        _pendingFileURL = pendingFileURL
    }

    var body: some View {
        ZStack {
            if isLoading {
                SplashScreenView(isLoading: $isLoading)
                    .transition(.opacity)
            } else {
                NavigationView {
                    HomeView(viewModel: viewModel, showEditScreen: $showEditScreen)
                }
                .sheet(isPresented: $showEditScreen, onDismiss: {
                    // Reload data when edit screen is dismissed
                    viewModel.loadRoutines()
                    viewModel.loadAllRoutines()
                }) {
                    RoutineEditView(viewModel: viewModel)
                }
                .transition(.opacity)
            }
        }
        .onChange(of: pendingFileURL) {
            guard let url = pendingFileURL else {
                print("⚠️ pendingFileURL is nil, skipping")
                return
            }

            print("🔵 onChange triggered with URL: \(url.lastPathComponent)")
            print("🔵 Current pendingImportURL: \(pendingImportURL?.lastPathComponent ?? "nil")")

            // Prevent duplicate imports
            if pendingImportURL != nil {
                print("⚠️ Import already pending, ignoring duplicate trigger")
                pendingFileURL = nil
                return
            }

            // Store URL and show confirmation
            pendingImportURL = url
            showReplaceConfirmation = true
            pendingFileURL = nil

            print("✅ Set pendingImportURL and showing confirmation")
        }
        .alert("기존 루틴 교체", isPresented: $showReplaceConfirmation) {
            Button("취소", role: .cancel) {
                pendingImportURL = nil
            }
            Button("교체", role: .destructive) {
                if let url = pendingImportURL {
                    performFileImport(url)
                    pendingImportURL = nil
                }
            }
        } message: {
            Text("가져온 루틴으로 모든 기존 루틴을 교체합니다.\n기존 루틴은 삭제됩니다.")
        }
        .alert("루틴 가져오기", isPresented: $showImportAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(importMessage)
        }
    }

    private func performFileImport(_ url: URL) {
        print("🟢 === START performFileImport ===")
        print("🟢 URL: \(url.lastPathComponent)")

        // Ensure we have access to the file
        guard url.startAccessingSecurityScopedResource() else {
            print("❌ Failed to access security scoped resource")
            importMessage = "파일 접근 권한이 없습니다."
            showImportAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            print("🟢 Read \(data.count) bytes from file")

            // Use RoutineExportManager to parse the data
            guard let importedRoutines = RoutineExportManager.shared.importRoutines(from: data) else {
                print("❌ Failed to parse routines from data")
                importMessage = "파일 형식이 올바르지 않습니다."
                showImportAlert = true
                return
            }

            print("🟢 Parsed \(importedRoutines.count) routines from file")

            // DELETE ALL EXISTING ROUTINES FIRST
            let fetchRequest: NSFetchRequest<Routine> = Routine.fetchRequest()

            do {
                // Fetch all existing routines
                let existingRoutines = try viewContext.fetch(fetchRequest)
                print("🟢 Found \(existingRoutines.count) existing routines to delete")

                // Delete each routine individually
                for routine in existingRoutines {
                    viewContext.delete(routine)
                }

                // Save the deletion
                try viewContext.save()

                print("✅ Successfully deleted \(existingRoutines.count) existing routines")
            } catch {
                print("❌ Failed to delete existing routines: \(error)")
                importMessage = "기존 루틴 삭제 실패: \(error.localizedDescription)"
                showImportAlert = true
                return
            }

            // Import new routines using Core Data directly
            var importedCount = 0
            for routineData in importedRoutines {
                let routine = Routine(context: viewContext)
                routine.id = UUID()
                routine.name = routineData.name
                routine.dayOfWeek = routineData.dayOfWeek
                routine.timeType = routineData.timeType
                routine.order = Int16(routineData.order)
                routine.isCompleted = false
                routine.createdAt = Date()
                routine.category = RoutineCategory.other.rawValue

                importedCount += 1
            }

            print("🟢 Created \(importedCount) new routines")

            // Save context
            try viewContext.save()
            print("✅ Saved new routines to Core Data")

            importMessage = "기존 루틴을 삭제하고 \(importedCount)개의 새로운 루틴을 가져왔습니다!"
            showImportAlert = true

            // Reload data
            viewModel.loadRoutines()
            viewModel.loadAllRoutines()
            print("✅ Reloaded viewModel data")
            print("🟢 === END performFileImport ===")
        } catch {
            print("❌ Error during import: \(error)")
            importMessage = "파일을 불러오는데 실패했습니다: \(error.localizedDescription)"
            showImportAlert = true
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
