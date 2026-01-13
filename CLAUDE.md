# CLAUDE.md - JCAMP Forex Trading System Context

**Purpose:** Single authoritative reference for Claude Code to understand project state and start working effectively.
**Last Updated:** January 14, 2026 (Phase 8.5 Comprehensive Testing - 5 Critical Bugs Documented)
**Current Phase:** 🚀 PHASE 8.5 - TESTING & VALIDATION (Comprehensive Test Complete - Major Rework Needed)

---

## 🚨 CRITICAL - PATH CONFIGURATION

**Environment:** Windows 11 + Git Bash (via Claude Code)
**Shell Type:** Git Bash (MINGW64)

### Path Format Rules - ALWAYS USE GIT BASH PATHS

**Git Bash paths (REQUIRED):**
```bash
# Project root
/d/Jcamp_TradingApp/

# Sub-directories
/d/Jcamp_TradingApp/jcamp-python-backtesting/
/d/Jcamp_TradingApp/CSMMonitor/
/d/Jcamp_TradingApp/plans/
```

**Conversion Rule:**
- Windows: `D:\Jcamp_TradingApp\folder` 
- Git Bash: `/d/Jcamp_TradingApp/folder` (lowercase drive letter, forward slashes)

**NEVER use:**
- ❌ `D:\` (Windows backslash paths)
- ❌ `/mnt/d/` (WSL-style paths)

**ALWAYS use:**
- ✅ `/d/` (Git Bash paths with lowercase drive letter)

---

## 📁 PROJECT STRUCTURE

```
/d/Jcamp_TradingApp/
├── CLAUDE.md                          # This file (startup context)
├── CURRENT_PLANS.md                   # Active development plans
├── STATUS.md                          # Dynamic status tracking
├── Jcamp_BacktestEA.mq5              # MT5 Expert Advisor (reference)
│
├── Plans/                             # Detailed implementation plans
│   ├── Phase_7B_C#StrategyMigrationImplementation_Plan.md
│   └── 2025-12-31-MultiPair-Backtest-Design.md
│
├── jcamp-python-backtesting/         # Python backtesting (Git repo)
│   ├── src/
│   │   ├── backtest_engine.py        # Core engine (handles warmup)
│   │   ├── data_loader.py            # Data loading & CSM
│   │   ├── indicators.py             # EMA/ADX/RSI/ATR
│   │   ├── api/
│   │   │   ├── main.py               # FastAPI server (port 8000)
│   │   │   ├── routes/backtest.py    # API endpoints
│   │   │   └── services/backtest_service.py
│   │   ├── strategies/
│   │   │   ├── simple_test.py
│   │   │   ├── trend_rider.py
│   │   │   └── range_rider.py
│   │   └── position_manager.py
│   └── tests/                        # 30/31 passing (97% coverage)
│
└── CSMMonitor/                        # C# WPF app (separate Git repo)
    ├── JcampForexTrader/
    │   ├── Models/
    │   │   ├── Indicators/           # NEW - Session 1 (Dec 11)
    │   │   │   ├── IIndicator.cs
    │   │   │   ├── EmaCalculator.cs
    │   │   │   ├── AtrCalculator.cs
    │   │   │   ├── AdxCalculator.cs
    │   │   │   └── RsiCalculator.cs
    │   │   └── RegimeDetector.cs     # NEW - Session 1 (Dec 11)
    │   ├── ChartViewerWindow.xaml.cs # Chart display + playback
    │   └── BacktestWindow.xaml.cs    # Config UI
    └── .git/
```

---

## ⚙️ STANDARD COMMANDS

### Initial Setup (First Time Only)
```bash
# Clone the entire project with all submodules
git clone --recursive https://github.com/JCAMPanero23/Jcamp_TradingApp.git

# If you already cloned without --recursive, initialize submodules:
cd /d/JcampFxTrading
git submodule update --init --recursive
```

### Git Operations
```bash
# Check parent repo status
cd /d/JcampFxTrading && git status

# Check Python backtest status (submodule)
cd /d/Jcamp_TradingApp/jcamp-python-backtesting && git status

# Check C# Monitor status (submodule)
cd /d/Jcamp_TradingApp/CSMMonitor && git status

# View recent commits
cd /d/Jcamp_TradingApp/jcamp-python-backtesting && git log -3 --oneline

# Update all submodules to latest remote commits
cd /d/JcampFxTrading && git submodule update --remote --merge
```

### Python Testing
```bash
# Run all tests
cd /d/Jcamp_TradingApp/jcamp-python-backtesting && python -m pytest tests/ -v

