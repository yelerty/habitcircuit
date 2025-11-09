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
            guard let url = pendingFileURL else { return }
            handleFileImport(url)
            pendingFileURL = nil // Reset after handling
        }
        .alert("루틴 가져오기", isPresented: $showImportAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(importMessage)
        }
    }

    private func handleFileImport(_ url: URL) {
        // Ensure we have access to the file
        guard url.startAccessingSecurityScopedResource() else {
            importMessage = "파일 접근 권한이 없습니다."
            showImportAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)

            // Use RoutineExportManager to parse the data
            guard let importedRoutines = RoutineExportManager.shared.importRoutines(from: data) else {
                importMessage = "파일 형식이 올바르지 않습니다."
                showImportAlert = true
                return
            }

            // Import routines using Core Data directly
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

            // Save context
            try viewContext.save()
            importMessage = "\(importedCount)개의 루틴을 가져왔습니다!"
            showImportAlert = true

            // Reload data
            viewModel.loadRoutines()
            viewModel.loadAllRoutines()
        } catch {
            importMessage = "파일을 불러오는데 실패했습니다: \(error.localizedDescription)"
            showImportAlert = true
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
