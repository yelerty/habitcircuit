import Foundation

enum DayOfWeek: String, CaseIterable {
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    case sunday = "sunday"

    var displayName: String {
        return L("day.\(self.rawValue)")
    }

    var shortName: String {
        return L("day.\(self.rawValue).short")
    }

    static var today: DayOfWeek {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())

        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }

    // Get next day (circular)
    var next: DayOfWeek {
        let allDays = DayOfWeek.allCases
        guard let currentIndex = allDays.firstIndex(of: self) else { return .monday }
        let nextIndex = (currentIndex + 1) % allDays.count
        return allDays[nextIndex]
    }

    // Get previous day (circular)
    var previous: DayOfWeek {
        let allDays = DayOfWeek.allCases
        guard let currentIndex = allDays.firstIndex(of: self) else { return .monday }
        let previousIndex = (currentIndex - 1 + allDays.count) % allDays.count
        return allDays[previousIndex]
    }
}