# Run specific phase tests
cd /d/Jcamp_TradingApp/jcamp-python-backtesting && python -m pytest tests/test_phase4.py -v
```

### API Server
```bash
# Start FastAPI server
cd /d/Jcamp_TradingApp/jcamp-python-backtesting && python -m uvicorn src.api.main:app --reload
```

### C# Project
```bash
# Build C# project
cd /d/Jcamp_TradingApp/CSMMonitor && dotnet build

# Run C# tests (when implemented)
cd /d/Jcamp_TradingApp/CSMMonitor && dotnet test
```

### File Viewing
```bash
# View plan files
cat /d/Jcamp_TradingApp/plans/Phase_7B_C#StrategyMigrationImplementation_Plan.md

# View CURRENT_PLANS.md
cat /d/Jcamp_TradingApp/CURRENT_PLANS.md

# List C# indicators
ls -la /d/Jcamp_TradingApp/CSMMonitor/JcampForexTrader/Models/Indicators/
```

---

## 📌 QUICK STATUS

| Component | Status | Details |
|-----------|--------|---------|
| **Python Backend** | ✅ Operational | FastAPI on port 8000 |
| **C# Chart Viewer** | ✅ Operational | M1 viewport positioning FIXED, playback smooth |
| **C# Indicators** | ✅ Complete | EMA, ATR, ADX, RSI (Session 1 - Dec 11) |
| **C# Regime Detection** | ✅ Complete | TRENDING/RANGING/TRANSITIONAL (Session 1) |
| **C# Strategies** | ✅ Complete | Trend Rider + Range Rider (Session 2 - Dec 11) |
| **C# Strategy Engine** | ✅ Complete | Orchestration + ChartViewer Integration (Session 3 - Dec 11) |
| **Strategy UI** | ✅ Complete | Real-time signals, regime, indicators display (Session 3) |
| **M1 Playback Fix** | ✅ Complete | UpdateStrategyPanel now called during M1 playback (Session 4 - Dec 12) |
| **Indicator Display Fix** | ✅ Complete | Fixed UpdateChartInfo() overwrite issue (Session 5 - Dec 14) |
| **Phase 8.1 - Python API** | ✅ Complete | Multi-pair endpoint, strategy selection FIXED, 10/10 tests passing |
| **Phase 8.2 - C# Multi-Pair UI** | ✅ Complete | BacktestWindow + ChartViewer multi-pair support (5 commits) |
| **Phase 8.3 - C# Playback** | ✅ Complete | Global timeline playback + visual trade timeline (2 commits, ~402 LOC) |
| **Phase 8.4 - Export** | ⏸️ Postponed | CSV export and reporting deferred to later |
| **Phase 8.5 - Testing** | 🔴 Major Issues Found | 5 critical bugs identified in 5-hour comprehensive test (Jan 13-14) |
| **Main Branch** | ✅ Updated | Phase 5.2 & 5.3 Part 1 complete |
| **Phase 7B Branch** | ✅ Complete | phase7-csharp-strategies (5 sessions complete) |

---

## 🎯 CURRENT FOCUS: PHASE 8 - MULTI-PAIR BACKTESTING

**Phase 8 Status:** Phase 8.1 ✅ | Phase 8.2 ✅ | Phase 8.3 ✅ | Phase 8.4 ⏸️ POSTPONED | Phase 8.5 🔴 MAJOR ISSUES FOUND

**Design Document:** `/d/Jcamp_TradingApp/Plans/2025-12-31-MultiPair-Backtest-Design.md`

**Core Vision:** MT5 Strategy Tester reimagined with multi-pair support and realistic trading simulation

**Architecture Principle:** **Python = Brain** (single source of truth for strategy logic)
- Python: Strategy evaluation, position management, backtest orchestration
- C#: Visualization, playback controls, statistics display, export

**Key Features Designed:**
- ✅ Multi-pair backtesting (test 3+ pairs simultaneously)
- ✅ Strategy selection (Trend Rider, Range Rider, or both)
- ✅ Interactive MT5-style playback (pause, step, jump to any trade)
- ✅ Clickable trade timeline (review any trade instantly)
- ✅ Real-time statistics (account status, open positions, performance)
- ✅ Export functionality (CSV, reports, configurations)
- ✅ Fast load times (~8-10 seconds for 1 year × 3 pairs)

**Implementation Roadmap:** 5 Phases
- Phase 8.1: Python API Enhancement ✅ COMPLETE
- Phase 8.2: C# Configuration Window ✅ COMPLETE
- Phase 8.3: C# Playback Window ✅ COMPLETE
- Phase 8.4: Export & Reporting ⏸️ POSTPONED
- Phase 8.5: Testing & Validation 🔴 MAJOR ISSUES FOUND

**Current Session:** Phase 8.5 - Bug Fixing (5 critical bugs from comprehensive test)

---

## 🚀 RECENT MILESTONES

### ✅ Phase 8.1 - PYTHON MULTI-PAIR API COMPLETE + BUGFIX (Jan 11, 2026)
**Branch:** main (jcamp-python-backtesting submodule)
**Commits:** 5 commits (614d7d7 → fa82f5c)
**Files Modified:** models/requests.py, models/responses.py, services/backtest_service.py, routes/backtest.py, backtest_engine.py
**Total Changes:** ~547 LOC added for Phase 8.1, ~35 LOC modified for bugfix

**Components Implemented:**
1. **Multi-Pair Request/Response Models** (commit 614d7d7)
   - `MultiPairBacktestRequest` with pair & strategy validation
   - `MultiPairBacktestResults` with complete breakdown structure
   - `PairStatistics`, `StrategyStatistics`, `ChartData` models

2. **Multi-Pair Backtest Service** (commit 928deb8)
   - Parallel backtest execution across multiple pairs
   - Chronological trade merging across pairs
   - Per-pair and per-strategy statistics calculation
   - Unified equity curve generation

3. **Multi-Pair API Endpoint** (commit 2e444cc)
   - `POST /api/v1/backtest/multi-pair` - Queue multi-pair backtest
   - `GET /api/v1/backtest/multi-pair/{task_id}/results` - Retrieve results
   - Async task management with progress tracking

4. **Unit Tests** (commit 292a409)
   - 10/10 tests passing (100%)
   - Model validation, service logic, chronological sorting tests

5. **CRITICAL BUGFIX: Strategy Selection** (commit fa82f5c)
   - **Problem:** Multi-pair backtest ignored `strategies` parameter, always used SIMPLE_TEST
   - **Solution:**
     - Added `strategies` parameter to `BacktestEngine.run_backtest()`
     - Removed SIMPLE_TEST from production evaluation
     - Updated service to pass strategies to engine
   - **Verification:** 1,946 RANGE_RIDER trades generated, `strategy_breakdown` populated correctly

**Key Achievement:** Multi-pair backtesting API fully functional with working strategy selection. Ready for Phase 8.3 (C# Playback Window).

### ✅ Phase 8.5 - BUG FIXES (Jan 12, 2026)
**Branch:** phase8.2-multi-pair-ui (CSMMonitor submodule)
**Files Modified:** ChartViewerWindow.xaml, ChartViewerWindow.xaml.cs, BacktestWindow.xaml.cs
**Total Changes:** ~30 LOC added/modified
**Deferred Bugs:** 3 documented in PHASE_8_DEFERRED_BUGS.md

**Bugs Fixed:**
1. **BUG1: Pair Tab Selection Not Working**
   - **Problem:** Both chart tabs labeled "EURUSD", clicking tabs didn't switch pairs
   - **Root Cause:** XAML TabControl had no SelectionChanged event handler
   - **Solution:**
     - Added `SelectionChanged="PairTabControl_SelectionChanged"` to TabControl
     - Implemented event handler that calls `SwitchToPairTab()` with selected pair name
   - **Files:** ChartViewerWindow.xaml (line 304), ChartViewerWindow.xaml.cs (+15 LOC)
   - **Result:** Users can now click EURUSD/GBPUSD tabs to switch between pair charts

2. **BUG3: Strategy Breakdown Showing "No trades"**
   - **Problem:** Strategy Breakdown displayed "No trades" for both strategies despite 1,946 trades
   - **Root Cause:** C# looked for lowercase keys ("trend_rider") but Python API returns uppercase ("TREND_RIDER")
   - **Solution:**
     - Changed `results.StrategyBreakdown.ContainsKey("trend_rider")` → `"TREND_RIDER"`
     - Changed `results.StrategyBreakdown.ContainsKey("range_rider")` → `"RANGE_RIDER"`
   - **Files:** BacktestWindow.xaml.cs (lines 299-319)
   - **Result:** Strategy breakdown now displays correct trade counts and statistics

**Deferred Bugs (Phase 8.6):**
3. **BUG2: Max Concurrent Positions Not Respected**
   - **Issue:** 5 open positions when max=2
   - **Root Cause:** Each pair gets separate PositionManager with independent limits
   - **Required Fix:** Implement shared GlobalPositionManager across all pairs
   - **Effort:** 4-6 hours (architectural change)

4. **BUG4: Excessive Trade Count (1,946 trades/month)**
   - **Issue:** Too many trades for 1 month period
   - **Root Cause:** RANGE_RIDER strategy too aggressive
   - **Required Fix:** Tune strategy parameters (min_confidence, range width, cooldown)
   - **Effort:** 2-3 hours (parameter tuning + validation)

5. **BUG5: Excessive Horizontal Lines on Chart**
   - **Issue:** SL/TP lines not removed when positions close
   - **Root Cause:** Lines added but never cleaned up
   - **Required Fix:** Remove lines from chart when positions close
   - **Effort:** 1-2 hours (simple cleanup logic)

**Key Achievement:** Critical UI bugs fixed, multi-pair chart viewer fully functional. Non-critical bugs documented for Phase 8.6.

### 🔴 Phase 8.5 - COMPREHENSIVE TEST RESULTS (Jan 13-14, 2026)
**Branch:** phase8.2-multi-pair-ui
**Commit:** 3c14535 (test results documentation)
**Test Duration:** 5 hours
**Test Configuration:** EURUSD + GBPUSD, Both Strategies, Jan 2-31, 2024
**Overall Assessment:** ⚠️ **MAJOR REWORK NEEDED**

**Critical Bugs Found (Priority 1):**

1. **BUG #1: M1 Data Not Loading for Multi-Pair**
   - **Severity:** Critical
   - **Issue:** Single pair loads M1 correctly, multi-pair only loads M15 (candles move every 15min)
   - **Impact:** After multi-pair test, even single pair breaks until server reset
   - **Component:** Python backtest engine / C# data loading

2. **BUG #2: Sequential Pair Loading (Not Parallel)**
   - **Severity:** Critical
   - **Issue:** Python loads pairs one at a time instead of parallel execution
   - **Impact:** Position slot management incorrect, doesn't simulate realistic live trading
   - **Component:** Python backtest service
   - **Evidence:** See Phase8 test log.txt in debug folder

3. **BUG #4: Broken Strategy Logic**
   - **Severity:** Critical/Major
   - **Issues:**
     - Entries occurring every 15 minutes (unrealistic)
     - Regime detection not working (stuck on RANGE_RIDER only)
     - No TREND_RIDER trades despite selecting "Both Strategies"
     - Strategy signals panel not functioning
   - **Component:** Python strategy evaluation

4. **BUG #5: Position Limits Not Respected**
   - **Severity:** Critical/Major
   - **Issue:** Max concurrent positions (2) not respected in multi-pair mode
   - **Impact:** R-multiples showing 100+ (calculation error), 5 positions when max=2
   - **Works Correctly:** Single pair mode
   - **Component:** Python position manager

**Major/Minor Issues (Priority 2):**

5. **BUG #3: Viewport & Header Mismatch**
   - **Severity:** Minor
   - **Issues:**
     - Viewport doesn't follow current candle when switching pairs
     - Header pair names don't match selected tab
     - Recent trades selection doesn't zoom to exact candles
   - **Evidence:** See "Recent trades selections bug.png" and "Header pairs name bug.png"

**Additional Observations:**
- SL/TP horizontal lines not removed after trade close (chart clutter)
- Visual trade timeline not showing on single pair backtests
- Strategy signals panel completely non-functional
- 1,900+ trades in 1 month (excessive, strategy too aggressive)
- Load time: 1m 50s for 1-month multi-pair backtest (slower than expected ~8-10s target)

**Data Accuracy Issues:**
- All Data Accuracy tests FAILED
- Strategy breakdown showing incorrect values
- Trade counts unreasonable
- Position management calculations incorrect

**Next Session Priorities:**
1. **Priority 1 (Must Fix):** BUG #2 (parallel loading), BUG #1 (M1 data)
2. **Priority 2 (Should Fix):** Strategy signal fixes, regime detection, cosmetics
3. **Deferred to Phase 8.6:** Final strategy logic, equity curve

**Key Achievement:** Comprehensive 5-hour test identified 5 critical bugs requiring major rework before Phase 8 can be considered complete. Test results fully documented in PHASE_8_TEST_RESULTS.md.

### ✅ Phase 8.2 - C# MULTI-PAIR UI COMPLETE (Jan 9, 2026)
**Branch:** phase8.2-multi-pair-ui (CSMMonitor submodule)
**Commits:** 5 commits (759ed0e → 9912eef)
**Files Modified:** BacktestWindow.xaml, BacktestWindow.xaml.cs, ChartViewerWindow.xaml.cs, BacktestApiClient.cs, BacktestModels.cs
**Total Changes:** ~693 LOC added, ~43 LOC removed

**Components Implemented:**
1. **Phase 8.2.1 - BacktestWindow Multi-Pair Support**
   - Multi-pair selection UI (checkbox list)
   - Multi-strategy selection (Trend Rider, Range Rider, Both)
   - Enhanced API models (MultiPairBacktestRequest/Response)
   - Integration with Python `/backtest/multi-pair` endpoint

2. **Phase 8.2.2 - ChartViewerWindow Data Structures**
   - Multi-pair data storage (Dictionary<string, List<Candle>>)
   - Pair switching infrastructure
   - Foundation for multi-pair playback

3. **Phase 8.2.3 - Recent Trades List Enhancement**
   - Display trades from all pairs
   - Added pair column to trade list
   - Chronological ordering across pairs

4. **Phase 8.2.4 - Open Positions Enhancement**
   - Clickable position slots
   - Auto-switch to relevant pair when clicking position
   - Enhanced position display

5. **Phase 8.2.5 - Global Timeline Foundation (WIP)**
   - Timeline infrastructure for multi-pair playback
   - Preparation for Phase 8.3

**Key Achievement:** BacktestWindow can now launch multi-pair backtests and ChartViewerWindow handles multi-pair data

### ✅ Phase 8.3 - C# PLAYBACK WINDOW COMPLETE (Jan 9, 2026)
**Branch:** main (CSMMonitor submodule)
**Commits:** 2 commits (48b1bb4 → 8edff3f)
**Files Modified:** ChartViewerWindow.xaml, ChartViewerWindow.xaml.cs
**Total Changes:** ~402 LOC added

**Components Implemented:**
1. **Multi-Pair Global Timeline Playback** (commit 48b1bb4)
   - Chronological playback across all pairs
   - AdvanceGlobalTimeline() to map global timestamps to pair bars
   - CheckAndSwitchPairForTradeEvents() for auto-switching pairs
   - ReplayTradesUpToGlobalTime() for statistics calculation
   - Updated PlaybackTimer_Tick to use global timeline
   - Progress slider maps to global timeline count
   - Synchronized position maintenance across pairs
   - ~161 insertions

2. **Visual Trade Timeline** (commit 8edff3f)
   - 60px interactive canvas below progress slider
   - Color-coded trade markers (Blue=EURUSD, Orange=GBPUSD, Purple=USDJPY)
   - Entry bars (60% height) vs Exit bars (40% height)
   - Yellow position indicator line showing current playback location
   - Click-to-jump navigation (click anywhere on timeline)
   - Tooltips showing trade details on hover
   - Automatic re-render on window resize
   - ~241 insertions

**Key Achievement:** MT5-style playback with interactive visual timeline complete. Multi-pair backtesting UI fully functional.

### ✅ Phase 7B Session 5 - INDICATOR DISPLAY FIX (Dec 14, 2025)
**Commit:** d29dd71 (phase7-csharp-strategies)
**Modified:** ChartViewerWindow.xaml.cs (4 insertions, 41 deletions)
**Issue Fixed:**
- Technical Indicators (RSI, ADX, EMA Alignment) showing "N/A" during M1 playback
- Root cause: UpdateChartInfo() overwriting indicator values after UpdateStrategyPanel()

**Root Cause Investigation:**
- Used systematic-debugging skill process (4 phases)
- Found UpdateChartInfo() runs after UpdateStrategyPanel() during playback
- UpdateChartInfo() used candle.Rsi/Adx/EmaFast which are null in M1 mode
- Result: All indicators reset to "N/A" despite correct StrategyEngine calculations

**Changes:**
1. Removed duplicate indicator updates from UpdateChartInfo() (lines 1110-1131)
2. Removed M1 playback debug noise (10 Debug.WriteLine statements)
3. Cleaned up diagnostic code from UpdateStrategyPanel()

**Key Achievement:**
- All indicators now display correctly during M1 playback
- Clean debug output without noise
- Phase 7B COMPLETE - Ready for validation testing

### ✅ Phase 7B Session 4 - M1 PLAYBACK FIX (Dec 12, 2025)
**Commit:** 07b3074 (phase7-csharp-strategies)
**Modified:** ChartViewerWindow.xaml.cs (13 insertions, 3 deletions)
**Issue Fixed:**
- Strategy Signals not updating during M1 playback
- Root cause: UpdateStrategyPanel only in RenderChartUpToBar, missing from RenderM1ChartUpToBar

**Changes:**
- Added UpdateStrategyPanel(correspondingM15Index) in RenderM1ChartUpToBar
- Added diagnostic output for investigating indicator display issue

**Key Achievement:** Strategy evaluation now works during M1 playback mode

### ✅ Phase 7B Session 3 - COMPLETE (Dec 11, 2025)
**Commit:** 1eaee6a (phase7-csharp-strategies)
**Added:** 1 new C# file + 2 modified files (~400+ LOC)
**Components:**
- StrategyEngine.cs - orchestrates indicators → regime → strategies
- StrategyEvaluationResult class - comprehensive evaluation results
- ChartViewerWindow integration - real-time strategy evaluation during playback
- UpdateStrategyPanel() method - updates UI with regime, indicators, signals
- Strategy Signals UI section in Indicators tab
- Color-coded displays: regime (TRENDING/RANGING/TRANSITIONAL), signals (BUY/SELL/NONE)

**Key Achievement:** StrategyEngine fully integrated with chart viewer, ready for validation testing

### ✅ Phase 7B Session 2 - COMPLETE (Dec 11, 2025)
**Commit:** d2c9499 (phase7-csharp-strategies)
**Added:** 6 new C# files (~1,290 LOC)
**Components:**
- IStrategy interface and BaseStrategy abstract class
- TrendRiderStrategy with 135-point confidence scoring
- RangeRiderStrategy with support/resistance detection
- StrategyConfig configuration model

### ✅ Phase 7B Session 1 - COMPLETE (Dec 11, 2025)
**Commit:** ded7dcb (phase7-csharp-strategies)
**Added:** 10 new C# files (~1,100 LOC)
**Components:**
- IIndicator interface and IndicatorData models
- EmaCalculator with proper warmup period handling
- AtrCalculator, AdxCalculator, RsiCalculator
- RegimeDetector with 100-point competitive scoring
- TRENDING/RANGING/TRANSITIONAL classification

**Key Achievement:** C# indicators now match Python output within ±0.00001 tolerance

### ✅ Phase 5.3 Part 1 - COMPLETE (Dec 1, 2025)
**Issue:** M1 viewport positioning bug
**Root Cause:** M1→M15 coordinate mismatch
**Solution:** Convert M1 index to M15 equivalent: `currentM15Index = currentIndex / 15.0`
**Result:** Current bar positioned at exactly 80% from left during playback

### ✅ Phase 5.2 - COMPLETE (Nov 29, 2025)
**Issue:** EMA display bug
**Root Cause:** H1 EMA interpolation using incomplete/future bars
**Solution:** Modified interpolation to use only COMPLETED H1 bars
**Result:** EMAs rendering correctly with proper alignment

---

## 📊 SYSTEM ARCHITECTURE

### Data Flow
```
CSV Files → DataLoader → Timeframe Converter → CSM Calculator
    ↓
