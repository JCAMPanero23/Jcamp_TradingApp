# Phase 8.5 - Deferred Bugs (Phase 8.6)

**Date Created:** January 12, 2026
**Created During:** Phase 8.5 Testing & Validation
**Target Phase:** Phase 8.6 - Multi-Pair Refinements

---

## Overview

During Phase 8.5 testing, three issues were identified that do not block multi-pair functionality but require architectural changes or refinements. These have been deferred to Phase 8.6 for proper implementation.

---

## BUG2: Max Concurrent Positions Not Respected

### Issue
**Severity:** Medium (functional, not critical)
**Observed Behavior:** 5 open positions displayed when `max_concurrent_positions` = 2
**Expected Behavior:** Maximum 2 positions across ALL pairs

### Root Cause
In multi-pair mode, each pair gets its own `BacktestEngine` with a separate `PositionManager`. This means:
- EURUSD can have 2 positions
- GBPUSD can have 2 positions
- Total = 4+ positions (violates "across all pairs" design)

**Code Location:**
```python
# src/api/services/backtest_service.py:827-832
engine = BacktestEngine(
    initial_balance=config['initial_balance'],
    risk_percent=config['risk_percent'] * 100,
    max_positions=config['max_concurrent_positions'],  # Each pair gets own limit!
    timeframe=request.get('timeframe', 'M15')
)
```

### Required Fix
**Architectural Change:** Implement a **shared PositionManager** across all pairs in multi-pair mode.

**Proposed Solution:**
1. Create a `GlobalPositionManager` class that tracks positions across all pairs
2. Modify `BacktestEngine` to accept an optional external PositionManager
3. In `multi_pair_backtest_service`:
   - Create one GlobalPositionManager for all pairs
   - Pass it to each BacktestEngine instance
   - GlobalPositionManager enforces max_concurrent_positions across pairs

**Effort Estimate:** 4-6 hours (requires refactoring, testing)

---

## BUG4: Excessive Trade Count

### Issue
**Severity:** Low (does not break functionality, but indicates strategy tuning needed)
**Observed Behavior:** 1,946 trades in 1 month (January 2024) for 2 pairs
**Expected Behavior:** ~50-150 trades per month (based on MT5 EA typical performance)

### Root Cause Analysis
**Likely Causes:**
1. **Range Rider over-trading:** Strategy entering too frequently in ranging markets
2. **Break-even exits:** Many positions exiting at break-even (+0.5R to +1R) leading to churn
3. **Both strategies active:** TREND_RIDER + RANGE_RIDER doubling trade count
4. **Multi-pair amplification:** 2 pairs × aggressive entries = high volume

**Evidence from Test:**
- All 1,946 trades were RANGE_RIDER (TREND_RIDER had 0 trades)
- Many STOP_LOSS and BREAK_EVEN exits (low win rate)
- Suggests RANGE_RIDER is too aggressive

### Required Fix
**Strategy Tuning:** Refine RANGE_RIDER entry criteria to be more selective.

**Proposed Solutions:**
1. **Increase min_confidence threshold:** Currently 50%, raise to 60-70%
2. **Stricter range detection:** Require wider ranges (>3 ATR vs current 2 ATR)
3. **Add cooldown period:** Don't re-enter same pair for X bars after exit
4. **Volume filter:** Only trade during higher liquidity hours
5. **Add trend filter:** Don't trade RANGE_RIDER when strong H4 trend exists

**Effort Estimate:** 2-3 hours (strategy parameter tuning + validation)

---

## BUG5: Excessive Horizontal Lines on Chart

### Issue
**Severity:** Low (visual clutter, does not affect functionality)
**Observed Behavior:** Too many horizontal lines (SL/TP levels) remain on chart after trades close
**Expected Behavior:** Only show levels for currently open positions

### Root Cause
**Current Implementation:**
- Each trade's SL/TP levels are drawn as horizontal lines
- Lines are not removed when positions close
- With 1,946 trades, chart becomes cluttered with hundreds of old lines

**Code Location:**
```csharp
// ChartViewerWindow.xaml.cs - Position rendering logic
// Lines are added but never removed when position closes
```

### Required Fix
**Chart Cleanup:** Remove horizontal lines when positions close.

**Proposed Solution:**
1. Store references to ScottPlot line objects in a dictionary: `Dictionary<int, (HLine sl, HLine tp)>`
2. When position closes, look up and remove its lines from the chart
3. Alternatively: Only draw lines for **open** positions (not closed ones)

**Implementation:**
```csharp
// When position closes:
if (_positionLines.ContainsKey(position.PositionId))
{
    var (slLine, tpLine) = _positionLines[position.PositionId];
    ChartPlot.Plot.Remove(slLine);
    ChartPlot.Plot.Remove(tpLine);
    _positionLines.Remove(position.PositionId);
    ChartPlot.Refresh();
}
```

**Effort Estimate:** 1-2 hours (simple cleanup logic)

---

## Phase 8.6 Implementation Plan

### Priority Order
1. **BUG5** (1-2 hours) - Quick win, improves UX immediately
2. **BUG4** (2-3 hours) - Strategy tuning for better results
3. **BUG2** (4-6 hours) - Architectural change, requires more work

### Total Effort: 7-11 hours

---

## Notes

- All three bugs are **non-blocking** for Phase 8 completion
- Phase 8.5 can proceed to documentation and commit despite these issues
- BUG2 is the most complex and should be planned carefully
- BUG4 requires backtesting validation after parameter changes
- BUG5 is the easiest and can be done first

---

*Document updated: January 12, 2026*
