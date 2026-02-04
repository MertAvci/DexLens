import SwiftUI

extension Font {
    static func roboto(_ size: CGFloat, weight: RobotoWeight = .regular) -> Font {
        Font.custom(weight.fontName, size: size)
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
            "Roboto-Thin"
        case .light:
            "Roboto-Light"
        case .regular:
            "Roboto-Regular"
        case .medium:
            "Roboto-Medium"
        case .bold:
            "Roboto-Bold"
        case .black:
            "Roboto-Black"
        }
    }
}
