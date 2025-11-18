import Foundation
import CoreData
import Combine

// MARK: - Repository Protocol

/// Protocol defining routine data access operations
protocol RoutineRepositoryProtocol {
    func fetchRoutines(for day: DayOfWeek, timeType: RoutineTimeType) async throws -> [RoutineItem]
    func fetchAllRoutines(for day: DayOfWeek) async throws -> [RoutineItem]
    func fetchRoutineCount(for day: DayOfWeek, timeType: RoutineTimeType) async throws -> Int
    func add(_ routine: RoutineItem) async throws
    func update(_ routine: RoutineItem) async throws
    func delete(_ id: UUID) async throws
    func deleteAll(for day: DayOfWeek, timeType: RoutineTimeType) async throws
    func updateOrder(routines: [RoutineItem]) async throws
    func updateCompletion(id: UUID, isCompleted: Bool) async throws
    func resetCompletions(for day: DayOfWeek) async throws
}

// MARK: - Core Data Repository Implementation

/// Concrete implementation of RoutineRepository using Core Data
final class CoreDataRoutineRepository: RoutineRepositoryProtocol {

    // MARK: - Properties

    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext

    // MARK: - Initialization

    init(context: NSManagedObjectContext) {
        self.context = context
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.parent = context
    }

    // MARK: - Fetch Operations

    func fetchRoutines(for day: DayOfWeek, timeType: RoutineTimeType) async throws -> [RoutineItem] {
        try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                let request = NSFetchRequest<Routine>(entityName: "Routine")
                request.predicate = NSPredicate(
                    format: "dayOfWeek == %@ AND timeType == %@",
                    day.rawValue,
                    timeType.rawValue
                )
                request.sortDescriptors = [NSSortDescriptor(keyPath: \Routine.order, ascending: true)]

                do {
                    let results = try self.backgroundContext.fetch(request)
                    let routines = results.map { self.mapToRoutineItem($0) }
                    continuation.resume(returning: routines)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchAllRoutines(for day: DayOfWeek) async throws -> [RoutineItem] {
        try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                let request = NSFetchRequest<Routine>(entityName: "Routine")
                request.predicate = NSPredicate(format: "dayOfWeek == %@", day.rawValue)
                request.sortDescriptors = [
                    NSSortDescriptor(keyPath: \Routine.timeType, ascending: true),
                    NSSortDescriptor(keyPath: \Routine.order, ascending: true)
                ]

                do {
                    let results = try self.backgroundContext.fetch(request)
                    let routines = results.map { self.mapToRoutineItem($0) }
                    continuation.resume(returning: routines)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchRoutineCount(for day: DayOfWeek, timeType: RoutineTimeType) async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                let request = NSFetchRequest<Routine>(entityName: "Routine")
                request.predicate = NSPredicate(
                    format: "dayOfWeek == %@ AND timeType == %@",
                    day.rawValue,
                    timeType.rawValue
                )

                do {
                    let count = try self.backgroundContext.count(for: request)
                    continuation.resume(returning: count)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Create/Update Operations

    func add(_ routine: RoutineItem) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            backgroundContext.perform {
                let entity = Routine(context: self.backgroundContext)
                self.mapToEntity(from: routine, to: entity)
                entity.createdAt = Date()

                do {
                    try self.backgroundContext.save()
                    try self.context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func update(_ routine: RoutineItem) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            backgroundContext.perform {
                let request = NSFetchRequest<Routine>(entityName: "Routine")
                request.predicate = NSPredicate(format: "id == %@", routine.id as CVarArg)

                do {
                    guard let entity = try self.backgroundContext.fetch(request).first else {
                        throw RepositoryError.notFound
                    }

                    self.mapToEntity(from: routine, to: entity)
                    try self.backgroundContext.save()
                    try self.context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func updateCompletion(id: UUID, isCompleted: Bool) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            backgroundContext.perform {
                let request = NSFetchRequest<Routine>(entityName: "Routine")
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                do {
                    guard let entity = try self.backgroundContext.fetch(request).first else {
                        throw RepositoryError.notFound
                    }

                    entity.isCompleted = isCompleted
                    try self.backgroundContext.save()
                    try self.context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func updateOrder(routines: [RoutineItem]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            backgroundContext.perform {
                do {
                    for routine in routines {
                        let request = NSFetchRequest<Routine>(entityName: "Routine")
                        request.predicate = NSPredicate(format: "id == %@", routine.id as CVarArg)

                        if let entity = try self.backgroundContext.fetch(request).first {
                            entity.order = Int16(routine.order)
                        }
                    }

                    try self.backgroundContext.save()
                    try self.context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Delete Operations

    func delete(_ id: UUID) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            backgroundContext.perform {
                let request = NSFetchRequest<Routine>(entityName: "Routine")
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

                do {
                    guard let entity = try self.backgroundContext.fetch(request).first else {
                        throw RepositoryError.notFound
                    }

                    self.backgroundContext.delete(entity)
                    try self.backgroundContext.save()
                    try self.context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func deleteAll(for day: DayOfWeek, timeType: RoutineTimeType) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            backgroundContext.perform {
                let request = NSFetchRequest<Routine>(entityName: "Routine")
                request.predicate = NSPredicate(
                    format: "dayOfWeek == %@ AND timeType == %@",
                    day.rawValue,
                    timeType.rawValue
                )

                do {
                    let results = try self.backgroundContext.fetch(request)
                    results.forEach { self.backgroundContext.delete($0) }

                    try self.backgroundContext.save()
                    try self.context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func resetCompletions(for day: DayOfWeek) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            backgroundContext.perform {
                let request = NSFetchRequest<Routine>(entityName: "Routine")
                request.predicate = NSPredicate(format: "dayOfWeek == %@", day.rawValue)

                do {
                    let results = try self.backgroundContext.fetch(request)
                    results.forEach { $0.isCompleted = false }

                    try self.backgroundContext.save()
                    try self.context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Mapping Helpers

    private func mapToRoutineItem(_ entity: Routine) -> RoutineItem {
        RoutineItem(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            order: Int(entity.order),
            dayOfWeek: entity.dayOfWeek ?? "",
            timeType: RoutineTimeType(rawValue: entity.timeType ?? "아침") ?? .morning,
            isCompleted: entity.isCompleted,
            category: RoutineCategory(rawValue: entity.category ?? "기타") ?? .other
        )
    }

    private func mapToEntity(from item: RoutineItem, to entity: Routine) {
        entity.id = item.id
        entity.name = item.name
        entity.order = Int16(item.order)
        entity.dayOfWeek = item.dayOfWeek
        entity.timeType = item.timeType.rawValue
        entity.isCompleted = item.isCompleted
        entity.category = item.category.rawValue
    }
}

// MARK: - Repository Errors

enum RepositoryError: LocalizedError {
    case notFound
    case saveFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Routine not found"
        case .saveFailed:
            return "Failed to save routine"
        case .deleteFailed:
            return "Failed to delete routine"
        }
    }
}
