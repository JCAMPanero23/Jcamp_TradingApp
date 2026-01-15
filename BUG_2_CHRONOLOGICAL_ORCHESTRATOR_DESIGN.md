# BUG #2: Sequential Pair Loading → Chronological Orchestrator
**Date:** January 15, 2026
**Status:** Design Phase
**Estimated Effort:** 16-24 hours

---

## Problem Analysis

### Current Architecture (Sequential)
```python
# In execute_multi_pair_backtest():
for pair in pairs:  # EURUSD, GBPUSD, USDJPY
    for strategy in strategies:  # TREND_RIDER, RANGE_RIDER
        engine = BacktestEngine(...)  # Creates NEW PositionManager for each
        results = engine.run_backtest(symbol=pair, ...)  # Processes ALL bars for this pair
```

**Problems:**
1. **Per-pair position limits** - Each pair gets max_positions=2 instead of shared limit
   - Result: Can have 2 EURUSD + 2 GBPUSD + 2 USDJPY = 6 total positions (should be 2 max)
2. **Not chronological** - Processes EURUSD Jan 1-31, then GBPUSD Jan 1-31, then USDJPY Jan 1-31
   - Result: Unrealistic simulation (live trading advances all pairs simultaneously)
3. **No signal prioritization** - Can't compare signals across pairs at same timestamp
   - Result: Missing trades that would happen in live trading
4. **Position slot timing incorrect** - EURUSD closes position → immediately available for EURUSD again
   - Reality: When EURUSD closes → slot available for ANY pair (EURUSD, GBPUSD, or USDJPY)

---

## Solution Design

### New Architecture (Chronological Orchestrator)

```python
def execute_multi_pair_backtest_chronological(task_id, request):
    """
    True chronological multi-pair backtest.
    Advances all pairs bar-by-bar in timestamp order.
    """
    # 1. Create SINGLE shared PositionManager for ALL pairs
    position_manager = PositionManager(max_positions=2)  # Shared across all pairs

    # 2. Load data for all pairs
    pair_engines = {}
    for pair in pairs:
        engine = BacktestEngine(
            initial_balance=initial_balance,
            risk_percent=risk_percent,
            max_positions=max_positions,
            position_manager=position_manager  # SHARED!
        )
        engine.prepare_data(pair, year, start_date, end_date)
        pair_engines[pair] = engine

    # 3. Create global timeline (all timestamps across all pairs)
    all_timestamps = get_chronological_timestamps(pair_engines)

    # 4. Advance bar-by-bar chronologically
    for timestamp in all_timestamps:
        # Check exits for all pairs
        for pair, engine in pair_engines.items():
            if has_bar_at_timestamp(engine, timestamp):
                engine.check_exits_at_timestamp(timestamp)

        # Check entries for all pairs (prioritize if needed)
        entry_signals = []
        for pair, engine in pair_engines.items():
            if has_bar_at_timestamp(engine, timestamp):
                signal = engine.check_entry_signal_at_timestamp(timestamp)
                if signal:
                    entry_signals.append((pair, signal))

        # Prioritize and execute entries (if position slots available)
        process_entry_signals(entry_signals, position_manager)

    # 5. Compile results
    return aggregate_results(pair_engines)
```

---

## Implementation Plan

### Phase 1: Shared Position Manager (2-3 hours)
**Goal:** Modify execute_multi_pair_backtest to use shared PositionManager

**Changes:**
1. **File:** `src/api/services/backtest_service.py`
   - Create single PositionManager instance before pair loop
   - Pass to each BacktestEngine via `position_manager` parameter

```python
# In execute_multi_pair_backtest():
# Create shared position manager BEFORE pair loop
shared_position_manager = PositionManager(config.get("max_concurrent_positions", 2))

for pair in pairs:
    engine = BacktestEngine(
        initial_balance=config.get("initial_balance", 10000.0),
        risk_percent=config.get("risk_percent", 2.0),
        max_positions=config.get("max_concurrent_positions", 2),
        timeframe=request.get("timeframe", "M15"),
        position_manager=shared_position_manager  # SHARED!
    )
    # ... rest of backtest
```

