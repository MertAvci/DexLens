import Foundation

// MARK: - Hyperliquid Response Models

struct HyperliquidMetaResponse: Codable {
    let universe: [HyperliquidAsset]
    let price: [String: Double]
    let fundingRates: [String: HyperliquidFundingRate]
}

struct HyperliquidAsset: Codable {
    let name: String
    let szDecimals: Int
    let maxLeverage: Int
    let onlyIsolated: Bool
}

struct HyperliquidFundingRate: Codable {
    let rate: String
    let lastTime: String
}

/// Mock position data for calculating buckets
struct MockHyperliquidPosition {
    let address: String
    let coin: String
    let size: Double // BTC size
    let side: String // "long" or "short"
    let value: Double // USD value
}

/// Since we don't have access to real position distribution data,
/// we'll create mock data that simulates realistic distribution
enum MockPositionData {
    static let mockPositions: [MockHyperliquidPosition] = [
        // Large positions > 50 BTC
        MockHyperliquidPosition(address: "0x1234...", coin: "BTC", size: 65.5, side: "long", value: 2_670_000),
        MockHyperliquidPosition(address: "0x5678...", coin: "BTC", size: 52.3, side: "short", value: 2_145_000),
        MockHyperliquidPosition(address: "0x9abc...", coin: "BTC", size: 58.9, side: "long", value: 2_419_000),

        // Medium positions 20-50 BTC
        MockHyperliquidPosition(address: "0xdef0...", coin: "BTC", size: 35.2, side: "short", value: 1_446_400),
        MockHyperliquidPosition(address: "0x1234...", coin: "BTC", size: 28.7, side: "long", value: 1_179_700),
        MockHyperliquidPosition(address: "0x5678...", coin: "BTC", size: 42.1, side: "short", value: 1_728_100),
        MockHyperliquidPosition(address: "0x9abc...", coin: "BTC", size: 31.8, side: "long", value: 1_305_400),
        MockHyperliquidPosition(address: "0xdef0...", coin: "BTC", size: 24.5, side: "short", value: 1_006_450),

        // Small-medium positions 10-20 BTC
        MockHyperliquidPosition(address: "0x1234...", coin: "BTC", size: 15.3, side: "long", value: 628_300),
        MockHyperliquidPosition(address: "0x5678...", coin: "BTC", size: 18.7, side: "short", value: 767_700),
        MockHyperliquidPosition(address: "0x9abc...", coin: "BTC", size: 12.4, side: "long", value: 508_800),
        MockHyperliquidPosition(address: "0xdef0...", coin: "BTC", size: 16.8, side: "short", value: 689_400),
        MockHyperliquidPosition(address: "0x1234...", coin: "BTC", size: 14.2, side: "long", value: 582_200),
        MockHyperliquidPosition(address: "0x5678...", coin: "BTC", size: 19.1, side: "short", value: 783_100),

        // Small positions 5-10 BTC
        MockHyperliquidPosition(address: "0x9abc...", coin: "BTC", size: 7.8, side: "long", value: 319_800),
        MockHyperliquidPosition(address: "0xdef0...", coin: "BTC", size: 9.2, side: "short", value: 377_200),
        MockHyperliquidPosition(address: "0x1234...", coin: "BTC", size: 6.4, side: "long", value: 262_400),
        MockHyperliquidPosition(address: "0x5678...", coin: "BTC", size: 8.7, side: "short", value: 356_700),
        MockHyperliquidPosition(address: "0x9abc...", coin: "BTC", size: 5.6, side: "long", value: 229_600),

        // Very small positions < 5 BTC
        MockHyperliquidPosition(address: "0xdef0...", coin: "BTC", size: 3.2, side: "short", value: 131_200),
        MockHyperliquidPosition(address: "0x1234...", coin: "BTC", size: 4.5, side: "long", value: 184_500),
        MockHyperliquidPosition(address: "0x5678...", coin: "BTC", size: 2.1, side: "short", value: 86100),
        MockHyperliquidPosition(address: "0x9abc...", coin: "BTC", size: 3.8, side: "long", value: 155_800),
        MockHyperliquidPosition(address: "0xdef0...", coin: "BTC", size: 4.2, side: "short", value: 172_200),
        MockHyperliquidPosition(address: "0x1234...", coin: "BTC", size: 1.5, side: "long", value: 61500),
        MockHyperliquidPosition(address: "0x5678...", coin: "BTC", size: 2.8, side: "short", value: 114_800),
    ]
}
