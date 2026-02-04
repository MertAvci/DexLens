import Foundation

protocol HomeServiceProtocol: ServiceProtocol {
    func fetchTopCoins(limit: Int) async throws -> [Coin]
    func fetchCoinImage(for coinId: String) async throws -> URL
}
