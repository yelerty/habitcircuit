import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var morningTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
    @Published var afternoonTime: Date = Calendar.current.date(from: DateComponents(hour: 12, minute: 0)) ?? Date()
    @Published var eveningTime: Date = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()

    @Published var morningEnabled: Bool = false
    @Published var afternoonEnabled: Bool = false
    @Published var eveningEnabled: Bool = false

    private let morningTimeKey = "morningNotificationTime"
    private let afternoonTimeKey = "afternoonNotificationTime"
    private let eveningTimeKey = "eveningNotificationTime"
    private let morningEnabledKey = "morningNotificationEnabled"
    private let afternoonEnabledKey = "afternoonNotificationEnabled"
    private let eveningEnabledKey = "eveningNotificationEnabled"

    private init() {
        loadSettings()
    }

    // MARK: - Load & Save Settings
    private func loadSettings() {
        if let morningData = UserDefaults.standard.object(forKey: morningTimeKey) as? Date {
            morningTime = morningData
        }
        if let afternoonData = UserDefaults.standard.object(forKey: afternoonTimeKey) as? Date {
            afternoonTime = afternoonData
        }
        if let eveningData = UserDefaults.standard.object(forKey: eveningTimeKey) as? Date {
            eveningTime = eveningData
        }

        morningEnabled = UserDefaults.standard.bool(forKey: morningEnabledKey)
        afternoonEnabled = UserDefaults.standard.bool(forKey: afternoonEnabledKey)
        eveningEnabled = UserDefaults.standard.bool(forKey: eveningEnabledKey)
    }

    func saveSettings() {
        UserDefaults.standard.set(morningTime, forKey: morningTimeKey)
        UserDefaults.standard.set(afternoonTime, forKey: afternoonTimeKey)
        UserDefaults.standard.set(eveningTime, forKey: eveningTimeKey)
        UserDefaults.standard.set(morningEnabled, forKey: morningEnabledKey)
        UserDefaults.standard.set(afternoonEnabled, forKey: afternoonEnabledKey)
        UserDefaults.standard.set(eveningEnabled, forKey: eveningEnabledKey)

        scheduleNotifications()
    }

    // MARK: - Request Permission
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleNotifications()
                }
                completion(granted)
            }
        }
    }

    // MARK: - Schedule Notifications
    func scheduleNotifications() {
        // Remove all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        if morningEnabled {
            scheduleNotification(for: .morning, time: morningTime)
        }
        if afternoonEnabled {
            scheduleNotification(for: .afternoon, time: afternoonTime)
        }
        if eveningEnabled {
            scheduleNotification(for: .evening, time: eveningTime)
        }
    }

    private func scheduleNotification(for timeType: RoutineTimeType, time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "\(timeType.rawValue) 루틴 시간이에요!"
        content.body = "오늘의 \(timeType.rawValue) 루틴을 시작해보세요 🔥"
        content.sound = .default
        content.badge = 1

        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = calendar.component(.hour, from: time)
        dateComponents.minute = calendar.component(.minute, from: time)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = "\(timeType.rawValue)Notification"

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    // MARK: - Cancel Notifications
    func cancelNotification(for timeType: RoutineTimeType) {
        let identifier = "\(timeType.rawValue)Notification"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
