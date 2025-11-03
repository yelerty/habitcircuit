import Foundation

struct RoutineItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var order: Int
    var dayOfWeek: String
    var timeType: RoutineTimeType
    var isCompleted: Bool

    init(id: UUID = UUID(), name: String, order: Int, dayOfWeek: String, timeType: RoutineTimeType = .morning, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.order = order
        self.dayOfWeek = dayOfWeek
        self.timeType = timeType
        self.isCompleted = isCompleted
    }
}
