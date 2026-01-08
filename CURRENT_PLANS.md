# CURRENT PLANS - JCAMP Forex Trading System

**Purpose:** Single authoritative source for all active development plans
**Last Updated:** December 11, 2025 (Session 3 Complete - Testing in Progress)
**Location:** `D:\JcampFxTrading\CURRENT_PLANS.md` (Local - NOT in .claude folder)

---

## ✅ PHASE 7A: INDICATOR VALIDATION (COMPLETE)

**Status:** ✅ COMPLETE
**Branch:** `phase7-validate-initial-load`
**Goal:** Validate Python indicators match MT5 EA exactly before C# strategy migration
**Completed:** December 11, 2025

### Plan Overview

Ensure all Python indicators (ATR, EMA, ADX, RSI) calculate identically to MT5 EA v1.96 so strategy migration to C# is safe.

### Tasks

1. **Modify MT5 EA to log indicator values** (30-45 min)
   - Add logging in `OnInit()` and `OnTick()` for first bar
   - Export indicator values to CSV or copy from MT5 log
   - Reference: `D:\JcampFxTrading\Jcamp_BacktestEA.mq5` v1.96

2. **Create test_indicator_accuracy.py** (30-45 min)
   - File: `tests/test_indicator_accuracy.py` (NEW, ~200-250 LOC)
   - Test framework comparing Python vs MT5 calculations
   - 4 test methods: ATR, EMA, ADX, RSI
   - Tolerance: ±0.00001 (ATR/EMA), ±0.1 (ADX/RSI)

3. **Add RSI to indicators.py** (15-30 min)
   - ✅ ALREADY DONE - RSI implemented at lines 280-348
   - Includes `calculate_rsi()`, `get_rsi()`, `is_rsi_overbought()`, `is_rsi_oversold()`

4. **Collect MT5 reference data** (30-45 min)
   - Run MT5 backtest on EURUSD H1 (2024-12-01 to 2024-12-07)
   - Export or screenshot indicator values for 10+ bars
   - Save to `tests/fixtures/mt5_reference_data.csv`

5. **Run validation tests** (15-30 min)
   - Execute: `python -m pytest tests/test_indicator_accuracy.py -v`
   - Verify all tests pass within tolerance
   - Document any systematic differences

6. **Document findings** (15-30 min)
   - Update CLAUDE.md with validation results
   - Record any precision differences or warmup behavior
   - Confirm safe to proceed with C# migration

### Key Tolerances

| Indicator | Tolerance | Rationale |
|-----------|-----------|-----------|
| ATR(14) | ±0.00001 | Price precision (5 decimals) |
| EMA(20/50/100) | ±0.00001 | Price precision (5 decimals) |
| ADX(14) | ±0.1 | Smoothing differences |
| RSI(14) | ±0.1 | Momentum calculation |
| +DI/-DI(14) | ±0.1 | Direction components |

### Success Criteria

✅ All 5 test methods pass within tolerance
✅ Warmup periods correct (EMA 100 after bar 100, ADX after bar 30)
✅ No systematic bias (always higher/lower by fixed amount)
✅ Documentation updated

### Files Involved

**Create:**
- `tests/test_indicator_accuracy.py` (NEW)
- `tests/fixtures/mt5_reference_data.csv` (NEW)

**Modify:**
- (None - RSI already done)

**Reference:**
- `D:\JcampFxTrading\Jcamp_BacktestEA.mq5`
- `src/indicators.py`

### Next Steps After Validation

1. ✅ **Indicators validated** → Proceed to Phase 7B (Strategy Enhancements)
2. ❌ **Issues found** → Fix calculation differences in Python before proceeding

---

## 🔥 PHASE 7B: C# STRATEGY MIGRATION (18-24 hours)

**Status:** ✅ IMPLEMENTATION COMPLETE - Session 1✅ Session 2✅ Session 3✅ | 🔄 TESTING IN PROGRESS
**Branch:** `phase7-csharp-strategies`
**Priority:** TOP - Critical for real-time trading
**Goal:** Port MT5 EA v1.96 strategy logic to C# for real-time trading execution
**Started:** December 11, 2025
**Completion Est.:** Pending backtest validation results

