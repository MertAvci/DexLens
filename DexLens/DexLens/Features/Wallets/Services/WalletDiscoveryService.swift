import Foundation

/// Notification name for wallet discovery events.
extension Notification.Name {
    static let walletsDiscovered = Notification.Name("walletsDiscovered")
}

/// Protocol defining the contract for wallet discovery operations.
///
/// This service handles the discovery of new wallets from Hyperliquid API,
/// batch processing, and persistence of discovered wallets.
protocol WalletDiscoveryServiceProtocol {
    /// The maximum number of wallets to process in a single batch.
    var batchSize: Int { get }

    /// Initiates wallet discovery from recent trades.
    /// - Parameter coins: Array of coin symbols to query (e.g., ["BTC", "ETH"]).
    /// - Returns: The number of new wallets discovered.
    func discoverWallets(fromCoins coins: [String]) async -> Int

    /// Fetches recent trades for a specific coin.
    /// - Parameter coin: The coin symbol (e.g., "BTC").
    /// - Returns: Array of wallet addresses extracted from trades.
    func fetchRecentTrades(coin: String) async throws -> [String]

    /// Processes a batch of wallet addresses, filtering duplicates and saving new ones.
    /// - Parameter addresses: Array of wallet addresses to process.
    /// - Returns: The number of new wallets saved.
    func processBatch(addresses: [String]) async -> Int

    /// Checks if a wallet address already exists in the database.
    /// - Parameter address: The wallet address to check.
    /// - Returns: True if the wallet exists.
    func walletExists(address: String) async -> Bool
}

/// Implementation of WalletDiscoveryService using Hyperliquid API.
///
/// This service discovers wallets by querying recent trades from the Hyperliquid API,
/// extracts wallet addresses, and persists new wallets to CoreData in batches.
/// All errors are silently handled - only success counts are reported via notifications.
final class WalletDiscoveryService: WalletDiscoveryServiceProtocol {
    let batchSize: Int = 20

    private let apiClient: APIClientProtocol
    private let repository: WalletRepository
    private let coins: [String] = ["BTC", "ETH", "SOL", "ARB", "OP"] // Default coins to monitor

    /// Initializes the discovery service with required dependencies.
    /// - Parameters:
    ///   - apiClient: The API client for network requests.
    ///   - repository: The repository for wallet persistence.
    init(apiClient: APIClientProtocol, repository: WalletRepository) {
        self.apiClient = apiClient
        self.repository = repository
    }

    func discoverWallets(fromCoins coins: [String] = []) async -> Int {
        let targetCoins = coins.isEmpty ? self.coins : coins
        var totalDiscovered = 0

        for coin in targetCoins {
            do {
                let addresses = try await fetchRecentTrades(coin: coin)
                let newWallets = await processBatch(addresses: addresses)
                totalDiscovered += newWallets
            } catch {
                // Silently continue - errors are not shown to user
                continue
            }
        }

        // Notify UI of discovered wallets
        if totalDiscovered > 0 {
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .walletsDiscovered,
                    object: totalDiscovered
                )
            }
        }

        return totalDiscovered
    }

    func fetchRecentTrades(coin _: String) async throws -> [String] {
        // For now, return empty array - implement actual API call in next iteration
        // This prevents compilation errors while we set up the structure
        []
    }

    func processBatch(addresses: [String]) async -> Int {
        // Remove duplicates from the batch itself
        let uniqueAddresses = Array(Set(addresses))

        // Process in batches of 20
        var totalCreated = 0
        var currentBatch: [String] = []

        for address in uniqueAddresses {
            // Check if wallet already exists
            let exists = await walletExists(address: address)
            guard !exists else { continue }

            currentBatch.append(address)

            // Process batch when it reaches batchSize
            if currentBatch.count >= batchSize {
                do {
                    let created = try await repository.createWallets(addresses: currentBatch)
                    totalCreated += created
                } catch {
                    // Silently continue on error
                }
                currentBatch.removeAll()
            }
        }

        // Process remaining wallets in the last batch
        if !currentBatch.isEmpty {
            do {
                let created = try await repository.createWallets(addresses: currentBatch)
                totalCreated += created
            } catch {
                // Silently continue on error
            }
        }

        return totalCreated
    }

    func walletExists(address: String) async -> Bool {
        do {
            return try await repository.walletExists(address: address)
        } catch {
            // On error, assume wallet doesn't exist to allow retry
            return false
        }
    }
}

/// Response model for Hyperliquid recent trades API.
struct HyperliquidRecentTradesResponse: Decodable {
    let trades: [HyperliquidTrade]
}

/// Individual trade data from Hyperliquid.
struct HyperliquidTrade: Decodable {
    let user: String
    let coin: String
    let side: String
    let size: String
    let price: String
    let time: Int
}