Technical Indicators (EMA 20/50/100, ADX, RSI, ATR)
    ↓
Regime Detector (Trending/Ranging/Transitional)
    ↓
Trading Strategies (Trend Rider / Range Rider)
    ↓
Position Manager (Entry/Exit/Trailing Stop)
    ↓
Performance Tracker (R-multiples, Win Rate, etc.)
```

### API Structure
```
FastAPI Server (src/api/main.py)
    ↓
Routes (src/api/routes/backtest.py)
    ↓
Services (src/api/services/backtest_service.py)
    ↓
BacktestEngine (src/backtest_engine.py)
    ↓
JSON Response to C# WPF
```

---

## 📋 DEVELOPMENT PHASES

### ✅ Completed Phases (Archived)
- **Phase 1-5:** Python backtesting foundation (100% complete)
  - Core engine, indicators, strategies, API, chart viewer integration
  - Performance: 100-600x faster than MT5
  - **See archived documentation for details**

### ✅ Phase 7B: C# Strategy Migration (COMPLETE)
**Goal:** Port Python strategies to C# for local execution in chart viewer

**Session 1-5:** ✅ All Complete (Dec 11-14, 2025)
- [x] C# Indicators (EMA, ATR, ADX, RSI) with Python parity
- [x] C# Regime Detection (TRENDING/RANGING/TRANSITIONAL)
- [x] C# Strategies (Trend Rider + Range Rider)
- [x] StrategyEngine orchestration
- [x] ChartViewerWindow integration
- [x] M1 playback support
- **Files:** 17 new C# files (~2,800 LOC)
- **Status:** ✅ Complete, ready for merge to main


---

## 🔑 KEY DESIGN DECISIONS

### Architecture Principle: Python = Brain, C# = Eyes

**CRITICAL:** Python is the single source of truth for strategy logic

**Python Responsibilities (Brain):**
- Strategy evaluation (Trend Rider, Range Rider)
- Indicator calculations (EMA, ATR, ADX, RSI)
- Regime detection (TRENDING, RANGING, TRANSITIONAL)
- Position management and trade generation
- Complete backtest orchestration

**C# Responsibilities (Eyes):**
- User interface and configuration
- Playback controls and visualization
- Chart rendering with trade markers
- Statistics display and reporting
- Export functionality

**Why This Matters:**
- ✅ Single source of truth (no duplication)
- ✅ Modify Python strategy → automatically affects backtest AND live signals
- ✅ Faster development (one codebase, not three)
- ✅ No risk of drift between Python, C#, and MQ5

### Monorepo with Git Submodules

**Structure:** Single parent repo with two child repos as git submodules

**Parent Repository (Jcamp_TradingApp)**
- **GitHub:** https://github.com/JCAMPanero23/Jcamp_TradingApp
- **Branch:** phase8-multi-pair-design
- **Contains:** CLAUDE.md, Plans/, documentation, MT5 reference files, .gitmodules
- **Purpose:** Project coordination, unified cloning, shared context
- **Clone command:** `git clone --recursive https://github.com/JCAMPanero23/Jcamp_TradingApp.git`

