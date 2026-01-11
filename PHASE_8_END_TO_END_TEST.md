# Phase 8: Multi-Pair Backtesting - End-to-End Test Guide

**Date:** January 11, 2026
**Purpose:** Verify complete multi-pair backtesting workflow (Phase 8.1 + 8.2 + 8.3)
**Duration:** ~15-20 minutes

---

## Pre-Test Setup ✅

### Environment Status

✅ **Python API Server**
- Status: Running on http://localhost:8001
- Health: OK (uptime: 31+ minutes)
- Endpoints: `/api/v1/backtest/multi-pair` available

✅ **C# Application**
- Build: Release configuration
- Status: Compiled successfully (0 errors, 17 warnings)
- Path: `D:\Jcamp_TradingApp\CSMMonitor\JcampForexTrader\bin\Release\net8.0-windows\JcampForexTrader.exe`

✅ **Test Data**
- Available pairs: EURUSD, GBPUSD, USDJPY (and others)
- Date range: 2024 data available
- Strategies: Trend Rider, Range Rider

---

## Test Scenario

**Test Name:** Multi-Pair Playback - 3 Pairs, Both Strategies, 1 Month

**Configuration:**
- Pairs: EURUSD, GBPUSD, USDJPY
- Strategies: Trend Rider + Range Rider
- Period: January 1-31, 2024 (1 month)
- Timeframe: M15
- Initial Balance: $10,000
- Risk per Trade: 2%
- Max Positions: 2

**Expected Results:**
- Total trades: 2,000-3,000 (estimated)
- Multiple pairs with trades
- Both strategies generating signals
- Visual timeline showing all trades
- Playback working smoothly

---

## Step-by-Step Test Procedure

### PART 1: Launch Application (2 minutes)

**Step 1.1: Start Application**
```bash
# Option A: Double-click the executable
D:\Jcamp_TradingApp\CSMMonitor\JcampForexTrader\bin\Release\net8.0-windows\JcampForexTrader.exe

# Option B: Run from command line
cd /d/Jcamp_TradingApp/CSMMonitor/JcampForexTrader/bin/Release/net8.0-windows
./JcampForexTrader.exe &
```

**Expected:** Application window opens

**Verification:**
- [ ] Application launches without errors
- [ ] Main window displays
- [ ] No crash dialogs

---

### PART 2: Configure Multi-Pair Backtest (3 minutes)

**Step 2.1: Open Backtest Configuration**
- Click "Configure Backtest" or similar button
- BacktestWindow should open

**Verification:**
- [ ] BacktestWindow opens
- [ ] Multi-pair selection UI visible
- [ ] Strategy selection visible

**Step 2.2: Configure Test Parameters**

Set the following:
1. **Pairs Selection:**
   - [x] EURUSD
   - [x] GBPUSD
   - [x] USDJPY
   - [ ] Others (unchecked)

2. **Strategy Selection:**
   - [x] Trend Rider
   - [x] Range Rider
   - OR: [x] Both

3. **Date Range:**
   - Start Date: 2024-01-01
   - End Date: 2024-01-31

4. **Risk Parameters:**
   - Initial Balance: 10000
   - Risk %: 2.0
   - Max Positions: 2

5. **Timeframe:**
   - M15 (15-minute)

**Verification:**
- [ ] All 3 pairs selected (checkboxes checked)
- [ ] Both strategies selected
- [ ] Date range set correctly
- [ ] Risk parameters set correctly
- [ ] Ready to submit

**Step 2.3: Submit Backtest**
- Click "Run Backtest" or "Start" button
- API call should be sent to Python backend

**Expected:**
- Loading indicator appears
- Status shows "Queued" or "Running"
- Progress updates appear

**Verification:**
- [ ] Backtest submitted successfully
- [ ] Loading/progress indicator visible
- [ ] No error messages
- [ ] Status updates appearing

---

### PART 3: Monitor Backtest Execution (1-2 minutes)

**Step 3.1: Watch Progress**
- Observe the progress bar or status messages
- Should show processing each pair

**Expected Progress Messages:**
1. "Running backtest for EURUSD (1/3)..."
2. "Running backtest for GBPUSD (2/3)..."
3. "Running backtest for USDJPY (3/3)..."
4. "Merging results across pairs..."
5. "Multi-pair backtest completed successfully"

**Verification:**
- [ ] Progress updates for each pair
- [ ] No error messages
- [ ] Completes within 90 seconds
- [ ] Status shows "Complete"

---

### PART 4: Chart Viewer Opens (1 minute)

