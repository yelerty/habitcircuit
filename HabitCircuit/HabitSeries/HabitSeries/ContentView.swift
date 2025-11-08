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

    init() {
        _viewModel = StateObject(wrappedValue: RoutineViewModel(context: PersistenceController.shared.container.viewContext))
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
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
