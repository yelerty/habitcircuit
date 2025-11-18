import SwiftUI

/// Modern, elegant day selector component
struct DaySelector: View {
    @Binding var selectedDay: DayOfWeek
    @Namespace private var animation

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        DayButton(
                            day: day,
                            isSelected: selectedDay == day,
                            isToday: day == .today,
                            namespace: animation
                        ) {
                            selectDay(day)
                        }
                        .id(day)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .onAppear {
                withAnimation {
                    proxy.scrollTo(selectedDay, anchor: .center)
                }
            }
        }
    }

    private func selectDay(_ day: DayOfWeek) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedDay = day
        }
    }
}

/// Individual day button with modern glassmorphism design
private struct DayButton: View {
    let day: DayOfWeek
    let isSelected: Bool
    let isToday: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(day.shortName)
                    .font(.system(size: 15, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(foregroundColor)

                if isToday {
                    Circle()
                        .fill(indicatorColor)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 56, height: 56)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "selectedDay", in: namespace)
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var foregroundColor: Color {
        isSelected ? .white : .primary
    }

    private var indicatorColor: Color {
        isSelected ? .white : .blue
    }
}

// MARK: - Preview

#Preview {
    VStack {
        DaySelector(selectedDay: .constant(.today))
            .background(Color(.systemGroupedBackground))

        Spacer()
    }
}
