# CLAUDE.md - JCAMP Forex Trading System Context

**Purpose:** Single authoritative reference for Claude Code to understand project state and start working effectively.
**Last Updated:** December 14, 2025 (Session 6 - Python Strategy Integration)
**Current Phase:** 🚀 PHASE 8 - PYTHON STRATEGY INTEGRATION (Session 1 - Regime-Based Routing COMPLETE)

---

## 🚨 CRITICAL - PATH CONFIGURATION

**Environment:** Windows 11 + Git Bash (via Claude Code)
**Shell Type:** Git Bash (MINGW64)

### Path Format Rules - ALWAYS USE GIT BASH PATHS

**Git Bash paths (REQUIRED):**
```bash
# Project root
/d/JcampFxTrading/

# Sub-directories
/d/JcampFxTrading/jcamp-python-backtesting/
/d/JcampFxTrading/CSMMonitor/
/d/JcampFxTrading/plans/
```

**Conversion Rule:**
- Windows: `D:\JcampFxTrading\folder` 
- Git Bash: `/d/JcampFxTrading/folder` (lowercase drive letter, forward slashes)

**NEVER use:**
- ❌ `D:\` (Windows backslash paths)
- ❌ `/mnt/d/` (WSL-style paths)

**ALWAYS use:**
- ✅ `/d/` (Git Bash paths with lowercase drive letter)

---

## 📁 PROJECT STRUCTURE

```
/d/JcampFxTrading/
├── CLAUDE.md                          # This file (startup context)
├── CURRENT_PLANS.md                   # Active development plans
├── STATUS.md                          # Dynamic status tracking
├── Jcamp_BacktestEA.mq5              # MT5 Expert Advisor (reference)
│
├── plans/                             # Detailed implementation plans
│   └── Phase_7B_C#StrategyMigrationImplementation_Plan.md
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

### Git Operations
```bash
# Check Python backtest status
cd /d/JcampFxTrading/jcamp-python-backtesting && git status

# Check C# Monitor status
cd /d/JcampFxTrading/CSMMonitor && git status

# View recent commits
cd /d/JcampFxTrading/jcamp-python-backtesting && git log -3 --oneline
```

### Python Testing
```bash
# Run all tests
cd /d/JcampFxTrading/jcamp-python-backtesting && python -m pytest tests/ -v

# Run specific phase tests
cd /d/JcampFxTrading/jcamp-python-backtesting && python -m pytest tests/test_phase4.py -v
```

### API Server
```bash
# Start FastAPI server
cd /d/JcampFxTrading/jcamp-python-backtesting && python -m uvicorn src.api.main:app --reload
```

### C# Project
```bash
# Build C# project
cd /d/JcampFxTrading/CSMMonitor && dotnet build

# Run C# tests (when implemented)
cd /d/JcampFxTrading/CSMMonitor && dotnet test
```

### File Viewing
```bash
# View plan files
cat /d/JcampFxTrading/plans/Phase_7B_C#StrategyMigrationImplementation_Plan.md

# View CURRENT_PLANS.md
cat /d/JcampFxTrading/CURRENT_PLANS.md

# List C# indicators
ls -la /d/JcampFxTrading/CSMMonitor/JcampForexTrader/Models/Indicators/
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
| **Tests** | 30/31 Passing | 1 Phase 2 test failing |
| **Main Branch** | ✅ Updated | Phase 5.2 & 5.3 Part 1 complete |
| **Phase 7B Branch** | ✅ Complete | phase7-csharp-strategies (5 sessions complete) |

---

## 🎯 CURRENT FOCUS: PHASE 7B COMPLETE ✅

**Phase 7B Status:** ✅ **COMPLETE** - All 5 sessions finished successfully

**Final Branch State:**
- C#: `phase7-csharp-strategies` (Ready for validation testing and merge to main)

**All Issues Resolved:**
1. ✅ **Session 4**: Strategy Signals not updating during M1 playback
   - Fixed: Added UpdateStrategyPanel() call in RenderM1ChartUpToBar
2. ✅ **Session 5**: Technical Indicators showing "N/A" during playback
   - Root Cause: UpdateChartInfo() overwriting values after UpdateStrategyPanel()
   - Fixed: Removed duplicate indicator updates from UpdateChartInfo()

**Completed Deliverables:**
- ✅ C# Indicators (EMA, ATR, ADX, RSI) with Python parity
- ✅ C# Regime Detection (TRENDING/RANGING/TRANSITIONAL)
- ✅ C# Strategies (Trend Rider + Range Rider)
- ✅ Strategy Engine with full orchestration
- ✅ Chart Viewer integration with real-time display
- ✅ M1 playback support with smooth strategy evaluation

**Next Phase Options:**
- Merge phase7-csharp-strategies to main branch
- Begin Phase 6: Multi-pair backtesting
- Add unit tests for C# strategy components

---

## 🚀 RECENT MILESTONES

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

### 🚀 Phase 7B: C# Strategy Migration (CURRENT)
**Goal:** Port Python strategies to C# for local execution in chart viewer

**Session 1:** ✅ Indicators + Regime Detection (COMPLETE)
**Session 2:** ✅ Strategy Implementation (COMPLETE - Dec 11)
- [x] IStrategy interface and BaseStrategy
- [x] TrendRiderStrategy (135-point confidence scoring)
- [x] RangeRiderStrategy (support/resistance detection)
- [x] StrategyConfig models
- **Files:** 6 new files (~1,290 LOC)
- **Status:** Build verified, all compilation successful

**Session 3:** 🔄 Strategy Integration & Testing (NEXT)
- [ ] StrategyEngine orchestration
- [ ] Unit tests for all components
- [ ] ChartViewerWindow integration

---

## 🔑 KEY DESIGN DECISIONS

### Two Git Repositories
- **jcamp-python-backtesting:** Core engine, API server, strategies
- **CSMMonitor:** C# WPF chart viewer application
- **Reason:** Independent versioning, separate deployment concerns
- **Important:** Commit changes to both repos independently

### Branch Strategy
- **main:** Stable, production-ready code
- **phase7-csharp-strategies:** Active Phase 7B development
- **Merge Policy:** Only merge when session is complete and tested

### C# Strategy Architecture
- **Mirror MT5 EA v1.96 logic:** Keep regime detection identical
- **Validation:** All indicators must match Python output within ±0.00001
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

**Single Source of Truth:** `/d/JcampFxTrading/CURRENT_PLANS.md`

---

## 🎯 PROJECT GOALS

### Technical Goals
- ✅ 100-600x faster backtesting than MT5
- ✅ Python API server with FastAPI
- ✅ C# WPF chart viewer with smooth playback
- 🔄 C# local strategy execution (Phase 7B)
- ⏳ Multi-pair backtesting (Phase 6)

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
- **Branch:** phase7-csharp-strategies
- **Plan:** `/d/JcampFxTrading/plans/Phase_7B_C#StrategyMigrationImplementation_Plan.md`
- **Next:** Implement IStrategy and TrendRiderStrategy classes

### Important Files
- **Python Strategies:** `/d/JcampFxTrading/jcamp-python-backtesting/src/strategies/`
- **C# Indicators:** `/d/JcampFxTrading/CSMMonitor/JcampForexTrader/Models/Indicators/`
- **C# Regime:** `/d/JcampFxTrading/CSMMonitor/JcampForexTrader/Models/RegimeDetector.cs`

---
*Read this file at the start of every Claude Code session for full context.*
- to memorize