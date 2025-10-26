import Foundation
import SwiftUI
import CoreData
import Combine

class RoutineViewModel: ObservableObject {
    @Published var routines: [RoutineItem] = []
    @Published var allRoutines: [RoutineItem] = []
    @Published var selectedDay: DayOfWeek = .today
    @Published var selectedTimeType: RoutineTimeType = .morning
    @Published var currentRoutineIndex: Int = 0

    private let viewContext: NSManagedObjectContext
    private let lastResetDateKey = "lastResetDate"

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        resetPastDaysIfNeeded()
        loadRoutines()
        loadAllRoutines()
    }

    // MARK: - Load Routines
    func loadRoutines() {
        let request = NSFetchRequest<Routine>(entityName: "Routine")
        request.predicate = NSPredicate(format: "dayOfWeek == %@ AND timeType == %@", selectedDay.rawValue, selectedTimeType.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Routine.order, ascending: true)]

        do {
            let results = try viewContext.fetch(request)
            routines = results.map { routine in
                let timeType = RoutineTimeType(rawValue: routine.timeType ?? "아침") ?? .morning
                return RoutineItem(
                    id: routine.id ?? UUID(),
                    name: routine.name ?? "",
                    order: Int(routine.order),
                    dayOfWeek: routine.dayOfWeek ?? "",
                    timeType: timeType,
                    isCompleted: routine.isCompleted
                )
            }
            updateCurrentRoutineIndex()
        } catch {
            print("Error fetching routines: \(error)")
        }
    }

    // MARK: - Load All Routines (for current day, all time types)
    func loadAllRoutines() {
        let request = NSFetchRequest<Routine>(entityName: "Routine")
        request.predicate = NSPredicate(format: "dayOfWeek == %@", selectedDay.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Routine.timeType, ascending: true),
            NSSortDescriptor(keyPath: \Routine.order, ascending: true)
        ]

        do {
            let results = try viewContext.fetch(request)
            allRoutines = results.map { routine in
                let timeType = RoutineTimeType(rawValue: routine.timeType ?? "아침") ?? .morning
                return RoutineItem(
                    id: routine.id ?? UUID(),
                    name: routine.name ?? "",
                    order: Int(routine.order),
                    dayOfWeek: routine.dayOfWeek ?? "",
                    timeType: timeType,
                    isCompleted: routine.isCompleted
                )
            }
        } catch {
            print("Error fetching all routines: \(error)")
        }
    }

    // MARK: - Get routines count by time type
    func getRoutineCount(for timeType: RoutineTimeType) -> Int {
        let request = NSFetchRequest<Routine>(entityName: "Routine")
        request.predicate = NSPredicate(format: "dayOfWeek == %@ AND timeType == %@", selectedDay.rawValue, timeType.rawValue)

        do {
            let count = try viewContext.count(for: request)
            return count
        } catch {
            print("Error counting routines: \(error)")
            return 0
        }
    }

    // MARK: - Add Routine
    func addRoutine(name: String, timeType: RoutineTimeType? = nil) {
        let routine = Routine(context: viewContext)
        routine.id = UUID()
        routine.name = name
        routine.dayOfWeek = selectedDay.rawValue
        routine.timeType = (timeType ?? selectedTimeType).rawValue
        routine.order = Int16(routines.count)
        routine.isCompleted = false
        routine.createdAt = Date()

        saveContext()
        loadRoutines()
        loadAllRoutines()
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
        loadAllRoutines()
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
                loadAllRoutines()
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
            loadAllRoutines()
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
        loadAllRoutines()
    }

    func changeTimeType(_ timeType: RoutineTimeType) {
        selectedTimeType = timeType
        loadRoutines()
    }

    // MARK: - Auto Reset Past Days
    private func resetPastDaysIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get last reset date from UserDefaults
        if let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
            let lastReset = calendar.startOfDay(for: lastResetDate)

            // If last reset was not today, reset all past days
            if lastReset < today {
                resetAllPastDays()
                UserDefaults.standard.set(today, forKey: lastResetDateKey)
            }
        } else {
            // First launch - set today as reset date
            UserDefaults.standard.set(today, forKey: lastResetDateKey)
        }
    }

    private func resetAllPastDays() {
        let allDays: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

        for day in allDays {
            // Skip today - don't reset today's routines
            if day == .today {
                continue
            }

            // Reset all routines for this day
            let request = NSFetchRequest<Routine>(entityName: "Routine")
            request.predicate = NSPredicate(format: "dayOfWeek == %@", day.rawValue)

            do {
                let results = try viewContext.fetch(request)
                for routine in results {
                    routine.isCompleted = false
                }
            } catch {
                print("Error resetting routines for \(day.rawValue): \(error)")
            }
        }

        saveContext()
    }

    // MARK: - Export/Import Functions
    func exportAllRoutines() -> Data? {
        let request = NSFetchRequest<Routine>(entityName: "Routine")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Routine.dayOfWeek, ascending: true),
            NSSortDescriptor(keyPath: \Routine.timeType, ascending: true),
            NSSortDescriptor(keyPath: \Routine.order, ascending: true)
        ]

        do {
            let results = try viewContext.fetch(request)
            let routineItems = results.map { routine in
                let timeType = RoutineTimeType(rawValue: routine.timeType ?? "아침") ?? .morning
                return RoutineItem(
                    id: routine.id ?? UUID(),
                    name: routine.name ?? "",
                    order: Int(routine.order),
                    dayOfWeek: routine.dayOfWeek ?? "",
                    timeType: timeType,
                    isCompleted: false // Don't export completion status
                )
            }

            return RoutineExportManager.shared.exportRoutines(routines: routineItems)
        } catch {
            print("Error fetching routines for export: \(error)")
            return nil
        }
    }

    func importRoutines(from data: Data, replaceExisting: Bool = false) -> Bool {
        guard let exportedRoutines = RoutineExportManager.shared.importRoutines(from: data) else {
            return false
        }

        // If replace existing, delete all routines first
        if replaceExisting {
            deleteAllRoutines()
        }

        // Import new routines
        for exportedRoutine in exportedRoutines {
            let routine = Routine(context: viewContext)
            routine.id = UUID()
            routine.name = exportedRoutine.name
            routine.dayOfWeek = exportedRoutine.dayOfWeek
            routine.timeType = exportedRoutine.timeType
            routine.order = Int16(exportedRoutine.order)
            routine.isCompleted = false
            routine.createdAt = Date()
        }

        saveContext()
        loadRoutines()
        loadAllRoutines()
        return true
    }

    private func deleteAllRoutines() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Routine")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try viewContext.execute(deleteRequest)
            saveContext()
        } catch {
            print("Error deleting all routines: \(error)")
        }
    }
}
