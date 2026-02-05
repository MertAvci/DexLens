import Foundation

/// Protocol defining the contract for wallet classification operations.
///
/// This service handles the classification of wallets based on their
/// position exposure in USD, assigning them to USD-based buckets.
///
/// Marked as @MainActor because it returns CoreData entities (WalletEntity).
@MainActor
protocol WalletClassificationServiceProtocol {
    /// The API client for making network requests
    nonisolated var apiClient: APIClientProtocol { get }

    /// The repository for wallet persistence operations
    var repository: WalletRepository { get }

    /// Classifies a wallet by fetching its positions from GMX
    ///
    /// - Parameters:
    ///   - address: The wallet address to classify
    ///   - gmxService: GMX discovery service to fetch positions
    /// - Returns: The updated WalletEntity with classification data, or nil if failed
    func classifyWallet(address: String, gmxService: GMXDiscoveryServiceProtocol) async -> WalletEntity?

    /// Classifies multiple wallets in batch
    ///
    /// - Parameters:
    ///   - addresses: Array of wallet addresses to classify
    ///   - gmxService: GMX discovery service to fetch positions
    /// - Returns: Number of wallets successfully classified
    func classifyWalletsBatch(addresses: [String], gmxService: GMXDiscoveryServiceProtocol) async -> Int

    /// Assigns a USD-based bucket category based on exposure
    ///
    /// Buckets:
    /// - 0: <$1,000 (Micro retail)
    /// - 1: $1,000 - $10,000 (Small retail)
    /// - 2: $10,000 - $100,000 (Retail)
    /// - 3: $100,000 - $1,000,000 (Trader)
    /// - 4: $1,000,000 - $10,000,000 (Whale)
    /// - 5: $10,000,000+ (Mega whale)
    ///
    /// - Parameter exposureUsd: The USD exposure value
    /// - Returns: Category string ("0" through "5")
    nonisolated func classifyExposureUsd(_ exposureUsd: Double) -> String

    /// Determines if wallet is long or short based on GMX positions
    ///
    /// - Parameter positions: Array of GMX positions for the wallet
    /// - Returns: "long" if majority long, "short" if majority short, "neutral" if equal
    nonisolated func determineSide(positions: [GMXPosition]) -> String
}

/// Implementation of WalletClassificationService using GMX data
///
/// This service fetches wallet positions from GMX API,
/// calculates total USD exposure, assigns USD bucket categories,
/// and persists the classification data to CoreData.
///
/// ## USD Classification Buckets
///
/// - 0: <$1,000 (Micro retail)
/// - 1: $1,000 - $10,000 (Small retail)
/// - 2: $10,000 - $100,000 (Retail)
/// - 3: $100,000 - $1,000,000 (Trader)
/// - 4: $1,000,000 - $10,000,000 (Whale)
/// - 5: $10,000,000+ (Mega whale)
///
/// ## Side Classification
/// Uses GMX isLong field directly (true = long, false = short)
///
/// Marked as @MainActor because it works with CoreData entities (WalletEntity).
@MainActor
final class WalletClassificationService: WalletClassificationServiceProtocol {
    let apiClient: APIClientProtocol
    let repository: WalletRepository

    /// Initializes the classification service with required dependencies
    /// - Parameters:
    ///   - apiClient: The API client for network requests
    ///   - repository: The repository for wallet persistence
    init(apiClient: APIClientProtocol, repository: WalletRepository) {
        self.apiClient = apiClient
        self.repository = repository
    }

    // MARK: - Classification

    func classifyWallet(address: String, gmxService: GMXDiscoveryServiceProtocol) async -> WalletEntity? {
        do {
            // Fetch all positions for this wallet from GMX
            let allPositions = try await gmxService.fetchPositions(minSizeUsd: nil)

            // Filter positions for this specific wallet
            let walletPositions = allPositions.filter { $0.account.lowercased() == address.lowercased() }

            guard !walletPositions.isEmpty else {
                // No positions found - wallet might be inactive
                print("⚠️ ClassificationService: No positions found for wallet \(address)")
                return nil
            }

            // Calculate total USD exposure
            let totalExposureUsd = walletPositions.reduce(0) { $0 + $1.sizeInUsdDouble }

            // Assign USD category
            let category = classifyExposureUsd(totalExposureUsd)

            // Determine if mostly long or short
            let side = determineSide(positions: walletPositions)

            // Update wallet in CoreData with classification data
            let updatedWallet = try await repository.updateWalletCategory(
                address: address,
                category: category,
                lastPositionCheck: Date()
            )

            // Optionally store side information in a separate field or metadata
            // For now, we just log it
            print(
                """
                ✅ ClassificationService: Wallet \(address) classified as category \(category), \
                side: \(side), exposure: $\(totalExposureUsd)
                """
            )

            return updatedWallet
        } catch {
            print("❌ ClassificationService: Failed to classify wallet \(address) - \(error)")
            return nil
        }
    }

    func classifyWalletsBatch(addresses: [String], gmxService: GMXDiscoveryServiceProtocol) async -> Int {
        var successfullyClassified = 0

        for address in addresses {
            let result = await classifyWallet(address: address, gmxService: gmxService)
            if result != nil {
                successfullyClassified += 1
            }
        }

        print(
            """
            ✅ ClassificationService: Batch classification complete \
            - \(successfullyClassified)/\(addresses.count) wallets classified
            """
        )
        return successfullyClassified
    }

    // MARK: - USD Category Assignment

    func classifyExposureUsd(_ exposureUsd: Double) -> String {
        switch exposureUsd {
        case 0 ..< 1000:
            "0" // <$1K: Micro retail
        case 1000 ..< 10000:
            "1" // $1K-$10K: Small retail
        case 10000 ..< 100_000:
            "2" // $10K-$100K: Retail
        case 100_000 ..< 1_000_000:
            "3" // $100K-$1M: Trader
        case 1_000_000 ..< 10_000_000:
            "4" // $1M-$10M: Whale
        default:
            "5" // $10M+: Mega whale
        }
    }

    // MARK: - Side Classification

    func determineSide(positions: [GMXPosition]) -> String {
        let longCount = positions.filter(\.isLong).count
        let shortCount = positions.filter { !$0.isLong }.count

        if longCount > shortCount {
            return "long"
        } else if shortCount > longCount {
            return "short"
        } else {
            return "neutral"
        }
    }
}
