import SwiftUI

// MARK: - Bouncy Button Effect
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Ripple Effect
struct RippleEffect: ViewModifier {
    @State private var ripples: [RippleData] = []

    struct RippleData: Identifiable {
        let id = UUID()
        let position: CGPoint
        var scale: CGFloat = 0
        var opacity: Double = 0.6
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    ZStack {
                        ForEach(ripples) { ripple in
                            Circle()
                                .fill(Color.white.opacity(ripple.opacity))
                                .frame(width: 100, height: 100)
                                .scaleEffect(ripple.scale)
                                .position(ripple.position)
                                .allowsHitTesting(false)
                        }
                    }
                }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Only create ripple on initial touch
                        if ripples.isEmpty || ripples.last?.scale ?? 1.0 > 0.1 {
                            createRipple(at: value.location)
                        }
                    }
            )
    }

    private func createRipple(at position: CGPoint) {
        let ripple = RippleData(position: position)
        ripples.append(ripple)

        withAnimation(.easeOut(duration: 0.6)) {
            if let index = ripples.firstIndex(where: { $0.id == ripple.id }) {
                ripples[index].scale = 2.0
                ripples[index].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }
}

// MARK: - Sparkle Effect
struct SparkleEffect: View {
    let isActive: Bool
    @State private var particles: [ParticleData] = []

    struct ParticleData: Identifiable {
        let id = UUID()
        var position: CGPoint
        var offset: CGSize = .zero
        var opacity: Double = 1.0
        var scale: CGFloat = 1.0
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.yellow, .orange, .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 5
                            )
                        )
                        .frame(width: 8, height: 8)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .offset(particle.offset)
                        .position(particle.position)
                }
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                createSparkles()
            }
        }
        .allowsHitTesting(false)
    }

    private func createSparkles() {
        let centerX: CGFloat = 50
        let centerY: CGFloat = 50

        for _ in 0..<12 {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance: CGFloat = 30

            let particle = ParticleData(
                position: CGPoint(x: centerX, y: centerY)
            )
            particles.append(particle)

            withAnimation(.easeOut(duration: 0.6)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].offset = CGSize(
                        width: cos(angle) * distance,
                        height: sin(angle) * distance
                    )
                    particles[index].opacity = 0
                    particles[index].scale = 0.5
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                particles.removeAll { $0.id == particle.id }
            }
        }
    }
}

// MARK: - Glow Effect
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.4), radius: radius * 1.5, x: 0, y: 0)
            .shadow(color: color.opacity(0.2), radius: radius * 2, x: 0, y: 0)
    }
}

// MARK: - Press and Hold Effect
struct PressEffect: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .opacity(isPressed ? 0.7 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}

// MARK: - Confetti Burst Effect
struct ConfettiBurst: View {
    let trigger: Bool
    @State private var confetti: [ConfettiPiece] = []

    struct ConfettiPiece: Identifiable {
        let id = UUID()
        let color: Color
        var position: CGPoint
        var offset: CGSize = .zero
        var rotation: Double = 0
        var opacity: Double = 1.0
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confetti) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: 8, height: 4)
                        .rotationEffect(.degrees(piece.rotation))
                        .opacity(piece.opacity)
                        .offset(piece.offset)
                        .position(piece.position)
                }
            }
        }
        .onChange(of: trigger) { _, _ in
            createConfetti()
        }
        .allowsHitTesting(false)
    }

    private func createConfetti() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        let centerX: CGFloat = 50
        let centerY: CGFloat = 50

        for _ in 0..<20 {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance: CGFloat = CGFloat.random(in: 40...80)
            let color = colors.randomElement() ?? .blue

            let piece = ConfettiPiece(
                color: color,
                position: CGPoint(x: centerX, y: centerY)
            )
            confetti.append(piece)

            withAnimation(.easeOut(duration: 0.8)) {
                if let index = confetti.firstIndex(where: { $0.id == piece.id }) {
                    confetti[index].offset = CGSize(
                        width: cos(angle) * distance,
                        height: sin(angle) * distance + 20 // Add gravity
                    )
                    confetti[index].rotation = Double.random(in: 0...360)
                    confetti[index].opacity = 0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                confetti.removeAll { $0.id == piece.id }
            }
        }
    }
}

// MARK: - Scale Button Style (for prominent buttons)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func rippleEffect() -> some View {
        self.modifier(RippleEffect())
    }

    func glowEffect(color: Color = .blue, radius: CGFloat = 10) -> some View {
        self.modifier(GlowEffect(color: color, radius: radius))
    }

    func pressEffect() -> some View {
        self.modifier(PressEffect())
    }

    func bouncyButton() -> some View {
        self.buttonStyle(BouncyButtonStyle())
    }

    func scaleButton() -> some View {
        self.buttonStyle(ScaleButtonStyle())
    }
}
