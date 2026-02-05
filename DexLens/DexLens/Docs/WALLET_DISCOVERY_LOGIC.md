# Wallet Discovery Logic

## Overview

DexLens uses a **combined discovery approach** to find active wallets on GMX (Arbitrum). This strategy maximizes coverage while maintaining focus on wallets with real trading activity using the GMX Subsquid GraphQL API.

## Migration Note

**Previous Implementation:** Hyperliquid API  
**Current Implementation:** GMX Subsquid GraphQL API

**Why GMX?**
- ✅ Wallet addresses included directly in API response
- ✅ `isLong` field for instant long/short classification
- ✅ USD position sizes (no price conversion needed)
- ✅ GraphQL for precise data fetching
- ✅ Better data coverage for active traders

## Discovery Strategy

### 1. Primary Source: GMX Open Positions

**Endpoint:**
```
POST https://gmx.squids.live/gmx-synthetics-arbitrum:prod/api/graphql
Content-Type: application/json
```

**GraphQL Query:**
```graphql
{
  positions(where: { sizeInUsd_gt: "0" }) {
    account
    isLong
    sizeInUsd
    market
  }
}
```

**Response Format:**
```json
{
  "positions": [
    {
      "account": "0xabc...",
      "isLong": true,
      "sizeInUsd": "50000.00",
      "market": "ETH-USD"
    }
  ]
}
```

**Why This Works:**
- ✅ All active wallets with open positions
- ✅ Wallet address directly in `account` field
- ✅ `isLong` boolean for instant side classification
- ✅ USD size ready for classification (no conversion)
- ✅ Real-time data from GMX Subsquid indexer

### 2. Secondary Source: GMX Liquidations

**GraphQL Query:**
```graphql
{
  positionLiquidations {
    account
    isLong
    sizeInUsd
    market
    timestamp
  }
}
```

**Response Format:**
```json
{
  "positionLiquidations": [
    {
      "account": "0xdef...",
      "isLong": false,
      "sizeInUsd": "100000.00",
      "market": "BTC-USD",
      "timestamp": 1681924499
    }
  ]
}
```

**Purpose:**
- Catches wallets that were recently liquidated
- Provides historical liquidation data
- Useful for risk analysis and whale tracking

### 3. Tertiary Source: Seed List

**File:** `Resources/WalletSeeds.json`

**Purpose:**
- Fallback when API discovery yields insufficient results
- Seed the system with known whale wallets
- Ensure we always have wallets to monitor

**Format:**
```json
{
  "wallets": [
    "0xabc123...",
    "0xdef456..."
  ]
}
```

## Wallet Classification

### USD-Based Classification

Wallets are classified into buckets based on total USD exposure:

| Bucket | Range (USD) | Description |
|--------|-------------|-------------|
| 0 | <$1,000 | Micro retail |
| 1 | $1,000 - $10,000 | Small retail |
| 2 | $10,000 - $100,000 | Retail |
| 3 | $100,000 - $1,000,000 | Trader |
| 4 | $1,000,000 - $10,000,000 | Whale |
| 5 | $10,000,000+ | Mega whale |

**Why USD?**
- Direct from GMX API (no price lookups)
- Easier to understand for users
- Consistent across all markets

### Side Classification

Uses GMX `isLong` field directly:
- `isLong: true` → Long positions
- `isLong: false` → Short positions

**Implementation:**
```swift
func determineSide(positions: [GMXPosition]) -> String {
    let longCount = positions.filter(\.isLong).count
    let shortCount = positions.filter { !$0.isLong }.count
    
    if longCount > shortCount { return "long" }
    else if shortCount > longCount { return "short" }
    else { return "neutral" }
}
```

## Discovery Flow

