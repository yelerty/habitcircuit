import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var showEditScreen: Bool
    @State private var showExecutionScreen = false

    var body: some View {
        VStack(spacing: 0) {
            // Day Selector
            DaySelectorView(selectedDay: $viewModel.selectedDay)
                .onChange(of: viewModel.selectedDay) { newDay in
                    viewModel.changeDay(newDay)
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
        .navigationTitle(viewModel.selectedDay.rawValue)
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

    var body: some View {
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
                }
            }
            .padding(.horizontal)
        }
    }
}
