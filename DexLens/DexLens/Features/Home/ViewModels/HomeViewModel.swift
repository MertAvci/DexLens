import Combine
import Foundation

@MainActor
final class HomeViewModel: HomeViewModelProtocol, ObservableObject {
    @Published var coins: [Coin] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    var lastRefreshTime: Date = .distantPast

    private let service: HomeServiceProtocol
    private let cache = ImageCache.shared
    private let minimumRefreshInterval: TimeInterval = 10
    private let debounceSpinnerDuration: TimeInterval = 3

    init(service: HomeServiceProtocol) {
        self.service = service
        // loadFromCache()
    }

    func fetchTopCoins() async {
        let now = Date()

        if now.timeIntervalSince(lastRefreshTime) < minimumRefreshInterval {
            isLoading = true
            try? await Task.sleep(nanoseconds: UInt64(debounceSpinnerDuration * 1_000_000_000))
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            coins = try await service.fetchTopCoins(limit: 20)
            lastRefreshTime = now
            saveToCache()
            await loadAllCoinImages()
        } catch {
            if !coins.isEmpty {
                // TODO: return stored coins.
            } else {
                handleError(error)
            }
        }

        isLoading = false
    }

    func loadAllCoinImages() async {
        await withTaskGroup(of: Void.self) { group in
            for index in coins.indices {
                group.addTask { [weak self] in
                    await self?.loadCoinImage(at: index)
                }
            }
        }
    }

    private func loadCoinImage(at index: Int) async {
        let coinId = coins[index].id

        if let cachedURL = cache.get(imageURL: coinId) {
            coins[index].imageURL = cachedURL
            return
        }

        coins[index].isImageLoading = true

        do {
            let imageURL = try await service.fetchCoinImage(for: coinId)
            cache.set(imageURL: imageURL, for: coinId)
            coins[index].imageURL = imageURL
        } catch {}

        coins[index].isImageLoading = false
    }

    private func saveToCache() {}

    private func loadFromCache() {}
}
