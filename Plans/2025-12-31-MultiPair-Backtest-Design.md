# Multi-Pair Backtesting System - Design Document

**Date:** December 31, 2025
**Phase:** Phase 8 - Multi-Pair Backtesting
**Status:** Design Complete - Ready for Implementation
**Author:** Claude Code (Brainstorming Session)

---

## Executive Summary

Design for a **multi-pair backtesting system** that enables MT5-style testing across multiple currency pairs simultaneously. The system maintains **Python as the single source of truth** for strategy logic while providing a rich C# visualization interface for playback and analysis.

**Core Vision:** MT5 Strategy Tester reimagined with multi-pair support and realistic trading simulation.

---

## System Architecture

### Design Principle: Python = Brain, C# = Eyes

**Python Responsibilities:**
- Strategy evaluation (Trend Rider, Range Rider)
- Indicator calculations (EMA, ATR, ADX, RSI)
- Regime detection (TRENDING, RANGING, TRANSITIONAL)
- Position management and trade generation
- Complete backtest orchestration

**C# Responsibilities:**
- User interface and configuration
- Playback controls and visualization
- Chart rendering with trade markers
- Statistics display and reporting
- Export functionality

### Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│  C# Multi-Pair Backtest Configuration Window                │
│  - Select pairs (EURUSD, GBPUSD, USDJPY, etc.)             │
│  - Select strategies (Trend Rider, Range Rider)             │
│  - Set date range and risk parameters                       │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Single API Call
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Python API: POST /backtest/multi-pair                      │
│  {                                                           │
│    "pairs": ["EURUSD", "GBPUSD", "USDJPY"],                │
│    "strategies": ["trend_rider", "range_rider"],            │
│    "start_date": "2024-01-01",                              │
│    "end_date": "2024-12-31",                                │
│    "config": { initial_balance, risk_percent, ... }         │
│  }                                                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ Python Processing (~8-10 seconds)
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Python Backtest Engine                                     │
│  - Loads data for all pairs                                 │
│  - Runs strategies bar-by-bar                               │
│  - Manages positions (entry, exit, R-multiple tracking)     │
│  - Calculates statistics by pair/strategy                   │
│  - Builds equity curve                                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      │ JSON Response
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Response: Complete Backtest Results                        │
│  {                                                           │
│    "trades": [ {...}, {...}, ... ],  (156 trades)          │
│    "statistics": { total_r, win_rate, drawdown, ... },      │
│    "equity_curve": [ {...}, {...}, ... ]                    │
│  }                                                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  C# Multi-Pair Playback Window                              │
│  - MT5-style playback controls (play, pause, step)          │
│  - Interactive trade timeline (click to jump)               │
│  - Multi-pair chart viewer                                  │
│  - Real-time statistics and open positions                  │
│  - Export trades and reports                                │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Design

### 1. Python API Enhancement

**New Endpoint:** `/backtest/multi-pair`

**Request Structure:**
```json
{
  "pairs": ["EURUSD", "GBPUSD", "USDJPY"],
  "strategies": ["trend_rider", "range_rider"],
  "start_date": "2024-01-01",
  "end_date": "2024-12-31",
  "timeframe": "M15",
  "config": {
    "initial_balance": 10000,
    "risk_percent": 0.02,
    "max_concurrent_positions": 2,
    "min_confidence": 50.0,
    "take_profit_r": 2.0
  }
}
```

**Response Structure:**
```json
{
  "trades": [
    {
      "id": 1,
      "symbol": "EURUSD",
      "side": "BUY",
      "strategy": "trend_rider",
      "entry_price": 1.1050,
      "entry_time": "2024-01-15 08:00:00",
      "exit_price": 1.1090,
      "exit_time": "2024-01-15 14:30:00",
      "stop_loss": 1.1030,
      "take_profit": 1.1090,
      "r_multiple": 2.0,
      "profit_loss": 420.0,
      "confidence": 75,
      "regime": "TRENDING",
      "exit_reason": "TAKE_PROFIT"
    }
  ],
  "statistics": {
    "total_trades": 156,
    "wins": 85,
    "losses": 71,
    "win_rate": 54.5,
    "total_r": 12.3,
    "avg_r": 0.08,
    "max_drawdown": -3.2,
    "sharpe_ratio": 1.8,
    "initial_balance": 10000,
    "final_balance": 11230,
    "net_profit": 1230,
    "return_percent": 12.3,
    "strategy_breakdown": {
      "trend_rider": { "trades": 89, "win_rate": 56.2, "total_r": 8.2 },
      "range_rider": { "trades": 67, "win_rate": 51.5, "total_r": 4.1 }
    },
    "pair_breakdown": {
      "EURUSD": { "trades": 52, "win_rate": 57.7, "total_r": 5.6 },
      "GBPUSD": { "trades": 51, "win_rate": 54.9, "total_r": 4.2 },
      "USDJPY": { "trades": 53, "win_rate": 50.9, "total_r": 2.5 }
    }
  },
  "equity_curve": [
    { "time": "2024-01-01 00:00:00", "equity": 10000 },
    { "time": "2024-01-15 14:30:00", "equity": 10420 },
    { "time": "2024-12-31 23:59:59", "equity": 11230 }
  ]
}
```