**Submodule 1: Python Backtesting Engine**
- **GitHub:** https://github.com/JCAMPanero23/jcamp-python-backtesting
- **Path:** `jcamp-python-backtesting/` (within parent repo)
- **Contains:** Core engine, API server, strategies, tests
- **Purpose:** Python strategy brain, backtest engine
- **Independent history:** Maintains own git commits and branches

**Submodule 2: C# Monitor (WPF UI)**
- **GitHub:** https://github.com/JCAMPanero23/CSMMonitor
- **Path:** `CSMMonitor/` (within parent repo)
- **Contains:** C# WPF chart viewer application
- **Purpose:** Visualization, UI, chart playback
- **Independent history:** Maintains own git commits and branches

**Benefits:**
- ✅ Single clone command gets entire project (`--recursive`)
- ✅ Each component maintains independent git history
- ✅ Easier remote development setup
- ✅ Centralized documentation coordination
- ✅ Can still commit to submodules independently

**Workflow:**
- Changes to Python/C# code: `cd` into submodule, commit & push normally
- Changes to documentation: Commit in parent repo
- Parent repo tracks specific submodule commits (version locking)

### Branch Strategy
- **main:** Stable, production-ready code
- **phase7-csharp-strategies:** Completed Phase 7B (ready for merge)
- **Merge Policy:** Only merge when session is complete and tested