```
┌─────────────────────────────────────────┐
│         Wallet Discovery Start          │
└──────────────────┬──────────────────────┘
                   │
     ┌─────────────┼──────────────┐
     │             │              │
     ▼             ▼              ▼
┌─────────┐  ┌───────────┐  ┌──────────┐
│  GMX    │  │    GMX    │  │   Seed   │
│Positions│  │Liquidations│  │   List   │
│(Primary)│  │(Secondary) │  │(Fallback)│
└────┬────┘  └─────┬─────┘  └────┬─────┘
     │             │              │
     └─────────────┼──────────────┘
                   │
                   ▼
      ┌──────────────────────────┐
      │   Deduplicate Addresses  │
      └───────────┬──────────────┘
                  │
                  ▼
      ┌──────────────────────────┐
      │   Check CoreData for     │
      │   Existing Wallets       │
      └───────────┬──────────────┘
                  │
                  ▼
      ┌──────────────────────────┐
      │  Filter Positions for    │
      │  Each New Wallet         │
      └───────────┬──────────────┘
                  │
                  ▼
      ┌──────────────────────────┐
      │  Calculate USD Exposure  │
      │  & Assign Category       │
      └───────────┬──────────────┘
                  │
                  ▼
      ┌──────────────────────────┐
      │   Save to CoreData       │
      └──────────────────────────┘
```

## Implementation Details

### Service Architecture

**GMXDiscoveryService:**
- Fetches positions and liquidations from GMX GraphQL API
- Rate limiting: < 1 request/sec
- Error handling: Returns empty array on failure (fallback to seed list)

**WalletClassificationService:**
- Uses GMX data directly (no additional API calls)
- Calculates total USD exposure: `SUM(position.sizeInUsd)`
- Determines side: Majority of isLong flags
- Updates CoreData with category and timestamp

**WalletDiscoveryService:**
- Orchestrates discovery from all 3 sources
- Deduplicates wallet addresses
- Batches CoreData writes (20 wallets/batch)
- Triggers classification immediately after discovery

### Batch Processing

- Discovery processes wallets in batches of 20
- Classification happens immediately after discovery
- Background tasks run every 15 minutes via `.backgroundTask`
- All operations use async/await for non-blocking execution

### Error Handling

- API failures print error and return empty array
- Duplicate wallets filtered automatically
- Invalid addresses skipped
- Classification errors don't block discovery
- Fallback to seed list if all APIs fail

### Rate Limiting

- GMX Subsquid: Soft limits, recommend < 1 req/sec
- Implemented 1-second throttle between requests
- 15-minute background refresh schedule maintained

## Data Storage

### CoreData Schema

**WalletEntity:**
- `walletAddress: String` (Primary key)
- `firstSeen: Date` - When first discovered
- `lastSeen: Date` - Last time wallet was active
- `category: String?` - USD bucket (0-5)
- `lastPositionCheck: Date?` - Last classification time
- `positions: NSSet?` - Relationship to PositionEntity

**PositionEntity:**
- `coin: String` - Asset symbol
- `side: String` - "long" or "short"
- `size: Double` - Position size
- `entryPrice: Double` - Average entry price
- `leverage: Double` - Current leverage
- `unrealizedPnl: Double` - Unrealized P&L
- `lastChecked: Date` - Last update time
- `wallet: WalletEntity?` - Parent wallet

## Performance Considerations

- GraphQL fetches only needed fields (no over-fetching)
- Batch processing prevents UI freezing
- CoreData operations on background context
- Deduplication before CoreData queries
- Rate limiting prevents API throttling

## Future Enhancements

### Potential Improvements

1. **Market Filtering**: Filter by specific markets (BTC, ETH, etc.)
2. **Minimum Size Filter**: Configure minimum USD threshold
3. **Historical Tracking**: Track position changes over time
4. **Risk Scoring**: Flag high-leverage or underwater wallets
5. **Price Alerts**: Notify when whale wallets make large moves

### Known Limitations

1. Only discovers wallets with open positions on GMX
2. No support for other perp DEXs yet
3. Static seed list requires manual maintenance
4. USD classification doesn't account for leverage

## Maintenance

### Updating Seed List

To add new whale wallets to the seed list:

1. Edit `Resources/WalletSeeds.json`
2. Add wallet address to the `wallets` array
3. Ensure address format is correct (0x...)
4. Changes take effect on next app launch

### Monitoring Discovery Health

Check the following metrics in the app:
- Total wallets discovered
- New wallets per discovery cycle
- Classification success rate
- Average exposure per bucket
- Long vs Short distribution

## API References

- [GMX Subsquid API](https://gmx.squids.live/gmx-synthetics-arbitrum:prod/api/graphql)
- [Subsquid Documentation](https://docs.subsquid.io/)
- CoreData documentation in `Core/Database/`
