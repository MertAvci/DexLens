import CoreData
import Foundation

public extension MarketStatsEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<MarketStatsEntity> {
        NSFetchRequest<MarketStatsEntity>(entityName: "MarketStatsEntity")
    }

    @NSManaged var coin: String
    @NSManaged var totalLongs: Double
    @NSManaged var totalShorts: Double
    @NSManaged var longShortRatio: Double
    @NSManaged var updatedAt: Date
}
