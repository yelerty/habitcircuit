import Foundation
import Combine

class DefaultRoutines: ObservableObject {
    private static let userDefaultsKey = "customDefaultRoutines"

    static var builtInExamples: [String] {
        return [
            L("example.routine.1"),
            L("example.routine.2"),
            L("example.routine.3"),
            L("example.routine.4"),
            L("example.routine.5"),
            L("example.routine.6"),
            L("example.routine.7"),
            L("example.routine.8"),
            L("example.routine.9"),
            L("example.routine.10"),
            L("example.routine.11"),
            L("example.routine.12"),
            L("example.routine.13"),
            L("example.routine.14"),
            L("example.routine.15"),
            L("example.routine.16"),
            L("example.routine.17"),
            L("example.routine.18"),
            L("example.routine.19"),
            L("example.routine.20"),
            L("example.routine.21"),
            L("example.routine.22"),
            L("example.routine.23")
        ]
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
