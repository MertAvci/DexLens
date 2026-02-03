import Foundation

/// Defines the contract for making network requests.
///
/// This protocol enables easy mocking and testing by providing a
/// generic fetch method that returns decoded data from any endpoint.
protocol APIClientProtocol {
    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T
}

/// Concrete implementation of `APIClientProtocol` using URLSession.
///
/// This client handles all network operations including:
/// - URL request construction from Endpoints
/// - Response validation (status code checks)
/// - JSON decoding using Swift's Codable protocol
/// - Error handling with NetworkError types
///
/// Example:
/// ```swift
/// let client = APIClient()
/// let data: MyModel = try await client.fetch(endpoint: MyEndpoint())
/// ```
final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }

    /// Fetches and decodes data from the specified endpoint.
    ///
    /// - Parameter endpoint: The endpoint to fetch data from.
    /// - Returns: Decoded data of type `T`.
    /// - Throws: `NetworkError` if the request fails, response is invalid,
    ///           or decoding fails.
    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T {
        guard let request = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}
