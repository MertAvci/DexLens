import Foundation

/// Represents wallet size categories based on USD exposure
///
/// Categories follow a logarithmic scale to capture the wide range of position sizes
/// in cryptocurrency trading, from retail traders to institutional whales.
///
/// ## Categories
/// - micro: <$1,000 (Micro retail)
/// - small: $1,000 - $10,000 (Small retail)
/// - medium: $10,000 - $100,000 (Retail)
/// - large: $100,000 - $1,000,000 (Trader)
/// - whale: $1,000,000 - $10,000,000 (Whale)
/// - megaWhale: $10,000,000+ (Mega whale)
///
/// ## Usage
/// ```swift
/// let category = WalletSizeCategory.small
/// print(category.displayName) // "Small ($1K-$10K)"
/// print(category.rawValue) // "1"
/// ```
enum WalletSizeCategory: String, CaseIterable {
    case micro = "0"
    case small = "1"
    case medium = "2"
    case large = "3"
    case whale = "4"
    case megaWhale = "5"

    /// Minimum USD value for this category
    var minUsd: Double {
        switch self {
        case .micro:
            0
        case .small:
            1000
        case .medium:
            10000
        case .large:
            100_000
        case .whale:
            1_000_000
        case .megaWhale:
            10_000_000
        }
    }

    /// Maximum USD value for this category (nil for unlimited)
    var maxUsd: Double? {
        switch self {
        case .micro:
            1000
        case .small:
            10000
        case .medium:
            100_000
        case .large:
            1_000_000
        case .whale:
            10_000_000
        case .megaWhale:
            nil
        }
    }

    /// Human-readable display name with USD range
    var displayName: String {
        switch self {
        case .micro:
            "Micro (<$1K)"
        case .small:
            "Small ($1K-$10K)"
        case .medium:
            "Medium ($10K-$100K)"
        case .large:
            "Large ($100K-$1M)"
        case .whale:
            "Whale ($1M-$10M)"
        case .megaWhale:
            "Mega Whale ($10M+)"
        }
    }

    /// Short display name without USD range
    var shortName: String {
        switch self {
        case .micro:
            "Micro"
        case .small:
            "Small"
        case .medium:
            "Medium"
        case .large:
            "Large"
        case .whale:
            "Whale"
        case .megaWhale:
            "Mega Whale"
        }
    }

    /// Icon name for UI representation
    var iconName: String {
        switch self {
        case .micro:
            "person"
        case .small:
            "person.2"
        case .medium:
            "person.3"
        case .large:
            "building.columns"
        case .whale:
            "water.waves"
        case .megaWhale:
            "crown"
        }
    }

    /// Color identifier for UI (can be mapped to actual colors in View)
    var colorIdentifier: String {
        switch self {
        case .micro:
            "gray"
        case .small:
            "blue"
        case .medium:
            "green"
        case .large:
            "orange"
        case .whale:
            "purple"
        case .megaWhale:
            "red"
        }
    }

    /// Initialize from a USD value, returns the appropriate category
    /// - Parameter usdValue: The USD exposure value
    /// - Returns: The corresponding WalletSizeCategory
    static func fromUsd(_ usdValue: Double) -> WalletSizeCategory {
        for category in WalletSizeCategory.allCases.reversed() {
            if usdValue >= category.minUsd {
                return category
            }
        }
        return .micro
    }

    /// Initialize from the stored CoreData category string
    /// - Parameter rawValue: The category string ("0" through "5")
    /// - Returns: The corresponding WalletSizeCategory, defaults to .micro if invalid
    static func fromRawValue(_ rawValue: String) -> WalletSizeCategory {
        WalletSizeCategory(rawValue: rawValue) ?? .micro
    }
}

// MARK: - Comparable

extension WalletSizeCategory: Comparable {
    static func < (lhs: WalletSizeCategory, rhs: WalletSizeCategory) -> Bool {
        lhs.minUsd < rhs.minUsd
    }
}

// MARK: - CustomStringConvertible

extension WalletSizeCategory: CustomStringConvertible {
    var description: String {
        displayName
    }
}
