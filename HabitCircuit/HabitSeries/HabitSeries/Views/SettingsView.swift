import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var streakManager = StreakManager.shared
    @StateObject private var viewModel = RoutineViewModel(context: PersistenceController.shared.container.viewContext)
    @StateObject private var timeSlotManager = TimeSlotManager.shared

    @State private var showExportSheet = false
    @State private var showImportSheet = false
    @State private var exportedFileURL: URL?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSavedRoutines = false
    @State private var showTimeGuide = false
    @State private var showDefaultRoutinesManagement = false

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
                    Label("알림 설정", systemImage: "bell.fill")
                } footer: {
                    Text("설정한 시간에 루틴 알림을 받을 수 있습니다")
                }

                // Streak Statistics Section
                Section {
                    HStack {
                        Label("현재 연속", systemImage: "flame.fill")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("\(streakManager.currentStreak)일")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }

                    HStack {
                        Label("최장 기록", systemImage: "trophy.fill")
                            .foregroundColor(.yellow)
                        Spacer()
                        Text("\(streakManager.longestStreak)일")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }

                    HStack {
                        Label("총 완료 일수", systemImage: "calendar.badge.checkmark")
                            .foregroundColor(.green)
                        Spacer()
                        Text("\(streakManager.completionDates.count)일")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                } header: {
                    Label("통계", systemImage: "chart.bar.fill")
                }

                // Data Management Section
                Section {
                    Button(action: {
                        showSavedRoutines = true
                    }) {
                        HStack {
                            Label("저장된 루틴 관리", systemImage: "folder.badge.gearshape")
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
                            Label("예시 루틴 관리", systemImage: "list.bullet.clipboard")
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
                            Label("루틴 내보내기", systemImage: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    }

                    Button(action: {
                        showImportSheet = true
                    }) {
                        HStack {
                            Label("루틴 가져오기", systemImage: "square.and.arrow.down")
                                .foregroundColor(.green)
                            Spacer()
                        }
                    }

                    Button(action: {
                        openWebSharing()
                    }) {
                        HStack {
                            Label("웹에서 공유하기", systemImage: "globe")
                                .foregroundColor(.purple)
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Label("데이터 관리", systemImage: "folder.fill")
                } footer: {
                    Text("루틴을 앱 내에 최대 5개까지 저장하거나, JSON 파일로 내보내고 가져올 수 있습니다.\n예시 루틴을 추가하여 빠르게 루틴을 만들 수 있습니다.\n웹에서 공유하면 다른 사람들과 루틴을 나눌 수 있습니다.")
                }

                // Time Slot Info Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        TimeSlotSummaryRow(
                            icon: "sunrise.fill",
                            color: .orange,
                            title: "아침",
                            timeType: .morning,
                            timeSlotManager: timeSlotManager
                        )

                        TimeSlotSummaryRow(
                            icon: "sun.max.fill",
                            color: .yellow,
                            title: "점심",
                            timeType: .afternoon,
                            timeSlotManager: timeSlotManager
                        )

                        TimeSlotSummaryRow(
                            icon: "moon.stars.fill",
                            color: .indigo,
                            title: "저녁",
                            timeType: .evening,
                            timeSlotManager: timeSlotManager
                        )
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("루틴 시간대", systemImage: "clock.fill")
                } footer: {
                    Text("각 루틴은 알림 시간의 1시간 전부터 3시간 후까지 실행할 수 있습니다.\n알림 시간을 변경하면 실행 가능한 시간대가 자동으로 조정됩니다.")
                }

                // App Info Section
                Section {
                    Button(action: {
                        showTimeGuide = true
                    }) {
                        HStack {
                            Label("루틴 실행 시간 안내", systemImage: "clock.fill")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    HStack {
                        Label("버전", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                } header: {
                    Label("앱 정보", systemImage: "app.fill")
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
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
            .alert("알림", isPresented: $showAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Export Function
    private func exportRoutines() {
        guard let jsonData = viewModel.exportAllRoutines() else {
            alertMessage = "루틴을 내보내는 중 오류가 발생했습니다."
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
            alertMessage = "파일 저장 중 오류가 발생했습니다: \(error.localizedDescription)"
            showAlert = true
        }
    }

    // MARK: - Import Function
    private func handleImport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let data = try Data(contentsOf: url)
                let success = viewModel.importRoutines(from: data, replaceExisting: false)
                if success {
                    alertMessage = "루틴을 성공적으로 가져왔습니다!"
                } else {
                    alertMessage = "루틴 가져오기에 실패했습니다. 파일 형식을 확인해주세요."
                }
            } catch {
                alertMessage = "파일 읽기 중 오류가 발생했습니다: \(error.localizedDescription)"
            }
            showAlert = true
        case .failure(let error):
            alertMessage = "파일 선택 중 오류가 발생했습니다: \(error.localizedDescription)"
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
                    Text(timeType.rawValue)
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
                DatePicker("시간", selection: $time, displayedComponents: .hourAndMinute)
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
    let title: String
    let timeType: RoutineTimeType
    @ObservedObject var timeSlotManager: TimeSlotManager

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.body)
                .frame(width: 24)

            Text(title)
                .font(.body)
                .frame(width: 40, alignment: .leading)

            Text(timeSlotManager.getTimeRangeString(for: timeType))
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
