import SwiftUI

struct Typography {
    
    private init() {}
    
    static let largeTitle = Font.roboto(34, weight: .bold)
    static let title1 = Font.roboto(28, weight: .bold)
    static let title2 = Font.roboto(22, weight: .bold)
    static let title3 = Font.roboto(20, weight: .medium)
    
    static let headline = Font.roboto(17, weight: .medium)
    static let body = Font.roboto(17, weight: .regular)
    static let bodyBold = Font.roboto(17, weight: .bold)
    static let callout = Font.roboto(16, weight: .regular)
    
    static let subheadline = Font.roboto(15, weight: .regular)
    static let subheadlineBold = Font.roboto(15, weight: .medium)
    
    static let footnote = Font.roboto(13, weight: .regular)
    static let footnoteBold = Font.roboto(13, weight: .medium)
    
    static let caption1 = Font.roboto(12, weight: .regular)
    static let caption2 = Font.roboto(11, weight: .regular)
}
