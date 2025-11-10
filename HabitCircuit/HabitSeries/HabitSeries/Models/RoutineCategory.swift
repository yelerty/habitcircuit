import Foundation
import SwiftUI

enum RoutineCategory: String, CaseIterable, Codable {
    case health = "health"
    case study = "study"
    case work = "work"
    case household = "household"
    case selfCare = "selfcare"
    case hobby = "hobby"
    case social = "social"
    case other = "other"

    var displayName: String {
        return L("category.\(self.rawValue)")
    }

    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .study: return "book.fill"
        case .work: return "briefcase.fill"
        case .household: return "house.fill"
        case .selfCare: return "sparkles"
        case .hobby: return "paintbrush.fill"
        case .social: return "person.2.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .health: return .red
        case .study: return .blue
        case .work: return .purple
        case .household: return .orange
        case .selfCare: return .pink
        case .hobby: return .green
        case .social: return .cyan
        case .other: return .gray
        }
    }

    var description: String {
        return L("category.\(self.rawValue).desc")
    }
}
