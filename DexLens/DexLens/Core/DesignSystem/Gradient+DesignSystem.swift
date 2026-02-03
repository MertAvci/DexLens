import SwiftUI

extension LinearGradient {
    static var primaryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#06B6D4"), Color(hex: "#0891B2")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var successGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#10B981"), Color(hex: "#059669")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var deepOceanGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#06B6D4"), Color(hex: "#0C4A6E")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func deepOceanGradient(opacity: Double = 1.0) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#06B6D4").opacity(opacity), Color(hex: "#0C4A6E").opacity(opacity)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
