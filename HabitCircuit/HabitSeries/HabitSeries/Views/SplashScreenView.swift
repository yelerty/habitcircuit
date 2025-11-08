import SwiftUI

struct SplashScreenView: View {
    @Binding var isLoading: Bool
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0.0
    @State private var progress: Double = 0.0
    @State private var loadingComplete = false
    @State private var showTapHint = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onTapGesture {
                if loadingComplete {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isLoading = false
                    }
                }
            }

            VStack(spacing: 20) {
                Spacer()

                // App Icon or Logo
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                .opacity(opacity)

                // App Name
                Text("HabitCircuit")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(opacity)

                // Tagline
                Text("루틴으로 만드는 습관")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(opacity)

                Spacer()

                // Loading Progress Bar and Tap Hint
                VStack(spacing: 16) {
                    // Progress Bar
                    VStack(spacing: 8) {
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 6)

                            // Progress
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .frame(width: max(0, progress * UIScreen.main.bounds.width * 0.7), height: 6)
                                .animation(.easeInOut(duration: 0.3), value: progress)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.7)

                        // Loading percentage
                        if !loadingComplete {
                            Text("\(Int(progress * 100))%")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .opacity(opacity)

                    // Tap to continue hint (appears when loading is complete)
                    if loadingComplete {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                                .font(.caption)
                            Text("화면을 터치하여 시작하기")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                        .opacity(showTapHint ? 1.0 : 0.6)
                        .scaleEffect(showTapHint ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: showTapHint)
                        .transition(.opacity)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Logo animation
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }

            // Simulate loading progress
            simulateLoading()
        }
    }

    private func simulateLoading() {
        let totalDuration: Double = 1.5
        let steps = 15
        let interval = totalDuration / Double(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                progress = Double(i) / Double(steps)

                // When loading is complete
                if i == steps {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            loadingComplete = true
                            showTapHint = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(isLoading: .constant(true))
}
