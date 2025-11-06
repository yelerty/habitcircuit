import Foundation
import Combine

class TimeSlotManager: ObservableObject {
    static let shared = TimeSlotManager()

    private let notificationManager = NotificationManager.shared
    private var cancellables = Set<AnyCancellable>()

    @Published private var updateTrigger = UUID()

    private init() {
        // Subscribe to notification manager changes
        notificationManager.$morningTime
            .sink { [weak self] _ in
                self?.updateTrigger = UUID()
            }
            .store(in: &cancellables)

        notificationManager.$afternoonTime
            .sink { [weak self] _ in
                self?.updateTrigger = UUID()
            }
            .store(in: &cancellables)

        notificationManager.$eveningTime
            .sink { [weak self] _ in
                self?.updateTrigger = UUID()
            }
            .store(in: &cancellables)
    }

    // MARK: - Calculate time range based on notification time
    // Each time slot is notification time -1 hour to +3 hours
    private func getNotificationHour(for timeType: RoutineTimeType) -> Int {
        let calendar = Calendar.current
        let time: Date

        switch timeType {
        case .morning:
            time = notificationManager.morningTime
        case .afternoon:
            time = notificationManager.afternoonTime
        case .evening:
            time = notificationManager.eveningTime
        }

        return calendar.component(.hour, from: time)
    }

    // MARK: - Time Range Helpers
    func getTimeRange(for timeType: RoutineTimeType) -> (start: Int, end: Int) {
        let notificationHour = getNotificationHour(for: timeType)

        // -1 hour to +3 hours from notification time
        let startHour = max(0, notificationHour - 1)
        let endHour = min(24, notificationHour + 4) // +3 means up to but not including +4

        return (startHour, endHour)
    }

    func getTimeRangeString(for timeType: RoutineTimeType) -> String {
        let range = getTimeRange(for: timeType)
        let startString = formatHour(range.start)
        let endString = formatHour(range.end)
        return "\(startString) - \(endString)"
    }

    private func formatHour(_ hour: Int) -> String {
        if hour == 0 {
            return "오전 12시(자정)"
        } else if hour == 24 {
            return "오전 12시(자정)"
        } else if hour < 12 {
            return "오전 \(hour)시"
        } else if hour == 12 {
            return "오후 12시"
        } else {
            return "오후 \(hour - 12)시"
        }
    }

    // MARK: - Check if current time is within time slot
    func canExecute(timeType: RoutineTimeType) -> (Bool, String) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let range = getTimeRange(for: timeType)

        if hour >= range.start && hour < range.end {
            return (true, "")
        } else {
            let message = "\(timeType.rawValue) 루틴은 \(getTimeRangeString(for: timeType))에만 실행할 수 있습니다."
            return (false, message)
        }
    }

    func getCurrentTimeType() -> RoutineTimeType? {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())

        // Check each time type to see if current hour falls within its range
        for timeType in RoutineTimeType.allCases {
            let range = getTimeRange(for: timeType)
            if hour >= range.start && hour < range.end {
                return timeType
            }
        }

        return nil
    }
}