### Migration Overview

**Objective:** Copy existing MT5 EA v1.96 logic to C# while keeping regime detection identical to validated Python implementation.

**Architecture:**
```
JcampForexTrader/
├── Indicators/           [NEW] - EMA, ATR, ADX, RSI calculators
├── Regime/              [NEW] - Regime detection (port from Python)
├── Strategies/          [NEW] - Trend Rider, Range Rider strategies
├── RiskManagement/      [NEW] - Position sizing, SL/TP calculation
└── [Integration with ChartViewerWindow]
```

**Key Components:**
1. **Technical Indicators:** EMA(20/50/100), ATR(14), ADX(14), RSI(14)
2. **Regime Detection:** Trending/Ranging/Transitional scoring system
3. **Trend Rider Strategy:** 135-point confidence scoring, EMA alignment
4. **Range Rider Strategy:** Support/resistance detection, mean reversion
5. **Strategy Engine:** Orchestrate indicators → regime → signals

### Session 1: Foundation (6-8 hours)

#### 1.1: Create Indicator Infrastructure (2 hours)

**Files to Create:**
- `CSMMonitor/JcampForexTrader/Indicators/IIndicator.cs` (NEW, ~30 LOC)
- `CSMMonitor/JcampForexTrader/Indicators/IndicatorData.cs` (NEW, ~80 LOC)
- `CSMMonitor/JcampForexTrader/Indicators/EmaCalculator.cs` (NEW, ~120 LOC)
- `CSMMonitor/JcampForexTrader/Indicators/AtrCalculator.cs` (NEW, ~100 LOC)

**Implementation:** EMA, ATR calculators with proper warmup handling

**Validation:** Unit test against Python indicators (±0.00001 tolerance)

---

#### 1.2: Implement ADX and RSI (2 hours)

**Objective:** Protect capital after small profit

**File:** `src/strategies/trend_rider.py`

**Config to add:**
- `breakeven_activation_r` = 0.8R
- `breakeven_buffer_pips` = 2

**Implementation:**
```python
# Move stop to breakeven + 2 pips after 0.8R profit
if current_r >= 0.8 and not position.breakeven_moved:
    if signal == 'BUY':
        position.stop_loss = entry_price + (2 * pip_size)
    else:
        position.stop_loss = entry_price - (2 * pip_size)
    position.breakeven_moved = True
```

**Expected Impact:** +2-3R improvement

---

#### 1.3: Trend Rider Take Profit Targets (1.5 hours)

**Objective:** Scale out at key profit levels

**File:** `src/strategies/trend_rider.py`

**Config to add:**
- `use_partial_exits` = True
- `tp1_r_multiple` = 2.0R (close 50%)
- `tp2_r_multiple` = 3.5R (close 30%)
- `tp3_trail_remainder` = True (trail 20%)

**Logic:**
```
TP1: Close 50% at 2.0R, move stop to breakeven
TP2: Close 30% at 3.5R, trail remainder by 1.0 ATR
TP3: Trail remaining 20% until stopped out
```

**Expected Impact:** +4-6R improvement

---

#### 1.4: Daily Loss Limit (1 hour)

**Objective:** Protect capital by stopping trading after max daily loss

**File:** `src/performance_tracker.py` (already has placeholder!)

**Config to add:**
- `max_daily_loss_pct` = 5%
- `max_daily_loss_trades` = 3 consecutive losses

**Logic:**
```python
if daily_loss_pct > 5.0 or consecutive_losses >= 3:
    return True  # Block new trades until next day
```

**Expected Impact:** -2 to -5R protection (prevent blown accounts)

---

#### 1.5: Position Correlation Filter (2 hours)

**Objective:** Avoid correlated positions that amplify risk

**File:** `src/position_manager.py`

