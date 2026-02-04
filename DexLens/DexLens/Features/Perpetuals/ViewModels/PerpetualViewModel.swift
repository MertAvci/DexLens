import Combine
import Foundation

@MainActor
final class PerpetualViewModel: PerpetualViewModelProtocol, ObservableObject {
    @Published var positionBuckets: [PositionSizeBucket] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    var lastRefreshTime: Date = .distantPast

    private let service: PerpetualServiceProtocol
    private let minimumRefreshInterval: TimeInterval = 30 // 30 seconds
    private let debounceSpinnerDuration: TimeInterval = 1

    init(service: PerpetualServiceProtocol) {
        self.service = service
    }

    func fetchPositionDistribution() async {
        let now = Date()

        // Prevent too frequent refreshes
        if now.timeIntervalSince(lastRefreshTime) < minimumRefreshInterval {
            isLoading = true
            try? await Task.sleep(nanoseconds: UInt64(debounceSpinnerDuration * 1_000_000_000))
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            positionBuckets = try await service.fetchPositionDistribution()
            lastRefreshTime = now
        } catch {
            if !positionBuckets.isEmpty {
                // Keep existing data and show error notification
            } else {
                handleError(error)
            }
        }

        isLoading = false
    }
}
