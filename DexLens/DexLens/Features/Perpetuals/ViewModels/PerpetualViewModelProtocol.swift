import Combine
import Foundation

@MainActor
protocol PerpetualViewModelProtocol: ViewModelProtocol {
    var positionBuckets: [PositionSizeBucket] { get }
    func fetchPositionDistribution() async
}
