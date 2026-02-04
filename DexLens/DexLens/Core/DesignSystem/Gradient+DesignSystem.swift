import SwiftUI

extension LinearGradient {
    static var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color("dsPrimaryMuted"), Color("dsPrimary")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var successGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.success.opacity(0.8), .surface]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var deepOceanGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.primary, .surface]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func deepOceanGradient(opacity: Double = 1.0) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.primary.opacity(opacity), .surface.opacity(opacity)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
