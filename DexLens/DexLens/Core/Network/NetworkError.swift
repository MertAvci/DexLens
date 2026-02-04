import Foundation

/// Represents network-related errors that can occur during API requests.
///
/// This enum provides type-safe error handling for all network operations
/// and conforms to `LocalizedError` for user-friendly error messages.
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .invalidResponse:
            "Invalid response"
        case let .serverError(statusCode):
            "Server error with status code: \(statusCode)"
        case let .decodingError(error):
            "Failed to decode response: \(error.localizedDescription)"
        case let .networkError(error):
            "Network error: \(error.localizedDescription)"
        }
    }
}
