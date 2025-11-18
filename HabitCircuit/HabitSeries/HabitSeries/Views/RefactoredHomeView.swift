import SwiftUI
import CoreData

/// Modern, refactored HomeView with improved architecture and design
struct RefactoredHomeView: View {
    @ObservedObject var viewModel: RefactoredRoutineViewModel
    @Binding var showEditScreen: Bool

    @State private var showExecutionScreen = false
    @State private var showSettings = false
    @State private var showTimeRestrictionAlert = false
    @State private var timeRestrictionMessage = ""
    @State private var streakPulseScale: CGFloat = 1.0

    @StateObject private var streakManager = StreakManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(.systemGroupedBackground),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Day Selector
                    DaySelector(selectedDay: $viewModel.selectedDay)
                        .padding(.vertical, 12)

                    // Main Content
                    if viewModel.hasRoutines {
                        routineContentView
                    } else {
                        EmptyStateView {
                            showEditScreen = true
                        }
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    streakBadge
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        settingsButton
                        editButton
                    }
                }
            }
            .fullScreenCover(isPresented: $showExecutionScreen) {
                Task { await viewModel.reloadData() }
            } content: {
                RoutineExecutionView(
                    viewModel: RoutineViewModel(
                        context: PersistenceController.shared.container.viewContext
                    ),
                    isPresented: $showExecutionScreen
                )
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert(L("time.restriction"), isPresented: $showTimeRestrictionAlert) {
                Button(L("ok"), role: .cancel) {}
            } message: {
                Text(timeRestrictionMessage)
            }
        }
    }

    // MARK: - Subviews

    private var navigationTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage == .korean ? "ko_KR" : "en_US")
        formatter.dateFormat = L("date.format.month.day")
        let dateString = formatter.string(from: Date())
        let today = DayOfWeek.today
        return "\(dateString) \(today.displayName)"
    }

    private var streakBadge: some View {
        HStack(spacing: 6) {
            Text(streakManager.streakEmoji)
                .font(.system(size: 18))
                .scaleEffect(streakPulseScale)

            Text("\(streakManager.currentStreak)")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.morningPrimary,
                            DesignSystem.Colors.morningSecondary
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(DesignSystem.Colors.morningPrimary.opacity(0.12))
        )
        .overlay(
            Capsule()
                .stroke(DesignSystem.Colors.morningPrimary.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: DesignSystem.Colors.morningPrimary.opacity(0.3), radius: 8, x: 0, y: 0)
        .onAppear {
            // Pulse animation (heartbeat-like)
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                streakPulseScale = 1.2
            }
        }
    }

    private var settingsButton: some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.blue)
        }
    }

    private var editButton: some View {
        Button {
            showEditScreen = true
        } label: {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blue)
        }
    }

    private var routineContentView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(RoutineTimeType.allCases, id: \.self) { timeType in
                        TimeRoutineCard(
                            timeType: timeType,
                            routines: routinesForTimeType(timeType),
                            onEdit: {
                                viewModel.changeTimeType(timeType)
                                showEditScreen = true
                            },
                            onRoutineTap: { routine in
                                // Handle routine tap
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            // Ad Banner
            AdBannerView()
                .frame(height: 50)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            // Action Button
            if viewModel.selectedDay == .today {
                actionButton
            } else {
                pastDayMessage
            }
        }
    }

    private var actionButton: some View {
        let canStartNow = viewModel.getCurrentTimeType() != nil

        return VStack(spacing: 8) {
            Button {
                guard canStartNow else { return }

                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()

                if viewModel.allRoutinesCompleted {
                    Task { await viewModel.resetDailyRoutines() }
                } else {
                    startRoutine()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.allRoutinesCompleted ? "arrow.clockwise.circle.fill" : "play.circle.fill")
                        .font(.system(size: 18, weight: .semibold))

                    Text(viewModel.allRoutinesCompleted ? L("home.restart") : L("home.start.routine"))
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Group {
                        if canStartNow {
                            LinearGradient(
                                colors: viewModel.allRoutinesCompleted
                                    ? [.green, .green.opacity(0.8)]
                                    : [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            LinearGradient(
                                colors: [.gray, .gray.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                .cornerRadius(16)
                .shadow(
                    color: canStartNow
                        ? (viewModel.allRoutinesCompleted ? Color.green : Color.blue).opacity(0.3)
                        : Color.clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }
            .disabled(!canStartNow)
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 16)

            if !canStartNow {
                Text(L("home.not.routine.time"))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 16)
    }

    private var pastDayMessage: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 32))
                .foregroundColor(.orange.opacity(0.7))

            Text(L("home.only.today"))
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
    }

    // MARK: - Helper Methods

    private func routinesForTimeType(_ timeType: RoutineTimeType) -> [RoutineItem] {
        viewModel.allRoutines.filter { $0.timeType == timeType }
    }

    private func startRoutine() {
        Task {
            guard let firstIncompleteTimeType = await viewModel.getFirstIncompleteTimeType() else {
                // All routines completed
                return
            }

            let (canExecute, message) = viewModel.canExecuteRoutine(for: firstIncompleteTimeType)

            if canExecute {
                viewModel.changeTimeType(firstIncompleteTimeType)
                showExecutionScreen = true
            } else {
                timeRestrictionMessage = message
                showTimeRestrictionAlert = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    RefactoredHomeView(
        viewModel: RefactoredRoutineViewModel(
            service: RoutineService(
                repository: CoreDataRoutineRepository(
                    context: PersistenceController.preview.container.viewContext
                )
            )
        ),
        showEditScreen: .constant(false)
    )
}
