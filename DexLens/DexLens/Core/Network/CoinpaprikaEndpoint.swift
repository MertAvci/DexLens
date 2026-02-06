import Foundation

enum CoinpaprikaEndpoint: Endpoint {

    case tickers(fiat: FiatCurrency)
    case coinById(String)

    var baseURL: URL {
        URL(string: "https://api.coinpaprika.com/v1")!
    }

    var path: String {
        switch self {
        case .tickers:
            return "/tickers"

        case let .coinById(id):
            return "/coins/\(id)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var headers: [String: String]? {
        nil
    }

    var parameters: [String: Any]? {
        switch self {
        case let .tickers(fiat):
            return [
                "quotes": fiat.rawValue
            ]

        case .coinById:
            return nil
        }
    }
}
