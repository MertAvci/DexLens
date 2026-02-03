import SwiftUI

enum TextStyle {
    case largeTitle
    case title1
    case title2
    case title3
    case headline
    case body
    case bodyBold
    case callout
    case subheadline
    case subheadlineBold
    case footnote
    case footnoteBold
    case caption1
    case caption2
}

enum ColorStyle {
    case primary
    case primaryMuted
    case success
    case error
    case warning
    case textPrimary
    case textSecondary
    case white
}

private struct TextStyleModifier: ViewModifier {
    let style: TextStyle
    let color: ColorStyle
    
    func body(content: Content) -> some View {
        content
            .font(font(for: style))
            .foregroundStyle(color(for: color))
    }
    
    private func font(for style: TextStyle) -> Font {
        switch style {
        case .largeTitle:
            return Font.custom("Roboto-Bold", size: 34)
        case .title1:
            return Font.custom("Roboto-Bold", size: 28)
        case .title2:
            return Font.custom("Roboto-Bold", size: 22)
        case .title3:
            return Font.custom("Roboto-Medium", size: 20)
        case .headline:
            return Font.custom("Roboto-Medium", size: 17)
        case .body:
            return Font.custom("Roboto-Regular", size: 17)
        case .bodyBold:
            return Font.custom("Roboto-Bold", size: 17)
        case .callout:
            return Font.custom("Roboto-Regular", size: 16)
        case .subheadline:
            return Font.custom("Roboto-Regular", size: 15)
        case .subheadlineBold:
            return Font.custom("Roboto-Medium", size: 15)
        case .footnote:
            return Font.custom("Roboto-Regular", size: 13)
        case .footnoteBold:
            return Font.custom("Roboto-Medium", size: 13)
        case .caption1:
            return Font.custom("Roboto-Regular", size: 12)
        case .caption2:
            return Font.custom("Roboto-Regular", size: 11)
        }
    }
    
    private func color(for style: ColorStyle) -> Color {
        switch style {
        case .primary:
            return Color("dsPrimary")
        case .primaryMuted:
            return Color("dsPrimaryMuted")
        case .success:
            return Color("dsSuccess")
        case .error:
            return Color("dsError")
        case .warning:
            return Color("dsWarning")
        case .textPrimary:
            return Color("dsTextPrimary")
        case .textSecondary:
            return Color("dsTextSecondary")
        case .white:
            return .white
        }
    }
}

extension View {
    func textStyle(_ style: TextStyle, color: ColorStyle) -> some View {
        modifier(TextStyleModifier(style: style, color: color))
    }
}
