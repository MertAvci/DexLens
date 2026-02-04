import Foundation

enum HyperliquidEndpoint: Endpoint {
    case meta
    case fundingRate

    var baseURL: URL {
        URL(string: "https://api.hyperliquid.xyz")!
    }

    var path: String {
        "/info"
    }

    var method: HTTPMethod {
        .post
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var parameters: [String: Any]? {
        switch self {
        case .meta:
            ["type": "meta"]
        case .fundingRate:
            ["type": "meta"] // Will be refined based on actual endpoint needs
        }
    }
}
