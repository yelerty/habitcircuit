import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var showEditScreen: Bool
    @State private var showExecutionScreen = false
    @State private var showSettings = false
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
                    viewModel.changeDay(newValue)
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
                                timeType: timeType
                            )
                        }
                    }
                    .padding()
                }

                // Start Button
                if viewModel.selectedDay == .today {
                    Button(action: {
                        if viewModel.allRoutinesCompleted {
                            viewModel.resetDailyRoutines()
                        } else {
                            showExecutionScreen = true
                        }
                    }) {
                        Text(viewModel.allRoutinesCompleted ? "다시 시작" : "루틴 시작")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.allRoutinesCompleted ? Color.green : Color.blue)
                            .cornerRadius(12)
                    }
                    .padding()
                } else {
                    // Disabled state for past/future days
                    VStack(spacing: 8) {
                        Text(viewModel.selectedDay == .today ? "루틴 시작" : "오늘만 루틴을 시작할 수 있습니다")
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
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("아직 루틴이 없습니다")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("우측 상단 버튼을 눌러\n오늘의 루틴을 추가해보세요")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        showEditScreen = true
                    }) {
                        Text("루틴 추가하기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .frame(maxHeight: .infinity)
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
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showExecutionScreen) {
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
            // Check streak status on app launch
            streakManager.checkStreakStatus()
        }
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
                            selectedDay = day
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

                            Text(routine.name)
                                .font(.body)
                                .foregroundColor(routine.isCompleted ? .gray : .primary)
                                .strikethrough(routine.isCompleted)

                            Spacer()
                        }
                        .padding(.vertical, 4)
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
