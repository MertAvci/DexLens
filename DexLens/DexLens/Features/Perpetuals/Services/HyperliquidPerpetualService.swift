import Foundation

final class HyperliquidPerpetualService: ServiceProtocol, PerpetualServiceProtocol {
    let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchPositionDistribution() async throws -> [PositionSizeBucket] {
        // Since Hyperliquid doesn't provide direct position distribution endpoint,
        // we'll use mock data that simulates realistic distribution
        // In a real implementation, you might:
        // 1. Use the meta endpoint to get available assets
        // 2. Aggregate position data from multiple sources
        // 3. Calculate buckets from raw position data

        let positions = MockPositionData.mockPositions

        // Create buckets based on BTC size
        return createBuckets(from: positions)
    }

    private func createBuckets(from positions: [MockHyperliquidPosition]) -> [PositionSizeBucket] {
        // Define bucket ranges
        let buckets = [
            (minSize: 50.0, maxSize: Double.infinity, tier: "> 50 BTC"),
            (minSize: 20.0, maxSize: 50.0, tier: "20-50 BTC"),
            (minSize: 10.0, maxSize: 20.0, tier: "10-20 BTC"),
            (minSize: 5.0, maxSize: 10.0, tier: "5-10 BTC"),
            (minSize: 0.0, maxSize: 5.0, tier: "< 5 BTC"),
        ]

        return buckets.map { bucket in
            let bucketPositions = positions.filter { position in
                position.size >= bucket.minSize && position.size < bucket.maxSize
            }

            let longPositions = bucketPositions.filter { $0.side == "long" }
            let shortPositions = bucketPositions.filter { $0.side == "short" }

            let longCount = longPositions.count
            let shortCount = shortPositions.count
            let longValue = longPositions.reduce(0) { $0 + $1.value }
            let shortValue = shortPositions.reduce(0) { $0 + $1.value }
            let totalAddresses = Set(bucketPositions.map(\.address)).count

            return PositionSizeBucket(
                tier: bucket.tier,
                minSize: bucket.minSize,
                maxSize: bucket.maxSize == Double.infinity ? nil : bucket.maxSize,
                longCount: longCount,
                shortCount: shortCount,
                longValue: longValue,
                shortValue: shortValue,
                totalAddresses: totalAddresses
            )
        }
    }
}
