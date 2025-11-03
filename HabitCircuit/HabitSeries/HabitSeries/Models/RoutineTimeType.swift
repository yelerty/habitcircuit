import Foundation

enum RoutineTimeType: String, CaseIterable, Codable {
    case morning = "아침"
    case afternoon = "점심"
    case evening = "저녁"

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
