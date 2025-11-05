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
            print("📥 loadRoutines - Fetched \(results.count) routines from DB for \(selectedDay.rawValue) \(selectedTimeType.rawValue)")

            let newRoutines = results.map { routine in
                let timeType = RoutineTimeType(rawValue: routine.timeType ?? "아침") ?? .morning
                let category = RoutineCategory(rawValue: routine.category ?? "기타") ?? .other
                return RoutineItem(
                    id: routine.id ?? UUID(),
                    name: routine.name ?? "",
                    order: Int(routine.order),
                    dayOfWeek: routine.dayOfWeek ?? "",
                    timeType: timeType,
                    isCompleted: routine.isCompleted,
                    category: category
                )
            }

            DispatchQueue.main.async {
                self.routines = newRoutines
                self.updateCurrentRoutineIndex()
                print("✅ loadRoutines - Updated routines to \(self.routines.count) items on main thread")
            }
        } catch {
            print("❌ Error fetching routines: \(error)")
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
            print("📥 loadAllRoutines - Fetched \(results.count) routines from DB for \(selectedDay.rawValue)")

            let newAllRoutines = results.map { routine in
                let timeType = RoutineTimeType(rawValue: routine.timeType ?? "아침") ?? .morning
                let category = RoutineCategory(rawValue: routine.category ?? "기타") ?? .other
                return RoutineItem(
                    id: routine.id ?? UUID(),
                    name: routine.name ?? "",
                    order: Int(routine.order),
                    dayOfWeek: routine.dayOfWeek ?? "",
                    timeType: timeType,
                    isCompleted: routine.isCompleted,
                    category: category
                )
            }

            DispatchQueue.main.async {
                self.allRoutines = newAllRoutines
                print("✅ loadAllRoutines - Updated allRoutines to \(self.allRoutines.count) items on main thread")
            }
        } catch {
            print("❌ Error fetching all routines: \(error)")
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
    func addRoutine(name: String, timeType: RoutineTimeType? = nil, category: RoutineCategory = .other) {
        let routine = Routine(context: viewContext)
        routine.id = UUID()
        routine.name = name
        routine.dayOfWeek = selectedDay.rawValue
        routine.timeType = (timeType ?? selectedTimeType).rawValue
        routine.category = category.rawValue
        routine.order = Int16(routines.count)
        routine.isCompleted = false
        routine.createdAt = Date()

        saveContext()
        loadRoutines()
        loadAllRoutines()
    }

    // MARK: - Delete Routine
    func deleteRoutine(at indexSet: IndexSet) {
        print("🗑️ Delete started - Current routines count: \(routines.count)")

        for index in indexSet {
            let routineToDelete = routines[index]
            print("🗑️ Deleting routine: \(routineToDelete.name) (ID: \(routineToDelete.id))")

            let request = NSFetchRequest<Routine>(entityName: "Routine")
            request.predicate = NSPredicate(format: "id == %@", routineToDelete.id as CVarArg)

            do {
                let results = try viewContext.fetch(request)
                if let routine = results.first {
                    viewContext.delete(routine)
                    print("✅ Deleted from context")
                }
            } catch {
                print("❌ Error deleting routine: \(error)")
            }
        }

        // Save the deletion
        saveContext()
        print("💾 Context saved after deletion")

        // Load routines to get fresh data
        loadRoutines()
        print("📊 After delete load - routines count: \(routines.count)")

        loadAllRoutines()
        print("📊 After delete load - allRoutines count: \(allRoutines.count)")

        // Reorder if there are remaining routines
        if !routines.isEmpty {
            print("🔢 Reordering \(routines.count) routines")
            reorderRoutines()

            // Reload after reordering to ensure UI is in sync
            loadRoutines()
            print("📊 After reorder - routines count: \(routines.count)")

            loadAllRoutines()
            print("📊 After reorder - allRoutines count: \(allRoutines.count)")
        } else {
            // If current time type has no routines, switch to a time type that has routines
            print("⚠️ Current time type is empty, checking other time types...")
            switchToNonEmptyTimeType()
        }

        print("✅ Delete completed - Final routines count: \(routines.count)")
    }

    // MARK: - Switch to Non-Empty Time Type
    private func switchToNonEmptyTimeType() {
        // Find a time type with routines
        for timeType in RoutineTimeType.allCases {
            let count = getRoutineCount(for: timeType)
            if count > 0 {
                print("🔄 Switching to \(timeType.rawValue) which has \(count) routines")
                selectedTimeType = timeType
                loadRoutines()
                return
            }
        }
        print("ℹ️ No routines in any time type")
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
                loadAllRoutines()
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
        !allRoutines.isEmpty
    }

    var allRoutinesCompleted: Bool {
        !routines.isEmpty && routines.allSatisfy { $0.isCompleted }
    }

    // Check if all routines for the entire day are completed
    var allDayRoutinesCompleted: Bool {
        // Check if ALL routines for the selected day are completed
        // This includes morning, afternoon, and evening routines
        guard !allRoutines.isEmpty else { return false }

        // Must verify all routines across all time types are completed
        let request = NSFetchRequest<Routine>(entityName: "Routine")
        request.predicate = NSPredicate(format: "dayOfWeek == %@", selectedDay.rawValue)

        do {
            let allDayRoutines = try viewContext.fetch(request)

            // If there are no routines at all, return false
            guard !allDayRoutines.isEmpty else { return false }

            // All routines must be completed
            return allDayRoutines.allSatisfy { $0.isCompleted }
        } catch {
            print("Error checking all day routines completion: \(error)")
            return false
        }
    }

    // Get next time type with incomplete routines
    func getNextIncompleteTimeType() -> RoutineTimeType? {
        let currentIndex = RoutineTimeType.allCases.firstIndex(of: selectedTimeType) ?? 0

        // Check time types after current one
        for i in (currentIndex + 1)..<RoutineTimeType.allCases.count {
            let timeType = RoutineTimeType.allCases[i]
            let count = getRoutineCount(for: timeType)
            if count > 0 {
                // Check if this time type has incomplete routines
                let request = NSFetchRequest<Routine>(entityName: "Routine")
                request.predicate = NSPredicate(format: "dayOfWeek == %@ AND timeType == %@ AND isCompleted == NO", selectedDay.rawValue, timeType.rawValue)

                do {
                    let incompleteCount = try viewContext.count(for: request)
                    if incompleteCount > 0 {
                        return timeType
                    }
                } catch {
                    print("Error checking incomplete routines: \(error)")
                }
            }
        }

        return nil
    }

    // MARK: - Time Restrictions
    func canExecuteRoutine(for timeType: RoutineTimeType) -> (Bool, String) {
        return TimeSlotManager.shared.canExecute(timeType: timeType)
    }

    // Get available time types at current time
    func getAvailableTimeTypes() -> [RoutineTimeType] {
        RoutineTimeType.allCases.filter { timeType in
            canExecuteRoutine(for: timeType).0
        }
    }

    // Get current appropriate time type
    func getCurrentTimeType() -> RoutineTimeType? {
        return TimeSlotManager.shared.getCurrentTimeType()
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
        print("🔄 changeDay called: \(selectedDay.rawValue) -> \(day.rawValue)")
        selectedDay = day
        loadRoutines()
        loadAllRoutines()
    }

    func changeTimeType(_ timeType: RoutineTimeType) {
        print("🔄 changeTimeType called: \(selectedTimeType.rawValue) -> \(timeType.rawValue)")
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