**Config to add:**
```python
correlation_map = {
    'EURUSD': ['GBPUSD', 'EURGBP'],
    'GBPUSD': ['EURUSD', 'EURGBP'],
    'AUDUSD': ['NZDUSD', 'AUDNZD'],
    'NZDUSD': ['AUDUSD', 'AUDNZD'],
    'USDJPY': ['USDCHF'],
    'USDCHF': ['USDJPY']
}
```

**Logic:**
```python
# Block new trade if 2+ correlated positions already open
if count_correlated_positions(new_symbol) >= 2:
    return False  # Can't open position
```

**Expected Impact:** -1 to -3R protection

---

### Session 2: Strategy Implementation (4-5 hours) - ✅ COMPLETE
**Commit:** d2c9499

#### 2.1: Create Strategy Base Classes (2 hours) - ✅ COMPLETE
- Files: IStrategy.cs, BaseStrategy.cs, StrategyConfig.cs
- Strategy interface with Evaluate() and CanTrade() methods
- Abstract base class for common functionality
- Configuration model with regime and risk parameters

#### 2.2: Implement Trend Rider Strategy (3-4 hours) - ✅ COMPLETE
- File: `Strategies/TrendRiderStrategy.cs` (~500 LOC)
- 135-point confidence scoring system
- EMA alignment, ADX strength, momentum, CSM support scores
- Bullish/bearish alignment detection
- RSI overbought/oversold filters

#### 2.3: Implement Range Rider Strategy (3-4 hours) - ✅ COMPLETE
- File: `Strategies/RangeRiderStrategy.cs` (~450 LOC)
- Support/resistance detection (100-bar lookback)
- Range width validation (ATR-based)
- Edge proximity detection
- RSI mean reversion confirmation

---

### Session 3: Strategy Engine Integration & Testing (3-4 hours) - ✅ COMPLETE

#### 3.1: Create Strategy Engine (2 hours) - ✅ COMPLETE
**Commit:** 1eaee6a
- File: `Strategies/StrategyEngine.cs` (~330 LOC)
- Orchestrates indicator → regime → strategy evaluation
- Caching system for performance optimization
- Result class: `StrategyEvaluationResult`

#### 3.2: ChartViewerWindow Integration (1 hour) - ✅ COMPLETE
**Components Updated:**
- Added `StrategyEngine` field and initialization
- Created `UpdateStrategyPanel()` method
- Integrated evaluation into `RenderChartUpToBar()`
- Real-time updates during playback

#### 3.3: Strategy Signals UI (1 hour) - ✅ COMPLETE
**XAML Changes:**
- Added "Strategy Signals" section to Indicators tab
- New TextBlocks: StrategyNameText, SignalText, ConfidenceText, ReasoningText
- Color-coded displays: regime, signals, confidence levels

**Status:** Implementation complete, **testing in progress**

---

### Session 4 (Optional): Unit Tests & Bug Fixes
- **Conditional:** If testing reveals issues, debug and fix
- **Unit Tests:** Only if time permits (2-3 hours)
- Reference: Original Session 3.2 plan for test structure

### Session 5 (Optional): Breakout Rider Strategy
- Capture explosive moves on breakouts
- File: NEW `src/strategies/breakout_rider.py` (300-400 LOC)
- Expected Performance: +8-12R

---

## 📋 PHASE 5.3 UX ENHANCEMENTS - DEFERRED

**Status:** ⏸️ DEFERRED until after Phase 7
**Complexity:** 13-19 hours total

### Enhancement #1: Timeline-Based Recent Trades (Completed)
- Remove `.Take(30)` hardcoded limit
- Add time-based filter by playback position
- Files: ChartViewerWindow.xaml, ChartViewerWindow.xaml.cs

### Enhancement #3: Multi-Pair Chart Existing Tab Display (13-19 hours)
- Synchronized playback across all pairs
- Combined trades list
- Files: Backend API, C# models, Multi-chart Tab
- Auto Call tab viewing based on Trade Slot number 1
- if slot number 1 closed. slot number 2 goes to slot number 1 position

