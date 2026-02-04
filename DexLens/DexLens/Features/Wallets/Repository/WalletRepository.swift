import CoreData
import Foundation

/// Protocol defining the contract for wallet data access and persistence.
///
/// This protocol abstracts CoreData operations for wallet entities, providing
/// a clean interface for the service layer while enabling easy testing through mocks.
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
}

/// Concrete implementation of WalletRepository using CoreData.
///
/// This class handles all CoreData operations for wallet entities, including
/// CRUD operations, batch processing, and relationship management.
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

        return try await context.perform {
            try context.fetch(request)
        }
    }

    func fetchWallet(byAddress address: String) async throws -> WalletEntity? {
        let context = persistenceController.viewContext
        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSPredicate(format: "walletAddress == %@", address)
        request.fetchLimit = 1

        return try await context.perform {
            try context.fetch(request).first
        }
    }

    func walletExists(address: String) async throws -> Bool {
        let wallet = try await fetchWallet(byAddress: address)
        return wallet != nil
    }

    func createWallet(address: String) async throws -> WalletEntity {
        let context = persistenceController.viewContext

        return try await context.perform {
            let wallet = WalletEntity(context: context)
            wallet.walletAddress = address
            wallet.firstSeen = Date()
            wallet.lastSeen = Date()

            try context.save()
            return wallet
        }
    }

    func createWallets(addresses: [String]) async throws -> Int {
        let context = persistenceController.viewContext
        var createdCount = 0

        try await context.perform {
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
        }

        return createdCount
    }

    func updateWalletCategory(address: String, category: String) async throws {
        let context = persistenceController.viewContext

        try await context.perform {
            let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
            request.predicate = NSPredicate(format: "walletAddress == %@", address)
            request.fetchLimit = 1

            if let wallet = try context.fetch(request).first {
                wallet.category = category
                try context.save()
            }
        }
    }

    func updateWalletLastSeen(address: String) async throws {
        let context = persistenceController.viewContext

        try await context.perform {
            let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
            request.predicate = NSPredicate(format: "walletAddress == %@", address)
            request.fetchLimit = 1

            if let wallet = try context.fetch(request).first {
                wallet.lastSeen = Date()
                try context.save()
            }
        }
    }

    func updateWalletLastPositionCheck(address: String) async throws {
        let context = persistenceController.viewContext

        try await context.perform {
            let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
            request.predicate = NSPredicate(format: "walletAddress == %@", address)
            request.fetchLimit = 1

            if let wallet = try context.fetch(request).first {
                wallet.lastPositionCheck = Date()
                try context.save()
            }
        }
    }

    func deleteWallet(address: String) async throws {
        let context = persistenceController.viewContext

        try await context.perform {
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
    }

    func deleteInactiveWallets(olderThanDays days: Int) async throws -> Int {
        let context = persistenceController.viewContext
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        var deletedCount = 0

        try await context.perform {
            let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
            request.predicate = NSPredicate(format: "lastSeen < %@", cutoffDate as NSDate)

            let wallets = try context.fetch(request)
            deletedCount = wallets.count

            for wallet in wallets {
                context.delete(wallet)
            }

            if context.hasChanges {
                try context.save()
            }
        }

        return deletedCount
    }

    func fetchWalletsByCategory(_ category: String) async throws -> [WalletEntity] {
        let context = persistenceController.viewContext
        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(key: "lastSeen", ascending: false)]

        return try await context.perform {
            try context.fetch(request)
        }
    }

    func getWalletCount() async throws -> Int {
        let context = persistenceController.viewContext
        let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()

        return try await context.perform {
            try context.count(for: request)
        }
    }
}
