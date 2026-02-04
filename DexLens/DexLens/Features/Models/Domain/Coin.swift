import Foundation

struct Coin: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let rank: Int
    let price: Double
    let marketCap: Double
    let volume24h: Double
    let priceChange24h: Double
    let marketCapChange24h: Double
    let athPrice: Double?
    let athDate: String?
    let lastUpdated: String
    var imageURL: URL? = nil
    var isImageLoading: Bool = false
    
    var formattedPrice: String {
            "$" + price.formatted(
                .number.precision(.fractionLength(2))
            )
        }
}
