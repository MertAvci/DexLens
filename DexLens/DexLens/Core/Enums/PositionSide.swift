import Foundation

/// Represents the side of a position (long or short)
///
/// In trading, a long position profits when the asset price increases,
/// while a short position profits when the asset price decreases.
///
/// ## Usage
/// ```swift
/// let side = PositionSide.long
/// print(side.displayName) // "Long"
/// print(side.icon) // "arrow.up"
/// ```
enum PositionSide: String, CaseIterable {
    case long
    case short
    case neutral

    /// Human-readable display name
    var displayName: String {
        rawValue.capitalized
    }

    /// SF Symbol icon name for UI representation
    var icon: String {
        switch self {
        case .long:
            "arrow.up"
        case .short:
            "arrow.down"
        case .neutral:
            "minus"
        }
    }

    /// Color identifier for UI (can be mapped to actual colors in View)
    var colorIdentifier: String {
        switch self {
        case .long:
            "green"
        case .short:
            "red"
        case .neutral:
            "gray"
        }
    }

    /// Returns the opposite side
    var opposite: PositionSide {
        switch self {
        case .long:
            .short
        case .short:
            .long
        case .neutral:
            .neutral
        }
    }

    /// Returns true if this side represents a bullish sentiment
    var isBullish: Bool {
        self == .long
    }

    /// Returns true if this side represents a bearish sentiment
    var isBearish: Bool {
        self == .short
    }

    /// Initialize from a boolean value (true = long, false = short)
    /// - Parameter isLong: true for long, false for short
    /// - Returns: The corresponding PositionSide
    static func from(isLong: Bool) -> PositionSide {
        isLong ? .long : .short
    }

    /// Initialize from GMX isLong boolean
    /// - Parameter isLong: The isLong value from GMX API
    /// - Returns: .long if true, .short if false
    static func fromGmx(isLong: Bool) -> PositionSide {
        isLong ? .long : .short
    }
}

// MARK: - CustomStringConvertible

extension PositionSide: CustomStringConvertible {
    var description: String {
        displayName
    }
}

// MARK: - Comparable for sorting

extension PositionSide: Comparable {
    private var sortOrder: Int {
        switch self {
        case .long:
            0
        case .neutral:
            1
        case .short:
            2
        }
    }

    static func < (lhs: PositionSide, rhs: PositionSide) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}
