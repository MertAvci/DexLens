import Foundation

/// Defines the contract for making network requests.
///
/// This protocol enables easy mocking and testing by providing a
/// generic fetch method that returns decoded data from any endpoint.
protocol NetworkClientProtocol {
    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T
}

/// Concrete implementation of `NetworkClientProtocol` using `URLSession`.
///
/// Responsibilities:
/// - Executes network requests created by `Endpoint`
/// - Validates HTTP responses
/// - Decodes responses using `Codable`
/// - Maps errors into `NetworkError`
///
/// `Endpoint` is responsible for:
/// - URL construction
/// - HTTP method
/// - Headers & authentication
/// - Query / body encoding
final class NetworkClient: NetworkClientProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = .init()
    ) {
        self.session = session
        self.decoder = decoder
    }

    /// Fetches and decodes data from the specified endpoint.
    ///
    /// - Parameter endpoint: The endpoint to fetch data from.
    /// - Returns: Decoded data of type `T`.
    /// - Throws: `NetworkError` on failure.
    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T {
        guard let request = endpoint.urlRequest else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await session.data(for: request)

            try validate(response)

            #if DEBUG
            log(request: request, response: response, data: data)
            #endif

            return try decoder.decode(T.self, from: data)
        }
        catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        }
        catch let error as NetworkError {
            throw error
        }
        catch {
            throw NetworkError.networkError(error)
        }
    }
}

// MARK: - Response Validation

private extension NetworkClient {

    func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - Debug Logging

#if DEBUG
private extension NetworkClient {

    func log(
        request: URLRequest,
        response: URLResponse,
        data: Data
    ) {
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "NO URL"

        print("""
        ⬆️ \(method) \(url)
        Headers: \(request.allHTTPHeaderFields ?? [:])
        """)

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("⬇️ Status: \(httpResponse.statusCode)")
        }

        if let responseString = String(data: data, encoding: .utf8) {
            print("Response: \(responseString)")
        }
    }
}
#endif

