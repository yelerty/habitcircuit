import Foundation

enum RoutineTimeType: String, CaseIterable, Codable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"

    var displayName: String {
        return L("time.\(self.rawValue)")
    }

    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        }
    }

    var color: String {
        switch self {
        case .morning: return "orange"
        case .afternoon: return "yellow"
        case .evening: return "indigo"
        }
    }
}