**Implementation:**
- Uses existing `backtest_engine.py` and `position_manager.py`
- Processes each pair sequentially
- Merges trades chronologically across all pairs
- Calculates aggregate statistics

**Performance Target:**
- 1 year × 3 pairs × 35,000 bars = ~105,000 bars
- Target processing speed: 10,000-20,000 bars/second
- **Total load time: 8-10 seconds**

---

### 2. C# Multi-Pair Backtest Configuration Window

**Purpose:** Configure and launch multi-pair backtests

**UI Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  Multi-Pair Backtest Configuration                      │
├─────────────────────────────────────────────────────────┤
│  Pairs:                                                  │
│    [x] EURUSD  [x] GBPUSD  [x] USDJPY  [ ] AUDUSD      │
│                                                          │
│  Strategies:                                             │
│    [x] Trend Rider  [x] Range Rider                     │
│                                                          │
│  Date Range: [2024-01-01] to [2024-12-31]              │
│                                                          │
│  Risk Management:                                        │
│    Initial Balance: $10,000   Risk per Trade: 2%        │
│    Max Concurrent Positions: 2                          │
│    Min Confidence: [50] %                               │
│    Take Profit Target: [2.0] R                          │
│                                                          │
│  [Run Backtest]  [Stop]  [Load Config]  [Save Config]  │
├─────────────────────────────────────────────────────────┤
│  Status: Running... (Processing EURUSD - Trend Rider)   │
│  Progress: ████████░░░░  65%                           │
├─────────────────────────────────────────────────────────┤
│  Results Ready - 156 trades across 3 pairs              │
│    • Trend Rider: 89 trades (56% win rate, +8.2R)      │
│    • Range Rider: 67 trades (51% win rate, +4.1R)      │
│  [View Playback]  [Export Trades]  [View Stats]        │
└─────────────────────────────────────────────────────────┘
```

**Features:**
- Multi-select pairs and strategies
- Date range picker with validation
- Risk parameter inputs with bounds checking
- Save/load configuration files (JSON)
- Progress tracking during backtest
- Error handling for API failures
- Results summary display

---

### 3. C# Multi-Pair Playback Window

**Purpose:** Interactive MT5-style playback with timeline navigation

**UI Layout:**
```
┌───────────────────────────────────────────┬─────────────────────────┐
│  Chart View Panel                         │  Right Panel (Details)  │
│  ┌─────────────────────────────────────┐  │                         │
│  │                                      │  │  Account Status         │
│  │                                      │  │  ───────────────────    │
│  │       EURUSD Chart                   │  │  Balance: $10,420       │
│  │   [Candles + Indicators]             │  │  Equity: $10,510        │
│  │   [Trade Markers]                    │  │  Total R: +4.2R         │
│  │                                      │  │  Drawdown: -1.8%        │
│  │                                      │  │                         │
│  │                                      │  │  ───────────────────    │
│  │                                      │  │  Trades: 48             │
│  │                                      │  │  Wins: 26 (54%)         │
│  └─────────────────────────────────────┘  │  Losses: 22 (46%)       │
├───────────────────────────────────────────┤                         │
│  Lower Panel (Playback Controls)          │  ─────────────────────  │
│  ─────────────────────────────────────    │  Open Positions (2/2)   │
│  Playback:                                │  ─────────────────────  │
│  [◄◄] [◄] [▶] [▶▶] [■]  Speed: [1x ▼]   │  #45 EURUSD BUY         │
│                                           │  @ 1.1050 | +1.2R       │
│  Timeline: ─────────●────────────────     │  Trend Rider | 75% conf │
│  2024-03-15 14:30                         │                         │
│                                           │  #47 GBPUSD SELL        │
│  Pair Selector:                           │  @ 1.2630 | -0.3R       │
│  [EURUSD*] [GBPUSD] [USDJPY]             │  Range Rider | 62% conf │
│  (* = currently viewing)                  │                         │
│                                           │  ─────────────────────  │
│                                           │  Trade Timeline         │
│                                           │  Filter: [All ▼]        │
│                                           │  ─────────────────────  │
│                                           │  ✓ 14:30 EURUSD #45     │
│                                           │    ENTRY BUY @ 1.1050   │
│                                           │                         │
│                                           │  ✓ 14:00 GBPUSD #44     │
│                                           │    EXIT +2.1R (TP Hit)  │
│                                           │                         │
│                                           │  ✗ 13:30 USDJPY #43     │
│                                           │    EXIT -1.0R (SL Hit)  │
└───────────────────────────────────────────┴─────────────────────────┘
```

**Key Features:**

**Chart Panel (Main Area):**
- Candlestick chart with indicators overlay
- Trade entry/exit markers
- Position status annotations
- Smooth rendering for selected pair

**Playback Controls (Lower Panel):**
- **Step Backward/Forward** - Single event navigation
- **Play/Pause** - Automated playback
- **Speed Control** - 1x, 2x, 5x, 10x speeds
- **Timeline Slider** - Jump to any point in time
- **Pair Selector** - Switch between pairs during playback

**Right Panel Details:**
- **Account Status** - Balance, equity, total R, drawdown
- **Trade Statistics** - Wins, losses, win rate
- **Open Positions** - Live position tracking with unrealized P&L
- **Trade Timeline** - Complete chronological event list

**Interactive Trade Timeline:**
- Shows ALL trade events (entries and exits)
- Color-coded: Green (✓) for wins, Red (✗) for losses, Orange (→) for entries
- **Clickable** - Click any event to jump to that moment
- Filters: All Events, Entries Only, Exits Only, Wins Only, Losses Only
- Filter by pair: All Pairs, specific pair
- Filter by strategy: All Strategies, specific strategy

**Timeline Navigation:**
```csharp
private void TradeTimeline_SelectionChanged(object sender, SelectionChangedEventArgs e)
{
    if (TradeTimelineList.SelectedItem is TradeTimelineEvent selectedEvent)
    {
        // Pause playback
        _playbackTimer.Stop();

        // Jump to this event
        JumpToEvent(selectedEvent.EventIndex);

        // Highlight trade on chart
        HighlightTradeOnChart(selectedEvent.TradeId);
    }
}
```

---

### 4. Export & Reporting

**Export Functionality:**

**CSV Trade Export:**
```csv
Trade ID,Symbol,Strategy,Side,Entry Time,Entry Price,Exit Time,Exit Price,Stop Loss,Take Profit,R-Multiple,Profit/Loss,Confidence,Regime,Exit Reason
1,EURUSD,trend_rider,BUY,2024-01-15 08:00,1.10500,2024-01-15 14:30,1.10900,1.10300,1.10900,2.00,420.00,75,TRENDING,TAKE_PROFIT
```

**Statistics Report (Text/HTML):**
```
═══════════════════════════════════════════════
   MULTI-PAIR BACKTEST REPORT