**Step 4.1: ChartViewerWindow Launches**
- After backtest completes, ChartViewerWindow should auto-open
- May need to click "View Results" button

**Expected:**
- ChartViewerWindow opens with multi-pair data loaded
- Visual trade timeline appears
- Chart displays for one of the pairs
- Statistics panels populated

**Verification:**
- [ ] ChartViewerWindow opens automatically
- [ ] Visual timeline canvas visible (60px height)
- [ ] Trade markers visible on timeline (colored bars)
- [ ] Chart displays candles for a pair
- [ ] Statistics show trade count > 0
- [ ] No error dialogs

**Step 4.2: Inspect Initial State**

**Check Visual Timeline:**
- [ ] Trade timeline canvas present (below progress slider)
- [ ] Multiple colored bars visible (trades)
- [ ] Colors: Blue (EURUSD), Orange (GBPUSD), Purple (USDJPY)
- [ ] Entry bars (tall 60%) vs Exit bars (short 40%)
- [ ] Yellow position indicator at start

**Check Statistics Panels:**
- [ ] Total Trades: 2000-3000 (estimated)
- [ ] Win Rate: 30-60%
- [ ] Net Profit: positive or negative
- [ ] Initial Balance: $10,000
- [ ] Final Balance: shown
- [ ] Max Drawdown: shown

**Check Pair Tabs:**
- [ ] Tab for EURUSD visible
- [ ] Tab for GBPUSD visible
- [ ] Tab for USDJPY visible
- [ ] Can switch between tabs

**Check Recent Trades List:**
- [ ] Trades list populated
- [ ] Shows trades from all 3 pairs
- [ ] Pair column shows EURUSD/GBPUSD/USDJPY
- [ ] Strategy column shows TREND_RIDER/RANGE_RIDER
- [ ] Entry/Exit times shown
- [ ] R-multiple values shown

---

### PART 5: Test Playback Controls (5 minutes)

**Step 5.1: Basic Playback**
- Click the **Play** button

**Expected:**
- Playback starts advancing through timeline
- Yellow position indicator moves along timeline
- Chart updates with new candles
- Current bar highlighted
- Statistics update in real-time

**Verification:**
- [ ] Playback starts smoothly
- [ ] Yellow indicator moves left to right
- [ ] Chart updates (candles appearing)
- [ ] Statistics updating (trade count increasing)
- [ ] No lag or stuttering
- [ ] No crashes

**Step 5.2: Pause Playback**
- Click **Pause** button during playback

**Verification:**
- [ ] Playback pauses immediately
- [ ] Yellow indicator stops moving
- [ ] Can resume from same position

**Step 5.3: Resume Playback**
- Click **Play** again

**Verification:**
- [ ] Playback resumes from paused position
- [ ] No jump or skip
- [ ] Continues smoothly

**Step 5.4: Reset Playback**
- Click **Reset** button

**Verification:**
- [ ] Playback returns to start
- [ ] Yellow indicator at left edge
- [ ] Chart clears or resets
- [ ] Statistics reset to initial state
- [ ] Trade count = 0

**Step 5.5: Speed Control**
- Adjust the **Speed Slider**
- Try: 1x, 5x, 10x, 25x

**Verification:**
- [ ] Speed slider moves smoothly
- [ ] Speed text updates (e.g., "10x (10.0 bars/sec)")
- [ ] Playback speed changes accordingly
- [ ] Faster speeds = faster progression
- [ ] No crashes at high speeds

---

### PART 6: Test Auto-Switching (3 minutes)

**Step 6.1: Watch for Trade Events**
- Start playback (Play button)
- Observe when trades open/close

**Expected:**
- When a trade opens on pair X, view auto-switches to pair X
- When a trade closes on pair Y, view auto-switches to pair Y
- Chart switches seamlessly between pairs

**Verification:**
- [ ] Auto-switches to EURUSD when EURUSD trade opens
- [ ] Auto-switches to GBPUSD when GBPUSD trade opens
- [ ] Auto-switches to USDJPY when USDJPY trade opens
- [ ] Chart updates correctly after switch
- [ ] Tab selection updates correctly
- [ ] No visual glitches during switch

**Step 6.2: Manual Pair Switching**
- During playback, manually click a different pair tab

**Verification:**
- [ ] Can manually switch to any pair
- [ ] Chart updates to show selected pair
- [ ] Playback continues in background
- [ ] Auto-switching still works after manual switch
- [ ] Yellow indicator position maintained

---

### PART 7: Test Click-to-Jump on Timeline (4 minutes)

