import Foundation

struct PositionSizeBucket: Identifiable {
    let id = UUID()
    let tier: String
    let minSize: Double
    let maxSize: Double?
    let longCount: Int
    let shortCount: Int
    let longValue: Double
    let shortValue: Double
    let totalAddresses: Int

    /// Computed properties
    var totalCount: Int {
        longCount + shortCount
    }

    var totalValue: Double {
        longValue + shortValue
    }

    var longPercentage: Double {
        totalCount > 0 ? Double(longCount) / Double(totalCount) * 100 : 0
    }

    var shortPercentage: Double {
        totalCount > 0 ? Double(shortCount) / Double(totalCount) * 100 : 0
    }

    var formattedLongValue: String {
        "$" + longValue.formatted(.number.precision(.fractionLength(0)))
    }

    var formattedShortValue: String {
        "$" + shortValue.formatted(.number.precision(.fractionLength(0)))
    }

    var formattedTotalValue: String {
        "$" + totalValue.formatted(.number.precision(.fractionLength(0)))
    }
}
