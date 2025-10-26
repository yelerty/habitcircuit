import Foundation
import Combine

class DefaultRoutines: ObservableObject {
    private static let userDefaultsKey = "customDefaultRoutines"

    static let builtInExamples: [String] = [
        "비타민 먹기",
        "팔굽혀펴기 30개",
        "스쿼트 100개",
        "5분 명상",
        "쓰레기 정리",
        "주식 점검",
        "내일 할일 정리",
        "듀오링고 하기",
        "책 읽기 (30분)",
        "이메일 정리",
        "물 마시기 (300ml)",
        "스트레칭",
        "감사일기 쓰기",
        "영어 공부 10분",
        "운동 20분",
        "아침 산책",
        "침대 정리",
        "설거지",
        "부모님께전화하기",
        "성경읽기",
        "경전읽기",
        "방청소하기",
        "화장실청소하기"
    ]

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
