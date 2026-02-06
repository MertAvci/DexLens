import SwiftUI

/// A reusable notification banner component that displays at the top of the screen.
///
/// This banner appears at the top like an iOS notification with:
/// - An icon indicating the notification type
/// - A title and message
/// - An optional dismiss button
/// - Auto-dismiss functionality after a specified duration
struct NotificationBanner: View {
    let type: NotificationType
    let title: String
    let message: String
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.iconName)
                .font(.title3)
                .foregroundStyle(type.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .textStyle(.subheadlineBold, color: .textPrimary)

                Text(message)
                    .textStyle(.caption1, color: .textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .textStyle(.caption1, color: .textSecondary)
            }
            .accessibilityLabel("Dismiss notification")
        }
        .padding()
        .background(Color.surfaceSecondary)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}


/// View modifier that adds notification banner support to any view.
struct NotificationBannerModifier: ViewModifier {
    @Binding var isPresented: Bool

    let type: NotificationType
    let title: String?
    let message: String
    let duration: NotificationDuration
    let onDismiss: () -> Void

    @State private var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        ZStack {
            content

            VStack {
                if isPresented {
                    NotificationBanner(
                        type: type,
                        title: title ?? type.defaultTitle,
                        message: message,
                        onClose: dismiss
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))

                    Spacer()
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
            .onChange(of: isPresented) { _, newValue in
                newValue ? scheduleDismiss() : dismissTask?.cancel()
            }
            .onDisappear {
                dismissTask?.cancel()
            }
        }
    }

    private func dismiss() {
        withAnimation {
            isPresented = false
        }
        onDismiss()
    }

    private func scheduleDismiss() {
        dismissTask?.cancel()

        dismissTask = Task {
            try? await Task.sleep(
                nanoseconds: UInt64(duration.timeInterval * 1_000_000_000)
            )

            guard !Task.isCancelled else { return }

            await MainActor.run {
                dismiss()
            }
        }
    }
}


extension View {
    func notificationBanner(
        isPresented: Binding<Bool>,
        type: NotificationType,
        title: String? = nil,
        message: String,
        duration: NotificationDuration = .normal,
        onDismiss: @escaping () -> Void = {}
    ) -> some View {
        modifier(
            NotificationBannerModifier(
                isPresented: isPresented,
                type: type,
                title: title,
                message: message,
                duration: duration,
                onDismiss: onDismiss
            )
        )
    }
}

// MARK: - Preview

#Preview("All Notifications") {
    VStack(spacing: 16) {
        ForEach(NotificationType.allCases) { type in
            NotificationBanner(
                type: type,
                title: type.defaultTitle,
                message: "This is a sample \(type) message"
            ) {}
        }
    }
    .padding()
}
