import Foundation

/// Notification name for wallet discovery events
extension Notification.Name {
    static let walletsDiscovered = Notification.Name("walletsDiscovered")
}

/// Protocol defining the contract for wallet discovery operations
///
/// This service handles the discovery of new wallets from GMX API,
/// batch processing, and persistence of discovered wallets
protocol WalletDiscoveryServiceProtocol {
    /// The maximum number of wallets to process in a single batch
    var batchSize: Int { get }

    /// Initiates wallet discovery from all available sources
    ///
    /// Combines GMX positions, liquidations, and seed list to discover wallets
    /// Newly discovered wallets are automatically classified
    ///
    /// - Returns: The number of new wallets discovered and classified
    func discoverWalletsCombined() async -> Int

    /// Loads wallet addresses from the static seed list
    ///
    /// - Returns: Array of wallet addresses from Resources/WalletSeeds.json
    func loadSeedWallets() async -> [String]

    /// Processes a batch of wallet addresses, filtering duplicates and saving new ones
    /// - Parameter addresses: Array of wallet addresses to process
    /// - Returns: The number of new wallets saved
    func processBatch(addresses: [String]) async -> Int

    /// Checks if a wallet address already exists in the database
    /// - Parameter address: The wallet address to check
    /// - Returns: True if the wallet exists
    func walletExists(address: String) async -> Bool
}

/// Implementation of WalletDiscoveryService using GMX Subsquid GraphQL API
///
/// This service discovers wallets using a combined approach:
/// 1. Primary: GMX open positions (all active wallets)
/// 2. Secondary: Static seed list (fallback)
///
/// Note: positionLiquidations endpoint is not available on Arbitrum Subsquid.
/// Liquidation detection (Option B) will be implemented in the future.
///
/// All discovered wallets are automatically classified and stored in CoreData
final class WalletDiscoveryService: WalletDiscoveryServiceProtocol {
    let batchSize: Int = 20

    private let apiClient: NetworkClientProtocol
    private let repository: WalletRepository
    private let classificationService: WalletClassificationServiceProtocol
    private let gmxService: GMXDiscoveryServiceProtocol

    /// Initializes the discovery service with required dependencies
    /// - Parameters:
    ///   - apiClient: The API client for network requests
    ///   - repository: The repository for wallet persistence
    ///   - classificationService: The service for classifying discovered wallets
    ///   - gmxService: The GMX discovery service
    init(
        apiClient: NetworkClientProtocol,
        repository: WalletRepository,
        classificationService: WalletClassificationServiceProtocol,
        gmxService: GMXDiscoveryServiceProtocol
    ) {
        self.apiClient = apiClient
        self.repository = repository
        self.classificationService = classificationService
        self.gmxService = gmxService
    }

    // MARK: - Combined Discovery

    func discoverWalletsCombined() async -> Int {
        var allAddresses: Set<String> = []

        // 1. Fetch from GMX positions (primary source - all open positions)
        let positionAddresses = await gmxService.discoverWalletsFromPositions()
        allAddresses.formUnion(positionAddresses)
        print("✅ WalletDiscovery: Found \(positionAddresses.count) wallets from GMX positions")

        // 2. Load from seed list (secondary source)
        // Note: positionLiquidations endpoint not available on Arbitrum Subsquid
        // Option B: Implement liquidation detection by caching positions over time
        let seedAddresses = await loadSeedWallets()
        allAddresses.formUnion(seedAddresses)
        print("✅ WalletDiscovery: Found \(seedAddresses.count) wallets from seed list")

        // 4. Process all unique addresses
        let uniqueAddresses = Array(allAddresses)
        print("📊 WalletDiscovery: Processing \(uniqueAddresses.count) total unique addresses")

        let newWalletCount = await processBatch(addresses: uniqueAddresses)

        // 5. Classify newly discovered wallets immediately
        if newWalletCount > 0 {
            print("🎯 WalletDiscovery: Classifying \(newWalletCount) new wallets...")

            let classifiedCount = await classificationService.classifyWalletsBatch(
                addresses: uniqueAddresses,
                gmxService: gmxService
            )

            // Notify UI of discovered and classified wallets
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .walletsDiscovered,
                    object: ["discovered": newWalletCount, "classified": classifiedCount]
                )
            }

            print("✅ WalletDiscovery: Complete - \(newWalletCount) discovered, \(classifiedCount) classified")
        } else {
            print("ℹ️ WalletDiscovery: No new wallets discovered")
        }

        return newWalletCount
    }

    // MARK: - Seed Wallets

    func loadSeedWallets() async -> [String] {
        // Load from bundle
        guard let url = Bundle.main.url(forResource: "WalletSeeds", withExtension: "json") else {
            print("⚠️ WalletDiscovery: WalletSeeds.json not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let seedData = try decoder.decode(WalletSeedData.self, from: data)
            return seedData.wallets
        } catch {
            print("❌ WalletDiscovery: Failed to load seed wallets - \(error)")
            return []
        }
    }

    // MARK: - Batch Processing

    func processBatch(addresses: [String]) async -> Int {
        // Remove duplicates from the batch itself
        let uniqueAddresses = Array(Set(addresses))

        // Process in batches
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
                    print("✅ WalletDiscovery: Batch created \(created) wallets")
                } catch {
                    print("❌ WalletDiscovery: Batch creation failed - \(error)")
                }
                currentBatch.removeAll()
            }
        }

        // Process remaining wallets in the last batch
        if !currentBatch.isEmpty {
            do {
                let created = try await repository.createWallets(addresses: currentBatch)
                totalCreated += created
                print("✅ WalletDiscovery: Final batch created \(created) wallets")
            } catch {
                print("❌ WalletDiscovery: Final batch creation failed - \(error)")
            }
        }

        return totalCreated
    }

    func walletExists(address: String) async -> Bool {
        do {
            return try await repository.walletExists(address: address)
        } catch {
            // On error, assume wallet doesn't exist to allow retry
            print("⚠️ CoreDataWallet: wallet deos not exist - \(error)")
            return false
        }
    }
}

// MARK: - Supporting Types

/// Data structure for WalletSeeds.json file
struct WalletSeedData: Codable {
    let wallets: [String]
}
