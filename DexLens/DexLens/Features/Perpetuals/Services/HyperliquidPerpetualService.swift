import Foundation

// MARK: - Mock Data Structures

/// Mock position data structure for Perpetuals view
private struct MockPosition {
    let address: String
    let coin: String
    let size: Double
    let side: String
    let value: Double
}

/// Mock data for Perpetuals view demonstration
private enum MockPositions {
    static let positions: [MockPosition] = [
        // Large positions > 50 BTC
        MockPosition(address: "0x1234...", coin: "BTC", size: 65.5, side: "long", value: 2_670_000),
        MockPosition(address: "0x5678...", coin: "BTC", size: 52.3, side: "short", value: 2_145_000),
        MockPosition(address: "0x9abc...", coin: "BTC", size: 58.9, side: "long", value: 2_419_000),

        // Medium positions 20-50 BTC
        MockPosition(address: "0xdef0...", coin: "BTC", size: 35.2, side: "short", value: 1_446_400),
        MockPosition(address: "0x1234...", coin: "BTC", size: 28.7, side: "long", value: 1_179_700),
        MockPosition(address: "0x5678...", coin: "BTC", size: 42.1, side: "short", value: 1_728_100),
        MockPosition(address: "0x9abc...", coin: "BTC", size: 31.8, side: "long", value: 1_305_400),
        MockPosition(address: "0xdef0...", coin: "BTC", size: 24.5, side: "short", value: 1_006_450),

        // Small-medium positions 10-20 BTC
        MockPosition(address: "0x1234...", coin: "BTC", size: 15.3, side: "long", value: 628_300),
        MockPosition(address: "0x5678...", coin: "BTC", size: 18.7, side: "short", value: 767_700),
        MockPosition(address: "0x9abc...", coin: "BTC", size: 12.4, side: "long", value: 508_800),
        MockPosition(address: "0xdef0...", coin: "BTC", size: 16.8, side: "short", value: 689_400),
        MockPosition(address: "0x1234...", coin: "BTC", size: 14.2, side: "long", value: 582_200),
        MockPosition(address: "0x5678...", coin: "BTC", size: 19.1, side: "short", value: 783_100),

        // Small positions 5-10 BTC
        MockPosition(address: "0x9abc...", coin: "BTC", size: 7.8, side: "long", value: 319_800),
        MockPosition(address: "0xdef0...", coin: "BTC", size: 9.2, side: "short", value: 377_200),
        MockPosition(address: "0x1234...", coin: "BTC", size: 6.4, side: "long", value: 262_400),
        MockPosition(address: "0x5678...", coin: "BTC", size: 8.7, side: "short", value: 356_700),
        MockPosition(address: "0x9abc...", coin: "BTC", size: 5.6, side: "long", value: 229_600),

        // Very small positions < 5 BTC
        MockPosition(address: "0xdef0...", coin: "BTC", size: 3.2, side: "short", value: 131_200),
        MockPosition(address: "0x1234...", coin: "BTC", size: 4.5, side: "long", value: 184_500),
        MockPosition(address: "0x5678...", coin: "BTC", size: 2.1, side: "short", value: 86100),
        MockPosition(address: "0x9abc...", coin: "BTC", size: 3.8, side: "long", value: 155_800),
        MockPosition(address: "0xdef0...", coin: "BTC", size: 4.2, side: "short", value: 172_200),
        MockPosition(address: "0x1234...", coin: "BTC", size: 1.5, side: "long", value: 61500),
        MockPosition(address: "0x5678...", coin: "BTC", size: 2.8, side: "short", value: 114_800),
    ]
}

// MARK: - Service Implementation

/// Service for fetching perpetuals position distribution
///
/// Note: Currently uses mock data for demonstration
/// TODO: Replace with real GMX data aggregation when implementing full Perpetuals feature
final class HyperliquidPerpetualService: ServiceProtocol, PerpetualServiceProtocol {
    let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchPositionDistribution() async throws -> [PositionSizeBucket] {
        // Use mock data for demonstration
        // In future: Aggregate from GMX positions
        createBuckets(from: MockPositions.positions)
    }

    private func createBuckets(from positions: [MockPosition]) -> [PositionSizeBucket] {
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
