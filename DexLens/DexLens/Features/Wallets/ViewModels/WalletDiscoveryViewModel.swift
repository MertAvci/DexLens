import Combine
import Foundation

/// ViewModel for wallet discovery functionality.
///
/// This ViewModel manages the UI state for wallet discovery, including:
/// - Tracking discovery status (idle, discovering, completed)
/// - Managing the list of discovered wallets
/// - Handling banner notifications for discovered wallet counts
@MainActor
final class WalletDiscoveryViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The current list of discovered wallets.
    @Published var wallets: [WalletEntity] = []

    /// Whether discovery is currently in progress.
    @Published var isDiscovering: Bool = false

    /// The number of wallets discovered in the last discovery session.
    @Published var lastDiscoveredCount: Int = 0

    /// Whether to show the discovery notification banner.
    @Published var showDiscoveryBanner: Bool = false

    /// The total count of wallets in the database.
    @Published var totalWalletCount: Int = 0

    // MARK: - Private Properties

    private let discoveryService: WalletDiscoveryServiceProtocol
    private let repository: WalletRepository
    private var bannerDismissTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// Initializes the ViewModel with required dependencies.
    /// - Parameters:
    ///   - discoveryService: The service for wallet discovery operations.
    ///   - repository: The repository for wallet data access.
    init(
        discoveryService: WalletDiscoveryServiceProtocol,
        repository: WalletRepository
    ) {
        self.discoveryService = discoveryService
        self.repository = repository

        setupNotificationObserver()
    }

    // MARK: - Public Methods

    /// Initiates wallet discovery from recent trades.
    ///
    /// This method starts the discovery process and updates the UI state
    /// accordingly. Discovery runs in the background and doesn't block the UI.
    func startDiscovery() {
        guard !isDiscovering else { return }

        isDiscovering = true

        Task {
            let discovered = await discoveryService.discoverWallets(fromCoins: [])

            self.lastDiscoveredCount = discovered
            self.isDiscovering = false

            if discovered > 0 {
                self.showDiscoveryBanner = true
                self.scheduleBannerDismiss()
            }

            // Refresh the wallet list
            await self.loadWallets()
        }
    }

    /// Loads all wallets from the repository.
    ///
    /// This method fetches the current list of wallets and updates the UI.
    func loadWallets() async {
        do {
            let fetchedWallets = try await repository.fetchAllWallets()
            let count = try await repository.getWalletCount()

            await MainActor.run {
                self.wallets = fetchedWallets
                self.totalWalletCount = count
            }
        } catch {
            // Silently handle errors
        }
    }

    /// Dismisses the discovery banner immediately.
    func dismissBanner() {
        bannerDismissTask?.cancel()
        showDiscoveryBanner = false
    }

    /// Refreshes the wallet list and count.
    ///
    /// This method can be called to manually refresh the data,
    /// for example on pull-to-refresh.
    func refresh() async {
        await loadWallets()
    }

    // MARK: - Private Methods

    private func setupNotificationObserver() {
        NotificationCenter.default.publisher(for: .walletsDiscovered)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let count = notification.object as? Int else { return }

                self?.lastDiscoveredCount = count
                self?.showDiscoveryBanner = true
                self?.scheduleBannerDismiss()

                // Refresh wallet list
                Task {
                    await self?.loadWallets()
                }
            }
            .store(in: &cancellables)
    }

    private func scheduleBannerDismiss() {
        bannerDismissTask?.cancel()

        bannerDismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000) // 5 seconds

            if !Task.isCancelled {
                self.showDiscoveryBanner = false
            }
        }
    }
}
