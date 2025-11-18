import Foundation
import SwiftUI
import CoreData
import Combine

/// Slim ViewModel focused on state management only
/// Business logic delegated to RoutineService
/// Data access delegated to RoutineRepository
@MainActor
class RefactoredRoutineViewModel: ObservableObject {

    // MARK: - Published State

    @Published var routines: [RoutineItem] = []
    @Published var allRoutines: [RoutineItem] = []
    @Published var selectedDay: DayOfWeek = .today {
        didSet {
            if oldValue != selectedDay {
                scheduleDataReload()
            }
        }
    }
    @Published var selectedTimeType: RoutineTimeType = .morning {
        didSet {
            if oldValue != selectedTimeType {
                scheduleRoutinesReload()
            }
        }
    }
    @Published var currentRoutineIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Debounce reload tasks
    private var reloadTask: Task<Void, Never>?
    private var routinesReloadTask: Task<Void, Never>?

    // MARK: - Dependencies

    private let service: RoutineServiceProtocol
    private let lastResetDateKey = "lastResetDate"

    // MARK: - Initialization

    init(service: RoutineServiceProtocol) {
        self.service = service
        Task {
            await resetPastDaysIfNeeded()
            await loadData()
        }
    }

    // MARK: - Data Loading

    func loadRoutines() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedRoutines = try await service.getRoutines(
                for: selectedDay,
                timeType: selectedTimeType
            )
            routines = fetchedRoutines
            updateCurrentRoutineIndex()
        } catch {
            errorMessage = "Failed to load routines: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func loadAllRoutines() async {
        do {
            let fetchedRoutines = try await service.getAllRoutines(for: selectedDay)
            allRoutines = fetchedRoutines
        } catch {
            errorMessage = "Failed to load all routines: \(error.localizedDescription)"
        }
    }

    func loadData() async {
        await loadRoutines()
        await loadAllRoutines()
    }

    func reloadData() async {
        await loadData()
    }

    // MARK: - Debounced Reload Methods

    private func scheduleDataReload() {
        // Cancel previous task
        reloadTask?.cancel()

        // Schedule new task with debounce
        reloadTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000) // 150ms debounce
            guard !Task.isCancelled else { return }
            await loadData()
        }
    }

    private func scheduleRoutinesReload() {
        // Cancel previous task
        routinesReloadTask?.cancel()

        // Schedule new task with debounce
        routinesReloadTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms debounce
            guard !Task.isCancelled else { return }
            await loadRoutines()
        }
    }

    // MARK: - CRUD Operations

    func addRoutine(name: String, timeType: RoutineTimeType? = nil, category: RoutineCategory = .other) async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Routine name cannot be empty"
            return
        }

        isLoading = true

        do {
            let targetTimeType = timeType ?? selectedTimeType
            let order = routines.count

            // Optimistic update: add to local array immediately
            let newRoutine = RoutineItem(
                id: UUID(),
                name: name,
                order: order,
                dayOfWeek: selectedDay.rawValue,
                timeType: targetTimeType,
                isCompleted: false,
                category: category
            )

            if targetTimeType == selectedTimeType {
                routines.append(newRoutine)
            }
            allRoutines.append(newRoutine)

            try await service.addRoutine(
                name: name,
                day: selectedDay,
                timeType: targetTimeType,
                category: category,
                order: order
            )
        } catch {
            errorMessage = "Failed to add routine: \(error.localizedDescription)"
            // Rollback on error
            await loadData()
        }

        isLoading = false
    }

    func updateRoutine(id: UUID, name: String, category: RoutineCategory) async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Routine name cannot be empty"
            return
        }

        isLoading = true

        // Store original values for rollback
        let originalRoutines = routines
        let originalAllRoutines = allRoutines

        do {
            // Optimistic update
            if let index = routines.firstIndex(where: { $0.id == id }) {
                routines[index].name = name
                routines[index].category = category
            }
            if let index = allRoutines.firstIndex(where: { $0.id == id }) {
                allRoutines[index].name = name
                allRoutines[index].category = category
            }

            try await service.updateRoutine(id: id, name: name, category: category)
        } catch {
            errorMessage = "Failed to update routine: \(error.localizedDescription)"
            // Rollback
            routines = originalRoutines
            allRoutines = originalAllRoutines
        }

        isLoading = false
    }

    func deleteRoutine(at indexSet: IndexSet) async {
        isLoading = true

        // Store for rollback
        let originalRoutines = routines
        let originalAllRoutines = allRoutines

        do {
            // Get routines to delete
            let routinesToDelete = indexSet.map { routines[$0] }

            // Optimistic delete
            routines.remove(atOffsets: indexSet)
            for routine in routinesToDelete {
                if let allIndex = allRoutines.firstIndex(where: { $0.id == routine.id }) {
                    allRoutines.remove(at: allIndex)
                }
            }

            // Reorder locally
            for (index, _) in routines.enumerated() {
                routines[index].order = index
            }

            // Perform actual delete
            for routine in routinesToDelete {
                try await service.deleteRoutine(id: routine.id)
            }

            // Reorder in database
            if !routines.isEmpty {
                try await service.reorderRoutines(routines)
            } else {
                // Switch to non-empty time type if current is empty
                await switchToNonEmptyTimeType()
            }
        } catch {
            errorMessage = "Failed to delete routine: \(error.localizedDescription)"
            // Rollback
            routines = originalRoutines
            allRoutines = originalAllRoutines
        }

        isLoading = false
    }

    func moveRoutine(from source: IndexSet, to destination: Int) async {
        let originalRoutines = routines

        // Optimistic update
        routines.move(fromOffsets: source, toOffset: destination)

        // Update order values
        for (index, _) in routines.enumerated() {
            routines[index].order = index
        }

        do {
            try await service.reorderRoutines(routines)
        } catch {
            errorMessage = "Failed to reorder routines: \(error.localizedDescription)"
            // Rollback
            routines = originalRoutines
        }
    }

    func completeCurrentRoutine() async {
        guard currentRoutineIndex < routines.count else { return }

        let routine = routines[currentRoutineIndex]
        let originalRoutines = routines
        let originalAllRoutines = allRoutines

        do {
            // Optimistic update
            routines[currentRoutineIndex].isCompleted = true
            if let allIndex = allRoutines.firstIndex(where: { $0.id == routine.id }) {
                allRoutines[allIndex].isCompleted = true
            }
            updateCurrentRoutineIndex()

            try await service.completeRoutine(id: routine.id)
        } catch {
            errorMessage = "Failed to complete routine: \(error.localizedDescription)"
            // Rollback
            routines = originalRoutines
            allRoutines = originalAllRoutines
            updateCurrentRoutineIndex()
        }
    }

    func resetDailyRoutines() async {
        isLoading = true

        do {
            try await service.resetCompletions(for: selectedDay)
            await loadData()
            currentRoutineIndex = 0
        } catch {
            errorMessage = "Failed to reset routines: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Navigation & State Helpers

    func changeDay(_ day: DayOfWeek) {
        selectedDay = day
    }

    func changeTimeType(_ timeType: RoutineTimeType) {
        selectedTimeType = timeType
    }

    private func switchToNonEmptyTimeType() async {
        for timeType in RoutineTimeType.allCases {
            do {
                let count = try await service.getRoutineCount(
                    for: selectedDay,
                    timeType: timeType
                )
                if count > 0 {
                    selectedTimeType = timeType
                    await loadRoutines()
                    return
                }
            } catch {
                continue
            }
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

    var progressPercentage: Double {
        guard !routines.isEmpty else { return 0 }
        let completedCount = routines.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(routines.count)
    }

    var progressText: String {
        let completedCount = routines.filter { $0.isCompleted }.count
        return "\(completedCount)/\(routines.count)"
    }

    // MARK: - Business Logic Queries

    func getRoutineCount(for timeType: RoutineTimeType) -> Int {
        // Synchronous version for UI - uses cached allRoutines
        allRoutines.filter { $0.timeType == timeType }.count
    }

    func getAvailableTimeTypes() -> [RoutineTimeType] {
        var available: [RoutineTimeType] = []
        for timeType in RoutineTimeType.allCases {
            let count = allRoutines.filter { $0.timeType == timeType }.count
            if count > 0 {
                available.append(timeType)
            }
        }
        return available
    }

    func canExecuteRoutine(for timeType: RoutineTimeType) -> (Bool, String) {
        TimeSlotManager.shared.canExecute(timeType: timeType)
    }

    func getCurrentTimeType() -> RoutineTimeType? {
        TimeSlotManager.shared.getCurrentTimeType()
    }

    func getNextIncompleteTimeType() async -> RoutineTimeType? {
        do {
            return try await service.getNextIncompleteTimeType(
                for: selectedDay,
                after: selectedTimeType
            )
        } catch {
            return nil
        }
    }

    func getFirstIncompleteTimeType() async -> RoutineTimeType? {
        do {
            return try await service.getFirstIncompleteTimeType(for: selectedDay)
        } catch {
            return nil
        }
    }

    func getAllIncompleteAvailableTimeTypes() -> [RoutineTimeType] {
        let availableTypes = getAvailableTimeTypes()
        return availableTypes.filter { timeType in
            let routinesForType = allRoutines.filter { $0.timeType == timeType }
            return !routinesForType.isEmpty && routinesForType.contains(where: { !$0.isCompleted })
        }
    }

    var allAvailableRoutinesCompleted: Bool {
        let availableTypes = getAvailableTimeTypes()
        guard !availableTypes.isEmpty else { return false }

        for timeType in availableTypes {
            let routinesForType = allRoutines.filter { $0.timeType == timeType }
            if !routinesForType.isEmpty && !routinesForType.allSatisfy({ $0.isCompleted }) {
                return false
            }
        }
        return true
    }

    var allDayRoutinesCompleted: Bool {
        !allRoutines.isEmpty && allRoutines.allSatisfy { $0.isCompleted }
    }

    // MARK: - Reset Logic

    private func resetPastDaysIfNeeded() async {
        let today = Date()
        let calendar = Calendar.current

        if let lastReset = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date {
            if !calendar.isDate(lastReset, inSameDayAs: today) {
                await resetPastDays(currentDate: today)
                UserDefaults.standard.set(today, forKey: lastResetDateKey)
            }
        } else {
            UserDefaults.standard.set(today, forKey: lastResetDateKey)
        }
    }

    private func resetPastDays(currentDate: Date) async {
        let calendar = Calendar.current
        let currentDayOfWeek = DayOfWeek.today

        for day in DayOfWeek.allCases {
            if shouldResetDay(day, currentDay: currentDayOfWeek, calendar: calendar, currentDate: currentDate) {
                do {
                    try await service.resetCompletions(for: day)
                } catch {
                    print("Failed to reset \(day.rawValue): \(error)")
                }
            }
        }
    }

    private func shouldResetDay(_ day: DayOfWeek, currentDay: DayOfWeek, calendar: Calendar, currentDate: Date) -> Bool {
        guard let dayDate = day.toDate(from: currentDate, calendar: calendar),
              let currentDayDate = currentDay.toDate(from: currentDate, calendar: calendar) else {
            return false
        }
        return dayDate < currentDayDate
    }

    // MARK: - Export/Import Support
    // Use RoutineExportManager.shared for export/import functionality
}

// MARK: - DayOfWeek Extension

extension DayOfWeek {
    func toDate(from currentDate: Date, calendar: Calendar) -> Date? {
        let currentWeekday = calendar.component(.weekday, from: currentDate)
        let targetWeekday = self.weekdayValue

        let daysToAdd = (targetWeekday - currentWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: daysToAdd, to: currentDate)
    }

    var weekdayValue: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
}
