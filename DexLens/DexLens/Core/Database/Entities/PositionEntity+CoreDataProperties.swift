import CoreData
import Foundation

public extension PositionEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<PositionEntity> {
        NSFetchRequest<PositionEntity>(entityName: "PositionEntity")
    }

    @NSManaged var coin: String
    @NSManaged var side: String
    @NSManaged var size: Double
    @NSManaged var entryPrice: Double
    @NSManaged var leverage: Double
    @NSManaged var unrealizedPnl: Double
    @NSManaged var lastChecked: Date
    @NSManaged var wallet: WalletEntity?
}