**Note:** Need to Plan properly

---

## 📁 PROJECT STRUCTURE

```
D:\JcampFxTrading/
├── CLAUDE.md                          # Main project context (READ THIS FIRST)
├── CURRENT_PLANS.md                   # This file - Active development plans
├── STATUS.md                          # Dynamic progress tracking (if exists)
│
├── archive/                           # Archived docs from old sessions
│   ├── docs/                          # Old implementation docs
│   └── plans/                         # Old session summaries
│
├── jcamp-python-backtesting/          # Python backtesting engine
│   ├── src/
│   │   ├── indicators.py              # ✅ Technical indicators (RSI added)
│   │   ├── strategies/
│   │   │   ├── simple_test.py
│   │   │   ├── trend_rider.py         # Phase 7B enhancements
│   │   │   └── range_rider.py         # Phase 7B enhancements
│   │   ├── position_manager.py        # Correlation filter (Phase 7B)
│   │   └── performance_tracker.py     # Daily loss limit (Phase 7B)
│   ├── tests/
│   │   └── test_indicator_accuracy.py # Phase 7A (NEW)
│   └── docs/current/
│       ├── PHASE_5_7_MASTER_PLAN.md
│       ├── PHASE_6_SMART_PORTFOLIO.md
│       └── PHASE_7_STRATEGY_ENHANCEMENTS.md
│
└── CSMMonitor/                        # C# WPF viewer
    ├── ChartViewerWindow.xaml.cs      # Phase 5.3 enhancements
    └── BacktestWindow.xaml.cs         # Phase 5.3 integration
```

---

## ✅ COMPLETED PHASES

### Phase 1-5: Core Engine
- ✅ Data loading and CSV parsing
- ✅ Timeframe conversion (M1/M15/H1/H4)
- ✅ Technical indicators (ATR, EMA, ADX, RSI)
- ✅ Regime detection (Trending/Ranging/Transitional)
- ✅ 3 trading strategies (Simple Test, Trend Rider, Range Rider)

### Phase 5.2: EMA Display Fix
- ✅ Fixed H1 EMA lookahead bias
- ✅ EMAs now display correctly in C# viewer
- ✅ Key commit: 13e2366

### Phase 5.3 Part 1: Viewport Fixes
- ✅ M1 viewport positioning (80% position maintained)
- ✅ Reset button viewport fix
- ✅ Zoom level preservation
- ✅ Key commits: 2309b9d, ed49bc2, f951fc0, ec96f47

### Performance Optimization Phase 1
- ✅ **Result:** 13 min → 46 sec (94% improvement)
- ✅ Eliminated duplicate H1 EMA calculations
- ✅ Reuse M1 data from engine
- ✅ Vectorized EMA interpolation
- ✅ Progress logging added

### Regime Detection Enhancements
- ✅ ATR volatility component
- ✅ Price action analysis
- ✅ Competitive scoring system
- ✅ MT5 validation logging

---

## 🎯 BUSINESS TIMELINE

```
Current (Dec 2025)
    ↓
Phase 7A: Indicator Validation (2-3 hrs)
    ↓
Phase 7B: Strategy Enhancements (14-18 hrs)
    ↓
Demo Account Validation (2 months) → Feb-Mar 2026
    ↓
Live Account Validation (4 months, $500 risk) → Apr-Jul 2026
    ↓
Launch Signal Service ($50/mo per subscriber) → Aug 2026
    ↓
Scale to 100 subscribers = $5k/month → Dec 2026
```

---

## 📊 KEY METRICS

| Metric | Value |
|--------|-------|
| Total Code | ~4,685 LOC (production) |
| Test Coverage | 97% (30/31 tests passing) |
| Performance vs MT5 | 100-600x faster |
| **Load Time (Target)** | **46 seconds** |
| API Endpoints | 5 operational |
| Strategies | 3 (Simple Test, Trend Rider, Range Rider) |
| Supported Pairs | 3+ (EURUSD, GBPUSD, USDJPY, etc.) |
| Current R-Multiple | +16.04R |
| **Target R-Multiple** | **+25-32R** |

