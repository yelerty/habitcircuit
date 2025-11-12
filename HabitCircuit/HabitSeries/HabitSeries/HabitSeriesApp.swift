//
//  HabitSeriesApp.swift
//  HabitSeries
//
//  Created by jihong on 10/25/25.
//

import SwiftUI
import CoreData
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

@main
struct HabitSeriesApp: App {
    let persistenceController = PersistenceController.shared
    @State private var pendingFileURL: URL?

    init() {
        // Initialize Google Mobile Ads SDK asynchronously (non-blocking)
        DispatchQueue.global(qos: .background).async {
            MobileAds.shared.start { initStatus in
                // AdMob SDK initialization complete
                print("🎯 AdMob SDK initialized")

                #if DEBUG
                print("🧪 DEBUG MODE: Using test ads")
                #else
                print("🚀 RELEASE MODE: Using production ads")
                #endif

                // Log initialization status
                let adapterStatuses = initStatus.adapterStatusesByClassName
                for (adapter, status) in adapterStatuses {
                    print("📡 AdMob Adapter: \(adapter) - State: \(status.state.rawValue)")
                }
            }
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

                    // Request ATT permission after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        requestTrackingPermission()
                    }
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

    private func requestTrackingPermission() {
        // Only request permission on iOS 14.5+
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization granted
                    print("✅ ATT: Tracking permission granted")
                    // Get IDFA if needed
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
                    print("📱 IDFA: \(idfa)")
                case .denied:
                    print("❌ ATT: Tracking permission denied")
                case .restricted:
                    print("⚠️ ATT: Tracking permission restricted")
                case .notDetermined:
                    print("❓ ATT: Tracking permission not determined")
                @unknown default:
                    print("❓ ATT: Unknown tracking status")
                }
            }
        }
    }
}
