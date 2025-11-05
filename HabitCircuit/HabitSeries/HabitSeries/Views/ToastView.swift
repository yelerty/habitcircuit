import SwiftUI

// MARK: - Toast Message View
struct ToastView: View {
    let message: String
    let type: ToastType

    enum ToastType {
        case success
        case error
        case info

        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundColor(.white)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .background(type.color)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let type: ToastView.ToastType
    let duration: TimeInterval

    func body(content: Content) -> some View {
        ZStack {
            content

            if isShowing {
                VStack {
                    ToastView(message: message, type: type)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation {
                                    isShowing = false
                                }
                            }
                        }

                    Spacer()
                }
                .zIndex(1)
            }
        }
        .animation(.spring(), value: isShowing)
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String, type: ToastView.ToastType = .success, duration: TimeInterval = 2.0) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message, type: type, duration: duration))
    }
}
