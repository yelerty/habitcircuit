import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var streakManager = StreakManager.shared
    @StateObject private var viewModel = RoutineViewModel(context: PersistenceController.shared.container.viewContext)

    @State private var showExportSheet = false
    @State private var showImportSheet = false
    @State private var exportedFileURL: URL?
    @State private var showAlert = false
    @State private var alertMessage = ""

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
                } header: {
                    Label("데이터 관리", systemImage: "folder.fill")
                } footer: {
                    Text("루틴을 JSON 파일로 내보내거나 파일에서 가져올 수 있습니다")
                }

                // App Info Section
                Section {
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
