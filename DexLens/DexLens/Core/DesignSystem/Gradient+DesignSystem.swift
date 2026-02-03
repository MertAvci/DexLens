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
            gradient: Gradient(colors: [Color("dsSuccess").opacity(0.8), Color("dsSuccess")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var deepOceanGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color("dsPrimary"), Color("dsSurface")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func deepOceanGradient(opacity: Double = 1.0) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color("dsPrimary").opacity(opacity), Color("dsSurface").opacity(opacity)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
