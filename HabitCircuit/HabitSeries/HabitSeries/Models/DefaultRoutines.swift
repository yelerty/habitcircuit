import Foundation

struct DefaultRoutines {
    static let examples: [String] = [
        "비타민 먹기",
        "팔굽혀펴기 30개",
        "스쿼트 100개",
        "5분 명상",
        "쓰레기 정리",
        "주식 점검",
        "내일 할일 정리",
        "일기 쓰기",
        "듀오링고 하기",
        "책 읽기 (30분)",
        "이메일 정리",
        "물 마시기 (500ml)",
        "스트레칭",
        "감사 일기",
        "영어 공부 20분",
        "운동 30분",
        "아침 산책",
        "침대 정리",
        "설거지",
        "청소하기"
    ]

    static func getRandomExamples(count: Int = 5) -> [String] {
        return Array(examples.shuffled().prefix(count))
    }
}
