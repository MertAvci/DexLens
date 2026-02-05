import CoreData
import Foundation

/// Protocol defining the contract for wallet data access and persistence.
///
/// This protocol abstracts CoreData operations for wallet entities, providing
/// a clean interface for the service layer while enabling easy testing through mocks.
///
/// Note: Marked as @MainActor because CoreData operations must occur on the main thread.
@MainActor
protocol WalletRepository {
    /// Fetches all wallets from the persistent store.
    /// - Returns: An array of all WalletEntity objects.
    func fetchAllWallets() async throws -> [WalletEntity]

    /// Fetches a wallet by its address.
    /// - Parameter address: The wallet address to search for.
    /// - Returns: The WalletEntity if found, nil otherwise.
    func fetchWallet(byAddress address: String) async throws -> WalletEntity?

    /// Checks if a wallet with the given address exists.
    /// - Parameter address: The wallet address to check.
    /// - Returns: True if the wallet exists, false otherwise.
    func walletExists(address: String) async throws -> Bool

    /// Creates a new wallet entity.
    /// - Parameter address: The wallet address.
    /// - Returns: The newly created WalletEntity.
    @discardableResult
    func createWallet(address: String) async throws -> WalletEntity

    /// Creates multiple wallets in a batch operation.
    /// - Parameter addresses: Array of wallet addresses to create.
    /// - Returns: The number of wallets successfully created.
    func createWallets(addresses: [String]) async throws -> Int

    /// Updates a wallet's category.
    /// - Parameters:
    ///   - address: The wallet address to update.
    ///   - category: The new category (Fibonacci bucket).
    func updateWalletCategory(address: String, category: String) async throws

    /// Updates a wallet's category and last position check timestamp.
    /// - Parameters:
    ///   - address: The wallet address to update.
    ///   - category: The new category (Fibonacci bucket).
    ///   - lastPositionCheck: The timestamp of the last position check.
    /// - Returns: The updated WalletEntity.
    func updateWalletCategory(address: String, category: String, lastPositionCheck: Date) async throws -> WalletEntity

    /// Updates a wallet's last seen timestamp.
    /// - Parameter address: The wallet address to update.
    func updateWalletLastSeen(address: String) async throws

    /// Updates a wallet's last position check timestamp.
    /// - Parameter address: The wallet address to update.
    func updateWalletLastPositionCheck(address: String) async throws

    /// Deletes a wallet by its address.
    /// - Parameter address: The wallet address to delete.
    func deleteWallet(address: String) async throws

    /// Deletes wallets that have no open positions and haven't been seen recently.
    /// - Parameter days: Number of days of inactivity before deletion.
    /// - Returns: The number of wallets deleted.
    func deleteInactiveWallets(olderThanDays days: Int) async throws -> Int

    /// Fetches wallets filtered by category.
    /// - Parameter category: The category to filter by.
    /// - Returns: An array of WalletEntity objects in the category.
    func fetchWalletsByCategory(_ category: String) async throws -> [WalletEntity]

    /// Returns the total count of wallets.
    /// - Returns: The number of wallets in the store.
    func getWalletCount() async throws -> Int

    // MARK: - Advanced Queries with Enums

    /// Fetches wallets filtered by size category and position side
    /// - Parameters:
    ///   - category: The wallet size category (micro, small, medium, large, whale, megaWhale)
    ///   - side: The position side (long, short)
    ///   - coin: Optional coin filter (e.g., "BTC", "ETH"). Pass nil for all coins.
    /// - Returns: Array of matching WalletEntity objects
    func fetchWalletsByCategory(
        _ category: WalletSizeCategory,
        side: PositionSide,
        coin: String?
    ) async throws -> [WalletEntity]

    /// Gets count of wallets by size category and side
    /// - Parameters:
    ///   - category: The wallet size category
    ///   - side: The position side
    ///   - coin: Optional coin filter
    /// - Returns: Count of matching wallets
    func getWalletCountByCategory(
        _ category: WalletSizeCategory,
        side: PositionSide,
        coin: String?
    ) async throws -> Int

    /// Gets statistics for all size categories
    /// - Parameter coin: Optional coin filter (e.g., "BTC"). Pass nil for all coins.
    /// - Returns: Dictionary mapping [Category: [Side: Count]]
    func getWalletStatistics(coin: String?) async throws -> [WalletSizeCategory: [PositionSide: Int]]
}

/// Concrete implementation of WalletRepository using CoreData.
///
/// This class handles all CoreData operations for wallet entities, including
/// CRUD operations, batch processing, and relationship management.
///
/// Marked as @MainActor because CoreData is inherently main-thread only.
@MainActor
final class WalletRepositoryImpl: WalletRepository {
    private let persistenceController: PersistenceController

