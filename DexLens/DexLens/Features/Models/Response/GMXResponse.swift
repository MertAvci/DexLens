import Foundation

// MARK: - GMX Position Models

/// Represents an open position on GMX
struct GMXPosition: Codable {
    let account: String
    let isLong: Bool
    let sizeInUsd: String
    let market: String

    /// Computed property to get size as Double
    var sizeInUsdDouble: Double {
        Double(sizeInUsd) ?? 0
    }
}

/// Response wrapper for positions query
struct GMXPositionsResponse: Codable {
    let positions: [GMXPosition]
}

// MARK: - GMX Liquidation Models

/// Represents a liquidated position on GMX
struct GMXLiquidation: Codable {
    let account: String
    let isLong: Bool
    let sizeInUsd: String
    let market: String
    let timestamp: Int

    /// Computed property to get size as Double
    var sizeInUsdDouble: Double {
        Double(sizeInUsd) ?? 0
    }

    /// Computed property to get Date from timestamp
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}

/// Response wrapper for liquidations query
struct GMXLiquidationsResponse: Codable {
    let positionLiquidations: [GMXLiquidation]
}

// MARK: - GraphQL Response Wrapper

/// GraphQL error structure
struct GraphQLError: Codable {
    let message: String
    let path: [String]?
}

/// Generic wrapper for GraphQL responses
struct GMXGraphQLResponse<T: Codable>: Codable {
    let data: T?
    let errors: [GraphQLError]?
}

// MARK: - Wallet Classification Models

/// Represents a discovered wallet with position data
struct GMXWalletData {
    let address: String
    let isLong: Bool
    let sizeInUsd: Double
    let market: String
    let timestamp: Date?

    init(from position: GMXPosition) {
        address = position.account
        isLong = position.isLong
        sizeInUsd = position.sizeInUsdDouble
        market = position.market
        timestamp = nil
    }

    init(from liquidation: GMXLiquidation) {
        address = liquidation.account
        isLong = liquidation.isLong
        sizeInUsd = liquidation.sizeInUsdDouble
        market = liquidation.market
        timestamp = liquidation.date
    }
}