═══════════════════════════════════════════════

Date Range: 2024-01-01 to 2024-12-31
Pairs Tested: EURUSD, GBPUSD, USDJPY
Strategies: Trend Rider, Range Rider

───────────────────────────────────────────────
  OVERALL PERFORMANCE
───────────────────────────────────────────────
Initial Balance:      $10,000.00
Final Balance:        $11,230.00
Net Profit:           $1,230.00
Return:               12.30%

Total Trades:         156
Wins:                 85 (54.5%)
Losses:               71 (45.5%)

Total R:              +12.30R
Average R:            +0.08R
Max Drawdown:         -3.20%
Sharpe Ratio:         1.80

───────────────────────────────────────────────
  BREAKDOWN BY STRATEGY
───────────────────────────────────────────────

TREND RIDER:
  Trades:     89
  Win Rate:   56.2%
  Total R:    +8.20R
  Avg R:      +0.09R

RANGE RIDER:
  Trades:     67
  Win Rate:   51.5%
  Total R:    +4.10R
  Avg R:      +0.06R

───────────────────────────────────────────────
  BREAKDOWN BY PAIR
───────────────────────────────────────────────

EURUSD:
  Trades:     52
  Win Rate:   57.7%
  Total R:    +5.60R

GBPUSD:
  Trades:     51
  Win Rate:   54.9%
  Total R:    +4.20R

