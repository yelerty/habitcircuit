import Foundation
import Combine

// Example routine with category
struct ExampleRoutineItem {
    let name: String
    let category: RoutineCategory
}

class DefaultRoutines: ObservableObject {
    private static let userDefaultsKey = "customDefaultRoutines"

    // Categorized built-in examples
    static var categorizedExamples: [RoutineCategory: [ExampleRoutineItem]] {
        return [
            .health: [
                ExampleRoutineItem(name: L("example.routine.1"), category: .health),   // Take vitamins
                ExampleRoutineItem(name: L("example.routine.11"), category: .health),  // Drink water
            ],
            .exercise: [
                ExampleRoutineItem(name: L("example.routine.2"), category: .exercise),   // 30 push-ups
                ExampleRoutineItem(name: L("example.routine.3"), category: .exercise),   // 100 squats
                ExampleRoutineItem(name: L("example.routine.12"), category: .exercise),  // Stretching
                ExampleRoutineItem(name: L("example.routine.15"), category: .exercise),  // Exercise 20 min
                ExampleRoutineItem(name: L("example.routine.16"), category: .exercise),  // Morning walk
            ],
            .selfCare: [
                ExampleRoutineItem(name: L("example.routine.4"), category: .selfCare),  // 5-minute meditation
                ExampleRoutineItem(name: L("example.routine.13"), category: .selfCare), // Write gratitude journal
                ExampleRoutineItem(name: L("example.routine.19"), category: .selfCare), // Call parents
                ExampleRoutineItem(name: L("example.routine.20"), category: .selfCare), // Read Bible
                ExampleRoutineItem(name: L("example.routine.21"), category: .selfCare), // Read scriptures
            ],
            .study: [
                ExampleRoutineItem(name: L("example.routine.8"), category: .study),  // Practice Duolingo
                ExampleRoutineItem(name: L("example.routine.9"), category: .study),  // Read book (30 min)
                ExampleRoutineItem(name: L("example.routine.14"), category: .study), // Study English 10 min
            ],
            .work: [
                ExampleRoutineItem(name: L("example.routine.6"), category: .work),  // Check stocks
                ExampleRoutineItem(name: L("example.routine.7"), category: .work),  // Plan tomorrow's tasks
                ExampleRoutineItem(name: L("example.routine.10"), category: .work), // Organize emails
            ],
            .household: [
                ExampleRoutineItem(name: L("example.routine.5"), category: .household),  // Clean up trash
                ExampleRoutineItem(name: L("example.routine.17"), category: .household), // Make bed
                ExampleRoutineItem(name: L("example.routine.18"), category: .household), // Wash dishes
                ExampleRoutineItem(name: L("example.routine.22"), category: .household), // Clean room
                ExampleRoutineItem(name: L("example.routine.23"), category: .household), // Clean bathroom
            ],
            .hobby: [
            ],
            .social: [
            ],
            .other: [
            ]
        ]
    }

    // Legacy support - flat list for backward compatibility
    static var builtInExamples: [String] {
        var all: [String] = []
        for category in RoutineCategory.allCases {
            if let items = categorizedExamples[category] {
                all.append(contentsOf: items.map { $0.name })
            }
        }
        return all
    }

    @Published var customRoutines: [String] = []

    init() {
        loadCustomRoutines()
    }

    var allExamples: [String] {
        return customRoutines + Self.builtInExamples
    }

    func loadCustomRoutines() {
        if let saved = UserDefaults.standard.array(forKey: Self.userDefaultsKey) as? [String] {
            customRoutines = saved
        }
    }

    func saveCustomRoutines() {
        UserDefaults.standard.set(customRoutines, forKey: Self.userDefaultsKey)
    }

    func addCustomRoutine(_ routine: String) {
        guard !routine.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        customRoutines.insert(routine, at: 0)
        saveCustomRoutines()
    }

    func deleteCustomRoutine(at index: Int) {
        guard index < customRoutines.count else { return }
        customRoutines.remove(at: index)
        saveCustomRoutines()
    }

    func isCustomRoutine(_ routine: String) -> Bool {
        return customRoutines.contains(routine)
    }

    static func getRandomExamples(count: Int = 5) -> [String] {
        let instance = DefaultRoutines()
        return Array(instance.allExamples.shuffled().prefix(count))
    }
}
