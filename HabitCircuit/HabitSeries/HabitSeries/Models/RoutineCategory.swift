import Foundation
import SwiftUI

enum RoutineCategory: String, CaseIterable, Codable {
    case health = "건강"
    case study = "학습"
    case work = "업무"
    case household = "청소/가사"
    case selfCare = "자기관리"
    case hobby = "취미"
    case social = "사회활동"
    case other = "기타"

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
        switch self {
        case .health: return "운동, 식사, 수면 등"
        case .study: return "독서, 강의, 학습 등"
        case .work: return "업무, 프로젝트, 회의 등"
        case .household: return "청소, 요리, 세탁 등"
        case .selfCare: return "명상, 일기, 관리 등"
        case .hobby: return "그림, 음악, 취미 등"
        case .social: return "모임, 친구, 가족 등"
        case .other: return "분류되지 않은 루틴"
        }
    }
}