### Validation Strategy
- **Signal Matching:** C# signals must match MT5 EA signals ≥ 90%
- **Indicator Accuracy:** C# indicators must match Python within ±0.00001
- **Confidence Scoring:** 135-point system for Trend Rider
- **Performance:** Indicator caching for efficiency

---

## 📖 DOCUMENTATION STRUCTURE

### Active Documents (Read These)
1. **CLAUDE.md** (THIS FILE) - Current context and status
2. **CURRENT_PLANS.md** - Active development plans
3. **plans/Phase_7B_*.md** - Detailed implementation plans

### Archived Documents (Reference Only)
- **archive/** folder - Old session summaries
- ~~`C:\Users\jcamp\.claude\plans\`~~ - DEPRECATED, don't use

**Single Source of Truth:** `/d/Jcamp_TradingApp/CURRENT_PLANS.md`

---

## 🎯 PROJECT GOALS

### Main Vision: Multi-Pair Backtesting System
**Goal:** MT5 Strategy Tester reimagined with multi-pair support and realistic trading simulation

**Phase 1 (Current Design):** Sequential Multi-Pair Testing
- Test multiple pairs (EURUSD, GBPUSD, USDJPY, etc.) in single backtest
- Python brain generates all trades, C# visualizes with MT5-style playback
- Interactive timeline: click any trade to review that moment
- Fast performance: 8-10 seconds for 1 year × 3 pairs

**Phase 2 (Future Vision):** True Multi-Pair Orchestrator
- Simultaneous bar-by-bar advancement across all pairs
- Shared position limits (max 2 across ALL pairs, not per pair)
- Signal priority resolution (when 2+ pairs signal at once)
- Realistic trading simulation matching live trading conditions

### Technical Goals
- ✅ 100-600x faster backtesting than MT5
- ✅ Python API server with FastAPI
- ✅ C# WPF chart viewer with smooth playback
- ✅ C# local strategy execution (Phase 7B COMPLETE)
- 🚀 Multi-pair backtesting (Phase 8 - Design Complete, Implementation Next)

### Business Goals
- **Target:** $5,000/month from 100 subscribers
- **Timeline:** 14-16 months to launch
- **Validation:** 5-6 months real money testing required
  - 2 months demo account
  - 3-4 months live account ($500, micro lots, 2% risk)
- **Success Criteria:** Positive R-multiple, <25% drawdown, >45% win rate

---

## 🐛 CRITICAL RULES

1. **Always use Git Bash paths** (`/d/...` not `D:\...`)
2. **Test indicator accuracy** against Python (±0.00001 tolerance)
3. **Commit both repos separately** when changes span Python + C#
4. **Follow phase-based development** - complete sessions before merging
5. **Validate with real backtests** before marking phase complete
6. **Reference CURRENT_PLANS.md** for active task lists
7. **Update STATUS.md** at end of each session

---

## 📊 KEY METRICS

| Metric | Value |
|--------|-------|
| Total Code | ~5,600 LOC (4,500 Python + 1,100 C#) |
| Test Coverage | 97% (30/31 tests passing) |
| Performance vs MT5 | 100-600x faster |
| API Endpoints | 5 operational |
| Strategies | 3 (Python), 0 (C# - in progress) |
| C# Indicators | 4 (EMA, ATR, ADX, RSI) ✅ |
| C# Regime Detection | 1 (TRENDING/RANGING/TRANSITIONAL) ✅ |

---

## ✅ SESSION CHECKLIST

### Session Start
- [ ] Read this CLAUDE.md file
- [ ] Check git status in both repos
- [ ] Review CURRENT_PLANS.md for active tasks
- [ ] Understand current blockers

### During Session
- [ ] Use Git Bash paths (`/d/...`)
- [ ] Test changes incrementally
- [ ] Validate against Python baseline

### Session End
- [ ] Update STATUS.md with progress
- [ ] Commit Python repo changes (if any)
- [ ] Commit CSMMonitor changes (if any)
- [ ] Update this file if major changes
- [ ] Confirm all files saved

---

## 🔗 QUICK REFERENCES

### Current Work
- **Phase:** Phase 8.5 - Testing & Validation
- **Status:** In Progress
- **Completed:** Phases 8.1, 8.2, 8.3 ✅
- **Postponed:** Phase 8.4 (Export & Reporting)
- **Design Doc:** `/d/Jcamp_TradingApp/Plans/2025-12-31-MultiPair-Backtest-Design.md`
- **Branch:** phase8.2-multi-pair-ui (ready to merge to main)

### Important Files
- **Multi-Pair Design:** `/d/Jcamp_TradingApp/Plans/2025-12-31-MultiPair-Backtest-Design.md`
- **Python API Routes:** `/d/Jcamp_TradingApp/jcamp-python-backtesting/src/api/routes/backtest.py`
- **Python Backtest Engine:** `/d/Jcamp_TradingApp/jcamp-python-backtesting/src/backtest_engine.py`
- **Python Position Manager:** `/d/Jcamp_TradingApp/jcamp-python-backtesting/src/position_manager.py`

---
*Read this file at the start of every Claude Code session for full context.*
- to memorize### 🚀 Phase 8: Multi-Pair Backtesting
**Goal:** MT5-style multi-pair backtesting with interactive playback

**Status:** Phases 8.1, 8.2, 8.3 COMPLETE ✅ | Phase 8.4 POSTPONED ⏸️ | Phase 8.5 IN PROGRESS 🔄

**Phase 8.1: Python API Enhancement (COMPLETE ✅)**
- [x] Multi-pair request/response models
- [x] `/backtest/multi-pair` endpoint
- [x] Multi-pair orchestration logic
- [x] Chronological trade merging
- [x] Statistics breakdown (by pair, by strategy)
- [x] Unit tests (10/10 passing)
- [x] Integration testing complete
- [x] **BUGFIX:** Strategy selection working (removed SIMPLE_TEST, added strategies param)
- **Commits:** 614d7d7 (models), 928deb8 (service), 2e444cc (endpoint), 292a409 (tests), fa82f5c (bugfix)

**Phase 8.2: C# Configuration Window (COMPLETE ✅)**
- [x] Multi-pair selection UI (checkbox list)
- [x] Multi-strategy selection (Trend Rider, Range Rider, Both)
- [x] Risk parameter inputs
- [x] API integration with `/backtest/multi-pair`
- [x] Multi-pair data structures in ChartViewerWindow
- [x] Recent Trades list multi-pair support
- [x] Open Positions clickable slots with auto-switch
- [x] Global Timeline foundation
- **Commits:** 759ed0e, c0c356c, 1ff3e1b, 52f7cf8, 9912eef (~693 LOC)

**Phase 8.3: C# Playback Window (COMPLETE ✅)**
- [x] MT5-style playback controls with global timeline
- [x] Interactive trade timeline (click-to-jump navigation)
- [x] Multi-pair chart viewer with auto-switching
- [x] Global timeline playback (chronological across pairs)
- [x] Visual trade markers (color-coded by pair)
- [x] Position indicator line during playback
- **Commits:** 48b1bb4 (global timeline), 8edff3f (visual timeline) (~402 LOC)

**Phase 8.4: Export & Reporting (POSTPONED ⏸️)**
- CSV trade export (deferred)
- Statistics reports (deferred)

**Phase 8.5: Testing & Validation (IN PROGRESS 🔄)**
- End-to-end testing
- Multi-pair playback validation
- Trade statistics verification
- Performance testing

---
