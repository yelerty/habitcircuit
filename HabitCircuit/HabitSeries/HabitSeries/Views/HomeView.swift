import SwiftUI
import CoreData

struct HomeView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var showEditScreen: Bool
    @State private var showExecutionScreen = false
    @State private var showSettings = false
    @State private var showTimeGuide = false
    @State private var showTimeRestrictionAlert = false
    @State private var timeRestrictionMessage = ""
    @StateObject private var streakManager = StreakManager.shared

    private var navigationTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        let dateString = formatter.string(from: Date())
        return "\(dateString) \(viewModel.selectedDay.rawValue)"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Day Selector
            DaySelectorView(selectedDay: $viewModel.selectedDay)
                .onChange(of: viewModel.selectedDay) { oldValue, newValue in
                    print("🎯 HomeView - selectedDay changed from \(oldValue.rawValue) to \(newValue.rawValue)")
                    viewModel.loadRoutines()
                    viewModel.loadAllRoutines()
                }
                .padding(.vertical)

            Divider()

            if viewModel.hasRoutines {
                // Time-based Routine Boxes
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(RoutineTimeType.allCases, id: \.self) { timeType in
                            TimeRoutineBoxView(
                                viewModel: viewModel,
                                timeType: timeType,
                                showEditScreen: $showEditScreen
                            )
                        }
                    }
                    .padding()
                }
                .id(viewModel.allRoutines.count)

                // AdMob Banner
                AdBannerView()
                    .frame(height: 50)
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Start Button
                if viewModel.selectedDay == .today {
                    let canStartNow = viewModel.getCurrentTimeType() != nil

                    Button(action: {
                        guard canStartNow else { return }

                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()

                        if viewModel.allRoutinesCompleted {
                            viewModel.resetDailyRoutines()
                        } else {
                            startRoutine()
                        }
                    }) {
                        Text(viewModel.allRoutinesCompleted ? "다시 시작" : "루틴 시작")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(canStartNow ? (viewModel.allRoutinesCompleted ? Color.green : Color.blue) : Color.gray)
                            .cornerRadius(12)
                    }
                    .scaleButton()
                    .allowsHitTesting(canStartNow)
                    .opacity(canStartNow ? 1.0 : 0.5)
                    .glowEffect(color: canStartNow ? (viewModel.allRoutinesCompleted ? .green : .blue) : .clear, radius: canStartNow ? 8 : 0)
                    .padding()

                    if !canStartNow {
                        Text("현재는 루틴 실행 시간이 아닙니다")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, -8)
                    }
                } else {
                    // Disabled state for past/future days
                    VStack(spacing: 8) {
                        Text("오늘만 루틴을 시작할 수 있습니다")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            } else {
                // Empty State
                VStack(spacing: 24) {
                    Spacer()

                    // Icon with animation
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 120, height: 120)

                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                    }

                    VStack(spacing: 12) {
                        Text("아직 루틴이 없습니다")
                            .font(.title2)
                            .fontWeight(.bold)

                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.blue)
                                Text("우측 상단의")
                                    .foregroundColor(.gray)
                                Image(systemName: "square.and.pencil")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                Text("버튼을 눌러")
                                    .foregroundColor(.gray)
                            }
                            .font(.body)

                            Text("새로운 루틴을 추가해보세요")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .multilineTextAlignment(.center)
                    }

                    // 또는 구분선
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text("또는")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 60)

                    // CTA Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        showEditScreen = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.pencil")
                            Text("루틴 편집하기")
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .scaleButton()
                    .glowEffect(color: .blue, radius: 8)

                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Streak Badge
                HStack(spacing: 6) {
                    Text(streakManager.streakEmoji)
                        .font(.system(size: 20))
                    Text("\(streakManager.currentStreak)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.15))
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                    }

                    Button(action: {
                        showEditScreen = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showExecutionScreen, onDismiss: {
            // Reload data when execution screen is dismissed
            viewModel.loadRoutines()
            viewModel.loadAllRoutines()
        }) {
            RoutineExecutionView(viewModel: viewModel, isPresented: $showExecutionScreen)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 {
                        // Swipe left - next day
                        withAnimation {
                            viewModel.changeDay(viewModel.selectedDay.next)
                        }
                    } else if value.translation.width > 50 {
                        // Swipe right - previous day
                        withAnimation {
                            viewModel.changeDay(viewModel.selectedDay.previous)
                        }
                    }
                }
        )
        .onAppear {
            // Reload routines data to ensure it's up to date
            viewModel.loadRoutines()
            viewModel.loadAllRoutines()

            // Check streak status on app launch
            streakManager.checkStreakStatus()

            // Show time guide on first launch
            let hasShownGuide = UserDefaults.standard.bool(forKey: "hasShownTimeGuide")
            if !hasShownGuide {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showTimeGuide = true
                    UserDefaults.standard.set(true, forKey: "hasShownTimeGuide")
                }
            }
        }
        .overlay(
            Group {
                if showTimeGuide {
                    TimeGuideView(isPresented: $showTimeGuide)
                }
            }
        )
        .alert("시간 제한", isPresented: $showTimeRestrictionAlert) {
            Button("확인", role: .cancel) {}
            Button("시간 안내 보기") {
                showTimeGuide = true
            }
        } message: {
            Text(timeRestrictionMessage)
        }
    }

    // MARK: - Helper Functions
    private func startRoutine() {
        // Debug: Check available time types
        let availableTypes = viewModel.getAvailableTimeTypes()
        print("🔍 Available time types: \(availableTypes.map { $0.rawValue })")

        // Get first incomplete time type from available time types
        guard let firstIncompleteTimeType = viewModel.getFirstIncompleteTimeType() else {
            // Check if there are any routines at all
            let hasRoutines = viewModel.hasRoutines
            let allCompleted = viewModel.allDayRoutinesCompleted

            print("⚠️ No incomplete time type found - hasRoutines: \(hasRoutines), allCompleted: \(allCompleted)")

            if !hasRoutines {
                timeRestrictionMessage = "루틴이 없습니다. 먼저 루틴을 추가해주세요."
                showTimeRestrictionAlert = true
                return
            }

            if allCompleted {
                timeRestrictionMessage = "오늘의 모든 루틴을 이미 완료했습니다! 🎉"
                showTimeRestrictionAlert = true
                return
            }

            // Check which time types are currently available and have incomplete routines
            let currentTimeType = viewModel.getCurrentTimeType()

            // Check if current time type routines are already completed
            if let currentTimeType = currentTimeType {
                // Current time type is available, but no incomplete routines
                // Check if there are incomplete routines in other time types
                let hasIncompleteInOtherTypes = RoutineTimeType.allCases.contains { timeType in
                    if timeType == currentTimeType { return false }
                    let count = viewModel.getRoutineCount(for: timeType)
                    if count == 0 { return false }

                    let request = NSFetchRequest<Routine>(entityName: "Routine")
                    request.predicate = NSPredicate(format: "dayOfWeek == %@ AND timeType == %@ AND isCompleted == NO",
                                                   viewModel.selectedDay.rawValue, timeType.rawValue)
                    do {
                        let incompleteCount = try PersistenceController.shared.container.viewContext.count(for: request)
                        return incompleteCount > 0
                    } catch {
                        return false
                    }
                }

                if hasIncompleteInOtherTypes {
                    // There are incomplete routines in other time types
                    let morningRange = TimeSlotManager.shared.getTimeRangeString(for: .morning)
                    let afternoonRange = TimeSlotManager.shared.getTimeRangeString(for: .afternoon)
                    let eveningRange = TimeSlotManager.shared.getTimeRangeString(for: .evening)

                    timeRestrictionMessage = """
                    현재 \(currentTimeType.rawValue) 시간대의 루틴은 모두 완료했습니다! 🎉

                    다른 시간대의 미완료 루틴이 있습니다.
                    해당 시간대에 실행해주세요.

                    실행 가능한 시간:
                    🌅 아침: \(morningRange)
                    ☀️ 점심: \(afternoonRange)
                    🌙 저녁: \(eveningRange)
                    """
                } else {
                    // Current time type routines are completed
                    timeRestrictionMessage = "현재 \(currentTimeType.rawValue) 시간대의 루틴은 모두 완료했습니다! 🎉"
                }
            } else {
                // Not in any time slot
                let morningRange = TimeSlotManager.shared.getTimeRangeString(for: .morning)
                let afternoonRange = TimeSlotManager.shared.getTimeRangeString(for: .afternoon)
                let eveningRange = TimeSlotManager.shared.getTimeRangeString(for: .evening)

                timeRestrictionMessage = """
                현재는 루틴 실행 시간이 아닙니다.

                실행 가능한 시간:
                🌅 아침: \(morningRange)
                ☀️ 점심: \(afternoonRange)
                🌙 저녁: \(eveningRange)
                """
            }

            showTimeRestrictionAlert = true
            return
        }

        print("✅ Starting routine for: \(firstIncompleteTimeType.rawValue)")

        // Check if user can execute this time type
        let (canExecute, message) = viewModel.canExecuteRoutine(for: firstIncompleteTimeType)
        if !canExecute {
            timeRestrictionMessage = message
            showTimeRestrictionAlert = true
            return
        }

        // Switch to first incomplete time type
        if viewModel.selectedTimeType != firstIncompleteTimeType {
            viewModel.changeTimeType(firstIncompleteTimeType)
        }

        // Start execution
        showExecutionScreen = true
    }
}

