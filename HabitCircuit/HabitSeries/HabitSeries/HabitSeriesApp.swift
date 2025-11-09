//
//  HabitSeriesApp.swift
//  HabitSeries
//
//  Created by jihong on 10/25/25.
//

import SwiftUI
import CoreData
import GoogleMobileAds

@main
struct HabitSeriesApp: App {
    let persistenceController = PersistenceController.shared
    @State private var pendingFileURL: URL?

    init() {
        // Initialize Google Mobile Ads SDK asynchronously (non-blocking)
        DispatchQueue.global(qos: .background).async {
            MobileAds.shared.start(completionHandler: nil)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(pendingFileURL: $pendingFileURL)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    // Handle file opening from external sources (Safari, Files app, etc.)
                    handleIncomingFile(url)
                }
        }
    }

    private func handleIncomingFile(_ url: URL) {
        // Check if it's a JSON file
        guard url.pathExtension.lowercased() == "json" else {
            return
        }

        // Store the URL to be processed by ContentView
        pendingFileURL = url
    }
}
