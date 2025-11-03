import Foundation
import CoreData
import Combine

struct SavedRoutineSlotInfo {
    let id: UUID
    let slotNumber: Int
    let title: String
    let savedAt: Date
    let routineCount: Int
    let dayCount: Int
    var isEmpty: Bool {
        return false
    }
}

class SavedRoutineManager: ObservableObject {
    static let shared = SavedRoutineManager()
    private let viewContext: NSManagedObjectContext

    @Published var savedSlots: [SavedRoutineSlotInfo] = []

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        loadSavedSlots()
    }

    // MARK: - Load Saved Slots
    func loadSavedSlots() {
        let request = NSFetchRequest<SavedRoutineSlot>(entityName: "SavedRoutineSlot")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SavedRoutineSlot.slotNumber, ascending: true)]

        do {
            let results = try viewContext.fetch(request)
            savedSlots = results.compactMap { slot in
                guard let routineData = slot.routineData,
                      let routines = try? JSONDecoder().decode([RoutineItem].self, from: routineData) else {
                    return SavedRoutineSlotInfo(
                        id: slot.id ?? UUID(),
                        slotNumber: Int(slot.slotNumber),
                        title: slot.title ?? "내 루틴",
                        savedAt: slot.savedAt ?? Date(),
                        routineCount: 0,
                        dayCount: 0
                    )
                }

                let uniqueDays = Set(routines.map { $0.dayOfWeek })

                return SavedRoutineSlotInfo(
                    id: slot.id ?? UUID(),
                    slotNumber: Int(slot.slotNumber),
                    title: slot.title ?? "내 루틴",
                    savedAt: slot.savedAt ?? Date(),
                    routineCount: routines.count,
                    dayCount: uniqueDays.count
                )
            }
        } catch {
            print("Error loading saved slots: \(error)")
            savedSlots = []
        }
    }

    // MARK: - Get Available Slot Number
    func getAvailableSlotNumber() -> Int? {
        let usedSlots = Set(savedSlots.map { $0.slotNumber })
        for slotNumber in 0..<5 {
            if !usedSlots.contains(slotNumber) {
                return slotNumber
            }
        }
        return nil
    }

    // MARK: - Save Current Routines to Slot
    func saveRoutinesToSlot(title: String, routines: [RoutineItem]) -> Bool {
        guard let slotNumber = getAvailableSlotNumber() else {
            print("All slots are full")
            return false
        }

        return saveRoutinesToSlot(slotNumber: slotNumber, title: title, routines: routines)
    }

    func saveRoutinesToSlot(slotNumber: Int, title: String, routines: [RoutineItem]) -> Bool {
        guard slotNumber >= 0 && slotNumber < 5 else {
            print("Invalid slot number")
            return false
        }

        // Delete existing slot if present
        deleteSlot(slotNumber: slotNumber)

        // Encode routines to Data
        guard let routineData = try? JSONEncoder().encode(routines) else {
            print("Error encoding routines")
            return false
        }

        // Create new saved slot
        let slot = SavedRoutineSlot(context: viewContext)
        slot.id = UUID()
        slot.slotNumber = Int16(slotNumber)
        slot.title = title
        slot.routineData = routineData
        slot.savedAt = Date()

        do {
            try viewContext.save()
            loadSavedSlots()
            return true
        } catch {
            print("Error saving routine slot: \(error)")
            return false
        }
    }

    // MARK: - Load Routines from Slot
    func loadRoutinesFromSlot(slotNumber: Int) -> [RoutineItem]? {
        let request = NSFetchRequest<SavedRoutineSlot>(entityName: "SavedRoutineSlot")
        request.predicate = NSPredicate(format: "slotNumber == %d", slotNumber)

        do {
            let results = try viewContext.fetch(request)
            guard let slot = results.first,
                  let routineData = slot.routineData else {
                return nil
            }

            let routines = try JSONDecoder().decode([RoutineItem].self, from: routineData)
            return routines
        } catch {
            print("Error loading routines from slot: \(error)")
            return nil
        }
    }

    // MARK: - Delete Slot
    func deleteSlot(slotNumber: Int) {
        let request = NSFetchRequest<SavedRoutineSlot>(entityName: "SavedRoutineSlot")
        request.predicate = NSPredicate(format: "slotNumber == %d", slotNumber)

        do {
            let results = try viewContext.fetch(request)
            for slot in results {
                viewContext.delete(slot)
            }
            try viewContext.save()
            loadSavedSlots()
        } catch {
            print("Error deleting slot: \(error)")
        }
    }

    // MARK: - Check if slots are full
    var isFull: Bool {
        return savedSlots.count >= 5
    }

    var availableSlotsCount: Int {
        return 5 - savedSlots.count
    }
}
