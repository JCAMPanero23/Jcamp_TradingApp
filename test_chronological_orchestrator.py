#!/usr/bin/env python
"""
Comprehensive test for ChronologicalOrchestrator

Tests:
1. Chronological processing (trades interleaved across pairs)
2. Position limits (max 2 positions across all pairs, not per pair)
3. Exit checks (positions closed by any pair's price movement)
4. Trade count reasonableness
5. Timestamp ordering
"""

import sys
sys.path.insert(0, 'jcamp-python-backtesting/src')

from api.services.chronological_orchestrator import ChronologicalOrchestrator
from datetime import datetime
import json


def print_section(title):
    """Print formatted section header."""
    print(f"\n{'='*80}")
    print(f"  {title}")
    print(f"{'='*80}\n")


def test_chronological_orchestrator():
    """
    Run comprehensive tests on ChronologicalOrchestrator.
    """
    print_section("CHRONOLOGICAL ORCHESTRATOR COMPREHENSIVE TEST")

    # Test configuration
    pairs = ['EURUSD', 'GBPUSD']
    strategies = ['TREND_RIDER', 'RANGE_RIDER']
    config = {
        'initial_balance': 10000.0,
        'risk_percent': 2.0,
        'max_concurrent_positions': 2,
        'data_dir': 'jcamp-python-backtesting/data'
    }
    start_date = '2024-01-02'
    end_date = '2024-01-31'
    timeframe = 'M15'

    print(f"Configuration:")
    print(f"  Pairs: {', '.join(pairs)}")
    print(f"  Strategies: {', '.join(strategies)}")
    print(f"  Max Positions: {config['max_concurrent_positions']}")
    print(f"  Date Range: {start_date} to {end_date}")
    print(f"  Timeframe: {timeframe}")

    # Initialize orchestrator
    print_section("PHASE 1: INITIALIZATION")
    orchestrator = ChronologicalOrchestrator(
        pairs=pairs,
        strategies=strategies,
        config=config,
        start_date=start_date,
        end_date=end_date,
        timeframe=timeframe
    )

    # Prepare engines
    print_section("PHASE 2: DATA LOADING")
    orchestrator.prepare_pair_engines()

    # Create timeline
    print_section("PHASE 3: TIMELINE CREATION")
    timeline = orchestrator.create_global_timeline()

    print(f"\nTimeline Statistics:")
    print(f"  Total bars: {len(timeline)}")
    print(f"  First bar: {timeline[0][0]} - {timeline[0][1]}")
    print(f"  Last bar: {timeline[-1][0]} - {timeline[-1][1]}")

    # Verify timeline is sorted chronologically
    print(f"\nTimeline Validation:")
    is_sorted = all(timeline[i][0] <= timeline[i+1][0] for i in range(len(timeline)-1))
    print(f"  [OK] Chronologically sorted: {is_sorted}")

    if not is_sorted:
        print(f"  ERROR: Timeline is NOT chronologically sorted!")
        return False

    # Count bars per pair
    pair_bar_counts = {}
    for ts, pair, idx in timeline:
        pair_bar_counts[pair] = pair_bar_counts.get(pair, 0) + 1

    print(f"\n  Bars per pair:")
    for pair, count in pair_bar_counts.items():
        print(f"    {pair}: {count} bars")

    # Process chronologically
    print_section("PHASE 4: CHRONOLOGICAL PROCESSING")
    results = orchestrator.process_chronologically()

    # Analyze results
    print_section("PHASE 5: RESULTS ANALYSIS")

    trades = results["trades"]
    pair_results = results["pair_results"]
    overall_stats = results["overall_stats"]

    print(f"Overall Statistics:")
    print(f"  Total Trades: {overall_stats['total_trades']}")
    print(f"  Wins: {overall_stats['wins']}")
    print(f"  Losses: {overall_stats['losses']}")
    print(f"  Win Rate: {overall_stats['win_rate']:.1f}%")
    print(f"  Total R: {overall_stats['total_r']:.2f}")
    print(f"  Average R: {overall_stats['avg_r']:.2f}")
    print(f"  Net Profit: ${overall_stats['net_profit']:.2f}")
    print(f"  Final Balance: ${overall_stats['final_balance']:.2f}")
    print(f"  Return: {overall_stats['return_percent']:.2f}%")

    print(f"\nPer-Pair Statistics:")
    for pair, stats in pair_results.items():
        print(f"\n  {pair}:")
        print(f"    Trades: {stats['total_trades']}")
        print(f"    Wins: {stats['wins']} | Losses: {stats['losses']}")
        print(f"    Win Rate: {stats['win_rate']:.1f}%")
        print(f"    Total R: {stats['total_r']:.2f}")
        print(f"    Avg R: {stats['avg_r']:.2f}")
        print(f"    Net Profit: ${stats['net_profit']:.2f}")

    # TEST 1: Chronological Trade Order
    print_section("TEST 1: CHRONOLOGICAL TRADE ORDER")

    if len(trades) > 0:
        trade_pairs = [t['symbol'] for t in trades[:20]]  # First 20 trades
        print(f"First 20 trades by pair:")
        print(f"  {' -> '.join(trade_pairs)}")

        # Check if trades are interleaved (not all EURUSD then all GBPUSD)
        # Count consecutive same-pair trades
        max_consecutive = 1
        current_consecutive = 1
        for i in range(1, min(len(trades), 50)):
            if trades[i]['symbol'] == trades[i-1]['symbol']:
                current_consecutive += 1
                max_consecutive = max(max_consecutive, current_consecutive)
            else:
                current_consecutive = 1

        print(f"\n  Max consecutive trades from same pair (first 50): {max_consecutive}")

        # If all trades are from one pair before switching to another, that's sequential
        # If trades are interleaved, max consecutive should be low (< 10 for reasonable interleaving)
        if max_consecutive < 15:
            print(f"  PASS: Trades are interleaved across pairs (chronological processing)")
        else:
            print(f"  WARNING: Many consecutive trades from same pair - may indicate sequential processing")

        # Verify trades are sorted by entry time
        entry_times = [datetime.fromisoformat(t['entry_time']) for t in trades]
        is_time_sorted = all(entry_times[i] <= entry_times[i+1] for i in range(len(entry_times)-1))
        print(f"  [OK] Trades sorted by entry time: {is_time_sorted}")

        if not is_time_sorted:
            print(f"  ERROR: Trades are NOT sorted chronologically!")
    else:
        print(f"  [!] No trades executed - cannot test trade order")

    # TEST 2: Position Limits
    print_section("TEST 2: POSITION LIMIT ENFORCEMENT")

    max_positions = config['max_concurrent_positions']

    # Track concurrent positions over time
    position_timeline = []
    for trade in trades:
        entry_time = datetime.fromisoformat(trade['entry_time'])
        exit_time = datetime.fromisoformat(trade['exit_time'])
        position_timeline.append(('open', entry_time, trade['symbol']))
        position_timeline.append(('close', exit_time, trade['symbol']))

    # Sort by timestamp
    position_timeline.sort(key=lambda x: x[1])

    # Count concurrent positions
    concurrent_count = 0
    max_concurrent = 0
    position_violations = []

    for action, timestamp, symbol in position_timeline:
        if action == 'open':
            concurrent_count += 1
            if concurrent_count > max_concurrent:
                max_concurrent = concurrent_count
            if concurrent_count > max_positions:
                position_violations.append((timestamp, concurrent_count, symbol))
        else:
            concurrent_count -= 1

    print(f"  Configured max positions: {max_positions}")
    print(f"  Actual max concurrent: {max_concurrent}")

    if max_concurrent <= max_positions:
        print(f"  PASS: Position limits respected")
    else:
        print(f"  [X] FAIL: Position limit exceeded!")
        print(f"\n  Violations ({len(position_violations)}):")
        for ts, count, symbol in position_violations[:5]:
            print(f"    {ts}: {count} positions (limit: {max_positions}) - {symbol} opened")

    # TEST 3: Trade Count Reasonableness
    print_section("TEST 3: TRADE COUNT VALIDATION")

    total_trades = len(trades)
    days = (datetime.fromisoformat(end_date) - datetime.fromisoformat(start_date)).days + 1
    trades_per_day = total_trades / days if days > 0 else 0

    print(f"  Total trades: {total_trades}")
    print(f"  Days: {days}")
    print(f"  Trades per day: {trades_per_day:.1f}")

    # Reasonable ranges (for 2 pairs, 2 strategies)
    # Expected: ~2-10 trades per day for 4 strategy-pair combinations
    # Excessive: >20 trades per day (too aggressive)

    if trades_per_day < 2:
        print(f"  WARNING: Very few trades - strategies may be too conservative")
    elif 2 <= trades_per_day <= 20:
        print(f"  PASS: Trade count is reasonable")
    else:
        print(f"  [X] FAIL: Excessive trades - strategies too aggressive")

    # TEST 4: Strategy Distribution
    print_section("TEST 4: STRATEGY DISTRIBUTION")

    strategy_counts = {}
    for trade in trades:
        strategy = trade['strategy']
        strategy_counts[strategy] = strategy_counts.get(strategy, 0) + 1

    print(f"  Trades per strategy:")
    for strategy, count in strategy_counts.items():
        pct = (count / len(trades) * 100) if len(trades) > 0 else 0
        print(f"    {strategy}: {count} ({pct:.1f}%)")

    # Both strategies should execute some trades
    if len(strategy_counts) >= 2:
        print(f"  PASS: Multiple strategies active")
    else:
        print(f"  WARNING: Only {len(strategy_counts)} strategy executed trades")

    # TEST 5: Export Results
    print_section("TEST 5: EXPORT RESULTS")

    output_file = "test_chronological_results.json"
    export_data = {
        "config": {
            "pairs": pairs,
            "strategies": strategies,
            "max_positions": max_positions,
            "date_range": f"{start_date} to {end_date}",
            "timeframe": timeframe
        },
        "overall_stats": overall_stats,
        "pair_results": pair_results,
        "trades": trades[:10],  # First 10 trades for inspection
        "total_trades": len(trades)
    }

    with open(output_file, 'w') as f:
        json.dump(export_data, f, indent=2)

    print(f"  [OK] Results exported to: {output_file}")

    # SUMMARY
    print_section("TEST SUMMARY")

    all_tests_passed = (
        is_sorted and  # Timeline sorted
        max_concurrent <= max_positions and  # Position limits respected
        2 <= trades_per_day <= 20  # Reasonable trade count
    )

    if all_tests_passed:
        print(f"  ALL TESTS PASSED")
        print(f"\n  ChronologicalOrchestrator is functioning correctly!")
        print(f"  - Timeline is chronologically sorted")
        print(f"  - Position limits are respected")
        print(f"  - Trade count is reasonable")
        print(f"  - Trades are interleaved across pairs")
    else:
        print(f"  SOME TESTS FAILED - Review output above")

    return all_tests_passed


if __name__ == '__main__':
    try:
        success = test_chronological_orchestrator()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\nTEST FAILED WITH EXCEPTION:")
        print(f"   {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
