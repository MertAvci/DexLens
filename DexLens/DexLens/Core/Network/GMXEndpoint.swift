import Foundation

/// GMX GraphQL API Endpoint for Arbitrum
///
/// This endpoint queries the GMX Subsquid indexer for position data.
/// Note: positionLiquidations endpoint is not available on Arbitrum Subsquid deployment.
/// Liquidations must be detected by comparing positions over time (see Option B for future implementation).
///
/// Endpoint: https://gmx.squids.live/gmx-synthetics-arbitrum:prod/api/graphql
enum GMXEndpoint: Endpoint {
    case positions(minSizeUsd: Double?)

    var baseURL: URL {
        URL(string: "https://gmx.squids.live/gmx-synthetics-arbitrum:prod/api/graphql")!
    }

    var path: String {
        "" // GraphQL uses single endpoint
    }

    var method: HTTPMethod {
        .post
    }

    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
        ]
    }

    var parameters: [String: Any]? {
        switch self {
        case let .positions(minSizeUsd):
            [
                "query": buildPositionsQuery(minSizeUsd: minSizeUsd),
            ]
        }
    }

    // MARK: - GraphQL Query Builders

    private func buildPositionsQuery(minSizeUsd: Double?) -> String {
        let sizeFilter = minSizeUsd != nil ? "sizeInUsd_gt: \"\(minSizeUsd!)\"" : "sizeInUsd_gt: \"0\""

        return """
        query {
            positions(where: { \(sizeFilter) }, limit: 1000) {
                account
                isLong
                sizeInUsd
                market
            }
        }
        """
    }
}