---

## 🔧 QUICK COMMANDS

### Check Project Status
```bash
cd D:\JcampFxTrading\jcamp-python-backtesting
git status
git log -5 --oneline
```

### Run Indicator Validation Tests (Phase 7A)
```bash
cd D:\JcampFxTrading\jcamp-python-backtesting
python -m pytest tests/test_indicator_accuracy.py -v
```

### Run All Tests
```bash
cd D:\JcampFxTrading\jcamp-python-backtesting
python -m pytest tests/ -v
```

### Start API Server
```bash
cd D:\JcampFxTrading\jcamp-python-backtesting
python -m uvicorn src.api.main:app --reload
```

### Build C# Project
```bash
cd D:\JcampFxTrading\CSMMonitor
dotnet build
```

---

## 📝 HOW TO USE THIS FILE

1. **At Session Start:** Read CLAUDE.md first (main context), then this file (plans)
2. **During Work:** Reference the phase you're working on for tasks and files
3. **For Planning:** Check "Next Steps" sections in each phase
4. **For Context:** Look at "Files Involved" to understand scope
5. **For Status:** Check "Status:" field at top of each phase

---

## 🗂️ ARCHIVE STRUCTURE

Old documentation moved to `D:\JcampFxTrading\archive/`:

**Session Summaries:**
- SESSION_SUMMARY_*.md (deprecated)
- PHASE_7_SESSION_SUMMARY.md

**Implementation Docs:**
- CHART_VIEWER_*.md
- EMA_ALIGNMENT_FIX.md
- M1_DATA_GAP_ANALYSIS.md
- REGIME_CSM_COMPARISON.md

**Validation Docs:**
- VALIDATION_*.md
- DATA_REQUIREMENTS_*.md
- CLEANUP_SUMMARY.md
- IMPLEMENTATION_STATUS.md

**Note:** Do NOT use archived docs - they're outdated. Use CURRENT_PLANS.md instead.

---

## ❌ OLD LOCATIONS (DO NOT USE)

These locations are DEPRECATED:
- ❌ `C:\Users\jcamp\.claude\plans\` - Stop using this folder
- ❌ `D:\JcampFxTrading\jcamp-python-backtesting\docs\current\PHASE_5_7_MASTER_PLAN.md` - Reference only
- ❌ `D:\JcampFxTrading\jcamp-python-backtesting\docs\current\PHASE_6_SMART_PORTFOLIO.md` - Reference only

**New Single Source of Truth:**
- ✅ `D:\JcampFxTrading\CURRENT_PLANS.md` (THIS FILE)
- ✅ `D:\JcampFxTrading\CLAUDE.md` (Project context)

---

**Last Updated:** December 10, 2025
**Maintained By:** Claude Code
**Next Review:** After Phase 7A completion



---

## 📋 PHASE 7B DETAILED IMPLEMENTATION PLAN

See full detailed plan in: `D:\JcampFxTrading\Plans\Phase_7B_C#StrategyMigrationImplementation_Plan.md`

**Summary:** 20 new files (~4,200 LOC), 3 sessions (18-24 hours total)

**Session 1:** ✅ Indicators (EMA, ATR, ADX, RSI) + Regime Detection (COMPLETE - Dec 11)
**Session 2:** ✅ Strategy classes (Trend Rider, Range Rider) (COMPLETE - Dec 11)
- 6 new files: IStrategy.cs, StrategyConfig.cs, BaseStrategy.cs, TrendRiderStrategy.cs, RangeRiderStrategy.cs, TrendRiderComponentScores
- 1,290 LOC total
- 135-point confidence scoring (Trend Rider)
- Support/resistance detection (Range Rider)

**Session 3:** 🔄 Strategy Engine + Testing + Integration (NEXT)


