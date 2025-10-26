import Foundation
import Combine

class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var completionDates: [Date] = []

    private let currentStreakKey = "currentStreak"
    private let longestStreakKey = "longestStreak"
    private let completionDatesKey = "completionDates"
    private let lastCompletionDateKey = "lastCompletionDate"

    static let shared = StreakManager()

    private init() {
        loadStreakData()
    }

    // MARK: - Load & Save
    private func loadStreakData() {
        currentStreak = UserDefaults.standard.integer(forKey: currentStreakKey)
        longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)

        if let datesData = UserDefaults.standard.array(forKey: completionDatesKey) as? [Double] {
            completionDates = datesData.map { Date(timeIntervalSince1970: $0) }
        }
    }

    private func saveStreakData() {
        UserDefaults.standard.set(currentStreak, forKey: currentStreakKey)
        UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)

        let datesData = completionDates.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(datesData, forKey: completionDatesKey)
    }

    // MARK: - Record Completion
    func recordCompletion(for date: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)

        // Check if already completed today
        if let lastDate = completionDates.last,
           calendar.isDate(lastDate, inSameDayAs: today) {
            // Already completed today, don't add again
            return
        }

        // Add today to completion dates
        completionDates.append(today)

        // Check if this continues the streak
        if let lastDate = UserDefaults.standard.object(forKey: lastCompletionDateKey) as? Date {
            let lastDay = calendar.startOfDay(for: lastDate)

            if let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day {
                if daysDifference == 1 {
                    // Consecutive day - increment streak
                    currentStreak += 1
                } else if daysDifference > 1 {
                    // Streak broken - reset to 1
                    currentStreak = 1
                }
                // If daysDifference == 0, same day (already handled above)
            }
        } else {
            // First completion ever
            currentStreak = 1
        }

        // Update longest streak
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        // Save last completion date
        UserDefaults.standard.set(today, forKey: lastCompletionDateKey)

        saveStreakData()
    }

    // MARK: - Check Streak Status
    func checkStreakStatus() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = UserDefaults.standard.object(forKey: lastCompletionDateKey) as? Date {
            let lastDay = calendar.startOfDay(for: lastDate)

            if let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day {
                if daysDifference > 1 {
                    // Streak broken - reset
                    currentStreak = 0
                    saveStreakData()
                }
            }
        }
    }

    // MARK: - Completion History
    func isCompleted(on date: Date) -> Bool {
        let calendar = Calendar.current
        return completionDates.contains { completionDate in
            calendar.isDate(completionDate, inSameDayAs: date)
        }
    }

    func getCompletionDatesInRange(from startDate: Date, to endDate: Date) -> [Date] {
        let calendar = Calendar.current
        return completionDates.filter { date in
            date >= calendar.startOfDay(for: startDate) &&
            date <= calendar.startOfDay(for: endDate)
        }
    }

    // MARK: - Helper Methods
    var streakEmoji: String {
        switch currentStreak {
        case 0: return "😴"
        case 1...2: return "🔥"
        case 3...6: return "🔥🔥"
        case 7...13: return "🔥🔥🔥"
        case 14...29: return "⚡️"
        case 30...99: return "🌟"
        default: return "🏆"
        }
    }

    var motivationalMessage: String {
        switch currentStreak {
        case 0: return "오늘 시작해보세요!"
        case 1: return "좋은 시작이에요!"
        case 2...6: return "계속 이어가세요!"
        case 7: return "1주일 달성! 🎉"
        case 14: return "2주 연속! 대단해요! 🎊"
        case 30: return "한 달 달성! 놀라워요! ✨"
        case 100: return "100일! 전설이에요! 👑"
        default: return "\(currentStreak)일 연속!"
        }
    }
}