struct RoutineRowView: View {
    let routine: RoutineItem
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 15) {
            // Completion Status Icon
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : (isActive ? Color.blue : Color.gray.opacity(0.3)))
                    .frame(width: 40, height: 40)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.headline)
                } else {
                    Text("\(routine.order + 1)")
                        .foregroundColor(isActive ? .white : .gray)
                        .font(.headline)
                }
            }

            // Routine Name
            Text(routine.name)
                .font(.body)
                .fontWeight(isActive ? .semibold : .regular)
                .foregroundColor(isCompleted ? .gray : (isActive ? .primary : .gray))

            Spacer()

            // Active Indicator
            if isActive && !isCompleted {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive && !isCompleted ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive && !isCompleted ? Color.blue : Color.clear, lineWidth: 2)
        )
        .opacity(isCompleted ? 0.6 : (isActive ? 1.0 : 0.5))
    }
}

struct DaySelectorView: View {
    @Binding var selectedDay: DayOfWeek
    @Namespace private var scrollSpace

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDay = day
                            }
                        }) {
                            VStack(spacing: 4) {
                                Text(day.shortName)
                                    .font(.headline)
                                    .foregroundColor(selectedDay == day ? .white : .primary)

                                if day == .today {
                                    Circle()
                                        .fill(selectedDay == day ? Color.white : Color.blue)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedDay == day ? Color.blue : Color.gray.opacity(0.1))
                            )
                        }
                        .bouncyButton()
                        .id(day)
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                // Scroll to today's day on appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        proxy.scrollTo(DayOfWeek.today, anchor: .center)
                    }
                }
            }
        }
    }
}

