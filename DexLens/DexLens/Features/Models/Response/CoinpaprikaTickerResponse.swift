import Foundation

struct CoinpaprikaTickerResponse: Codable {
    let id: String
    let name: String
    let symbol: String
    let rank: Int
    let quotes: [String: Quote]
    let lastUpdated: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case rank
        case quotes
        case lastUpdated = "last_updated"
    }
}

struct Quote: Codable {
    let price: Double
    let marketCap: Double
    let volume24h: Double
    let marketCapChange24h: Double
    let percentChange24h: Double
    let athPrice: Double?
    let athDate: String?

    enum CodingKeys: String, CodingKey {
        case price
        case marketCap = "market_cap"
        case volume24h = "volume_24h"
        case marketCapChange24h = "market_cap_change_24h"
        case percentChange24h = "percent_change_24h"
        case athPrice = "ath_price"
        case athDate = "ath_date"
    }
}
