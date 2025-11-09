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
        .onChange(of: pendingFileURL) { newURL in
            if let url = newURL {
                handleFileImport(url)
                pendingFileURL = nil
            }
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
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let routineData = try decoder.decode(RoutineExportData.self, from: data)

            // Import routines
            var importedCount = 0
            for routine in routineData.routines {
                viewModel.addRoutine(
                    name: routine.name,
                    dayOfWeek: routine.dayOfWeek,
                    timeType: routine.timeType,
                    order: Int16(routine.order)
                )
                importedCount += 1
            }

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
