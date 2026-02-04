import Foundation

enum CoinpaprikaEndpoint: Endpoint {
    case tickers
    case coinById(String)

    var baseURL: URL {
        URL(string: "https://api.coinpaprika.com/v1")!
    }

    var path: String {
        switch self {
        case .tickers: "/tickers"
        case let .coinById(id): "/coins/\(id)"
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
        case .tickers: ["quotes": "USD"]
        case .coinById: nil
        }
    }
}