**Step 7.1: Click on Timeline - Beginning**
- Click near the **left edge** of the visual timeline

**Verification:**
- [ ] Playback jumps to that position
- [ ] Yellow indicator moves to clicked position
- [ ] Chart updates to show that moment
- [ ] Statistics reflect trades up to that point
- [ ] No errors

**Step 7.2: Click on Timeline - Middle**
- Click in the **middle** of the visual timeline

**Verification:**
- [ ] Playback jumps to middle
- [ ] Yellow indicator at middle
- [ ] Chart shows middle period
- [ ] Statistics show ~50% of trades

**Step 7.3: Click on Timeline - End**
- Click near the **right edge** of the visual timeline

**Verification:**
- [ ] Playback jumps to end
- [ ] Yellow indicator at right
- [ ] Chart shows final period
- [ ] Statistics show final results

**Step 7.4: Click on Specific Trade Marker**
- Find a visible trade marker (blue/orange/purple bar)
- Click directly on it

**Expected:**
- Playback jumps to that exact trade moment
- Chart displays the bar where trade occurred
- Trade details shown in Recent Trades list

**Verification:**
- [ ] Jumps to exact trade moment
- [ ] Chart shows correct pair
- [ ] Trade visible in Recent Trades list
- [ ] Can identify the specific trade
- [ ] Entry/Exit details match

**Step 7.5: Hover Over Trade Markers**
- Hover mouse over different trade markers

**Expected:**
- Tooltip appears showing:
  - Pair (e.g., "EURUSD")
  - Event type (Entry/Exit)
  - Time
  - Trade details

**Verification:**
- [ ] Tooltips appear on hover
- [ ] Show correct pair name
- [ ] Show Entry or Exit
- [ ] Show timestamp
- [ ] Tooltips disappear when mouse moves away

---

### PART 8: Test Progress Slider (2 minutes)

**Step 8.1: Drag Progress Slider**
- Drag the progress slider to different positions

**Verification:**
- [ ] Can drag slider smoothly
- [ ] Playback position updates as dragged
- [ ] Yellow timeline indicator follows slider
- [ ] Chart updates in real-time during drag
- [ ] Statistics update during drag

**Step 8.2: Click on Progress Bar**
- Click directly on the progress bar (not slider thumb)

**Verification:**
- [ ] Slider jumps to clicked position
- [ ] Playback jumps to that moment
- [ ] Chart and stats update

---

### PART 9: Verify Multi-Pair Data (2 minutes)

**Step 9.1: Check Pair-Specific Statistics**
- Look for per-pair breakdown (if displayed)

**Expected:**
- Statistics broken down by pair:
  - EURUSD: X trades, Y win rate, Z profit
  - GBPUSD: X trades, Y win rate, Z profit
  - USDJPY: X trades, Y win rate, Z profit

**Verification:**
- [ ] Per-pair statistics visible
- [ ] Each pair has trade count > 0
- [ ] Win rates make sense (0-100%)
- [ ] Profits shown (can be + or -)

**Step 9.2: Check Strategy Breakdown**
- Look for per-strategy breakdown

**Expected:**
- Statistics broken down by strategy:
  - TREND_RIDER: X trades, Y profit
  - RANGE_RIDER: X trades, Y profit

**Verification:**
- [ ] Strategy breakdown visible
- [ ] Both strategies have trades
- [ ] No SIMPLE_TEST trades (bug is fixed!)
- [ ] Statistics make sense

**Step 9.3: Review Recent Trades List**
- Scroll through the Recent Trades list

**Verification:**
- [ ] Trades from all 3 pairs present
- [ ] Mix of EURUSD, GBPUSD, USDJPY
- [ ] Mix of TREND_RIDER and RANGE_RIDER
- [ ] Chronological order (by exit time)
- [ ] All columns populated (pair, strategy, entry, exit, R, profit)

---

### PART 10: Stress Testing (Optional, 2 minutes)

**Step 10.1: Rapid Controls**
- Rapidly click: Play → Pause → Play → Reset → Play
- Drag slider back and forth quickly
- Switch pairs rapidly during playback

**Verification:**
- [ ] No crashes
- [ ] No visual corruption
- [ ] Playback recovers correctly
- [ ] No memory leaks (process stable)

**Step 10.2: Edge Cases**
- Jump to very end, then click Play
- Jump to very beginning, then click Reset
- Switch pairs while paused

**Verification:**
- [ ] Handles edge cases gracefully
- [ ] No errors or exceptions
- [ ] Behavior is predictable

---

## Expected Test Results

### Success Criteria

