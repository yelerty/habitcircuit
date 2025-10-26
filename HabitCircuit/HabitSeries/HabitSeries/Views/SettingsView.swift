import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var streakManager = StreakManager.shared

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
