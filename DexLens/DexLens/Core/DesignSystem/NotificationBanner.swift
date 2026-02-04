import SwiftUI

/// Enum representing different types of notifications.
enum NotificationType {
    case success
    case information
    case failure

    /// The icon name for each notification type.
    var iconName: String {
        switch self {
        case .success:
            "checkmark.circle.fill"
        case .information:
            "info.circle.fill"
        case .failure:
            "xmark.circle.fill"
        }
    }

    /// The color for each notification type using the project's design system.
    var color: Color {
        switch self {
        case .success:
            .success
        case .information:
            .primary
        case .failure:
            .error
        }
    }

    /// The default title for each notification type.
    var defaultTitle: String {
        switch self {
        case .success:
            "Success"
        case .information:
            "Information"
        case .failure:
            "Error"
        }
    }
}

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
    let onDismiss: () -> Void

    @State private var isVisible: Bool = false

    init(
        type: NotificationType,
        title: String? = nil,
        message: String,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.type = type
        self.title = title ?? type.defaultTitle
        self.message = message
        self.onDismiss = onDismiss
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.iconName)
                .foregroundStyle(type.color)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .textStyle(.subheadlineBold, color: .textPrimary)

                Text(message)
                    .textStyle(.caption1, color: .textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: {
                withAnimation(.easeOut(duration: 0.2)) {
                    isVisible = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onDismiss()
                }
            }) {
                Image(systemName: "xmark")
                    .textStyle(.caption1, color: .textSecondary)
            }
        }
        .padding()
        .background(Color.surfaceSecondary)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .padding(.top, 8)
        .offset(y: isVisible ? 0 : -100)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}

/// View modifier that adds notification banner support to any view.
struct NotificationBannerModifier: ViewModifier {
    @Binding var isPresented: Bool
    let type: NotificationType
    let title: String?
    let message: String
    let duration: TimeInterval
    let onDismiss: () -> Void

    @State private var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        ZStack {
            content

            VStack {
                if isPresented {
                    NotificationBanner(
                        type: type,
                        title: title,
                        message: message,
                        onDismiss: {
                            isPresented = false
                            onDismiss()
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))

                    Spacer()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isPresented)
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    scheduleDismiss()
                } else {
                    dismissTask?.cancel()
                }
            }
        }
    }

    private func scheduleDismiss() {
        dismissTask?.cancel()

        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation {
                        isPresented = false
                    }
                }

                // Call onDismiss after animation completes
                try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
                if !Task.isCancelled {
                    await MainActor.run {
                        onDismiss()
                    }
                }
            }
        }
    }
}

extension View {
    /// Adds a notification banner to the view that appears at the top.
    ///
    /// - Parameters:
    ///   - isPresented: Binding to control banner visibility.
    ///   - type: The type of notification (success, information, failure).
    ///   - title: Optional custom title. Uses default title for type if nil.
    ///   - message: The message to display in the banner.
    ///   - duration: Time before auto-dismiss in seconds. Default is 5.
    ///   - onDismiss: Closure called when banner is dismissed.
    /// - Returns: A view with the notification banner overlay.
    func notificationBanner(
        isPresented: Binding<Bool>,
        type: NotificationType,
        title: String? = nil,
        message: String,
        duration: TimeInterval = 5,
        onDismiss: @escaping () -> Void = {}
    ) -> some View {
        modifier(NotificationBannerModifier(
            isPresented: isPresented,
            type: type,
            title: title,
            message: message,
            duration: duration,
            onDismiss: onDismiss
        ))
    }
}

// MARK: - Preview

#Preview("Success") {
    NotificationBanner(
        type: .success,
        message: "5 new wallets discovered successfully!"
    )
}

#Preview("Information") {
    NotificationBanner(
        type: .information,
        title: "Discovery in Progress",
        message: "Scanning for new wallet addresses..."
    )
}

#Preview("Failure") {
    NotificationBanner(
        type: .failure,
        message: "Failed to connect to Hyperliquid API. Please try again."
    )
}

#Preview("With Dismiss") {
    NotificationBanner(
        type: .success,
        message: "Tap the X to dismiss",
        onDismiss: {
            print("Banner dismissed")
        }
    )
}
