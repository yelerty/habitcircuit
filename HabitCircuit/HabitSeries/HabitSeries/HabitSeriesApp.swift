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
                    if url.scheme == "habitcircuit" {
                        // Handle URL scheme from Share Extension
                        checkPendingImport()
                    } else {
                        // Handle direct file opening
                        handleIncomingFile(url)
                    }
                }
                .onAppear {
                    // Check for pending import from Share Extension when app appears
                    checkPendingImport()
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

    private func checkPendingImport() {
        // Check if there's a pending import from Share Extension
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.habitcircuit.shared") else {
            return
        }

        let fileURL = sharedContainerURL.appendingPathComponent("pending_import.json")

        // Check if file exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // Set as pending file URL
            pendingFileURL = fileURL

            // Delete the file after reading
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}
