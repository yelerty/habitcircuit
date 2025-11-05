import SwiftUI
import CoreData

struct RoutineExecutionView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var isPresented: Bool
    @State private var showCompletionView = false
    @State private var rectangleOffset: CGSize = .zero
    @State private var currentCorner: Int = 0
    @State private var showTransitionView = false
    @State private var nextTimeType: RoutineTimeType?
    @State private var showSparkle = false
    @State private var showExitConfirmation = false

    var body: some View {
        ZStack {
            if showTransitionView, let nextTimeType = nextTimeType {
                TransitionView(
                    timeType: nextTimeType,
                    onContinue: {
                        viewModel.changeTimeType(nextTimeType)
                        showTransitionView = false
                        self.nextTimeType = nil
                    },
                    onFinish: {
                        // Only show completion if ALL day's routines are done
                        if viewModel.allDayRoutinesCompleted {
                            showCompletionView = true
                        } else {
                            // User chose to finish, but not all routines completed
                            isPresented = false
                        }
                        showTransitionView = false
                    }
                )
            } else if viewModel.allDayRoutinesCompleted || showCompletionView {
                CompletionView(
                    viewModel: viewModel,
                    isPresented: $isPresented
                )
            } else {
                executionContent
            }
        }
    }

    var executionContent: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()

                // Moving dot indicator for screen burn-in protection (small, subtle)
                Circle()
                    .fill(Color.white.opacity(0.03))
                    .frame(width: 20, height: 20)
                    .offset(rectangleOffset)
                    .animation(.easeInOut(duration: 30), value: rectangleOffset)
                    .onAppear {
                        moveToNextCorner(screenSize: geometry.size)
                    }

                // Fixed content container
                VStack(spacing: 0) {
                    // Header with Close Button
                    HStack {
                        Button(action: {
                            showExitConfirmation = true
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.9))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }

                        Spacer()

                        // Enhanced progress indicator
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("현재: \(viewModel.progressText)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))

                            if viewModel.allRoutines.count > 0 {
                                let totalCompleted = viewModel.allRoutines.filter { $0.isCompleted }.count
                                Text("전체: \(totalCompleted)/\(viewModel.allRoutines.count)")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                    .padding()

                    Spacer()

                    // Current Routine - Large and Centered
                    if let currentRoutine = viewModel.currentRoutine {
                        VStack(spacing: 24) {
                            // Progress Circle - Minimal
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                                    .frame(width: 80, height: 80)

                                Circle()
                                    .trim(from: 0, to: viewModel.progressPercentage)
                                    .stroke(
                                        Color.white.opacity(0.8),
                                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                    )
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut, value: viewModel.progressPercentage)
                            }

                            // Current Routine Name - Large Focus
                            Text(currentRoutine.name)
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .lineLimit(3)

                            // Subtle hint
                            Text("집중하세요")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .id(currentRoutine.id)
                        .transition(.opacity)
                    }

                    Spacer()

                    // Complete Button - Small and Dark
                    if let _ = viewModel.currentRoutine {
                        ZStack {
                            Button(action: {
                                // Haptic feedback
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)

                                // Sparkle effect
                                showSparkle = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showSparkle = false
                                }

                                withAnimation {
                                    viewModel.completeCurrentRoutine()

                                    // Check if current time type is completed
                                    if viewModel.allRoutinesCompleted {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            // Check if ALL day's routines are completed (not just current time type)
                                            if viewModel.allDayRoutinesCompleted {
                                                print("✅ All routines for the entire day completed!")
                                                showCompletionView = true
                                            } else if let next = viewModel.getNextIncompleteTimeType() {
                                                // There are more time types to complete
                                                print("🔄 Current time type completed, transitioning to \(next.rawValue)")
                                                nextTimeType = next
                                                showTransitionView = true
                                            } else {
                                                // Current time type done, but there might be incomplete routines in previous time types
                                                print("⚠️ Current time type completed, but some routines remain incomplete")
                                                showCompletionView = false
                                                isPresented = false
                                            }
                                        }
                                    }
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.caption)

                                    Text("완료")
                                        .font(.caption)
                                }
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(20)
                            }
                            .scaleButton()

                            SparkleEffect(isActive: showSparkle)
                                .frame(width: 100, height: 100)
                        }
                        .frame(minWidth: 80, minHeight: 44)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .alert("루틴 종료", isPresented: $showExitConfirmation) {
            Button("계속하기", role: .cancel) { }
            Button("종료", role: .destructive) {
                isPresented = false
            }
        } message: {
            Text("루틴 실행을 종료하시겠습니까?\n진행 상황은 저장됩니다.")
        }
    }

    private func moveToNextCorner(screenSize: CGSize) {
        // Calculate center position
        let centerX = screenSize.width / 2
        let centerY = screenSize.height / 2

        // Calculate offsets from center to each corner
        let padding: CGFloat = 150
        let offsets: [CGSize] = [
            CGSize(width: -(centerX - padding), height: -(centerY - padding)), // Top-left
            CGSize(width: (centerX - padding), height: -(centerY - padding)), // Top-right
            CGSize(width: (centerX - padding), height: (centerY - padding)), // Bottom-right
            CGSize(width: -(centerX - padding), height: (centerY - padding)), // Bottom-left
        ]

        currentCorner = (currentCorner + 1) % offsets.count
        rectangleOffset = offsets[currentCorner]

        // Schedule next move
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if !showCompletionView && !viewModel.allRoutinesCompleted {
                moveToNextCorner(screenSize: screenSize)
            }
        }
    }
}

