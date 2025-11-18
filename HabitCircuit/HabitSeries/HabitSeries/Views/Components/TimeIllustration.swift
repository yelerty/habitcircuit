import SwiftUI

/// Animated time-of-day illustrations for visual appeal
struct TimeIllustration: View {
    let timeType: RoutineTimeType
    @State private var isAnimating = false
    @State private var cloudOffset: CGFloat = 0
    @State private var starOpacity: Double = 1.0

    var body: some View {
        ZStack {
            switch timeType {
            case .morning:
                morningIllustration
            case .afternoon:
                afternoonIllustration
            case .evening:
                eveningIllustration
            }
        }
        .frame(width: 120, height: 120)
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Morning Illustration 🌅

    private var morningIllustration: some View {
        ZStack {
            // Sun rays
            ForEach(0..<8) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.morningSecondary.opacity(0.8),
                                DesignSystem.Colors.morningSecondary.opacity(0)
                            ],
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 40, height: 3)
                    .offset(x: 20)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .opacity(isAnimating ? 1.0 : 0.3)
            }

            // Sun
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Colors.morningSecondary,
                            DesignSystem.Colors.morningPrimary
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .shadow(color: DesignSystem.Colors.morningSecondary.opacity(0.6), radius: 20)

            // Coffee steam (animated)
            VStack(spacing: 4) {
                ForEach(0..<3) { index in
                    WavyLine()
                        .stroke(
                            DesignSystem.Colors.morningPrimary.opacity(0.5),
                            lineWidth: 2
                        )
                        .frame(width: 8, height: 12)
                        .offset(
                            x: 25,
                            y: 25 + CGFloat(index) * 5
                        )
                        .opacity(isAnimating ? 0.8 : 0.2)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
        }
    }

    // MARK: - Afternoon Illustration ☀️

    private var afternoonIllustration: some View {
        ZStack {
            // Bright sun
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Colors.afternoonSecondary,
                            DesignSystem.Colors.afternoonPrimary
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 35
                    )
                )
                .frame(width: 70, height: 70)
                .shadow(color: DesignSystem.Colors.afternoonPrimary.opacity(0.6), radius: 25)

            // Floating clouds (animated)
            ForEach(0..<2) { index in
                Cloud()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 40, height: 20)
                    .offset(
                        x: cloudOffset + CGFloat(index * 30) - 40,
                        y: CGFloat(index * 20) - 30
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
            }
        }
    }

    // MARK: - Evening Illustration 🌙

    private var eveningIllustration: some View {
        ZStack {
            // Moon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DesignSystem.Colors.eveningLight,
                                DesignSystem.Colors.eveningSecondary
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: DesignSystem.Colors.eveningPrimary.opacity(0.6), radius: 20)

                // Moon craters
                Circle()
                    .fill(DesignSystem.Colors.eveningPrimary.opacity(0.2))
                    .frame(width: 12, height: 12)
                    .offset(x: -8, y: -5)

                Circle()
                    .fill(DesignSystem.Colors.eveningPrimary.opacity(0.15))
                    .frame(width: 8, height: 8)
                    .offset(x: 10, y: 8)
            }

            // Stars (twinkling)
            ForEach(0..<6) { index in
                Star()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .offset(starPosition(for: index))
                    .opacity(starOpacity)
                    .animation(
                        .easeInOut(duration: 1.0 + Double(index) * 0.2)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: starOpacity
                    )
            }
        }
    }

    // MARK: - Helper Views

    private struct WavyLine: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.midY),
                control: CGPoint(x: rect.midX, y: rect.minY)
            )
            return path
        }
    }

    private struct Cloud: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.width
            let height = rect.height

            // Simple cloud shape using circles
            path.addEllipse(in: CGRect(x: 0, y: height * 0.3, width: width * 0.4, height: height * 0.6))
            path.addEllipse(in: CGRect(x: width * 0.2, y: 0, width: width * 0.6, height: height * 0.8))
            path.addEllipse(in: CGRect(x: width * 0.5, y: height * 0.2, width: width * 0.5, height: height * 0.7))

            return path
        }
    }

    private struct Star: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let outerRadius = min(rect.width, rect.height) / 2
            let innerRadius = outerRadius * 0.4

            for i in 0..<5 {
                let outerAngle = Double(i) * 2 * .pi / 5 - .pi / 2
                let innerAngle = outerAngle + .pi / 5

                let outerPoint = CGPoint(
                    x: center.x + CGFloat(cos(outerAngle)) * outerRadius,
                    y: center.y + CGFloat(sin(outerAngle)) * outerRadius
                )
                let innerPoint = CGPoint(
                    x: center.x + CGFloat(cos(innerAngle)) * innerRadius,
                    y: center.y + CGFloat(sin(innerAngle)) * innerRadius
                )

                if i == 0 {
                    path.move(to: outerPoint)
                } else {
                    path.addLine(to: outerPoint)
                }
                path.addLine(to: innerPoint)
            }
            path.closeSubpath()

            return path
        }
    }

    // MARK: - Animation Helpers

    private func startAnimations() {
        // Sun rays / general pulsing
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            isAnimating = true
        }

        // Cloud drift
        withAnimation(
            .linear(duration: 8.0)
            .repeatForever(autoreverses: false)
        ) {
            cloudOffset = 80
        }

        // Star twinkling
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            starOpacity = 0.3
        }
    }

    private func starPosition(for index: Int) -> CGSize {
        let positions: [CGSize] = [
            CGSize(width: -35, height: -25),
            CGSize(width: 30, height: -30),
            CGSize(width: -25, height: 20),
            CGSize(width: 35, height: 15),
            CGSize(width: -40, height: 0),
            CGSize(width: 40, height: -10)
        ]
        return positions[index]
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        VStack {
            Text("Morning")
                .font(.caption)
            TimeIllustration(timeType: .morning)
        }

        VStack {
            Text("Afternoon")
                .font(.caption)
            TimeIllustration(timeType: .afternoon)
        }

        VStack {
            Text("Evening")
                .font(.caption)
            TimeIllustration(timeType: .evening)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
