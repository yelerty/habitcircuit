import SwiftUI

/// Centralized design system for consistent UI/UX
enum DesignSystem {

    // MARK: - Colors

    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let accent = Color.orange

        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red

        // MARK: - Enhanced Time-based Color Palettes

        // Morning Palette 🌅
        static let morningPrimary = Color(hex: "#FF6B35")      // Coral Orange
        static let morningSecondary = Color(hex: "#FFD93D")    // Golden Yellow
        static let morningAccent = Color(hex: "#F95738")       // Sunset Red
        static let morningLight = Color(hex: "#FFA07A")        // Light Salmon

        // Afternoon Palette ☀️
        static let afternoonPrimary = Color(hex: "#2EC4B6")    // Turquoise
        static let afternoonSecondary = Color(hex: "#00B4D8")  // Sky Blue
        static let afternoonAccent = Color(hex: "#0096C7")     // Deep Blue
        static let afternoonLight = Color(hex: "#90E0EF")      // Light Cyan

        // Evening Palette 🌙
        static let eveningPrimary = Color(hex: "#7209B7")      // Deep Purple
        static let eveningSecondary = Color(hex: "#B5179E")    // Magenta
        static let eveningAccent = Color(hex: "#F72585")       // Hot Pink
        static let eveningLight = Color(hex: "#C77DFF")        // Light Purple

        // Legacy time-based colors (for backward compatibility)
        static let morning = morningPrimary
        static let afternoon = afternoonPrimary
        static let evening = eveningPrimary

        // MARK: - Enhanced Gradients

        static func primaryGradient(_ color: Color) -> LinearGradient {
            LinearGradient(
                colors: [color, color.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static func subtleGradient(_ color: Color) -> LinearGradient {
            LinearGradient(
                colors: [color.opacity(0.2), color.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        // Rich time-based gradients
        static let morningGradient = LinearGradient(
            colors: [morningPrimary, morningSecondary, morningLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let afternoonGradient = LinearGradient(
            colors: [afternoonPrimary, afternoonSecondary, afternoonLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let eveningGradient = LinearGradient(
            colors: [eveningPrimary, eveningSecondary, eveningLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Soft background gradients for cards
        static let morningSoftGradient = LinearGradient(
            colors: [
                morningPrimary.opacity(0.15),
                morningSecondary.opacity(0.1),
                morningLight.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let afternoonSoftGradient = LinearGradient(
            colors: [
                afternoonPrimary.opacity(0.15),
                afternoonSecondary.opacity(0.1),
                afternoonLight.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let eveningSoftGradient = LinearGradient(
            colors: [
                eveningPrimary.opacity(0.15),
                eveningSecondary.opacity(0.1),
                eveningLight.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let backgroundGradient = LinearGradient(
            colors: [
                Color(.systemGroupedBackground),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Typography

    enum Typography {
        // Display
        static let displayLarge = Font.system(size: 36, weight: .bold)
        static let displayMedium = Font.system(size: 28, weight: .bold)
        static let displaySmall = Font.system(size: 24, weight: .bold)

        // Headline
        static let headlineLarge = Font.system(size: 20, weight: .semibold)
        static let headlineMedium = Font.system(size: 18, weight: .semibold)
        static let headlineSmall = Font.system(size: 16, weight: .semibold)

        // Body
        static let bodyLarge = Font.system(size: 17, weight: .regular)
        static let bodyMedium = Font.system(size: 15, weight: .regular)
        static let bodySmall = Font.system(size: 13, weight: .regular)

        // Label
        static let labelLarge = Font.system(size: 15, weight: .semibold)
        static let labelMedium = Font.system(size: 13, weight: .semibold)
        static let labelSmall = Font.system(size: 11, weight: .semibold)

        // Caption
        static let caption = Font.system(size: 12, weight: .regular)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let pill: CGFloat = 999
    }

    // MARK: - Shadows

    enum Shadow {
        static func soft(color: Color = .black, opacity: Double = 0.1) -> some View {
            EmptyView()
                .shadow(color: color.opacity(opacity), radius: 8, x: 0, y: 4)
        }

        static func medium(color: Color = .black, opacity: Double = 0.15) -> some View {
            EmptyView()
                .shadow(color: color.opacity(opacity), radius: 12, x: 0, y: 6)
        }

        static func strong(color: Color = .black, opacity: Double = 0.2) -> some View {
            EmptyView()
                .shadow(color: color.opacity(opacity), radius: 20, x: 0, y: 10)
        }
    }

    // MARK: - Animations

    enum Animation {
        static let quick = SwiftUI.Animation.spring(response: 0.2, dampingFraction: 0.7)
        static let standard = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let smooth = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
        static let bounce = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.6)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply card style with shadow
    func cardStyle(
        cornerRadius: CGFloat = DesignSystem.CornerRadius.md,
        shadowColor: Color = .black,
        shadowOpacity: Double = 0.1
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: shadowColor.opacity(shadowOpacity), radius: 8, x: 0, y: 4)
    }

    /// Apply glass morphism effect
    func glassMorphism(
        cornerRadius: CGFloat = DesignSystem.CornerRadius.md
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
    }

    /// Apply gradient border
    func gradientBorder(
        colors: [Color],
        lineWidth: CGFloat = 1.5,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.md
    ) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: lineWidth
                    )
            )
    }

    /// Apply shimmer effect
    func shimmer(
        active: Bool = true,
        duration: Double = 2.0
    ) -> some View {
        self.modifier(ShimmerModifier(active: active, duration: duration))
    }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    let active: Bool
    let duration: Double

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if active {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .white.opacity(0.3),
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                        .blendMode(.screen)
                    }
                }
            )
            .onAppear {
                if active {
                    withAnimation(
                        .linear(duration: duration)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1.0
                    }
                }
            }
    }
}

// MARK: - Reusable Components

/// Primary button component
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        color: Color = DesignSystem.Colors.primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(DesignSystem.Typography.labelMedium)
                }

                Text(title)
                    .font(DesignSystem.Typography.labelLarge)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                DesignSystem.Colors.primaryGradient(color)
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
            .shadow(
                color: color.opacity(0.3),
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .scaleButton()
    }
}

/// Secondary button component
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        color: Color = DesignSystem.Colors.primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(DesignSystem.Typography.labelMedium)
                }

                Text(title)
                    .font(DesignSystem.Typography.labelLarge)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(color.opacity(0.3), lineWidth: 1.5)
                    )
            )
        }
        .scaleButton()
    }
}

/// Badge component
struct Badge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(DesignSystem.Typography.labelSmall)
            .foregroundColor(color)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Color Extension

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color code (e.g., "#FF6B35" or "FF6B35")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PrimaryButton("Start Routine", icon: "play.circle.fill") {}
        SecondaryButton("Skip", icon: "forward.fill", color: .orange) {}
        Badge(text: "5 days streak", color: .orange)

        // Color palette preview
        HStack {
            VStack {
                Text("Morning")
                Circle().fill(DesignSystem.Colors.morningGradient)
                    .frame(width: 60, height: 60)
            }
            VStack {
                Text("Afternoon")
                Circle().fill(DesignSystem.Colors.afternoonGradient)
                    .frame(width: 60, height: 60)
            }
            VStack {
                Text("Evening")
                Circle().fill(DesignSystem.Colors.eveningGradient)
                    .frame(width: 60, height: 60)
            }
        }
    }
    .padding()
}