**Testing:**
- Run multi-pair backtest with EURUSD + GBPUSD
- Verify max 2 positions TOTAL (not 2 per pair)
- Check logs for position slot usage

**Benefit:** Quick win (2-3 hours), fixes position limit issue immediately

---

### Phase 2: Chronological Timeline (4-6 hours)
**Goal:** Create global timeline and advance bars chronologically

**New Components:**

#### 1. Timeline Generator
```python
def create_global_timeline(pair_engines: Dict) -> List[Tuple[datetime, str]]:
    """
    Create chronological timeline of all bars across all pairs.

    Returns:
        List of (timestamp, pair) tuples sorted chronologically
    """
    timeline = []
    for pair, engine in pair_engines.items():
        for idx in range(len(engine.df)):
            timestamp = engine.df.index[idx]
            timeline.append((timestamp, pair, idx))

    # Sort chronologically
    timeline.sort(key=lambda x: x[0])
    return timeline
```

#### 2. Chronological Orchestrator
```python
def process_chronological_bars(pair_engines: Dict, timeline: List):
    """
    Process bars in chronological order across all pairs.
    """
    for timestamp, pair, bar_idx in timeline:
        engine = pair_engines[pair]

        # 1. Check exits for ALL pairs at this timestamp
        for p, eng in pair_engines.items():
            eng.check_exits_at_current_price(timestamp)

        # 2. Check entry signal for this specific pair
        if engine.position_manager.can_open_position():
            engine._check_entries(engine.df, bar_idx, pair)
```

**Testing:**
- Verify bars advance in timestamp order (not pair-by-pair)
- Check trade timestamps are chronological across pairs
- Verify position slots released immediately when closed

---

### Phase 3: Signal Prioritization (4-6 hours)
**Goal:** When multiple pairs signal simultaneously, prioritize best signal

**New Logic:**
```python
def collect_signals_at_timestamp(pair_engines: Dict, timestamp: datetime) -> List:
    """
    Collect all entry signals at this timestamp across all pairs.

    Returns:
        List of (pair, signal, confidence) tuples
    """
    signals = []
    for pair, engine in pair_engines.items():
        if not engine.position_manager.can_open_position():
            continue

        bar_idx = engine.get_bar_index_at_timestamp(timestamp)
        if bar_idx is None:
            continue

        # Get signal from strategy
        signal = engine.evaluate_signal_at_bar(bar_idx)
        if signal and signal['should_enter']:
            signals.append((pair, signal, signal['confidence']))

    return signals


def prioritize_and_execute_signals(signals: List, position_manager: PositionManager):
    """
    Prioritize signals by confidence and execute if slots available.
    """
    # Sort by confidence (highest first)
    signals.sort(key=lambda x: x[2], reverse=True)

    # Execute best signals up to available slots
    for pair, signal, confidence in signals:
        if not position_manager.can_open_position():
            break

        # Execute entry
        execute_entry(pair, signal)
```

**Testing:**
- Create scenario with simultaneous signals from 3 pairs
- Verify only highest confidence signals get executed
- Verify lower confidence signals rejected due to position limits

---

### Phase 4: Testing & Validation (4-6 hours)

#### Test Scenarios

**Test 1: Position Limit Enforcement**
- Config: EURUSD + GBPUSD, max_positions=2
- Expected: Never more than 2 open positions across both pairs
- Verify: Position log shows proper slot management

**Test 2: Chronological Processing**
- Config: 3 pairs, 1 month
- Verify: Trade timestamps are chronological across all pairs
- Verify: Trade log shows interleaved pairs (not all EURUSD, then all GBPUSD)

**Test 3: Signal Prioritization**
- Create synthetic signals at same timestamp with different confidence
- Expected: Higher confidence signal wins
- Verify: Only 2 best signals get executed when 3+ pairs signal

**Test 4: Realistic Trade Count**
- Config: EURUSD + GBPUSD, Jan 2024, Both strategies
- Expected: ~40-100 trades (not 1,946!)
- Verify: Trade count reasonable for 2 pairs × 1 month

