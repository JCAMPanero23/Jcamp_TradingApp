# RE-TEST INSTRUCTIONS - Phase 8 Multi-Pair Backtest
**Date:** January 11, 2026
**Status:** ✅ READY TO TEST

---

## What Was Fixed

### ✅ ROOT CAUSE IDENTIFIED & RESOLVED

**Problem:** API server was running from the wrong directory, causing data files to be inaccessible.

**Solution Applied:**
1. ✅ New API server running from **correct directory** (jcamp-python-backtesting/)
2. ✅ C# app updated to use **port 8001** (where the working server is)
3. ✅ Enhanced error handling in ChartViewerWindow
4. ✅ All components rebuilt successfully

### ✅ VERIFIED WORKING

Test on port 8001 confirmed:
- ✅ **950 trades** generated for EURUSD (Jan 2024)
- ✅ Win rate: 52.20%
- ✅ Net profit: $5,232.91
- ✅ Total R: 38.34
- ✅ PairChartData populated: **2,112 M15 candles + 31,515 M1 candles**

---

## How to Test

### STEP 1: Launch the Application

```bash
cd /d/Jcamp_TradingApp/CSMMonitor/JcampForexTrader/bin/Release/net8.0-windows
./JcampForexTrader.exe &
```

### STEP 2: Configure Multi-Pair Backtest

1. Open **Backtest Configuration** window
2. Select pairs:
   - ✅ **EURUSD**
   - ✅ **GBPUSD**
3. Select strategy: **Both** (or choose Trend Rider + Range Rider)
4. Set dates:
   - Start: **2024-01-01**
   - End: **2024-01-31**
5. Risk settings:
   - Initial Balance: **$10,000**
   - Risk: **2%**
   - Max Positions: **2**

### STEP 3: Run Backtest

Click **"Run Backtest"** button

**Expected Results:**
- ✅ Progress updates for each pair
- ✅ ~1,900+ trades total (EURUSD ~950, GBPUSD ~996)
- ✅ Completes in 60-90 seconds
- ✅ ChartViewerWindow opens automatically

### STEP 4: Verify Chart Viewer

ChartViewerWindow should show:
- ✅ Visual timeline with colored trade markers
  - Blue = EURUSD trades
  - Orange = GBPUSD trades
- ✅ Chart displays with candles
- ✅ Statistics show total trades > 0
- ✅ Win rate ~52-53%
- ✅ Net profit positive

### STEP 5: Test Playback

1. Click **Play** button
2. Verify:
   - ✅ Yellow indicator moves smoothly
   - ✅ Chart updates with new candles
   - ✅ Statistics update in real-time
3. Try **Pause**, **Resume**, **Reset**
4. Test speed controls: **1x, 5x, 10x, 25x**
5. Click on timeline to jump to specific trades

---

## Expected Performance

| Metric | EURUSD | GBPUSD | Total |
|--------|--------|--------|-------|
| Trades | ~950 | ~996 | ~1,946 |
| Win Rate | 52.2% | 53.4% | ~52.8% |
| Net Profit | $5,233 | $7,858 | $13,091 |
| Total R | 38.34 | 47.40 | ~85.74 |

---

## If Issues Occur

### Issue: "Cannot connect to API server"

**Check:**
```bash
curl http://localhost:8001/api/v1/health
```

**Should show:** `{"status":"ok",...}`

**If not running:**
```bash
cd /d/Jcamp_TradingApp/jcamp-python-backtesting
python -m uvicorn src.api.main:app --reload --port 8001
```

### Issue: Still getting 0 trades

**Verify API is working:**
```bash
cd /d/Jcamp_TradingApp
python test_port_8001.py
```

**Should generate 950 trades.**

### Issue: "Sequence contains no elements"

This means `PairChartData` is empty. Check:
1. API server logs for errors
2. Debug folder for new screenshots
3. Run `diagnose_response.py` to inspect API response

---

## Files Reference

- **API Test:** `test_port_8001.py` - Verified working
- **Root Cause Analysis:** `PHASE_8_ROOT_CAUSE_ANALYSIS.md`
- **All Bug Fixes:** `PHASE_8_BUGFIXES.md`
- **Test Results:** `PHASE_8_TEST_RESULTS.md` (update after testing)

---

## API Server Status

**Port 8001:** ✅ Working (correct directory, generating trades)
**Port 8000:** ❌ Old server (wrong directory, returns 0 trades)

**Always use port 8001** for Phase 8 testing.

---

## Summary

✅ **API Server:** Running from correct directory on port 8001
✅ **C# Application:** Rebuilt to use port 8001
✅ **Verification:** API tested and confirmed working (950 trades)
✅ **Ready:** Launch app and run multi-pair backtest

**Expected:** ChartViewerWindow should open with ~1,946 trades and working playback!

---

Good luck with the test! 🚀