    /// Initializes the repository with a persistence controller.
    /// - Parameter persistenceController: The controller managing CoreData stack.
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    func fetchAllWallets() async throws -> [WalletEntity] {
        let context = persistenceController.viewContext
        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "lastSeen", ascending: false)]

        return try context.fetch(request)
    }

    func fetchWallet(byAddress address: String) async throws -> WalletEntity? {
        let context = persistenceController.viewContext
        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSPredicate(format: "walletAddress == %@", address)
        request.fetchLimit = 1

        return try context.fetch(request).first
    }

    func walletExists(address: String) async throws -> Bool {
        let wallet = try await fetchWallet(byAddress: address)
        return wallet != nil
    }

    func createWallet(address: String) async throws -> WalletEntity {
        let context = persistenceController.viewContext

        let wallet = WalletEntity(context: context)
        wallet.walletAddress = address
        wallet.firstSeen = Date()
        wallet.lastSeen = Date()

        try context.save()
        return wallet
    }

    func createWallets(addresses: [String]) async throws -> Int {
        let context = persistenceController.viewContext
        var createdCount = 0

        for address in addresses {
            // Check if wallet already exists
            let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
            request.predicate = NSPredicate(format: "walletAddress == %@", address)
            request.fetchLimit = 1

            let existingCount = try context.count(for: request)
            guard existingCount == 0 else { continue }

            let wallet = WalletEntity(context: context)
            wallet.walletAddress = address
            wallet.firstSeen = Date()
            wallet.lastSeen = Date()
            createdCount += 1
        }

        if context.hasChanges {
            try context.save()
        }

        return createdCount
    }

    func updateWalletCategory(address: String, category: String) async throws {
        let context = persistenceController.viewContext

        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSPredicate(format: "walletAddress == %@", address)
        request.fetchLimit = 1

        if let wallet = try context.fetch(request).first {
            wallet.category = category
            try context.save()
        }
    }

    func updateWalletCategory(address: String, category: String, lastPositionCheck: Date) async throws -> WalletEntity {
        let context = persistenceController.viewContext

        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSPredicate(format: "walletAddress == %@", address)
        request.fetchLimit = 1

        guard let wallet = try context.fetch(request).first else {
            throw NetworkError.invalidResponse
        }

        wallet.category = category
        wallet.lastPositionCheck = lastPositionCheck
        wallet.lastSeen = Date()

        try context.save()
        return wallet
    }

    func updateWalletLastSeen(address: String) async throws {
        let context = persistenceController.viewContext

        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSPredicate(format: "walletAddress == %@", address)
        request.fetchLimit = 1

        if let wallet = try context.fetch(request).first {
            wallet.lastSeen = Date()
            try context.save()
        }
    }

    func updateWalletLastPositionCheck(address: String) async throws {
        let context = persistenceController.viewContext

        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSPredicate(format: "walletAddress == %@", address)
        request.fetchLimit = 1

        if let wallet = try context.fetch(request).first {
            wallet.lastPositionCheck = Date()
            try context.save()
        }
    }

    func deleteWallet(address: String) async throws {
        let context = persistenceController.viewContext

        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSPredicate(format: "walletAddress == %@", address)

        let wallets = try context.fetch(request)
        for wallet in wallets {
            context.delete(wallet)
        }

        if context.hasChanges {
            try context.save()
        }
    }

    func deleteInactiveWallets(olderThanDays days: Int) async throws -> Int {
        let context = persistenceController.viewContext
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSPredicate(format: "lastSeen < %@", cutoffDate as NSDate)

        let wallets = try context.fetch(request)
        let deletedCount = wallets.count

        for wallet in wallets {
            context.delete(wallet)
        }

        if context.hasChanges {
            try context.save()
        }

        return deletedCount
    }

    func fetchWalletsByCategory(_ category: String) async throws -> [WalletEntity] {
        let context = persistenceController.viewContext
        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(key: "lastSeen", ascending: false)]

        return try context.fetch(request)
    }

    func getWalletCount() async throws -> Int {
        let context = persistenceController.viewContext
        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()

        return try context.count(for: request)
    }

    // MARK: - Advanced Queries with Enums

    func fetchWalletsByCategory(
        _ category: WalletSizeCategory,
        side: PositionSide,
        coin: String?
    ) async throws -> [WalletEntity] {
        let context = persistenceController.viewContext

        // Build predicates
        var predicates: [NSPredicate] = [
            NSPredicate(format: "category == %@", category.rawValue),
        ]

        // Add side filter (skip for neutral)
        if side != .neutral {
            predicates.append(
                NSPredicate(format: "ANY positions.side == %@", side.rawValue)
            )
        }

        // Add coin filter if specified
        if let coin {
            predicates.append(
                NSPredicate(format: "ANY positions.coin == %@", coin)
            )
        }

        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "lastSeen", ascending: false)]

        return try context.fetch(request)
    }

    func getWalletCountByCategory(
        _ category: WalletSizeCategory,
        side: PositionSide,
        coin: String?
    ) async throws -> Int {
        let wallets = try await fetchWalletsByCategory(category, side: side, coin: coin)
        return wallets.count
    }

    func getWalletStatistics(coin: String?) async throws -> [WalletSizeCategory: [PositionSide: Int]] {
        var statistics: [WalletSizeCategory: [PositionSide: Int]] = [:]

        for category in WalletSizeCategory.allCases {
            var sideCounts: [PositionSide: Int] = [:]

            // Only count long and short (skip neutral)
            for side in [PositionSide.long, .short] {
                let count = try await getWalletCountByCategory(category, side: side, coin: coin)
                sideCounts[side] = count
            }

            statistics[category] = sideCounts
        }

        return statistics
    }
}