USDJPY:
  Trades:     53
  Win Rate:   50.9%
  Total R:    +2.50R
```

**Configuration File (JSON):**
```json
{
  "pairs": ["EURUSD", "GBPUSD", "USDJPY"],
  "strategies": ["trend_rider", "range_rider"],
  "start_date": "2024-01-01",
  "end_date": "2024-12-31",
  "initial_balance": 10000,
  "risk_percent": 0.02,
  "max_concurrent_positions": 2,
  "min_confidence": 50.0,
  "take_profit_r": 2.0
}
```

---

## Risk Management Model

**Fixed R-Risk Approach:**

**Position Sizing Formula:**
```
Risk Amount = Account Balance × Risk Percent
            = $10,000 × 2% = $200

Stop Loss Distance = 2 × ATR (e.g., 20 pips)

Position Size = Risk Amount / (Stop Loss Pips × Pip Value)
              = $200 / (20 pips × $10/pip)
              = 1.0 lot
```

**Entry/Exit Rules:**

**Entry Conditions:**
- Strategy signal generated (BUY/SELL)
- Signal confidence ≥ minimum threshold (default 50%)
- Open positions < max concurrent positions (default 2)
- Account not in daily loss limit (future enhancement)

**Exit Conditions:**
1. **Stop Loss Hit** - Price reaches stop loss level
2. **Take Profit Hit** - Price reaches take profit target (2R or 3R)
3. **Opposite Signal** - Strategy signals reversal (future enhancement)
4. **Max Hold Time** - Position held too long (future enhancement)
5. **Break-Even Stop** - Move SL to entry after +1R (future enhancement)

**Current Implementation (Phase 1):**
- Simple signal-based entry (confidence ≥ threshold)
- ATR-based stop loss (2× ATR)
- Fixed take profit (2R target)
- Max 2 concurrent positions per pair

---

## Error Handling & Validation

**API Connection Errors:**
- Detect Python server offline
- Display user-friendly error message
- Suggest starting Python server with command

**Validation Checks:**
- At least 1 pair selected
- At least 1 strategy selected
- Valid date range (end > start)
- Risk percent within bounds (0-10%)
- Positive initial balance
- Warn if backtest is very large (> 2 years)

**Data Integrity:**
- Handle zero trades scenario
- Validate response structure from Python
- Check for null/missing fields
- Handle timeout for long-running backtests

**Performance Safeguards:**
- Progress reporting for long backtests
- Data caching to prevent redundant API calls
- Lazy loading for chart data
- Memory management during playback

---

## Testing Strategy

### Phase 1: Python Unit Tests

Test multi-pair endpoint functionality:
- Valid multi-pair requests return correct structure
- Statistics calculations are accurate
- Trades sorted chronologically across pairs
- Validation rejects invalid requests
- Edge cases: zero trades, single pair, all strategies

### Phase 2: C# Unit Tests

Test playback logic:
- Timeline construction from trades
- Event ordering (chronological)
- Jump-to-event functionality
- Filter operations (by pair, strategy, outcome)
- Statistics calculations match Python

### Phase 3: Integration Tests

End-to-end workflow:
- Configuration → API call → Results → Playback
- Export functionality (CSV, reports)
- Save/load configuration files
- Error handling scenarios

### Phase 4: Validation Tests

**Signal Matching with MT5 EA:**
- Run same backtest in MT5 and C#
- Compare generated signals
- Target: **90%+ match rate**
- Document any discrepancies

**Performance Tests:**
- Load time for 1 year × 3 pairs (target: < 15 seconds)
- Playback smoothness at different speeds
- Memory usage during long playbacks
- Large dataset handling (5 years × 5 pairs)

---

## Implementation Roadmap

### Phase 1: Python API Enhancement (2-3 days)

**Tasks:**
1. Create `/backtest/multi-pair` endpoint in `src/api/routes/backtest.py`
2. Implement multi-pair orchestration logic
3. Merge trades chronologically across pairs
4. Calculate statistics breakdown (by pair, by strategy)
5. Add request validation
6. Write unit tests (30+ test cases)

**Deliverables:**
- Working API endpoint
- Complete JSON response structure
- Tests passing
- API documentation updated

**Acceptance Criteria:**
- Endpoint returns 200 for valid requests
- Trades sorted by time across all pairs
- Statistics accurate (verified manually)
- < 15 second response time for 1 year × 3 pairs

---

### Phase 2: C# Configuration Window (2-3 days)

**Tasks:**
1. Create `MultiPairBacktestWindow.xaml`
2. Build UI for pair/strategy selection
3. Add date range and risk parameter inputs
4. Implement `ApiClient.RunMultiPairBacktest()`
5. Add loading indicators and progress tracking
6. Display results summary
7. Implement validation logic

**Deliverables:**
- Working configuration window
- Successful API integration
- Error handling for failures
- Save/load configuration files

**Acceptance Criteria:**
- Can select multiple pairs and strategies
- API call succeeds and returns results
- Validation prevents invalid inputs
- Clear error messages for failures

---

### Phase 3: C# Playback Window (4-5 days)

**Tasks:**
1. Create `MultiPairPlaybackWindow.xaml` with 3-panel layout
2. Implement timeline event construction
3. Build playback engine (play, pause, step, jump)
4. Add clickable trade timeline list
5. Implement pair switching
6. Add chart rendering for selected pair
7. Display open positions and account status
8. Implement filtering (pair, strategy, outcome)
9. Add speed controls (1x, 2x, 5x, 10x)

**Deliverables:**
- Complete playback interface
- Smooth playback at multiple speeds
- Clickable trade navigation
- Real-time statistics display

**Acceptance Criteria:**
- Playback advances smoothly without lag
- Click any trade to jump to that moment
- Chart displays correctly for selected pair
- Statistics update in real-time
- Filters work correctly

---

### Phase 4: Export & Reporting (1-2 days)

**Tasks:**
1. Implement CSV trade export
2. Build statistics report generator (text/HTML)
3. Add equity curve visualization (optional)
4. Implement configuration save/load

**Deliverables:**
- CSV export functionality
- Formatted statistics reports
- Configuration file management

**Acceptance Criteria:**
- CSV contains all trade details
- Report is readable and accurate
- Saved config can be reloaded

---

### Phase 5: Testing & Validation (2-3 days)

**Tasks:**
1. Write Python unit tests for endpoint
2. Write C# unit tests for playback
3. Run integration tests (end-to-end)
4. Validate signal matching with MT5 EA
5. Performance testing with large datasets
6. Bug fixes and polish

**Deliverables:**
- All tests passing
- 90%+ signal match with MT5
- Performance benchmarks met
- Production-ready code

**Acceptance Criteria:**
- Test coverage > 80%
- Signal match rate ≥ 90%
- Load time < 15 seconds for standard backtest
- Zero critical bugs

---

### Total Timeline: 12-16 days

**Breakdown:**
- Python API: 2-3 days
- C# Config UI: 2-3 days
- C# Playback UI: 4-5 days
- Export/Reports: 1-2 days
- Testing: 2-3 days

---

## Future Enhancements

### Phase 6: Advanced Visualization

- Real-time equity curve chart during playback
- Drawdown visualization and recovery tracking
- Trade heatmap (win/loss distribution by time/day)
- Compare multiple backtest runs side-by-side
- Parameter optimization mode (test different settings)
- Monte Carlo simulation (stress test)

### Phase 7: Multi-Pair Orchestrator (Main Vision)

**The Ultimate Goal:** True multi-pair simultaneous backtesting

**Architecture:**
```
┌────────────────────────────────────────────────────┐
│  Multi-Pair Orchestrator Window                    │
│  ┌──────────────┬──────────────┬──────────────┐   │
│  │  EURUSD      │  GBPUSD      │  USDJPY      │   │
│  │  Mini Chart  │  Mini Chart  │  Mini Chart  │   │
│  └──────────────┴──────────────┴──────────────┘   │
│                                                    │
│  Timeline (synchronized across all pairs):         │
│  ─────────────────●────────────────                │
│  2024-03-15 14:30                                  │
│                                                    │
│  Account Dashboard:                                │
│  Balance: $10,420 | Open Positions: 2/2           │
│  Equity: $10,510  | Available: 0 slots            │
│                                                    │
│  Signal Queue (when 2+ pairs signal at once):     │
│  1. EURUSD BUY (75% conf, Trend Rider)            │
│  2. GBPUSD SELL (62% conf, Range Rider) ← PENDING │
│                                                    │
│  Position Priority Rules:                          │
│  [x] Higher confidence wins                        │
│  [ ] First signal wins                             │
│  [ ] Specific strategy priority                    │
└────────────────────────────────────────────────────┘
```

**Key Features:**
- Advance time bar-by-bar across ALL pairs simultaneously
- Shared position manager (max 2 across all pairs, not per pair)
- Signal priority resolution when multiple pairs signal at once
- Realistic trading simulation (can't take every signal)
- Dashboard view showing all pairs + account state
- Enhanced realism for multi-pair strategy testing

---

## Success Criteria

The implementation will be considered **complete** when:

✅ Multi-pair backtests run successfully via Python API
✅ C# playback window displays results with MT5-style controls
✅ Users can click any trade in timeline to review that moment
✅ Export functionality generates CSV and reports
✅ Load time ≤ 15 seconds for 1 year × 3 pairs
✅ Signal matching ≥ 90% with MT5 EA
✅ All unit and integration tests passing
✅ Documentation updated (CLAUDE.md, user guide)
✅ Zero critical bugs in production
✅ Positive user feedback on UX

---

## Documentation Requirements

**To Be Updated:**
1. **CLAUDE.md** - Add multi-pair vision to PROJECT GOALS
2. **API Documentation** - Document `/backtest/multi-pair` endpoint
3. **User Guide** - How to run multi-pair backtests
4. **Developer Guide** - Architecture and code structure
5. **Implementation Plan** - Detailed Phase 1-5 breakdown

---

## Appendices

### Appendix A: Technology Stack

**Python:**
- FastAPI (API framework)
- Pandas (data processing)
- Existing backtest_engine.py
- Existing position_manager.py

**C#:**
- WPF (UI framework)
- ScottPlot (charting)
- Newtonsoft.Json (JSON serialization)
- System.Net.Http (API client)

**Data Format:**
- JSON for API communication
- CSV for data export
- M15 timeframe (primary)

### Appendix B: Performance Benchmarks

**Target Performance:**
- API response time: < 15 seconds (1 year × 3 pairs)
- Playback frame rate: 30+ FPS
- Memory usage: < 500 MB for standard backtest
- Timeline jump: < 100ms response time

**Optimization Strategies:**
- Python: Vectorized calculations with Pandas
- C#: Data caching, lazy loading, incremental rendering
- API: Batch processing, compression (optional)

### Appendix C: Risk & Mitigation

**Risk 1: Python API Performance**
- Mitigation: Profile and optimize bottlenecks
- Fallback: Implement progress reporting for long backtests

**Risk 2: C# UI Lag with Large Datasets**
- Mitigation: Virtualization for timeline list, chart data sampling
- Fallback: Limit visible data range, implement paging

**Risk 3: Signal Mismatch with MT5**
- Mitigation: Systematic validation testing
- Fallback: Document known differences, adjust thresholds

**Risk 4: Scope Creep**
- Mitigation: Stick to Phase 1-5 roadmap
- Fallback: Defer advanced features to Phase 6-7

---

## Conclusion

This design provides a **clear, actionable path** to building a multi-pair backtesting system that:

1. **Maintains Python as the single source of truth** for strategy logic
2. **Delivers fast performance** (~8-10 second load times)
3. **Provides rich UX** (MT5-style playback, clickable timeline, filters)
4. **Enables multi-pair testing** (realistic trading simulation)
5. **Validates against MT5 EA** (90%+ signal matching)
6. **Supports future vision** (Phase 7 multi-pair orchestrator)

The architecture is **simple, maintainable, and scalable** - exactly what's needed to validate strategies before risking real capital.

**Next Steps:**
1. Review and approve this design
2. Update CLAUDE.md with multi-pair vision
3. Begin Phase 1 implementation (Python API)
4. Iterate through phases sequentially
5. Celebrate when backtesting like a boss! 🚀

---

**Design Status:** ✅ Complete - Ready for Implementation
**Estimated Timeline:** 12-16 days
**Next Session:** Phase 1 - Python API Enhancement
