import SwiftUI

/// Modern empty state view with animation and guidance
struct EmptyStateView: View {
    let onAddRoutine: () -> Void

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Animated icon
            ZStack {
                // Pulsing background circles
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color.blue.opacity(0.1), lineWidth: 2)
                        .scaleEffect(isAnimating ? 1.3 + CGFloat(index) * 0.2 : 1.0)
                        .opacity(isAnimating ? 0 : 0.6)
                        .frame(width: 120, height: 120)
                        .animation(
                            .easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.3),
                            value: isAnimating
                        )
                }

                // Main icon container
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.15),
                                    Color.blue.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .blue.opacity(0.1), radius: 20, x: 0, y: 10)

                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 54, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
            }

            // Text content
            VStack(spacing: 16) {
                Text(L("home.no.routines"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                VStack(spacing: 12) {
                    // Instructions
                    HStack(spacing: 8) {
                        Image(systemName: "1.circle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text(L("home.tap.top.right"))
                            .foregroundColor(.secondary)
                        Image(systemName: "square.and.pencil")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    .font(.body)

                    HStack(spacing: 8) {
                        Image(systemName: "2.circle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text(L("home.add.first.routine"))
                            .foregroundColor(.secondary)
                    }
                    .font(.body)

                    HStack(spacing: 8) {
                        Image(systemName: "3.circle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text(L("home.start.building.habits"))
                            .foregroundColor(.secondary)
                    }
                    .font(.body)
                }
                .padding(.horizontal)
            }
            .multilineTextAlignment(.center)

            // CTA Button
            Button(action: onAddRoutine) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))

                    Text(L("home.add.routine.now"))
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: 280)
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.top, 8)

            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Preview

#Preview {
    EmptyStateView(onAddRoutine: {})
        .background(Color(.systemGroupedBackground))
}
