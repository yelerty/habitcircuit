import SwiftUI

/// Modern, elegant time routine card with glassmorphism design
struct TimeRoutineCard: View {
    let timeType: RoutineTimeType
    let routines: [RoutineItem]
    let onEdit: () -> Void
    let onRoutineTap: (RoutineItem) -> Void

    private var completedCount: Int {
        routines.filter { $0.isCompleted }.count
    }

    private var progress: Double {
        guard !routines.isEmpty else { return 0 }
        return Double(completedCount) / Double(routines.count)
    }

    private var timeColor: Color {
        switch timeType {
        case .morning:
            return DesignSystem.Colors.morningPrimary
        case .afternoon:
            return DesignSystem.Colors.afternoonPrimary
        case .evening:
            return DesignSystem.Colors.eveningPrimary
        }
    }

    private var timeGradient: LinearGradient {
        switch timeType {
        case .morning:
            return DesignSystem.Colors.morningGradient
        case .afternoon:
            return DesignSystem.Colors.afternoonGradient
        case .evening:
            return DesignSystem.Colors.eveningGradient
        }
    }

    private var softGradient: LinearGradient {
        switch timeType {
        case .morning:
            return DesignSystem.Colors.morningSoftGradient
        case .afternoon:
            return DesignSystem.Colors.afternoonSoftGradient
        case .evening:
            return DesignSystem.Colors.eveningSoftGradient
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

            if !routines.isEmpty {
                Divider()
                    .padding(.horizontal, 16)

                // Routines List
                VStack(spacing: 8) {
                    ForEach(routines) { routine in
                        RoutineRow(
                            routine: routine,
                            isActive: routine == routines.first(where: { !$0.isCompleted }),
                            color: timeColor
                        ) {
                            onRoutineTap(routine)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(softGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            timeColor.opacity(0.3),
                            timeColor.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: timeColor.opacity(0.1), radius: 12, x: 0, y: 6)
    }

    private var headerView: some View {
        HStack(spacing: 12) {
            // Time icon with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [timeColor.opacity(0.2), timeColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: timeType.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [timeColor, timeColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(timeType.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                if routines.isEmpty {
                    Text(L("no.routines"))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                } else {
                    HStack(spacing: 6) {
                        Text("\(completedCount)/\(routines.count)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(timeColor)

                        // Progress bar with glow effect
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(timeColor.opacity(0.15))
                                    .frame(height: 6)

                                // Animated progress bar with glow
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(timeGradient)
                                    .frame(width: geometry.size.width * progress, height: 6)
                                    .shadow(color: timeColor.opacity(0.6), radius: 4, x: 0, y: 0)
                                    .shadow(color: timeColor.opacity(0.3), radius: 8, x: 0, y: 0)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }

            Spacer()

            // Edit button
            Button(action: onEdit) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(timeColor)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(timeColor.opacity(0.1))
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

/// Individual routine row with modern design
private struct RoutineRow: View {
    let routine: RoutineItem
    let isActive: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Status indicator
                ZStack {
                    Circle()
                        .fill(statusBackgroundColor)
                        .frame(width: 32, height: 32)

                    if routine.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(routine.order + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(statusTextColor)
                    }
                }

                // Routine name with category icon
                HStack(spacing: 8) {
                    Image(systemName: routine.category.icon)
                        .font(.system(size: 14))
                        .foregroundColor(routine.category.color.opacity(0.8))

                    Text(routine.name)
                        .font(.system(size: 15, weight: isActive ? .semibold : .regular))
                        .foregroundColor(textColor)
                        .lineLimit(2)
                }

                Spacer()

                // Active indicator
                if isActive && !routine.isCompleted {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color.opacity(0.6))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(rowBackgroundColor)
            )
        }
        .buttonStyle(PressEffectButtonStyle())
    }

    private var statusBackgroundColor: Color {
        if routine.isCompleted {
            return .green
        } else if isActive {
            return color
        } else {
            return Color(.systemGray5)
        }
    }

    private var statusTextColor: Color {
        isActive ? .white : .gray
    }

    private var textColor: Color {
        routine.isCompleted ? .secondary : .primary
    }

    private var rowBackgroundColor: Color {
        if routine.isCompleted {
            return Color(.systemGray6).opacity(0.5)
        } else if isActive {
            return color.opacity(0.08)
        } else {
            return Color.clear
        }
    }
}

/// Press effect button style
private struct PressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            TimeRoutineCard(
                timeType: .morning,
                routines: [
                    RoutineItem(
                        name: "명상하기",
                        order: 0,
                        dayOfWeek: "월요일",
                        timeType: .morning,
                        isCompleted: true,
                        category: .health
                    ),
                    RoutineItem(
                        name: "운동하기",
                        order: 1,
                        dayOfWeek: "월요일",
                        timeType: .morning,
                        isCompleted: false,
                        category: .health
                    ),
                    RoutineItem(
                        name: "영어 공부",
                        order: 2,
                        dayOfWeek: "월요일",
                        timeType: .morning,
                        isCompleted: false,
                        category: .study
                    )
                ],
                onEdit: {},
                onRoutineTap: { _ in }
            )

            TimeRoutineCard(
                timeType: .afternoon,
                routines: [],
                onEdit: {},
                onRoutineTap: { _ in }
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
