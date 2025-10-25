import SwiftUI
import CoreData

struct RoutineExecutionView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var isPresented: Bool
    @State private var showCompletionView = false

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
        VStack(spacing: 0) {
            // Header with Close Button
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()

            Spacer()

            // Progress Circle
            VStack(spacing: 20) {
                ZStack {
                    // Background Circle
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                        .frame(width: 200, height: 200)

                    // Progress Circle
                    Circle()
                        .trim(from: 0, to: viewModel.progressPercentage)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: viewModel.progressPercentage)

                    // Progress Text
                    VStack(spacing: 8) {
                        Text(viewModel.progressText)
                            .font(.system(size: 36, weight: .bold))

                        Text("완료")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }

                // Current Routine Name
                if let currentRoutine = viewModel.currentRoutine {
                    VStack(spacing: 12) {
                        Text("현재 루틴")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text(currentRoutine.name)
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                }
            }

            Spacer()

            // Complete Button
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
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)

                        Text("완료")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
    }
}

struct CompletionView: View {
    @ObservedObject var viewModel: RoutineViewModel
    @Binding var isPresented: Bool
    @State private var showConfetti = false
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0

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