struct CompletionView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var isPresented: Bool
    @State private var showConfetti = false
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0
    @StateObject private var streakManager = StreakManager.shared

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()

                // Success Animation with Confetti
                ZStack {
                    // Background Circle with pulse animation
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 150, height: 150)
                        .scaleEffect(showConfetti ? 1.0 : 0.8)
                        .animation(.easeOut(duration: 0.6).repeatForever(autoreverses: true), value: showConfetti)

                    CelebrationAnimationView()
                }

                VStack(spacing: 12) {
                    Text("모든 루틴 완료!")
                        .font(.system(size: 32, weight: .bold))
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)

                    Text(viewModel.selectedDay.rawValue + " 루틴을 모두 완료했습니다")
                        .font(.body)
                        .foregroundColor(.gray)
                        .opacity(titleOpacity)

                    // Streak Display
                    HStack(spacing: 12) {
                        Text(streakManager.streakEmoji)
                            .font(.system(size: 40))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(streakManager.currentStreak)일 연속")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.orange)

                            Text(streakManager.motivationalMessage)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.1))
                    )
                    .opacity(titleOpacity)
                }
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) {
                        titleScale = 1.0
                        titleOpacity = 1.0
                    }
                }

            // Routine Summary
            VStack(alignment: .leading, spacing: 12) {
                Text("완료한 루틴")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.routines) { routine in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)

                                Text(routine.name)
                                    .font(.body)

                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 250)
            }

            Spacer()

            // Close Button
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                isPresented = false
            }) {
                Text("완료")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(15)
            }
            .scaleButton()
            .glowEffect(color: .green, radius: 10)
            .padding()
        }
        .background(Color(.systemBackground))

        // Confetti overlay
        if showConfetti {
            ConfettiView()
                .allowsHitTesting(false)
        }
    }
    .onAppear {
        // Record streak completion
        streakManager.recordCompletion()

        // Trigger confetti animation
        showConfetti = true

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Additional celebration haptics
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
    }
}

// MARK: - Transition View
struct TransitionView: View {
    let timeType: RoutineTimeType
    let onContinue: () -> Void
    let onFinish: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    private var timeTypeIcon: String {
        switch timeType {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        }
    }

    private var timeTypeColor: Color {
        switch timeType {
        case .morning: return .orange
        case .afternoon: return .yellow
        case .evening: return .indigo
        }
    }

    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Time type icon with animation
                ZStack {
                    Circle()
                        .fill(timeTypeColor.opacity(0.2))
                        .frame(width: 150, height: 150)

                    Image(systemName: timeTypeIcon)
                        .font(.system(size: 60))
                        .foregroundColor(timeTypeColor)
                }
                .scaleEffect(scale)
                .opacity(opacity)

                VStack(spacing: 16) {
                    Text("\(timeType.rawValue) 루틴 완료!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("다음 시간대로 이동하시겠습니까?")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(opacity)

                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onContinue()
                    }) {
                        Text("계속하기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(timeTypeColor)
                            .cornerRadius(12)
                    }
                    .scaleButton()
                    .glowEffect(color: timeTypeColor, radius: 8)

                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        onFinish()
                    }) {
                        Text("오늘은 여기까지")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .scaleButton()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

struct RoutineExecutionView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineExecutionView(
            viewModel: RoutineViewModel(context: PersistenceController.shared.container.viewContext),
            isPresented: .constant(true)
        )
    }
}
