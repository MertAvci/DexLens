import Foundation

protocol PerpetualServiceProtocol: ServiceProtocol {
    func fetchPositionDistribution() async throws -> [PositionSizeBucket]
}
