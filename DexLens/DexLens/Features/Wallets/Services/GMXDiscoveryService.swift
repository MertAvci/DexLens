import Foundation

/// Protocol defining the contract for GMX discovery operations
///
/// Note: positionLiquidations endpoint is not available on Arbitrum Subsquid deployment.
/// This service currently only supports discovering wallets from open positions.
/// Future Option B: Implement liquidation detection by caching and comparing positions over time.
protocol GMXDiscoveryServiceProtocol {
    /// The API client for making network requests
    var apiClient: NetworkClientProtocol { get }

    /// Fetches all open positions from GMX
    /// - Parameter minSizeUsd: Optional minimum position size in USD (nil = no filter)
    /// - Returns: Array of GMX positions
    func fetchPositions(minSizeUsd: Double?) async throws -> [GMXPosition]

    /// Discovers wallet addresses from open positions
    /// - Returns: Array of unique wallet addresses
    func discoverWalletsFromPositions() async -> [String]
}

/// Implementation of GMX discovery service using GMX Subsquid GraphQL API
///
/// This service discovers wallets by querying GMX positions.
/// Uses GraphQL endpoint: https://gmx.squids.live/gmx-synthetics-arbitrum:prod/api/graphql
///
/// Note: Liquidation detection (Option B) will be implemented in the future by:
/// 1. Caching positions between API calls
/// 2. Comparing current positions to cached positions
/// 3. Detecting positions that disappeared or have sizeInUsd = 0
final class GMXDiscoveryService: GMXDiscoveryServiceProtocol {
    let apiClient: NetworkClientProtocol

    /// Rate limiting: minimum interval between requests (1 second)
    private let minRequestInterval: TimeInterval = 1.0
    private var lastRequestTime: Date?

    /// Initializes the discovery service with required dependencies
    /// - Parameter apiClient: The API client for network requests
    init(apiClient: NetworkClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - Fetch Methods

    func fetchPositions(minSizeUsd: Double?) async throws -> [GMXPosition] {
        await throttleRequest()

        let endpoint = GMXEndpoint.positions(minSizeUsd: minSizeUsd)

        do {
            let response: GMXGraphQLResponse<GMXPositionsResponse> = try await apiClient.fetch(endpoint: endpoint)

            // Check for GraphQL errors
            if let errors = response.errors, !errors.isEmpty {
                let errorMessages = errors.map(\.message).joined(separator: ", ")
                print("❌ GMXDiscoveryService: GraphQL errors - \(errorMessages)")
                throw NetworkError.invalidResponse
            }

            // Handle null data
            guard let data = response.data else {
                print("⚠️ GMXDiscoveryService: No data returned from positions query")
                return []
            }

            return data.positions
        } catch {
            print("❌ GMXDiscoveryService: Failed to fetch positions - \(error)")
            throw error
        }
    }

    // MARK: - Discovery Methods

    func discoverWalletsFromPositions() async -> [String] {
        do {
            let positions = try await fetchPositions(minSizeUsd: nil)
            let addresses = positions.map(\.account)
            let uniqueAddresses = Array(Set(addresses))
            print("✅ GMXDiscoveryService: Discovered \(uniqueAddresses.count) wallets from positions")
            return uniqueAddresses
        } catch {
            print("⚠️ GMXDiscoveryService: Position discovery failed, returning empty array")
            return []
        }
    }

    // MARK: - Helper Methods

    /// Throttles requests to comply with rate limits (< 1 req/sec)
    private func throttleRequest() async {
        if let lastRequest = lastRequestTime {
            let timeSinceLastRequest = Date().timeIntervalSince(lastRequest)
            if timeSinceLastRequest < minRequestInterval {
                let waitTime = minRequestInterval - timeSinceLastRequest
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }
}