struct TimeRoutineBoxView: View {
    @ObservedObject var viewModel: RoutineViewModel
    let timeType: RoutineTimeType
    @Binding var showEditScreen: Bool

    private var routinesForTimeType: [RoutineItem] {
        viewModel.allRoutines.filter { $0.timeType == timeType }
    }

    private var completedCount: Int {
        routinesForTimeType.filter { $0.isCompleted }.count
    }

    private var totalCount: Int {
        routinesForTimeType.count
    }

    private var progressPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    private var timeTypeColor: Color {
        switch timeType {
        case .morning: return .orange
        case .afternoon: return .yellow
        case .evening: return .indigo
        }
    }

    var body: some View {
        if totalCount > 0 {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: timeType.icon)
                        .font(.title2)
                        .foregroundColor(timeTypeColor)

                    Text(timeType.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Text("\(completedCount)/\(totalCount)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // Progress Bar
                ProgressView(value: progressPercentage)
                    .tint(timeTypeColor)

                // Routine List
                VStack(spacing: 8) {
                    ForEach(routinesForTimeType) { routine in
                        HStack(spacing: 12) {
                            Image(systemName: routine.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(routine.isCompleted ? .green : .gray)
                                .font(.body)

                            // Category icon
                            Image(systemName: routine.category.icon)
                                .foregroundColor(routine.category.color)
                                .font(.caption)
                                .opacity(routine.isCompleted ? 0.5 : 1.0)

                            Text(routine.name)
                                .font(.body)
                                .foregroundColor(routine.isCompleted ? .gray : .primary)
                                .strikethrough(routine.isCompleted)

                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: 0.5) {
                            print("🔵 Long press detected on: \(routine.name)")
                            print("🔵 Routine day: \(routine.dayOfWeek), time: \(routine.timeType.rawValue)")

                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()

                            // Switch to the routine's day of week
                            if let day = DayOfWeek(rawValue: routine.dayOfWeek) {
                                viewModel.selectedDay = day
                                print("🔵 Switched to day: \(day.rawValue)")
                            }

                            // Switch to the routine's time type before opening edit screen
                            viewModel.changeTimeType(routine.timeType)
                            print("🔵 Switched to time type: \(routine.timeType.rawValue)")

                            // Small delay to ensure state updates
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showEditScreen = true
                                print("🔵 Opening edit screen")
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(timeTypeColor.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(timeTypeColor.opacity(0.3), lineWidth: 2)
            )
        }
    }
}
