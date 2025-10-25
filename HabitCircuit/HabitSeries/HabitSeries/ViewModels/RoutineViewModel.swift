import Foundation
import SwiftUI
import CoreData
import Combine

class RoutineViewModel: ObservableObject {
    @Published var routines: [RoutineItem] = []
    @Published var selectedDay: DayOfWeek = .today
    @Published var currentRoutineIndex: Int = 0

    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadRoutines()
    }

    // MARK: - Load Routines
    func loadRoutines() {
        let request = NSFetchRequest<Routine>(entityName: "Routine")
        request.predicate = NSPredicate(format: "dayOfWeek == %@", selectedDay.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Routine.order, ascending: true)]

        do {
            let results = try viewContext.fetch(request)
            routines = results.map { routine in
                RoutineItem(
                    id: routine.id ?? UUID(),
                    name: routine.name ?? "",
                    order: Int(routine.order),
                    dayOfWeek: routine.dayOfWeek ?? "",
                    isCompleted: routine.isCompleted
                )
            }
            updateCurrentRoutineIndex()
        } catch {
            print("Error fetching routines: \(error)")
        }
    }

    // MARK: - Add Routine
    func addRoutine(name: String) {
        let routine = Routine(context: viewContext)
        routine.id = UUID()
        routine.name = name
        routine.dayOfWeek = selectedDay.rawValue
        routine.order = Int16(routines.count)
        routine.isCompleted = false
        routine.createdAt = Date()

        saveContext()
        loadRoutines()
    }

    // MARK: - Delete Routine
    func deleteRoutine(at indexSet: IndexSet) {
        for index in indexSet {
            let routineToDelete = routines[index]
            let request = NSFetchRequest<Routine>(entityName: "Routine")
            request.predicate = NSPredicate(format: "id == %@", routineToDelete.id as CVarArg)

            do {
                let results = try viewContext.fetch(request)
                if let routine = results.first {
                    viewContext.delete(routine)
                }
            } catch {
                print("Error deleting routine: \(error)")
            }
        }

        saveContext()
        reorderRoutines()
        loadRoutines()
    }

    // MARK: - Move Routine
    func moveRoutine(from source: IndexSet, to destination: Int) {
        routines.move(fromOffsets: source, toOffset: destination)
        reorderRoutines()
    }

    // MARK: - Update Routine
    func updateRoutine(id: UUID, newName: String) {
        let request = NSFetchRequest<Routine>(entityName: "Routine")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try viewContext.fetch(request)
            if let routine = results.first {
                routine.name = newName
                saveContext()
                loadRoutines()
            }
        } catch {
            print("Error updating routine: \(error)")
        }
    }

    // MARK: - Complete Current Routine
    func completeCurrentRoutine() {
        guard currentRoutineIndex < routines.count else { return }

        let currentRoutine = routines[currentRoutineIndex]
        let request = NSFetchRequest<Routine>(entityName: "Routine")
        request.predicate = NSPredicate(format: "id == %@", currentRoutine.id as CVarArg)

        do {
            let results = try viewContext.fetch(request)
            if let routine = results.first {
                routine.isCompleted = true
                saveContext()
                loadRoutines()
                // loadRoutines()가 updateCurrentRoutineIndex()를 호출하므로 별도 증가 불필요
            }
        } catch {
            print("Error completing routine: \(error)")
        }
    }

    // MARK: - Reset Daily Routines
    func resetDailyRoutines() {
        let request = NSFetchRequest<Routine>(entityName: "Routine")
        request.predicate = NSPredicate(format: "dayOfWeek == %@", selectedDay.rawValue)

        do {
            let results = try viewContext.fetch(request)
            for routine in results {
                routine.isCompleted = false
            }
            saveContext()
            loadRoutines()
            currentRoutineIndex = 0
        } catch {
            print("Error resetting routines: \(error)")
        }
    }

    // MARK: - Helper Methods
    private func reorderRoutines() {
        for (index, routine) in routines.enumerated() {
            let request = NSFetchRequest<Routine>(entityName: "Routine")
            request.predicate = NSPredicate(format: "id == %@", routine.id as CVarArg)

            do {
                let results = try viewContext.fetch(request)
                if let routineEntity = results.first {
                    routineEntity.order = Int16(index)
                }
            } catch {
                print("Error reordering routine: \(error)")
            }
        }

        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    private func updateCurrentRoutineIndex() {
        if let firstIncompleteIndex = routines.firstIndex(where: { !$0.isCompleted }) {
            currentRoutineIndex = firstIncompleteIndex
        } else {
            currentRoutineIndex = routines.count
        }
    }

    // MARK: - Computed Properties
    var hasRoutines: Bool {
        !routines.isEmpty
    }

    var allRoutinesCompleted: Bool {
        !routines.isEmpty && routines.allSatisfy { $0.isCompleted }
    }

    var currentRoutine: RoutineItem? {
        guard currentRoutineIndex < routines.count else { return nil }
        return routines[currentRoutineIndex]
    }

    var progressPercentage: Double {
        guard !routines.isEmpty else { return 0 }
        let completed = routines.filter { $0.isCompleted }.count
        return Double(completed) / Double(routines.count)
    }

    var progressText: String {
        let completed = routines.filter { $0.isCompleted }.count
        return "\(completed)/\(routines.count)"
    }

    func changeDay(_ day: DayOfWeek) {
        selectedDay = day
        loadRoutines()
    }
}
