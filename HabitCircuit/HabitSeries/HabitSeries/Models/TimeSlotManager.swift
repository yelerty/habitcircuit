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
        var endHour = notificationHour + 4 // +3 means up to but not including +4

        // For evening routines, allow extending past midnight
        // Cap at 27 (which represents 3 AM next day) for proper wrap-around
        if timeType == .evening && endHour > 24 {
            endHour = min(27, endHour)
        } else {
            endHour = min(24, endHour)
        }

        return (startHour, endHour)
    }

    func getTimeRangeString(for timeType: RoutineTimeType) -> String {
        let range = getTimeRange(for: timeType)
        let startString = formatHour(range.start)

        // Handle end times that extend past midnight
        let endString: String
        if range.end > 24 {
            // Convert 25 -> 1 AM, 26 -> 2 AM, 27 -> 3 AM (next day)
            let nextDayHour = range.end - 24
            endString = formatHour(nextDayHour) + " " + L("time.next.day")
        } else {
            endString = formatHour(range.end)
        }

        return "\(startString) - \(endString)"
    }

    private func formatHour(_ hour: Int) -> String {
        if hour == 0 {
            return L("time.midnight")
        } else if hour == 24 {
            return L("time.midnight")
        } else if hour < 12 {
            return String(format: L("time.hour.format"), L("time.am"), hour)
        } else if hour == 12 {
            return L("time.noon")
        } else {
            return String(format: L("time.hour.format"), L("time.pm"), hour - 12)
        }
    }

    // MARK: - Check if current time is within time slot
    func canExecute(timeType: RoutineTimeType) -> (Bool, String) {
        let calendar = Calendar.current
        let originalHour = calendar.component(.hour, from: Date())
        var hour = originalHour
        let range = getTimeRange(for: timeType)

        // Handle time ranges that extend past midnight
        // If current time is early morning (0-2 AM) and range extends past 24,
        // add 24 to current hour for comparison
        if range.end > 24 && hour < 3 {
            hour += 24
        }

        let canRun = hour >= range.start && hour < range.end
        print("⏰ canExecute(\(timeType.rawValue)) - Current: \(originalHour):00, Range: \(range.start)-\(range.end), Adjusted: \(hour), Result: \(canRun)")

        if canRun {
            return (true, "")
        } else {
            let message = String(format: L("time.range.restriction"), timeType.displayName, getTimeRangeString(for: timeType))
            return (false, message)
        }
    }

    func getCurrentTimeType() -> RoutineTimeType? {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())

        // Check each time type to see if current hour falls within its range
        for timeType in RoutineTimeType.allCases {
            let range = getTimeRange(for: timeType)

            // Handle time ranges that extend past midnight
            var adjustedHour = hour
            if range.end > 24 && hour < 3 {
                adjustedHour = hour + 24
            }

            if adjustedHour >= range.start && adjustedHour < range.end {
                return timeType
            }
        }

        return nil
    }
}
