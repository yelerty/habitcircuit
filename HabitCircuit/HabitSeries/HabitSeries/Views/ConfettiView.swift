import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece(
                    color: colors.randomElement() ?? .blue,
                    delay: Double.random(in: 0...0.3),
                    xOffset: Double.random(in: -200...200),
                    yOffset: Double.random(in: -500...500),
                    rotation: Double.random(in: 0...360),
                    scale: Double.random(in: 0.5...1.5)
                )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let delay: Double
    let xOffset: Double
    let yOffset: Double
    let rotation: Double
    let scale: Double

    @State private var isAnimating = false

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(isAnimating ? rotation + 360 : rotation))
            .offset(
                x: isAnimating ? xOffset : 0,
                y: isAnimating ? yOffset : -100
            )
            .opacity(isAnimating ? 0 : 1)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.5)
                    .delay(delay)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Celebration Animation View
struct CelebrationAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -10
    @State private var opacity: Double = 0

    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 80))
            .foregroundColor(.green)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                    scale = 1.0
                    rotation = 0
                    opacity = 1
                }
            }
    }
}
