import Foundation

final class HomeService: ServiceProtocol, HomeServiceProtocol {
    let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchTopCoins(limit: Int = 20) async throws -> [Coin] {
        let response: [CoinpaprikaTickerResponse] = try await apiClient.fetch(endpoint: CoinpaprikaEndpoint.tickers)
        
        let filtered = response.filter { $0.quotes["USD"] != nil }
        let sorted = filtered.sorted { $0.quotes["USD"]!.marketCap > $1.quotes["USD"]!.marketCap }
        let topCoins = Array(sorted.prefix(limit))
        
        return topCoins.map { mapToDomain($0) }
    }
    
    func fetchCoinImage(for coinId: String) async throws -> URL {
        let response: CoinpaprikaCoinDetailResponse = try await apiClient.fetch(endpoint: CoinpaprikaEndpoint.coinById(coinId))
        guard let url = URL(string: response.logo) else {
            throw NetworkError.invalidURL
        }
        return url
    }
    
    private func mapToDomain(_ response: CoinpaprikaTickerResponse) -> Coin {
        guard let usdQuote = response.quotes["USD"] else {
            fatalError("USD quote not found")
        }
        return Coin(
            id: response.id,
            name: response.name,
            symbol: response.symbol,
            rank: response.rank,
            price: usdQuote.price,
            marketCap: usdQuote.marketCap,
            volume24h: usdQuote.volume24h,
            priceChange24h: usdQuote.percentChange24h,
            marketCapChange24h: usdQuote.marketCapChange24h,
            athPrice: usdQuote.athPrice,
            athDate: usdQuote.athDate,
            lastUpdated: response.lastUpdated
        )
    }
}

enum FiatCurrency: String {
    case usd = "USD"
    
    var signatur: String {
        switch self {
        case .usd:
            return "$"
        }
    }
}