✅ **Phase 8.1 - Python API:**
- [ ] Multi-pair backtest executes successfully
- [ ] Returns data for all 3 pairs
- [ ] Strategy breakdown shows TREND_RIDER and RANGE_RIDER
- [ ] No SIMPLE_TEST trades (bug fix verified)
- [ ] Execution time < 2 minutes

✅ **Phase 8.2 - C# Configuration:**
- [ ] Multi-pair selection UI works
- [ ] Can select 3+ pairs
- [ ] Can select multiple strategies
- [ ] API call succeeds
- [ ] Results received and parsed

✅ **Phase 8.3 - C# Playback:**
- [ ] ChartViewerWindow opens with multi-pair data
- [ ] Visual timeline displays all trades
- [ ] Playback advances chronologically
- [ ] Auto-switches pairs on trade events
- [ ] Click-to-jump works on timeline
- [ ] Speed controls work
- [ ] Progress slider synced
- [ ] No lag or crashes

### Performance Targets

- [ ] Load time < 15 seconds (from API call to ChartViewer open)
- [ ] Playback smooth at 1x-10x speeds
- [ ] No visible lag during auto-switching
- [ ] Click-to-jump responsive (< 100ms)
- [ ] Memory usage stable during long playback

### Visual Quality

- [ ] Timeline markers clearly visible
- [ ] Color coding distinguishable (blue/orange/purple)
- [ ] Yellow indicator visible and smooth
- [ ] Entry bars taller than exit bars
- [ ] Charts render correctly
- [ ] No graphical glitches

---

## Troubleshooting

### Issue: ChartViewerWindow doesn't open
**Solution:**
- Check for error messages in BacktestWindow
- Verify API returned results (check console/logs)
- Try re-running the backtest

### Issue: No trade markers on timeline
**Solution:**
- Verify trades exist (check statistics panel)
- Check console for JavaScript errors
- Resize window to trigger re-render

### Issue: Playback doesn't advance
**Solution:**
- Check if paused (click Play)
- Verify speed slider not at 0
- Check for frozen UI (wait 10 seconds)

### Issue: Auto-switching not working
**Solution:**
- Verify trades are opening/closing
- Check console for errors
- Try manual pair switching first

### Issue: Click-to-jump not responding
**Solution:**
- Ensure clicking on canvas area (not margins)
- Try clicking different positions
- Check if playback is frozen

---

## Test Results Template

```markdown
# Phase 8 End-to-End Test Results

**Date:** YYYY-MM-DD
**Tester:** [Your Name]
**Duration:** XX minutes

## Summary
- Overall Status: PASS / FAIL / PARTIAL
- Phase 8.1 (API): PASS / FAIL
- Phase 8.2 (Config): PASS / FAIL
- Phase 8.3 (Playback): PASS / FAIL

## Test Configuration
- Pairs: EURUSD, GBPUSD, USDJPY
- Strategies: Trend Rider + Range Rider
- Period: Jan 1-31, 2024
- Total Trades: XXXX

## Checklist Results
- [X/Total] Application Launch
- [X/Total] Backtest Configuration
- [X/Total] Backtest Execution
- [X/Total] Chart Viewer Opening
- [X/Total] Playback Controls
- [X/Total] Auto-Switching
- [X/Total] Click-to-Jump
- [X/Total] Progress Slider
- [X/Total] Multi-Pair Data
- [X/Total] Stress Testing

## Issues Found
1. [Issue description]
   - Severity: Critical / High / Medium / Low
   - Steps to reproduce: ...
   - Expected: ...
   - Actual: ...

## Performance Metrics
- Load time: XX seconds
- Playback smoothness: Excellent / Good / Fair / Poor
- Memory usage: XX MB

## Screenshots
[Attach screenshots of key moments]

## Conclusion
[Overall assessment and recommendations]
```

---

## Quick Start Command

Run this to launch the test:

```bash
# Start the C# application
cd /d/Jcamp_TradingApp/CSMMonitor/JcampForexTrader/bin/Release/net8.0-windows
./JcampForexTrader.exe &

# Python API is already running on http://localhost:8001
```

---

## Post-Test Actions

After completing the test:

1. **Document Results:** Fill out the test results template
2. **Report Bugs:** Create bug reports for any issues found
3. **Update Status:** Update PHASE_8.3_STATUS.md with test results
4. **Commit Changes:** Commit any fixes or updates
5. **Mark Complete:** If all tests pass, mark Phase 8.3 as TESTED & COMPLETE ✅

---

**Good luck with the test! 🚀**
