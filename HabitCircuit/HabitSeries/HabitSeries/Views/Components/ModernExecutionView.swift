import SwiftUI
import Combine
import CoreData

/// Modern, elegant execution view with smooth animations
struct ModernExecutionView: View {
    @ObservedObject var viewModel: RefactoredRoutineViewModel
    @Binding var isPresented: Bool

    @State private var currentProgress: Double = 0
    @State private var showConfetti = false
    @State private var showCompletionMessage = false
    @State private var showExitConfirmation = false

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private var currentRoutine: RoutineItem? {
        guard viewModel.currentRoutineIndex < viewModel.routines.count else { return nil }
        return viewModel.routines[viewModel.currentRoutineIndex]
    }

    var body: some View {
        ZStack {
            // Gradient background based on time type
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                Spacer()

                // Main content
                if let routine = currentRoutine {
                    routineContentView(routine)
                } else {
                    allCompletedView
                }

                Spacer()

                // Action buttons
                actionButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }

            // Confetti overlay (commented out - use TouchEffectModifier's ConfettiBurst instead)
            // if showConfetti {
            //     ConfettiView()
            //         .allowsHitTesting(false)
            // }

            // Completion message overlay
            if showCompletionMessage {
                completionOverlay
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .confirmationDialog(
            L("execution.exit.confirm"),
            isPresented: $showExitConfirmation,
            titleVisibility: .visible
        ) {
            Button(L("execution.exit.yes"), role: .destructive) {
                isPresented = false
            }
            Button(L("cancel"), role: .cancel) {}
        }
        .onAppear {
            updateProgress()
        }
    }

    // MARK: - Subviews

    private var backgroundGradient: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // Animated orbs in background (optimized with drawingGroup)
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 200
                            )
                        )
                        .frame(width: 300, height: 300)
                        .offset(orbOffset(for: index))
                        .blur(radius: 30)
                }
            }
            .drawingGroup() // Renders to offscreen image for better performance
        )
    }

    private var gradientColors: [Color] {
        switch viewModel.selectedTimeType {
        case .morning:
            return [
                DesignSystem.Colors.morningPrimary.opacity(0.6),
                DesignSystem.Colors.morningSecondary.opacity(0.5),
                DesignSystem.Colors.morningLight.opacity(0.4)
            ]
        case .afternoon:
            return [
                DesignSystem.Colors.afternoonPrimary.opacity(0.6),
                DesignSystem.Colors.afternoonSecondary.opacity(0.5),
                DesignSystem.Colors.afternoonLight.opacity(0.4)
            ]
        case .evening:
            return [
                DesignSystem.Colors.eveningPrimary.opacity(0.6),
                DesignSystem.Colors.eveningSecondary.opacity(0.5),
                DesignSystem.Colors.eveningLight.opacity(0.4)
            ]
        }
    }

    private func orbOffset(for index: Int) -> CGSize {
        let positions: [CGSize] = [
            CGSize(width: -100, height: -150),
            CGSize(width: 150, height: 100),
            CGSize(width: -80, height: 200)
        ]
        return positions[index]
    }

    private var headerView: some View {
        HStack {
            Button {
                showExitConfirmation = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.2), radius: 4)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(viewModel.selectedTimeType.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))

                Text(viewModel.progressText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }

    private func routineContentView(_ routine: RoutineItem) -> some View {
        VStack(spacing: 32) {
            // Time illustration (at the top)
            TimeIllustration(timeType: viewModel.selectedTimeType)
                .opacity(0.8)

            // Progress circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 180, height: 180)

                // Progress circle with glow
                Circle()
                    .trim(from: 0, to: currentProgress)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round
                        )
                    )
                    .frame(width: 180, height: 180)
                    .shadow(color: .white.opacity(0.8), radius: 6, x: 0, y: 0)
                    .shadow(color: .white.opacity(0.5), radius: 12, x: 0, y: 0)
                    .rotationEffect(.degrees(-90))
                    .animation(
                        reduceMotion
                            ? .none
                            : .spring(response: 0.6, dampingFraction: 0.8),
                        value: currentProgress
                    )

                // Category icon
                VStack(spacing: 8) {
                    Image(systemName: routine.category.icon)
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.white)

                    Text("\(viewModel.currentRoutineIndex + 1)/\(viewModel.routines.count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }
            }

            // Routine name
            VStack(spacing: 12) {
                Text(routine.name)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 32)
                    .shadow(color: .black.opacity(0.2), radius: 4)

                Text(L("execution.focus"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var allCompletedView: some View {
        VStack(spacing: 32) {
            // Celebration icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 180, height: 180)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100, weight: .light))
                    .foregroundColor(.white)
            }
            .scaleEffect(showCompletionMessage ? 1.1 : 1.0)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true),
                value: showCompletionMessage
            )

            VStack(spacing: 12) {
                Text(L("execution.all.complete"))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                Text(L("execution.great.job"))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            if currentRoutine != nil {
                // Skip button
                Button {
                    skipRoutine()
                } label: {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text(L("execution.skip"))
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }

                // Complete button
                Button {
                    completeRoutine()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(L("execution.complete"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(completionButtonTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.white, Color.white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
            } else {
                // Close button
                Button {
                    isPresented = false
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(L("execution.close"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(completionButtonTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.white, Color.white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var completionButtonTextColor: Color {
        switch viewModel.selectedTimeType {
        case .morning:
            return DesignSystem.Colors.morningPrimary
        case .afternoon:
            return DesignSystem.Colors.afternoonPrimary
        case .evening:
            return DesignSystem.Colors.eveningPrimary
        }
    }

    private var completionOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text(L("execution.routine.complete"))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20)
        )
    }

    // MARK: - Actions

    private func completeRoutine() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        Task {
            await viewModel.completeCurrentRoutine()
            updateProgress()

            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showCompletionMessage = true
                showConfetti = true
            }

            try? await Task.sleep(nanoseconds: 1_500_000_000)

            withAnimation {
                showCompletionMessage = false
            }

            try? await Task.sleep(nanoseconds: 500_000_000)
            showConfetti = false

            if viewModel.allRoutinesCompleted {
                try? await Task.sleep(nanoseconds: 500_000_000)
                // Show all completed view
            }
        }
    }

    private func skipRoutine() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        // Move to next routine without marking current as complete
        viewModel.currentRoutineIndex += 1
        updateProgress()
    }

    private func updateProgress() {
        withAnimation(.easeInOut(duration: 0.6)) {
            currentProgress = viewModel.progressPercentage
        }
    }
}

// MARK: - Preview

#Preview {
    ModernExecutionView(
        viewModel: RefactoredRoutineViewModel(
            service: RoutineService(
                repository: CoreDataRoutineRepository(
                    context: PersistenceController.preview.container.viewContext
                )
            )
        ),
        isPresented: .constant(true)
    )
}
