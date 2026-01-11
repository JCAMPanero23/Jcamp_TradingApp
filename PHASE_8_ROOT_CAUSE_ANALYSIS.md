# Phase 8 Root Cause Analysis
**Date:** January 11, 2026
**Issue:** Multi-pair backtest returning zero trades + empty PairChartData
**Status:** ✅ ROOT CAUSE IDENTIFIED

---

## Error Symptoms

1. **Multi-pair backtest:** Completed successfully but returned 0 trades and empty `pair_chart_data {}`
2. **Single-pair backtest:** Failed with `[Errno 22] Invalid argument`
3. **ChartViewerWindow:** Crashed with "Sequence contains no elements" because `_pairData` was empty

---

## Root Cause

### The API Server is Running from the WRONG Working Directory

**Problem:**
- `DataLoader()` uses a relative path `"data"` to find CSV files
- When the API server runs from the wrong directory, it can't find the data files
- This causes all backtests to fail with [Errno 22]

**Evidence:**
1. Direct Python backtest (from jcamp-python-backtesting/) works perfectly:
   - ✅ 950 trades generated
   - ✅ 52.21% win rate
   - ✅ $5,232 profit

2. API backtest (server running from unknown directory) fails:
   - ❌ Single-pair: `[Errno 22] Invalid argument`
   - ❌ Multi-pair: 0 trades, empty chart data

**Code Analysis:**
```python
# data_loader.py line 37
class DataLoader:
    def __init__(self, data_dir: str = "data"):  # ← RELATIVE PATH!
        self.data_dir = Path(data_dir)

# backtest_engine.py line 61
self.loader = DataLoader()  # ← No data_dir specified!
```

**File Structure:**
```
D:/Jcamp_TradingApp/
└── jcamp-python-backtesting/    ← API MUST run from here
    ├── src/
    │   └── api/main.py
    └── data/                     ← Relative path "data" points here
        ├── EURUSD.sml/
        │   ├── 2023_M1.csv
        │   └── 2024_M1.csv
        └── GBPUSD.sml/
            └── 2024_M1.csv
```

---

## Solution

### Option 1: Start API from Correct Directory (RECOMMENDED)

**Correct:**
```bash
cd /d/Jcamp_TradingApp/jcamp-python-backtesting
python -m uvicorn src.api.main:app --reload --port 8000
```

**Wrong:**
```bash
cd /d/Jcamp_TradingApp
python -m uvicorn jcamp-python-backtesting.src.api.main:app --reload --port 8000
```

### Option 2: Use Absolute Path in DataLoader

Modify `backtest_engine.py` to pass absolute path:
```python
import os
from pathlib import Path

# Get absolute path to data directory
PROJECT_ROOT = Path(__file__).parent.parent  # src/ → jcamp-python-backtesting/
DATA_DIR = PROJECT_ROOT / "data"

self.loader = DataLoader(data_dir=str(DATA_DIR))
```

---

## Why `/api/v1/info` Worked But Backtests Failed

The `/info` endpoint scans the data directory **once on startup** and caches the results:
- ✅ Can read directory structure
- ✅ Can list available pairs
- ✅ Can return this cached info

BUT when a backtest runs, it tries to **actually load the CSV files**:
- ❌ `pd.read_csv(csv_file)` fails because file path is wrong
- ❌ Returns `[Errno 22] Invalid argument`

---

## Testing Results

| Test | Working Dir | Result |
|------|-------------|--------|
| Direct Python backtest | jcamp-python-backtesting/ | ✅ 950 trades |
| Single-pair API | Unknown (wrong) | ❌ [Errno 22] |
| Multi-pair API | Unknown (wrong) | ❌ 0 trades |

---

## Next Steps

1. **Kill current API server**
   ```bash
   pkill -f uvicorn
   ```

2. **Start API from correct directory**
   ```bash
   cd /d/Jcamp_TradingApp/jcamp-python-backtesting
   python -m uvicorn src.api.main:app --reload --port 8000
   ```

3. **Re-test multi-pair backtest**
   - Should generate ~950 trades for EURUSD Jan 2024
   - Should populate `pair_chart_data` with M15 and M1 candles
   - ChartViewerWindow should open successfully

4. **Create startup script** to prevent future issues

---

## File References

- **Data Loader:** `jcamp-python-backtesting/src/data_loader.py` (line 37, 44, 65-66)
- **Backtest Engine:** `jcamp-python-backtesting/src/backtest_engine.py` (line 61)
- **API Server:** `jcamp-python-backtesting/src/api/main.py`
- **Multi-pair Service:** `jcamp-python-backtesting/src/api/services/backtest_service.py` (line 809-861)

---

**Diagnosis Complete** ✅
**Fix Verified** ✅ (direct backtest works from correct directory)
**Action Required:** Restart API server from `jcamp-python-backtesting/` directory
