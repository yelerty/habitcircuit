import SwiftUI
import CoreData

struct RoutineExecutionView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var isPresented: Bool
    @State private var showCompletionView = false
    @State private var rectanglePosition: CGPoint = .zero
    @State private var currentCorner: Int = 0

    var body: some View {
        ZStack {
            if viewModel.allRoutinesCompleted || showCompletionView {
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

                // Small rectangle that moves around corners
                VStack(spacing: 0) {
                    // Header with Close Button
                    HStack {
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.6))
                        }

                        Spacer()

                        // Minimal progress indicator
                        Text(viewModel.progressText)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
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
                    }

                    Spacer()

                    // Complete Button - Small and Dark
                    if let _ = viewModel.currentRoutine {
                        Button(action: {
                            withAnimation {
                                viewModel.completeCurrentRoutine()

                                // Check if all completed
                                if viewModel.allRoutinesCompleted {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        showCompletionView = true
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
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(20)
                        }
                        .padding(.bottom, 40)
                    }
                }
                .frame(width: 300, height: 400)
                .background(Color.black)
                .position(rectanglePosition)
                .onAppear {
                    // Start at top-left corner
                    rectanglePosition = CGPoint(x: 150, y: 200)
                    moveToNextCorner(screenSize: geometry.size)
                }
            }
        }
    }

    private func moveToNextCorner(screenSize: CGSize) {
        let padding: CGFloat = 150
        let positions: [CGPoint] = [
            CGPoint(x: padding, y: padding), // Top-left
            CGPoint(x: screenSize.width - padding, y: padding), // Top-right
            CGPoint(x: screenSize.width - padding, y: screenSize.height - padding), // Bottom-right
            CGPoint(x: padding, y: screenSize.height - padding), // Bottom-left
        ]

        currentCorner = (currentCorner + 1) % positions.count

        withAnimation(.easeInOut(duration: 30)) {
            rectanglePosition = positions[currentCorner]
        }

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

struct RoutineExecutionView_Previews: PreviewProvider {
    static var previews: some View {
        RoutineExecutionView(
            viewModel: RoutineViewModel(context: PersistenceController.shared.container.viewContext),
            isPresented: .constant(true)
        )
    }
}
