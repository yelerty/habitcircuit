//
//  HabitSeriesApp.swift
//  HabitSeries
//
//  Created by jihong on 10/25/25.
//

import SwiftUI
import CoreData

@main
struct HabitSeriesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
