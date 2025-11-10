import SwiftUI
import CoreData

struct RoutineExecutionView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var isPresented: Bool
    @State private var rectangleOffset: CGSize = .zero
    @State private var currentCorner: Int = 0
    @State private var showSparkle = false
    @State private var showExitConfirmation = false

    private var timeTypeColor: Color {
        switch viewModel.selectedTimeType {
        case .morning: return .orange
        case .afternoon: return .yellow
        case .evening: return .indigo
        }
    }

    var body: some View {
        executionContent
            .onChange(of: viewModel.allRoutinesCompleted) { oldValue, newValue in
                if newValue {
                    // All routines for current time type completed
                    print("✅ All routines completed detected, closing in 0.5s")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        isPresented = false
                    }
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
                            Text("\(viewModel.selectedTimeType.rawValue): \(viewModel.progressText)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding()

                    Spacer()

                    // Current Routine - Large and Centered
                    if let currentRoutine = viewModel.currentRoutine {
                        VStack(spacing: 24) {
                            // Time Type Display
                            HStack(spacing: 8) {
                                Image(systemName: viewModel.selectedTimeType.icon)
                                    .font(.title3)
                                    .foregroundColor(timeTypeColor)

                                Text(viewModel.selectedTimeType.rawValue)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(timeTypeColor.opacity(0.2))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(timeTypeColor.opacity(0.5), lineWidth: 1)
                            )

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
                            Text(L("execution.focus"))
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
                                    // onChange handler will detect completion and close automatically
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.caption)

                                    Text(L("execution.complete.button"))
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
        .alert(L("execution.exit.title"), isPresented: $showExitConfirmation) {
            Button(L("execution.continue"), role: .cancel) { }
            Button(L("execution.exit"), role: .destructive) {
                isPresented = false
            }
        } message: {
            Text(L("execution.exit.message"))
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
            if !viewModel.allRoutinesCompleted {
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
                    Text(L("execution.all.complete"))
                        .font(.system(size: 32, weight: .bold))
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)

                    Text(String(format: L("execution.all.complete.message"), viewModel.selectedDay.displayName))
                        .font(.body)
                        .foregroundColor(.gray)
                        .opacity(titleOpacity)

                    // Streak Display
                    HStack(spacing: 12) {
                        Text(streakManager.streakEmoji)
                            .font(.system(size: 40))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(format: L("execution.streak"), "\(streakManager.currentStreak)"))
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
                Text(L("execution.completed.routines"))
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
                Text(L("execution.complete.button"))
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
                    Text(String(format: L("execution.timetype.complete"), timeType.displayName))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(L("execution.next.timetype"))
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
                        Text(L("execution.continue"))
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
                        Text(L("execution.today.done"))
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
