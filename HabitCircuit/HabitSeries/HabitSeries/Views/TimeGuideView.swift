import SwiftUI

struct TimeGuideView: View {
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @StateObject private var timeSlotManager = TimeSlotManager.shared

    var body: some View {
        ZStack {
            // Background dim
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            // Content card
            VStack(spacing: 24) {
                // Title
                VStack(spacing: 8) {
                    Text(L("time.guide.execution.time"))
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(L("time.guide.subtitle"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Circular time chart
                timeChart

                // Time descriptions
                VStack(alignment: .leading, spacing: 16) {
                    TimeSlotRow(
                        icon: "sunrise.fill",
                        color: .orange,
                        title: L("time.guide.morning.routine"),
                        time: timeSlotManager.getTimeRangeString(for: .morning)
                    )

                    TimeSlotRow(
                        icon: "sun.max.fill",
                        color: .yellow,
                        title: L("time.guide.afternoon.routine"),
                        time: timeSlotManager.getTimeRangeString(for: .afternoon)
                    )

                    TimeSlotRow(
                        icon: "moon.stars.fill",
                        color: .indigo,
                        title: L("time.guide.evening.routine"),
                        time: timeSlotManager.getTimeRangeString(for: .evening)
                    )
                }
                .padding(.horizontal)

                // Close button
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Text(L("ok"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
            )
            .padding(40)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    // Convert hour (0-24) to fraction for Circle trim (0.0-1.0)
    private func hourToFraction(_ hour: Int) -> CGFloat {
        return CGFloat(hour) / 24.0
    }

    // Circular time chart view
    private var timeChart: some View {
        let morningRange = timeSlotManager.getTimeRange(for: .morning)
        let afternoonRange = timeSlotManager.getTimeRange(for: .afternoon)
        let eveningRange = timeSlotManager.getTimeRange(for: .evening)

        return ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 40)
                .frame(width: 240, height: 240)

            // Morning segment - dynamic based on notification time
            Circle()
                .trim(from: hourToFraction(morningRange.start),
                      to: hourToFraction(morningRange.end))
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 40, lineCap: .round))
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))

            // Afternoon segment - dynamic based on notification time
            Circle()
                .trim(from: hourToFraction(afternoonRange.start),
                      to: hourToFraction(afternoonRange.end))
                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 40, lineCap: .round))
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))

            // Evening segment - dynamic based on notification time
            Circle()
                .trim(from: hourToFraction(eveningRange.start),
                      to: hourToFraction(eveningRange.end))
                .stroke(Color.indigo, style: StrokeStyle(lineWidth: 40, lineCap: .round))
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))

            // Center info
            VStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
                Text(L("time.guide.24hours"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TimeSlotRow: View {
    let icon: String
    let color: Color
    let title: String
    let time: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.body)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)

                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct TimeGuideView_Previews: PreviewProvider {
    static var previews: some View {
        TimeGuideView(isPresented: .constant(true))
    }
}