**Test 5: Performance Verification**
- Compare sequential vs chronological results
- Verify: Chronological results are MORE realistic
- Verify: Position management more accurate

---

## Backward Compatibility

### Two Implementation Options

#### Option 1: New Method (Recommended)
- Create new `execute_multi_pair_backtest_chronological()` method
- Keep old `execute_multi_pair_backtest()` for backward compatibility
- Add request parameter: `"chronological": true/false`
- Default to chronological after testing

**Pros:**
- Can test without breaking existing functionality
- Easy rollback if issues found
- Gradual migration path

**Cons:**
- Code duplication (temporary)

#### Option 2: Replace Existing (Aggressive)
- Modify `execute_multi_pair_backtest()` directly
- No backward compatibility
- One implementation to maintain

**Pros:**
- Clean codebase
- No duplication

**Cons:**
- Can't rollback easily
- Higher risk

**Recommendation:** Use Option 1 during implementation, migrate to Option 2 after validation

---

## File Changes Summary

### Modified Files
1. **src/api/services/backtest_service.py** (primary changes)
   - Add `execute_multi_pair_backtest_chronological()` method
   - Add helper methods: `create_global_timeline()`, `collect_signals_at_timestamp()`, `prioritize_signals()`
   - Modify `execute_multi_pair_backtest()` to use shared PositionManager (Phase 1 quick win)

2. **src/backtest_engine.py** (minor changes)
   - Already supports shared PositionManager (✅ no changes needed!)
   - May add helper: `check_exits_at_current_price(timestamp)` for cleaner code
   - May add helper: `evaluate_signal_at_bar(idx)` to separate signal evaluation from execution

3. **src/position_manager.py** (no changes needed)
   - Already supports shared usage across multiple engines
   - ✅ Architecture already prepared for this!

### New Files
- None required (all changes in existing files)

---

## Success Criteria

### Functional Requirements
- ✅ Max 2 positions TOTAL across all pairs (not per pair)
- ✅ Bars processed in chronological order (timestamp-sorted)
- ✅ Position slots immediately available after closing (any pair can use)
- ✅ Signal prioritization when multiple pairs signal simultaneously
- ✅ Trade count reasonable (~40-100 for 2 pairs × 1 month, not 1,946)

### Performance Requirements
- ✅ Load time ≤ 10 seconds for 1 year × 3 pairs
- ✅ No significant slowdown vs sequential processing
- ✅ Memory usage acceptable (<2GB for typical backtest)

### Code Quality
- ✅ Clean, documented code
- ✅ Minimal duplication
- ✅ Easy to understand and maintain
- ✅ Backward compatible (during transition)

---

## Timeline Estimate

| Phase | Task | Hours | Cumulative |
|-------|------|-------|------------|
| 1 | Shared PositionManager quick win | 2-3h | 2-3h |
| 2 | Chronological timeline | 4-6h | 6-9h |
| 3 | Signal prioritization | 4-6h | 10-15h |
| 4 | Testing & validation | 4-6h | 14-21h |
| **Total** | **All phases** | **14-21h** | **~16-24h** |

**Recommended Approach:**
- Session 1 (3h): Phase 1 - Quick win with shared PositionManager
- Session 2 (5h): Phase 2 - Chronological timeline
- Session 3 (5h): Phase 3 - Signal prioritization
- Session 4 (5h): Phase 4 - Comprehensive testing

---

## Next Steps

1. **Approve design** - Review and confirm approach
2. **Start Phase 1** - Implement shared PositionManager (2-3 hours, immediate benefit)
3. **Test Phase 1** - Verify position limits working correctly
4. **Continue to Phase 2** - Implement chronological timeline
5. **Final validation** - Run comprehensive multi-pair tests

---

## Questions for User

1. **Should we start with Phase 1 (shared PositionManager)** for quick win? (2-3 hours)
2. **Do you want full chronological orchestrator** (all 4 phases) or incremental approach?
3. **Preferred testing strategy** - Unit tests or integration tests?
4. **Backward compatibility** - Keep old method during transition or replace immediately?

---

Ready to implement when you approve! 🚀
