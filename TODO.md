# DexLens Development TODO

## Feature: Hyperliquid Wallet Indexer

### Phase 1: Core Infrastructure

#### 1.1 CoreData Schema Setup
- [ ] Create Wallet Entity
  - wallet_address: String (Primary key)
  - first_seen: Date
  - last_seen: Date
  - category: String (Fibonacci bucket)
  - last_position_check: Date
- [ ] Create Position Entity
  - wallet: Relationship → Wallet
  - coin: String
  - side: String (LONG / SHORT)
  - size: Double
  - entry_price: Double
  - leverage: Double
  - unrealized_pnl: Double
  - last_checked: Date
- [ ] Create MarketStats Entity
  - coin: String
  - total_longs: Double
  - total_shorts: Double
  - long_short_ratio: Double
  - updated_at: Date
- [ ] Create CoreData model version with relationships

#### 1.2 API Client Extensions
- [ ] Extend APIClient with POST support for Hyperliquid info endpoint
- [ ] Create HyperliquidWalletEndpoint for clearinghouseState queries
- [ ] Create HyperliquidDiscoveryEndpoint for recentTrades queries
- [ ] Implement batch request handling for wallet discovery
- [ ] Add async batch processing utilities

---

### Phase 2: Wallet Discovery

#### 2.1 Discovery Service
- [ ] Create WalletDiscoveryService with protocol
- [ ] Implement fetchRecentTrades(coin: String) method
- [ ] Extract wallet addresses from trade data
- [ ] Filter duplicates using CoreData
- [ ] Store new wallets with initial metadata
- [ ] Implement batch processing for multiple coins
- [ ] Add async/await pattern for non-blocking API calls

#### 2.2 Background Discovery
- [ ] Implement BGTaskScheduler for periodic discovery (15-30 min intervals)
- [ ] Schedule discovery job on app launch
- [ ] Add configurable interval settings
- [ ] Handle offline/retry logic

---

### Phase 3: Wallet Classification

#### 3.1 Fibonacci Bucket System
Define buckets:
- 0 – 1 BTC
- 1 – 2 BTC
- 2 – 3 BTC
- 3 – 5 BTC
- 5 – 8 BTC
- 8 – 13 BTC
- 13 – 21 BTC
- 21+ BTC

#### 3.2 Classification Service
- [ ] Create WalletClassificationService
- [ ] Implement fetchClearinghouseState(wallet: String) method
- [ ] Calculate exposure_BTC: SUM(ABS(position.size) * position.entryPrice_in_BTC)
- [ ] Assign category based on Fibonacci bucket
- [ ] Update CoreData with category and timestamp
- [ ] Implement batch fetching for multiple wallets
- [ ] Process classifications in parallel using async
- [ ] Remove wallets with no open positions

---

### Phase 4: Position Tracking

#### 4.1 Position Service
- [ ] Create WalletPositionService
- [ ] Implement fetchPositions(wallet: String) method
- [ ] Parse position data:
  - position.size → LONG (>0) or SHORT (<0)
  - position.entryPrice → entry price
  - position.leverage → leverage
  - position.unrealizedPnl → PnL
- [ ] Save/update positions in CoreData
- [ ] Handle position closure (size = 0) → remove wallet

#### 4.2 Position Refresh
- [ ] Batch query all active wallets
- [ ] Update position data atomically
- [ ] Track position history for analytics
- [ ] Handle partial position updates

---

### Phase 5: Background Refresh Loop

#### 5.1 Indexer Service
- [ ] Create WalletIndexer orchestrator service
- [ ] Implement full refresh cycle:
  1. Discover new wallets
  2. Update positions for existing wallets
  3. Reclassify wallets if exposure changed
  4. Remove wallets with no open positions
- [ ] Track wallet activity score (update last_seen on trade)
- [ ] Auto-remove inactive wallets after N days

#### 5.2 Scheduling & Background Tasks
- [ ] Configure BGTaskScheduler with identifier
- [ ] Implement background fetch handler
- [ ] Add foreground refresh capability
- [ ] Progress tracking for long operations
- [ ] Error handling and retry logic

---

### Phase 6: Market Metrics Aggregation

#### 6.1 Aggregation Service
- [ ] Create MarketMetricsService
- [ ] Calculate exposure per Fibonacci bucket
  - Sum of longs vs shorts per bucket
  - Total BTC per bucket
- [ ] Compute market-wide long/short ratio
  - long_short_ratio = total_long_BTC / total_short_BTC
- [ ] Store aggregated metrics in CoreData
- [ ] Cache recent metrics in memory for UI performance

#### 6.2 Metrics Dashboard
- [ ] Create MarketMetricsViewModel
- [ ] Expose aggregated data for UI binding
- [ ] Add real-time update notifications
- [ ] Historical metrics tracking

---

### Phase 7: UI Implementation

#### 7.1 Wallet Discovery View
- [ ] WalletDiscoveryView with discovery status
- [ ] List of recently discovered wallets
- [ ] Discovery statistics (count, last scan time)

#### 7.2 Wallet Classification View
- [ ] WalletClassificationView with bucket breakdown
- [ ] Filter/sort by category
- [ ] Wallet detail view with position breakdown

#### 7.3 Market Metrics View
- [ ] MarketMetricsView with long/short ratio
- [ ] Fibonacci bucket visualization
- [ ] Historical trend charts

---

### Phase 8: Optional Enhancements

- [ ] **Risk Alerts**: Detect high-leverage wallets (threshold configurable)
- [ ] **Position History**: Track position changes over time (historic snapshots)
- [ ] **Whale Highlighting**: Mark wallets >13 BTC with special indicators
- [ ] **Push Notifications**: Alert when certain buckets exceed thresholds
- [ ] **Daily Snapshots**: Maintain daily snapshots for long-term analytics
- [ ] **Export Data**: CSV/JSON export of wallet data

---

## Technical Considerations

### Performance Optimizations
- [ ] Batch API calls to prevent UI freeze
- [ ] Use async/await for all network operations
- [ ] Implement request deduplication
- [ ] Add request caching with TTL
- [ ] Background processing for heavy operations

### Data Management
- [ ] Implement CoreData migrations safely
- [ ] Add data pruning for old snapshots
- [ ] Handle CoreData conflicts gracefully
- [ ] Add CoreData debugging tools

### Error Handling
- [ ] API rate limiting handling
- [ ] Network error retry with exponential backoff
- [ ] Data validation and sanitization
- [ ] Graceful degradation when API is unavailable

---

## Progress Tracking

**Current Phase:** Planning
**Next Action:** Set up CoreData schema
**Estimated Completion:** TBD

---

## Notes

- Use async/await patterns throughout for clean concurrency
- Keep CoreData lightweight by removing closed positions
- Fibonacci buckets align with trading psychology
- Batch processing is critical for performance with many wallets
- Consider implementing a settings screen for configurable intervals
