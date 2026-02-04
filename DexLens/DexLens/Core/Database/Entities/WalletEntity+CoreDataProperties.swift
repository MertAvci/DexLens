import CoreData
import Foundation

public extension WalletEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<WalletEntity> {
        NSFetchRequest<WalletEntity>(entityName: "WalletEntity")
    }

    @NSManaged var walletAddress: String
    @NSManaged var firstSeen: Date
    @NSManaged var lastSeen: Date
    @NSManaged var category: String?
    @NSManaged var lastPositionCheck: Date?
    @NSManaged var positions: NSSet?
}

// MARK: Generated accessors for positions

public extension WalletEntity {
    @objc(addPositionsObject:)
    @NSManaged func addToPositions(_ value: PositionEntity)

    @objc(removePositionsObject:)
    @NSManaged func removeFromPositions(_ value: PositionEntity)

    @objc(addPositions:)
    @NSManaged func addToPositions(_ values: NSSet)

    @objc(removePositions:)
    @NSManaged func removeFromPositions(_ values: NSSet)
}
