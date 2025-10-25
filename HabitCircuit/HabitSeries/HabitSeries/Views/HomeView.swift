import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var showEditScreen: Bool
    @State private var showExecutionScreen = false

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

            if viewModel.hasRoutines {
                // Progress Bar
                ProgressView(value: viewModel.progressPercentage)
                    .padding(.horizontal)

                Text(viewModel.progressText + " 완료")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)

                // Routine List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.routines.enumerated()), id: \.element.id) { index, routine in
                            RoutineRowView(
                                routine: routine,
                                isActive: index == viewModel.currentRoutineIndex,
                                isCompleted: routine.isCompleted
                            )
                        }
                    }
                    .padding()
                }

                // Start Button
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditScreen = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
        }
        .fullScreenCover(isPresented: $showExecutionScreen) {
            RoutineExecutionView(viewModel: viewModel, isPresented: $showExecutionScreen)
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
