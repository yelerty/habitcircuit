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

    init() {
        _viewModel = StateObject(wrappedValue: RoutineViewModel(context: PersistenceController.shared.container.viewContext))
    }

    var body: some View {
        NavigationView {
            HomeView(viewModel: viewModel, showEditScreen: $showEditScreen)
        }
        .sheet(isPresented: $showEditScreen) {
            RoutineEditView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
