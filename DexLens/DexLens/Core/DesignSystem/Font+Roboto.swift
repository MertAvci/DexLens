import SwiftUI

extension Font {
    
    static func roboto(_ size: CGFloat, weight: RobotoWeight = .regular) -> Font {
        return Font.custom(weight.fontName, size: size)
    }
}

enum RobotoWeight {
    case thin
    case light
    case regular
    case medium
    case bold
    case black
    
    var fontName: String {
        switch self {
        case .thin:
            return "Roboto-Thin"
        case .light:
            return "Roboto-Light"
        case .regular:
            return "Roboto-Regular"
        case .medium:
            return "Roboto-Medium"
        case .bold:
            return "Roboto-Bold"
        case .black:
            return "Roboto-Black"
        }
    }
}
