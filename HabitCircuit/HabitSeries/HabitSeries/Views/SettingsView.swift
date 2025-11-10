import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var streakManager = StreakManager.shared
    @StateObject private var viewModel = RoutineViewModel(context: PersistenceController.shared.container.viewContext)
    @StateObject private var timeSlotManager = TimeSlotManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared

    @State private var showExportSheet = false
    @State private var showImportSheet = false
    @State private var exportedFileURL: URL?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSavedRoutines = false
    @State private var showTimeGuide = false
    @State private var showDefaultRoutinesManagement = false
    @State private var showLanguageSelection = false

    var body: some View {
        NavigationView {
            List {
                // Notification Settings Section
                Section {
                    NotificationTimeRow(
                        timeType: .morning,
                        time: $notificationManager.morningTime,
                        isEnabled: $notificationManager.morningEnabled
                    )

                    NotificationTimeRow(
                        timeType: .afternoon,
                        time: $notificationManager.afternoonTime,
                        isEnabled: $notificationManager.afternoonEnabled
                    )

                    NotificationTimeRow(
                        timeType: .evening,
                        time: $notificationManager.eveningTime,
                        isEnabled: $notificationManager.eveningEnabled
                    )
                } header: {
                    Label(L("settings.notifications"), systemImage: "bell.fill")
                } footer: {
                    Text(L("settings.notifications.footer"))
                }

                // Streak Statistics Section
                Section {
                    HStack {
                        Label(L("settings.current.streak"), systemImage: "flame.fill")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("\(streakManager.currentStreak)\(L("home.days"))")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }

                    HStack {
                        Label(L("settings.longest.streak"), systemImage: "trophy.fill")
                            .foregroundColor(.yellow)
                        Spacer()
                        Text("\(streakManager.longestStreak)\(L("home.days"))")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }

                    HStack {
                        Label(L("settings.total.completion"), systemImage: "calendar.badge.checkmark")
                            .foregroundColor(.green)
                        Spacer()
                        Text("\(streakManager.completionDates.count)\(L("home.days"))")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                } header: {
                    Label(L("settings.statistics"), systemImage: "chart.bar.fill")
                }

                // Data Management Section
                Section {
                    Button(action: {
                        showSavedRoutines = true
                    }) {
                        HStack {
                            Label(L("settings.saved.routines"), systemImage: "folder.badge.gearshape")
                                .foregroundColor(.orange)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    Button(action: {
                        showDefaultRoutinesManagement = true
                    }) {
                        HStack {
                            Label(L("settings.example.routines"), systemImage: "list.bullet.clipboard")
                                .foregroundColor(.cyan)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    Button(action: {
                        exportRoutines()
                    }) {
                        HStack {
                            Label(L("settings.export.routines"), systemImage: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    }

                    Button(action: {
                        showImportSheet = true
                    }) {
                        HStack {
                            Label(L("settings.import.routines"), systemImage: "square.and.arrow.down")
                                .foregroundColor(.green)
                            Spacer()
                        }
                    }

                    Button(action: {
                        openWebSharing()
                    }) {
                        HStack {
                            Label(L("settings.web.sharing"), systemImage: "globe")
                                .foregroundColor(.purple)
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Label(L("settings.data.management"), systemImage: "folder.fill")
                } footer: {
                    Text(L("settings.data.management.footer"))
                }

                // Time Slot Info Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        TimeSlotSummaryRow(
                            icon: "sunrise.fill",
                            color: .orange,
                            timeType: .morning,
                            timeSlotManager: timeSlotManager
                        )

                        TimeSlotSummaryRow(
                            icon: "sun.max.fill",
                            color: .yellow,
                            timeType: .afternoon,
                            timeSlotManager: timeSlotManager
                        )

                        TimeSlotSummaryRow(
                            icon: "moon.stars.fill",
                            color: .indigo,
                            timeType: .evening,
                            timeSlotManager: timeSlotManager
                        )
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label(L("settings.time.slots"), systemImage: "clock.fill")
                } footer: {
                    Text(L("settings.time.slots.footer"))
                }

                // Language Section
                Section {
                    Button(action: {
                        showLanguageSelection = true
                    }) {
                        HStack {
                            Label(L("settings.language"), systemImage: "globe")
                                .foregroundColor(.purple)
                            Spacer()
                            Text("\(localizationManager.currentLanguage.flag) \(localizationManager.currentLanguage.displayName)")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Label(L("settings.language"), systemImage: "globe")
                }

                // App Info Section
                Section {
                    Button(action: {
                        showTimeGuide = true
                    }) {
                        HStack {
                            Label(L("settings.time.guide"), systemImage: "clock.fill")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    HStack {
                        Label(L("settings.version"), systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                } header: {
                    Label(L("settings.app.info"), systemImage: "app.fill")
                }
            }
            .navigationTitle(L("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L("done")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
            .sheet(isPresented: $showImportSheet) {
                DocumentPicker(completion: handleImport)
            }
            .sheet(isPresented: $showSavedRoutines) {
                SavedRoutinesView(viewModel: viewModel)
            }
            .sheet(isPresented: $showDefaultRoutinesManagement) {
                DefaultRoutinesManagementView()
            }
            .sheet(isPresented: $showTimeGuide) {
                TimeGuideView(isPresented: $showTimeGuide)
            }
            .sheet(isPresented: $showLanguageSelection) {
                LanguageSelectionView(isPresented: $showLanguageSelection)
            }
            .alert(L("alert.title"), isPresented: $showAlert) {
                Button(L("ok"), role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Export Function
    private func exportRoutines() {
        guard let jsonData = viewModel.exportAllRoutines() else {
            alertMessage = L("alert.export.error")
            showAlert = true
            return
        }

        let fileName = RoutineExportManager.shared.generateFileName()
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try jsonData.write(to: tempURL)
            exportedFileURL = tempURL
            showExportSheet = true
        } catch {
            alertMessage = "\(L("alert.file.save.error")): \(error.localizedDescription)"
            showAlert = true
        }
    }

    // MARK: - Import Function
    private func handleImport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let data = try Data(contentsOf: url)
                let success = viewModel.importRoutines(from: data, replaceExisting: true)
                if success {
                    alertMessage = L("alert.import.success")
                } else {
                    alertMessage = L("alert.import.error")
                }
            } catch {
                alertMessage = "\(L("alert.file.read.error")): \(error.localizedDescription)"
            }
            showAlert = true
        case .failure(let error):
            alertMessage = "\(L("alert.file.select.error")): \(error.localizedDescription)"
            showAlert = true
        }
    }

    // MARK: - Open Web Sharing
    private func openWebSharing() {
        if let url = URL(string: "https://yelerty.github.io/habitcircuitpage/") {
            UIApplication.shared.open(url)
        }
    }
}

struct NotificationTimeRow: View {
    let timeType: RoutineTimeType
    @Binding var time: Date
    @Binding var isEnabled: Bool
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isEnabled) {
                HStack(spacing: 8) {
                    Image(systemName: timeType.icon)
                        .foregroundColor(timeTypeColor)
                    Text(timeType.displayName)
                        .font(.body)
                }
            }
            .onChange(of: isEnabled) { oldValue, newValue in
                notificationManager.saveSettings()
                if newValue {
                    requestNotificationPermission()
                }
            }

            if isEnabled {
                DatePicker(L("settings.notifications"), selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .onChange(of: time) { oldValue, newValue in
                        notificationManager.saveSettings()
                    }
            }
        }
    }

    private var timeTypeColor: Color {
        switch timeType {
        case .morning: return .orange
        case .afternoon: return .yellow
        case .evening: return .indigo
        }
    }

    private func requestNotificationPermission() {
        notificationManager.requestPermission { granted in
            if !granted {
                // Permission denied - disable toggle
                isEnabled = false
            }
        }
    }
}

struct TimeSlotSummaryRow: View {
    let icon: String
    let color: Color
    let timeType: RoutineTimeType
    @ObservedObject var timeSlotManager: TimeSlotManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.body)
                .frame(width: 24)

            Text(timeType.displayName)
                .font(.body)
                .frame(minWidth: 80, alignment: .leading)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Text(timeSlotManager.getTimeRangeString(for: timeType))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
