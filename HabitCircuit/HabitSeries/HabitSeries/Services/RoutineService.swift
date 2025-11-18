import Foundation
import Combine

// MARK: - Service Protocol

/// Protocol defining business logic for routine operations
protocol RoutineServiceProtocol {
    func getRoutines(for day: DayOfWeek, timeType: RoutineTimeType) async throws -> [RoutineItem]
    func getAllRoutines(for day: DayOfWeek) async throws -> [RoutineItem]
    func getRoutineCount(for day: DayOfWeek, timeType: RoutineTimeType) async throws -> Int
    func addRoutine(name: String, day: DayOfWeek, timeType: RoutineTimeType, category: RoutineCategory, order: Int) async throws
    func updateRoutine(id: UUID, name: String, category: RoutineCategory) async throws
    func deleteRoutine(id: UUID) async throws
    func completeRoutine(id: UUID) async throws
    func reorderRoutines(_ routines: [RoutineItem]) async throws
    func resetCompletions(for day: DayOfWeek) async throws
    func getNextIncompleteTimeType(for day: DayOfWeek, after currentType: RoutineTimeType) async throws -> RoutineTimeType?
    func getFirstIncompleteTimeType(for day: DayOfWeek) async throws -> RoutineTimeType?
    func areAllRoutinesCompleted(for day: DayOfWeek, timeType: RoutineTimeType) async throws -> Bool
    func areAllDayRoutinesCompleted(for day: DayOfWeek) async throws -> Bool
}

// MARK: - Service Implementation

/// Concrete implementation of RoutineService
final class RoutineService: RoutineServiceProtocol {

    // MARK: - Properties

    private let repository: RoutineRepositoryProtocol

    // MARK: - Initialization

    init(repository: RoutineRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Query Operations

    func getRoutines(for day: DayOfWeek, timeType: RoutineTimeType) async throws -> [RoutineItem] {
        try await repository.fetchRoutines(for: day, timeType: timeType)
    }

    func getAllRoutines(for day: DayOfWeek) async throws -> [RoutineItem] {
        try await repository.fetchAllRoutines(for: day)
    }

    func getRoutineCount(for day: DayOfWeek, timeType: RoutineTimeType) async throws -> Int {
        try await repository.fetchRoutineCount(for: day, timeType: timeType)
    }

    // MARK: - Mutation Operations

    func addRoutine(name: String, day: DayOfWeek, timeType: RoutineTimeType, category: RoutineCategory, order: Int) async throws {
        let routine = RoutineItem(
            id: UUID(),
            name: name,
            order: order,
            dayOfWeek: day.rawValue,
            timeType: timeType,
            isCompleted: false,
            category: category
        )

        try await repository.add(routine)
    }

    func updateRoutine(id: UUID, name: String, category: RoutineCategory) async throws {
        // First fetch the existing routine to preserve other properties
        let allRoutines = try await repository.fetchAllRoutines(for: .today)

        guard var routine = allRoutines.first(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }

        routine.name = name
        routine.category = category

        try await repository.update(routine)
    }

    func deleteRoutine(id: UUID) async throws {
        try await repository.delete(id)
    }

    func completeRoutine(id: UUID) async throws {
        try await repository.updateCompletion(id: id, isCompleted: true)
    }

    func reorderRoutines(_ routines: [RoutineItem]) async throws {
        var updatedRoutines: [RoutineItem] = []

        for (index, var routine) in routines.enumerated() {
            routine.order = index
            updatedRoutines.append(routine)
        }

        try await repository.updateOrder(routines: updatedRoutines)
    }

    func resetCompletions(for day: DayOfWeek) async throws {
        try await repository.resetCompletions(for: day)
    }

    // MARK: - Business Logic

    func getNextIncompleteTimeType(for day: DayOfWeek, after currentType: RoutineTimeType) async throws -> RoutineTimeType? {
        guard let currentIndex = RoutineTimeType.allCases.firstIndex(of: currentType) else {
            return nil
        }

        // OPTIMIZED: Fetch all routines once instead of N queries
        let allRoutines = try await repository.fetchAllRoutines(for: day)

        // Filter in memory
        for i in (currentIndex + 1)..<RoutineTimeType.allCases.count {
            let timeType = RoutineTimeType.allCases[i]
            let routinesForType = allRoutines.filter { $0.timeType == timeType }

            // Check if this time type has incomplete routines
            if !routinesForType.isEmpty && routinesForType.contains(where: { !$0.isCompleted }) {
                return timeType
            }
        }

        return nil
    }

    func getFirstIncompleteTimeType(for day: DayOfWeek) async throws -> RoutineTimeType? {
        // OPTIMIZED: Fetch all routines once instead of N queries
        let allRoutines = try await repository.fetchAllRoutines(for: day)

        for timeType in RoutineTimeType.allCases {
            let routinesForType = allRoutines.filter { $0.timeType == timeType }

            if !routinesForType.isEmpty && routinesForType.contains(where: { !$0.isCompleted }) {
                return timeType
            }
        }

        return nil
    }

    func areAllRoutinesCompleted(for day: DayOfWeek, timeType: RoutineTimeType) async throws -> Bool {
        let routines = try await repository.fetchRoutines(for: day, timeType: timeType)
        return !routines.isEmpty && routines.allSatisfy { $0.isCompleted }
    }

    func areAllDayRoutinesCompleted(for day: DayOfWeek) async throws -> Bool {
        let allRoutines = try await repository.fetchAllRoutines(for: day)
        return !allRoutines.isEmpty && allRoutines.allSatisfy { $0.isCompleted }
    }

    // MARK: - Helper Methods

    private func getAvailableTimeTypes(for day: DayOfWeek) async throws -> [RoutineTimeType] {
        // OPTIMIZED: Fetch all routines once and filter in memory
        let allRoutines = try await repository.fetchAllRoutines(for: day)

        var available: [RoutineTimeType] = []
        for timeType in RoutineTimeType.allCases {
            let count = allRoutines.filter { $0.timeType == timeType }.count
            if count > 0 {
                available.append(timeType)
            }
        }

        return available
    }
}

// MARK: - Service Error

enum ServiceError: LocalizedError {
    case invalidInput
    case operationFailed

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid input provided"
        case .operationFailed:
            return "Operation failed"
        }
    }
}
