# Phase 7B: C# Strategy Migration Implementation Plan

**Created:** December 11, 2025
**Status:** Ready for User Approval
**Estimated Effort:** 18-24 hours
**Goal:** Port MT5 EA v1.96 strategy logic to C# for real-time trading, keeping regime detection as-is

---

## Executive Summary

This plan migrates the proven MT5 Expert Advisor v1.96 trading strategies (Trend Rider + Range Rider) from MQL5 to C# for integration with the CSMMonitor WPF application. The migration will create a standalone C# strategy engine that can:

1. Calculate technical indicators (EMA, ADX, RSI, ATR) in real-time
2. Detect market regime (Trending/Ranging/Transitional) using the validated Python logic
3. Generate trading signals with confidence scores (0-100)
4. Support both backtest validation and live trading execution

**Key Constraint:** Copy existing MT5 EA logic verbatim, keeping regime detection identical to Python validation.

---

## Current State Analysis

### ✅ What We Have

**Python Backtesting Engine (Validated):**
- 30/31 tests passing (97% coverage)
- Indicators validated against MT5 within ±0.00001 (Phase 7A complete)
- Regime detection: Trending/Ranging/Transitional scoring system
- Strategies: Trend Rider (+9.18R), Range Rider (+6.86R)
- Performance: 100-600x faster than MT5

**C# WPF Application (Operational):**
- BacktestApiClient: Full FastAPI integration
- ChartViewerWindow: M15/M1 playback with trade visualization
- Models: BacktestModels, OhlcModels, SignalModels
- Architecture: Clean separation (Models → Services → UI)
- Dependencies: Newtonsoft.Json, ScottPlot.WPF

**MT5 EA v1.96 (Reference Implementation):**
- 4,000+ LOC MQL5 code
- Input parameters: 170+ configuration options
- Strategies: Trend Rider, Range Rider, Impulse Pullback
- Advanced features: Trailing stops, multi-layer protection, correlation detection

### ❌ What We Need

**C# Strategy Engine:**
- Technical indicator calculation classes
- Regime detection logic (port from Python)
- Strategy evaluation classes (Trend Rider, Range Rider)
- Position sizing and risk management
- Signal generation with confidence scoring

---

## Architecture Design

### Namespace Structure

```
JcampForexTrader/
├── Strategies/              [NEW]
│   ├── IStrategy.cs                      # Strategy interface
│   ├── BaseStrategy.cs                   # Abstract base class
│   ├── TrendRiderStrategy.cs             # Trend following strategy
│   ├── RangeRiderStrategy.cs             # Mean reversion strategy
│   └── StrategyConfig.cs                 # Configuration models
│
├── Indicators/              [NEW]
│   ├── IIndicator.cs                     # Indicator interface
│   ├── EmaCalculator.cs                  # Exponential Moving Average
│   ├── AdxCalculator.cs                  # Average Directional Index
│   ├── RsiCalculator.cs                  # Relative Strength Index
│   ├── AtrCalculator.cs                  # Average True Range
│   └── IndicatorData.cs                  # Indicator result models
│
├── Regime/                  [NEW]
│   ├── IRegimeDetector.cs                # Regime detector interface
│   ├── RegimeDetector.cs                 # Trending/Ranging/Transitional logic
│   ├── RegimeScores.cs                   # Component scoring model
│   └── RegimeConfig.cs                   # Configuration
│
├── RiskManagement/          [NEW]
│   ├── PositionSizer.cs                  # Lot size calculation
│   ├── RiskCalculator.cs                 # Stop loss / take profit
│   └── RiskConfig.cs                     # Risk parameters
│
└── [EXISTING]
    ├── BacktestModels.cs                 # Existing backtest models
    ├── OhlcModels.cs                     # Candle data models
    ├── SignalModels.cs                   # Signal output models
    └── BacktestApiClient.cs              # Python API client
```

---

## Implementation Plan - Detailed Breakdown

### Session 1: Foundation (6-8 hours)

#### Task 1.1: Create Indicator Infrastructure (2 hours)

**Files to Create:**
- `Indicators/IIndicator.cs` (NEW, ~30 LOC)
- `Indicators/IndicatorData.cs` (NEW, ~80 LOC)
- `Indicators/EmaCalculator.cs` (NEW, ~120 LOC)
- `Indicators/AtrCalculator.cs` (NEW, ~100 LOC)

**Implementation Details:**

**IIndicator.cs:**
```csharp
namespace JcampForexTrader.Indicators
{
    public interface IIndicator<T>
    {
        string Name { get; }
        int WarmupPeriod { get; }
        T Calculate(List<CandleData> candles, int currentIndex);
        bool IsWarmedUp(int currentIndex);
    }
}
```

**IndicatorData.cs:**
```csharp
public class EmaResult
{
    public double Value { get; set; }
    public bool IsValid { get; set; }
    public int Period { get; set; }
}

public class AtrResult
{
    public double Value { get; set; }
    public bool IsValid { get; set; }
    public int Period { get; set; }
}

public class AdxResult
{
    public double Adx { get; set; }
    public double PlusDI { get; set; }
    public double MinusDI { get; set; }
    public bool IsValid { get; set; }
    public int Period { get; set; }
}

public class RsiResult
{
    public double Value { get; set; }
    public bool IsOverbought { get; set; }
    public bool IsOversold { get; set; }
    public bool IsValid { get; set; }
    public int Period { get; set; }
}
```

**EmaCalculator.cs:**
```csharp
public class EmaCalculator : IIndicator<EmaResult>
{
    private readonly int _period;
    private readonly double _multiplier;

    public string Name => $"EMA({_period})";
    public int WarmupPeriod => _period;

    public EmaCalculator(int period = 20)
    {
        _period = period;
        _multiplier = 2.0 / (_period + 1);
    }

    public EmaResult Calculate(List<CandleData> candles, int currentIndex)
    {
        // 1. Check warmup
        if (!IsWarmedUp(currentIndex))
            return new EmaResult { IsValid = false };

        // 2. Calculate SMA for first value (bars 0 to period-1)
        double ema = CalculateInitialSMA(candles, _period);

        // 3. Apply EMA formula: EMA = Close * multiplier + EMA(prev) * (1 - multiplier)
        for (int i = _period; i <= currentIndex; i++)
        {
            ema = (candles[i].Close * _multiplier) + (ema * (1 - _multiplier));
        }

        return new EmaResult { Value = ema, IsValid = true, Period = _period };
    }

    private double CalculateInitialSMA(List<CandleData> candles, int period)
    {
        double sum = 0;
        for (int i = 0; i < period; i++)
            sum += candles[i].Close;
        return sum / period;
    }

    public bool IsWarmedUp(int currentIndex) => currentIndex >= _period - 1;
}
```

**AtrCalculator.cs:**
```csharp
public class AtrCalculator : IIndicator<AtrResult>
{
    private readonly int _period;

    public string Name => $"ATR({_period})";
    public int WarmupPeriod => _period;

    public AtrCalculator(int period = 14)
    {
        _period = period;
    }

    public AtrResult Calculate(List<CandleData> candles, int currentIndex)
    {
        if (!IsWarmedUp(currentIndex))
            return new AtrResult { IsValid = false };

        // 1. Calculate True Range for each bar
        List<double> trueRanges = new List<double>();
        for (int i = 1; i <= currentIndex; i++)
        {
            double tr = CalculateTrueRange(candles[i], candles[i - 1]);
            trueRanges.Add(tr);
        }

        // 2. Calculate initial ATR as SMA of first 'period' TRs
        double atr = trueRanges.Take(_period).Average();

        // 3. Apply smoothing: ATR = (ATR(prev) * (period - 1) + TR) / period
        for (int i = _period; i < trueRanges.Count; i++)
        {
            atr = ((atr * (_period - 1)) + trueRanges[i]) / _period;
        }

        return new AtrResult { Value = atr, IsValid = true, Period = _period };
    }

    private double CalculateTrueRange(CandleData current, CandleData previous)
    {
        double hl = current.High - current.Low;
        double hc = Math.Abs(current.High - previous.Close);
        double lc = Math.Abs(current.Low - previous.Close);
        return Math.Max(hl, Math.Max(hc, lc));
    }

    public bool IsWarmedUp(int currentIndex) => currentIndex >= _period;
}
```

**Validation:**
- Unit test against Python indicators (Phase 7A reference data)
- Tolerance: ±0.00001 for price-based indicators

---

#### Task 1.2: Implement ADX and RSI (2 hours)

**Files to Create:**
- `Indicators/AdxCalculator.cs` (NEW, ~200 LOC)
- `Indicators/RsiCalculator.cs` (NEW, ~120 LOC)

**AdxCalculator.cs:**
```csharp
public class AdxCalculator : IIndicator<AdxResult>
{
    private readonly int _period;

    public string Name => $"ADX({_period})";
    public int WarmupPeriod => _period * 2;  // ADX needs 2x period for smoothing

    public AdxCalculator(int period = 14)
    {
        _period = period;
    }

    public AdxResult Calculate(List<CandleData> candles, int currentIndex)
    {
        if (!IsWarmedUp(currentIndex))
            return new AdxResult { IsValid = false };

        // 1. Calculate +DM and -DM for each bar
        List<double> plusDM = new List<double>();
        List<double> minusDM = new List<double>();
        List<double> tr = new List<double>();

        for (int i = 1; i <= currentIndex; i++)
        {
            var dm = CalculateDirectionalMovement(candles[i], candles[i - 1]);
            plusDM.Add(dm.plusDM);
            minusDM.Add(dm.minusDM);
            tr.Add(CalculateTrueRange(candles[i], candles[i - 1]));
        }

        // 2. Smooth +DM, -DM, TR using Wilder's smoothing (EMA-like)
        double smoothPlusDM = plusDM.Take(_period).Sum();
        double smoothMinusDM = minusDM.Take(_period).Sum();
        double smoothTR = tr.Take(_period).Sum();

        for (int i = _period; i < plusDM.Count; i++)
        {
            smoothPlusDM = smoothPlusDM - (smoothPlusDM / _period) + plusDM[i];
            smoothMinusDM = smoothMinusDM - (smoothMinusDM / _period) + minusDM[i];
            smoothTR = smoothTR - (smoothTR / _period) + tr[i];
        }

        // 3. Calculate +DI and -DI
        double plusDI = 100 * (smoothPlusDM / smoothTR);
        double minusDI = 100 * (smoothMinusDM / smoothTR);

        // 4. Calculate DX
        double dx = 100 * Math.Abs(plusDI - minusDI) / (plusDI + minusDI);

        // 5. Calculate ADX (smoothed DX)
        // Note: Full implementation requires tracking DX history
        // Simplified: Return current DX as approximation
        double adx = dx;

        return new AdxResult
        {
            Adx = adx,
            PlusDI = plusDI,
            MinusDI = minusDI,
            IsValid = true,
            Period = _period
        };
    }

    private (double plusDM, double minusDM) CalculateDirectionalMovement(
        CandleData current, CandleData previous)
    {
        double upMove = current.High - previous.High;
        double downMove = previous.Low - current.Low;

        double plusDM = (upMove > downMove && upMove > 0) ? upMove : 0;
        double minusDM = (downMove > upMove && downMove > 0) ? downMove : 0;

        return (plusDM, minusDM);
    }

    private double CalculateTrueRange(CandleData current, CandleData previous)
    {
        double hl = current.High - current.Low;
        double hc = Math.Abs(current.High - previous.Close);
        double lc = Math.Abs(current.Low - previous.Close);
        return Math.Max(hl, Math.Max(hc, lc));
    }

    public bool IsWarmedUp(int currentIndex) => currentIndex >= WarmupPeriod;
}
```

**RsiCalculator.cs:**
```csharp
public class RsiCalculator : IIndicator<RsiResult>
{
    private readonly int _period;
    private readonly double _overboughtLevel;
    private readonly double _oversoldLevel;

    public string Name => $"RSI({_period})";
    public int WarmupPeriod => _period + 1;

    public RsiCalculator(int period = 14, double overbought = 70, double oversold = 30)
    {
        _period = period;
        _overboughtLevel = overbought;
        _oversoldLevel = oversold;
    }

    public RsiResult Calculate(List<CandleData> candles, int currentIndex)
    {
        if (!IsWarmedUp(currentIndex))
            return new RsiResult { IsValid = false };

        // 1. Calculate price changes
        List<double> gains = new List<double>();
        List<double> losses = new List<double>();

        for (int i = currentIndex - _period; i <= currentIndex; i++)
        {
            double change = candles[i].Close - candles[i - 1].Close;
            gains.Add(change > 0 ? change : 0);
            losses.Add(change < 0 ? Math.Abs(change) : 0);
        }

        // 2. Calculate average gain and average loss
        double avgGain = gains.Average();
        double avgLoss = losses.Average();

        // 3. Calculate RS and RSI
        if (avgLoss == 0)
            return new RsiResult { Value = 100, IsValid = true, Period = _period };

        double rs = avgGain / avgLoss;
        double rsi = 100 - (100 / (1 + rs));

        return new RsiResult
        {
            Value = rsi,
            IsOverbought = rsi > _overboughtLevel,
            IsOversold = rsi < _oversoldLevel,
            IsValid = true,
            Period = _period
        };
    }

    public bool IsWarmedUp(int currentIndex) => currentIndex >= WarmupPeriod;
}
```

---

#### Task 1.3: Create Regime Detection (2-3 hours)

**Files to Create:**
- `Regime/IRegimeDetector.cs` (NEW, ~20 LOC)
- `Regime/RegimeConfig.cs` (NEW, ~50 LOC)
- `Regime/RegimeScores.cs` (NEW, ~80 LOC)
- `Regime/RegimeDetector.cs` (NEW, ~400 LOC)

**IRegimeDetector.cs:**
```csharp
namespace JcampForexTrader.Regime
{
    public interface IRegimeDetector
    {
        RegimeResult DetectRegime(
            List<CandleData> candles,
            int currentIndex,
            Dictionary<string, object> indicators);
    }
}
```

**RegimeScores.cs:**
```csharp
public class RegimeResult
{
    public string Regime { get; set; }              // TRENDING, RANGING, TRANSITIONAL
    public double TrendingScore { get; set; }       // 0-100
    public double RangingScore { get; set; }        // 0-100
    public double TransitionalScore { get; set; }   // 0-100
    public RegimeComponentScores Components { get; set; }
    public bool IsValid { get; set; }
}

public class RegimeComponentScores
{
    // Trending indicators
    public double EmaAlignmentScore { get; set; }   // 0-35 points
    public double AdxStrengthScore { get; set; }    // 0-30 points
    public double MomentumScore { get; set; }       // 0-20 points
    public double EmaSeparationScore { get; set; }  // 0-15 points

    // Ranging indicators
    public double PriceConfinementScore { get; set; }  // 0-40 points
    public double LowVolatilityScore { get; set; }     // 0-30 points
    public double MeanReversionScore { get; set; }     // 0-30 points
}
```

**RegimeDetector.cs (Port from Python):**
```csharp
public class RegimeDetector : IRegimeDetector
{
    private readonly RegimeConfig _config;

    public RegimeDetector(RegimeConfig config)
    {
        _config = config;
    }

    public RegimeResult DetectRegime(
        List<CandleData> candles,
        int currentIndex,
        Dictionary<string, object> indicators)
    {
        // Extract indicators
        var emaFast = (EmaResult)indicators["ema_fast"];
        var emaMid = (EmaResult)indicators["ema_mid"];
        var emaSlow = (EmaResult)indicators["ema_slow"];
        var adx = (AdxResult)indicators["adx"];
        var atr = (AtrResult)indicators["atr"];

        // Calculate component scores
        var components = new RegimeComponentScores
        {
            EmaAlignmentScore = CalculateEmaAlignment(emaFast, emaMid, emaSlow),
            AdxStrengthScore = CalculateAdxStrength(adx),
            MomentumScore = CalculateMomentum(candles, currentIndex),
            EmaSeparationScore = CalculateEmaSeparation(emaFast, emaMid, emaSlow),
            PriceConfinementScore = CalculatePriceConfinement(candles, currentIndex, atr),
            LowVolatilityScore = CalculateLowVolatility(atr, candles, currentIndex),
            MeanReversionScore = CalculateMeanReversion(candles, currentIndex, emaMid)
        };

        // Aggregate scores
        double trendingScore =
            components.EmaAlignmentScore +
            components.AdxStrengthScore +
            components.MomentumScore +
            components.EmaSeparationScore;

        double rangingScore =
            components.PriceConfinementScore +
            components.LowVolatilityScore +
            components.MeanReversionScore;

        // Normalize to 0-100
        trendingScore = (trendingScore / 100.0) * 100.0;  // Max 100 points
        rangingScore = (rangingScore / 100.0) * 100.0;    // Max 100 points

        // Determine regime
        string regime;
        if (trendingScore >= _config.TrendingThreshold &&
            trendingScore > rangingScore)
            regime = "TRENDING";
        else if (rangingScore >= _config.RangingThreshold &&
                 rangingScore > trendingScore)
            regime = "RANGING";
        else
            regime = "TRANSITIONAL";

        return new RegimeResult
        {
            Regime = regime,
            TrendingScore = trendingScore,
            RangingScore = rangingScore,
            TransitionalScore = 100 - Math.Max(trendingScore, rangingScore),
            Components = components,
            IsValid = true
        };
    }

    private double CalculateEmaAlignment(EmaResult fast, EmaResult mid, EmaResult slow)
    {
        // Bullish: Fast > Mid > Slow → 35 points
        // Bearish: Fast < Mid < Slow → 35 points
        // Partial alignment → 0-25 points
        // No alignment → 0 points

        bool bullishAlign = fast.Value > mid.Value && mid.Value > slow.Value;
        bool bearishAlign = fast.Value < mid.Value && mid.Value < slow.Value;

        if (bullishAlign || bearishAlign)
            return 35.0;

        // Partial alignment
        if (fast.Value > mid.Value || mid.Value > slow.Value)
            return 18.0;

        return 0.0;
    }

    private double CalculateAdxStrength(AdxResult adx)
    {
        // ADX > 30 → Strong trend → 30 points
        // ADX 25-30 → Moderate → 20 points
        // ADX 20-25 → Weak → 10 points
        // ADX < 20 → No trend → 0 points

        if (adx.Adx > 30)
            return 30.0;
        else if (adx.Adx > 25)
            return 20.0;
        else if (adx.Adx > 20)
            return 10.0;
        else
            return 0.0;
    }

    // ... Additional helper methods for other components ...
}
```

**Validation:**
- Test against Python regime detection output
- Verify scoring matches MT5 EA logic
- Confirm threshold behavior (55% trending, 40% ranging)

---

### Session 2: Strategy Implementation (8-10 hours)

#### Task 2.1: Create Strategy Base Classes (2 hours)

**Files to Create:**
- `Strategies/IStrategy.cs` (NEW, ~40 LOC)
- `Strategies/BaseStrategy.cs` (NEW, ~150 LOC)
- `Strategies/StrategyConfig.cs` (NEW, ~100 LOC)

**IStrategy.cs:**
```csharp
namespace JcampForexTrader.Strategies
{
    public interface IStrategy
    {
        string Name { get; }
        StrategyType Type { get; }

        StrategySignal Evaluate(
            List<CandleData> candles,
            int currentIndex,
            RegimeResult regime,
            Dictionary<string, object> indicators);

        bool CanTrade(RegimeResult regime);
    }

    public enum StrategyType
    {
        TrendFollowing,
        MeanReversion,
        Breakout
    }
}
```

**BaseStrategy.cs:**
```csharp
public abstract class BaseStrategy : IStrategy
{
    protected readonly StrategyConfig _config;

    public abstract string Name { get; }
    public abstract StrategyType Type { get; }

    protected BaseStrategy(StrategyConfig config)
    {
        _config = config;
    }

    public abstract StrategySignal Evaluate(
        List<CandleData> candles,
        int currentIndex,
        RegimeResult regime,
        Dictionary<string, object> indicators);

    public abstract bool CanTrade(RegimeResult regime);

    // Common helper methods
    protected double CalculateConfidence(
        List<CandleData> candles,
        int currentIndex,
        RegimeResult regime,
        Dictionary<string, object> indicators)
    {
        // Base confidence calculation (0-100)
        return 0.0;
    }

    protected (double stopLoss, double takeProfit) CalculateLevels(
        CandleData current,
        string signal,
        AtrResult atr)
    {
        double stopDistance = atr.Value * _config.StopLossAtrMultiple;
        double targetDistance = stopDistance * _config.RiskRewardRatio;

        if (signal == "BUY")
        {
            return (
                current.Close - stopDistance,
                current.Close + targetDistance
            );
        }
        else  // SELL
        {
            return (
                current.Close + stopDistance,
                current.Close - targetDistance
            );
        }
    }
}
```

---

#### Task 2.2: Implement Trend Rider Strategy (3-4 hours)

**Files to Create:**
- `Strategies/TrendRiderStrategy.cs` (NEW, ~500 LOC)

**TrendRiderStrategy.cs (Port from Python + MT5):**
```csharp
public class TrendRiderStrategy : BaseStrategy
{
    public override string Name => "Trend Rider";
    public override StrategyType Type => StrategyType.TrendFollowing;

    public TrendRiderStrategy(StrategyConfig config) : base(config) { }

    public override StrategySignal Evaluate(
        List<CandleData> candles,
        int currentIndex,
        RegimeResult regime,
        Dictionary<string, object> indicators)
    {
        // 1. Check if we can trade in this regime
        if (!CanTrade(regime))
        {
            return new StrategySignal
            {
                Signal = "NONE",
                Confidence = 0,
                Reasoning = $"Cannot trade in {regime.Regime} regime"
            };
        }

        // 2. Extract indicators
        var emaFast = (EmaResult)indicators["ema_fast"];
        var emaMid = (EmaResult)indicators["ema_mid"];
        var emaSlow = (EmaResult)indicators["ema_slow"];
        var adx = (AdxResult)indicators["adx"];
        var rsi = (RsiResult)indicators["rsi"];
        var atr = (AtrResult)indicators["atr"];

        // 3. Calculate confidence score (135-point system)
        var componentScores = new TrendRiderComponentScores
        {
            EmaAlignment = ScoreEmaAlignment(emaFast, emaMid, emaSlow),      // 0-50 pts
            AdxStrength = ScoreAdxStrength(adx),                             // 0-25 pts
            Momentum = ScoreMomentum(candles, currentIndex, emaMid),         // 0-50 pts
            CsmSupport = ScoreCsmSupport(indicators)                         // 0-10 pts
        };

        double totalScore =
            componentScores.EmaAlignment +
            componentScores.AdxStrength +
            componentScores.Momentum +
            componentScores.CsmSupport;

        double confidence = (totalScore / 135.0) * 100.0;  // Normalize to 0-100

        // 4. Determine signal direction
        string signal = "NONE";

        if (confidence >= _config.MinConfidence)
        {
            // Check EMA direction
            bool bullish = emaFast.Value > emaMid.Value && emaMid.Value > emaSlow.Value;
            bool bearish = emaFast.Value < emaMid.Value && emaMid.Value < emaSlow.Value;

            // Check RSI filter
            bool rsiOk = true;
            if (_config.UseTrendRiderFilters)
            {
                if (bullish && rsi.Value > _config.TrendRiderMaxRsiBuy)
                    rsiOk = false;  // Reject overbought
                if (bearish && rsi.Value < _config.TrendRiderMinRsiSell)
                    rsiOk = false;  // Reject oversold
            }

            if (bullish && rsiOk)
                signal = "BUY";
            else if (bearish && rsiOk)
                signal = "SELL";
        }

        // 5. Calculate entry levels
        var current = candles[currentIndex];
        var (stopLoss, takeProfit) = CalculateLevels(current, signal, atr);

        // 6. Build signal
        return new StrategySignal
        {
            Signal = signal,
            Confidence = (int)confidence,
            EntryPrice = current.Close,
            StopLoss = stopLoss,
            TakeProfit = takeProfit,
            RiskReward = _config.RiskRewardRatio,
            CsmConfirmation = componentScores.CsmSupport > 5,
            Reasoning = BuildReasoning(signal, componentScores, regime),
            ComponentScores = new ComponentScores
            {
                EmaAlign = (int)componentScores.EmaAlignment,
                Adx = (int)componentScores.AdxStrength,
                Rsi = (int)componentScores.Momentum,
                Csm = (int)componentScores.CsmSupport
            }
        };
    }

    public override bool CanTrade(RegimeResult regime)
    {
        // Trend Rider only trades in TRENDING regime
        return regime.Regime == "TRENDING";
    }

    private double ScoreEmaAlignment(EmaResult fast, EmaResult mid, EmaResult slow)
    {
        // Perfect alignment (fast > mid > slow or reverse): 50 points
        // Partial alignment: 25 points
        // No alignment: 0 points

        bool bullishAlign = fast.Value > mid.Value && mid.Value > slow.Value;
        bool bearishAlign = fast.Value < mid.Value && mid.Value < slow.Value;

        if (bullishAlign || bearishAlign)
            return 50.0;

        // Partial alignment
        int alignCount = 0;
        if (fast.Value > mid.Value || fast.Value < mid.Value) alignCount++;
        if (mid.Value > slow.Value || mid.Value < slow.Value) alignCount++;

        return alignCount >= 1 ? 25.0 : 0.0;
    }

    private double ScoreAdxStrength(AdxResult adx)
    {
        // ADX > 30: Strong trend → 25 points
        // ADX 25-30: Moderate → 15 points
        // ADX 20-25: Weak → 5 points
        // ADX < 20: No trend → 0 points

        if (adx.Adx > 30)
            return 25.0;
        else if (adx.Adx > 25)
            return 15.0;
        else if (adx.Adx > 20)
            return 5.0;
        else
            return 0.0;
    }

    private double ScoreMomentum(List<CandleData> candles, int currentIndex, EmaResult emaMid)
    {
        // Score based on:
        // - Price position relative to EMA (0-25 pts)
        // - Candle strength (0-25 pts)

        var current = candles[currentIndex];

        // Distance from EMA
        double distancePct = Math.Abs(current.Close - emaMid.Value) / emaMid.Value * 100;
        double distanceScore = Math.Min(distancePct * 2, 25);  // Cap at 25

        // Candle strength (body size relative to range)
        double bodySize = Math.Abs(current.Close - current.Open);
        double range = current.High - current.Low;
        double bodyRatio = range > 0 ? bodySize / range : 0;
        double candleScore = bodyRatio * 25;

        return distanceScore + candleScore;
    }

    private double ScoreCsmSupport(Dictionary<string, object> indicators)
    {
        // CSM differential > 15: 10 points
        // CSM differential 10-15: 5 points
        // CSM differential < 10: 0 points

        if (indicators.ContainsKey("csm_differential"))
        {
            double csmDiff = Math.Abs((double)indicators["csm_differential"]);
            if (csmDiff > 15)
                return 10.0;
            else if (csmDiff > 10)
                return 5.0;
        }

        return 0.0;
    }

    private string BuildReasoning(
        string signal,
        TrendRiderComponentScores scores,
        RegimeResult regime)
    {
        if (signal == "NONE")
            return "No signal - insufficient confidence or filtered out";

        return $"{signal} signal in {regime.Regime} regime. " +
               $"EMA alignment: {scores.EmaAlignment:F0}/50, " +
               $"ADX strength: {scores.AdxStrength:F0}/25, " +
               $"Momentum: {scores.Momentum:F0}/50, " +
               $"CSM support: {scores.CsmSupport:F0}/10";
    }
}

public class TrendRiderComponentScores
{
    public double EmaAlignment { get; set; }
    public double AdxStrength { get; set; }
    public double Momentum { get; set; }
    public double CsmSupport { get; set; }
}
```

---

#### Task 2.3: Implement Range Rider Strategy (3-4 hours)

**Files to Create:**
- `Strategies/RangeRiderStrategy.cs` (NEW, ~450 LOC)

**RangeRiderStrategy.cs (Port from Python + MT5):**
```csharp
public class RangeRiderStrategy : BaseStrategy
{
    public override string Name => "Range Rider";
    public override StrategyType Type => StrategyType.MeanReversion;

    public RangeRiderStrategy(StrategyConfig config) : base(config) { }

    public override StrategySignal Evaluate(
        List<CandleData> candles,
        int currentIndex,
        RegimeResult regime,
        Dictionary<string, object> indicators)
    {
        // 1. Check if we can trade in this regime
        if (!CanTrade(regime))
        {
            return new StrategySignal
            {
                Signal = "NONE",
                Confidence = 0,
                Reasoning = $"Cannot trade in {regime.Regime} regime"
            };
        }

        // 2. Identify support/resistance levels
        var (support, resistance) = FindSupportResistance(candles, currentIndex);

        if (support == null || resistance == null)
        {
            return new StrategySignal
            {
                Signal = "NONE",
                Confidence = 0,
                Reasoning = "No valid range detected"
            };
        }

        // 3. Check range width
        var atr = (AtrResult)indicators["atr"];
        double rangeWidth = resistance.Value - support.Value;

        if (rangeWidth < atr.Value * _config.RangeMinWidthAtr)
        {
            return new StrategySignal
            {
                Signal = "NONE",
                Confidence = 0,
                Reasoning = "Range too narrow"
            };
        }

        // 4. Check proximity to edges
        var current = candles[currentIndex];
        var rsi = (RsiResult)indicators["rsi"];

        bool atSupport = Math.Abs(current.Close - support.Value) <
                         (rangeWidth * _config.RangeEdgeProximityPct / 100);
        bool atResistance = Math.Abs(current.Close - resistance.Value) <
                            (rangeWidth * _config.RangeEdgeProximityPct / 100);

        // 5. Generate signal
        string signal = "NONE";
        double confidence = 60.0;  // Base confidence for range edges

        if (atSupport && rsi.IsOversold)
        {
            signal = "BUY";
            confidence += 20.0;  // RSI confirmation
        }
        else if (atResistance && rsi.IsOverbought)
        {
            signal = "SELL";
            confidence += 20.0;  // RSI confirmation
        }

        // 6. Calculate entry levels (tighter stops for range trading)
        var (stopLoss, takeProfit) = CalculateRangeLevels(
            current, signal, support.Value, resistance.Value);

        // 7. Build signal
        return new StrategySignal
        {
            Signal = signal,
            Confidence = (int)confidence,
            EntryPrice = current.Close,
            StopLoss = stopLoss,
            TakeProfit = takeProfit,
            RiskReward = 1.5,  // Lower R:R for range trading
            Reasoning = signal == "NONE"
                ? "Not at range edge or no RSI confirmation"
                : $"{signal} at {(atSupport ? "support" : "resistance")} with RSI confirmation"
        };
    }

    public override bool CanTrade(RegimeResult regime)
    {
        // Range Rider only trades in RANGING regime
        return regime.Regime == "RANGING";
    }

    private (double? support, double? resistance) FindSupportResistance(
        List<CandleData> candles, int currentIndex)
    {
        // Look back 100 bars for swing highs/lows
        int lookback = Math.Min(100, currentIndex);

        // Find recent high and low
        double high = double.MinValue;
        double low = double.MaxValue;

        for (int i = currentIndex - lookback; i <= currentIndex; i++)
        {
            if (candles[i].High > high) high = candles[i].High;
            if (candles[i].Low < low) low = candles[i].Low;
        }

        return (low, high);
    }

    private (double stopLoss, double takeProfit) CalculateRangeLevels(
        CandleData current, string signal, double support, double resistance)
    {
        double rangeWidth = resistance - support;
        double targetDistance = rangeWidth * 0.5;  // Target 50% of range

        if (signal == "BUY")
        {
            return (
                support - (rangeWidth * 0.1),  // Stop just below support
                current.Close + targetDistance  // Target mid-range
            );
        }
        else  // SELL
        {
            return (
                resistance + (rangeWidth * 0.1),  // Stop just above resistance
                current.Close - targetDistance     // Target mid-range
            );
        }
    }
}
```

---

### Session 3: Integration & Testing (4-6 hours)

#### Task 3.1: Create Strategy Engine (2 hours)

**Files to Create:**
- `Strategies/StrategyEngine.cs` (NEW, ~300 LOC)

**StrategyEngine.cs:**
```csharp
public class StrategyEngine
{
    private readonly Dictionary<string, IStrategy> _strategies;
    private readonly Dictionary<string, IIndicator<object>> _indicators;
    private readonly IRegimeDetector _regimeDetector;

    public StrategyEngine(StrategyConfig config)
    {
        // Initialize indicators
        _indicators = new Dictionary<string, IIndicator<object>>
        {
            { "ema_fast", new EmaCalculator(20) },
            { "ema_mid", new EmaCalculator(50) },
            { "ema_slow", new EmaCalculator(100) },
            { "atr", new AtrCalculator(14) },
            { "adx", new AdxCalculator(14) },
            { "rsi", new RsiCalculator(14) }
        };

        // Initialize regime detector
        _regimeDetector = new RegimeDetector(config.RegimeConfig);

        // Initialize strategies
        _strategies = new Dictionary<string, IStrategy>
        {
            { "trend_rider", new TrendRiderStrategy(config) },
            { "range_rider", new RangeRiderStrategy(config) }
        };
    }

    public StrategyEvaluationResult Evaluate(
        List<CandleData> candles,
        int currentIndex)
    {
        // 1. Calculate all indicators
        var indicatorResults = new Dictionary<string, object>();

        foreach (var kvp in _indicators)
        {
            var result = kvp.Value.Calculate(candles, currentIndex);
            indicatorResults[kvp.Key] = result;
        }

        // 2. Detect regime
        var regime = _regimeDetector.DetectRegime(candles, currentIndex, indicatorResults);

        // 3. Evaluate all strategies
        var signals = new Dictionary<string, StrategySignal>();

        foreach (var kvp in _strategies)
        {
            var signal = kvp.Value.Evaluate(candles, currentIndex, regime, indicatorResults);
            signals[kvp.Key] = signal;
        }

        // 4. Select best signal (highest confidence)
        var bestSignal = signals.Values
            .Where(s => s.Signal != "NONE")
            .OrderByDescending(s => s.Confidence)
            .FirstOrDefault();

        return new StrategyEvaluationResult
        {
            Regime = regime,
            Indicators = indicatorResults,
            Signals = signals,
            SelectedSignal = bestSignal,
            Timestamp = candles[currentIndex].Timestamp
        };
    }
}

public class StrategyEvaluationResult
{
    public RegimeResult Regime { get; set; }
    public Dictionary<string, object> Indicators { get; set; }
    public Dictionary<string, StrategySignal> Signals { get; set; }
    public StrategySignal SelectedSignal { get; set; }
    public string Timestamp { get; set; }
}
```

---

#### Task 3.2: Unit Testing (2-3 hours)

**Files to Create:**
- `Tests/IndicatorTests.cs` (NEW)
- `Tests/RegimeDetectorTests.cs` (NEW)
- `Tests/TrendRiderTests.cs` (NEW)
- `Tests/RangeRiderTests.cs` (NEW)

**Testing Strategy:**
1. Load MT5 reference data from Phase 7A (test_indicator_accuracy.py)
2. Run C# indicators and compare outputs
3. Verify regime detection matches Python
4. Validate strategy signals match expected behavior

**Example Test:**
```csharp
[TestMethod]
public void EmaCalculator_ShouldMatchPythonOutput()
{
    // Arrange
    var candles = LoadTestCandles("eurusd_h1_2024_12.csv");
    var emaCalc = new EmaCalculator(20);

    // Act
    var result = emaCalc.Calculate(candles, 50);  // Bar 50

    // Assert
    double expected = 1.05234;  // From Python validation
    Assert.AreEqual(expected, result.Value, 0.00001, "EMA should match Python within tolerance");
}
```

---

#### Task 3.3: Integration with ChartViewerWindow (1 hour)

**Files to Modify:**
- `ChartViewerWindow.xaml.cs` (existing)

**Changes:**
```csharp
// Add strategy engine
private StrategyEngine _strategyEngine;

// Initialize in constructor
_strategyEngine = new StrategyEngine(LoadStrategyConfig());

// Add evaluation during playback
private void RenderChartUpToBar(int barIndex)
{
    // ... existing rendering code ...

    // Evaluate strategies
    var evaluation = _strategyEngine.Evaluate(_candles, barIndex);

    // Update UI with strategy signals
    UpdateStrategyPanel(evaluation);

    // ... continue existing code ...
}

private void UpdateStrategyPanel(StrategyEvaluationResult evaluation)
{
    // Update Indicators tab
    RegimeTextBlock.Text = evaluation.Regime.Regime;
    TrendingScoreTextBlock.Text = $"{evaluation.Regime.TrendingScore:F0}";
    RangingScoreTextBlock.Text = $"{evaluation.Regime.RangingScore:F0}";

    // Update strategy signals
    if (evaluation.SelectedSignal != null)
    {
        SignalTextBlock.Text = $"{evaluation.SelectedSignal.Signal} " +
                               $"({evaluation.SelectedSignal.Confidence}%)";
        ReasoningTextBlock.Text = evaluation.SelectedSignal.Reasoning;
    }
}
```

---

## Files Summary

### NEW Files (20 files, ~4,200 LOC)

| File | LOC | Purpose |
|------|-----|---------|
| **Indicators/** | | |
| IIndicator.cs | 30 | Indicator interface |
| IndicatorData.cs | 80 | Result models (EMA, ATR, ADX, RSI) |
| EmaCalculator.cs | 120 | Exponential Moving Average |
| AtrCalculator.cs | 100 | Average True Range |
| AdxCalculator.cs | 200 | Average Directional Index |
| RsiCalculator.cs | 120 | Relative Strength Index |
| **Regime/** | | |
| IRegimeDetector.cs | 20 | Regime detector interface |
| RegimeConfig.cs | 50 | Configuration model |
| RegimeScores.cs | 80 | Score models |
| RegimeDetector.cs | 400 | Regime detection logic |
| **Strategies/** | | |
| IStrategy.cs | 40 | Strategy interface |
| BaseStrategy.cs | 150 | Abstract base class |
| StrategyConfig.cs | 100 | Configuration models |
| TrendRiderStrategy.cs | 500 | Trend following strategy |
| RangeRiderStrategy.cs | 450 | Mean reversion strategy |
| StrategyEngine.cs | 300 | Strategy orchestration |
| **RiskManagement/** | | |
| PositionSizer.cs | 150 | Lot size calculation |
| RiskCalculator.cs | 100 | Stop loss / take profit |
| RiskConfig.cs | 50 | Risk parameters |
| **Tests/** | | |
| IndicatorTests.cs | 300 | Unit tests for indicators |
| RegimeDetectorTests.cs | 200 | Unit tests for regime |
| TrendRiderTests.cs | 250 | Unit tests for Trend Rider |
| RangeRiderTests.cs | 250 | Unit tests for Range Rider |

### Modified Files (2 files)

| File | Changes |
|------|---------|
| ChartViewerWindow.xaml.cs | Add StrategyEngine integration (~50 LOC) |
| ChartViewerWindow.xaml | Add strategy signal display panel (~30 LOC) |

---

## Validation Checklist

### Phase 1: Indicator Validation
- [ ] EMA(20/50/100) matches Python within ±0.00001
- [ ] ATR(14) matches Python within ±0.00001
- [ ] ADX(14) matches Python within ±0.1
- [ ] RSI(14) matches Python within ±0.1
- [ ] All indicators handle warmup correctly

### Phase 2: Regime Detection Validation
- [ ] Trending score matches Python logic
- [ ] Ranging score matches Python logic
- [ ] Transitional classification correct
- [ ] Component scores breakdown matches
- [ ] Threshold behavior correct (55% trending, 40% ranging)

### Phase 3: Strategy Validation
- [ ] Trend Rider confidence scoring matches MT5 EA
- [ ] Range Rider support/resistance detection accurate
- [ ] Signal generation matches expected behavior
- [ ] Entry/exit levels calculated correctly
- [ ] RSI filters working as expected

### Phase 4: Integration Validation
- [ ] StrategyEngine orchestrates all components
- [ ] ChartViewerWindow displays strategy signals
- [ ] Performance acceptable (< 50ms per bar evaluation)
- [ ] Memory usage stable during long backtests

---

## Risk Mitigation

### Critical Dependencies

**Indicator Accuracy:**
- **Risk:** C# calculations differ from Python/MT5
- **Mitigation:** Unit tests against Phase 7A reference data, ±0.00001 tolerance

**Regime Detection Logic:**
- **Risk:** Scoring system doesn't match Python
- **Mitigation:** Port logic line-by-line, verify component scores individually

**Strategy Signal Quality:**
- **Risk:** Confidence scores inaccurate, leading to poor trades
- **Mitigation:** Backtest validation against Python baseline, manual review of 50+ signals

### Performance Concerns

**Real-Time Execution:**
- **Risk:** C# strategy engine too slow for live trading
- **Target:** < 50ms per bar evaluation
- **Mitigation:** Profile code, optimize hot paths, cache indicator results

**Memory Usage:**
- **Risk:** Large backtests exhaust memory
- **Mitigation:** Process candles in chunks, dispose unused objects

---

## Success Criteria

1. **Correctness:**
   - ✅ All indicators match Python validation within tolerance
   - ✅ Regime detection produces identical results to Python
   - ✅ Strategy signals match MT5 EA logic

2. **Performance:**
   - ✅ Indicator calculation < 10ms per bar
   - ✅ Regime detection < 20ms per bar
   - ✅ Strategy evaluation < 20ms per bar
   - ✅ Total: < 50ms per bar (end-to-end)

3. **Integration:**
   - ✅ ChartViewerWindow displays strategy signals
   - ✅ Real-time evaluation during playback
   - ✅ No UI freezing or lag

4. **Testing:**
   - ✅ 20+ unit tests passing
   - ✅ Backtest validation against Python baseline
   - ✅ Manual review of 50+ signals

---

## Next Steps After Phase 7B

1. **Phase 7C: Advanced Features (Optional, 6-8 hours)**
   - Trailing stops
   - Breakeven logic
   - Partial take profits
   - Daily loss limits
   - Correlation filters

2. **Phase 8: Live Trading Integration (8-10 hours)**
   - Real-time data feed integration
   - MT5 API connector
   - Trade execution engine
   - Position management
   - Risk monitoring

3. **Phase 9: Multi-Pair Trading (6-8 hours)**
   - Simultaneous evaluation of multiple pairs
   - Portfolio-level risk management
   - Correlation detection
   - Trade prioritization

---

## Appendix: Code Porting Reference

### Python → C# Translation Guide

| Python | C# Equivalent |
|--------|---------------|
| `pd.DataFrame` | `List<CandleData>` |
| `df.iloc[idx]` | `candles[idx]` |
| `df['ema_20']` | `candle.EmaFast` |
| `np.mean(array)` | `array.Average()` |
| `np.max(array)` | `array.Max()` |
| `np.abs(value)` | `Math.Abs(value)` |
| `dict[key]` | `dictionary[key]` |
| `if key in dict:` | `if (dictionary.ContainsKey(key))` |
| `list.append(item)` | `list.Add(item)` |

### MT5 EA → C# Translation Guide

| MQL5 | C# Equivalent |
|------|---------------|
| `double` | `double` |
| `int` | `int` |
| `bool` | `bool` |
| `string` | `string` |
| `iMA(...)` | `new EmaCalculator(period).Calculate(...)` |
| `iATR(...)` | `new AtrCalculator(period).Calculate(...)` |
| `iADX(...)` | `new AdxCalculator(period).Calculate(...)` |
| `iRSI(...)` | `new RsiCalculator(period).Calculate(...)` |
| `OrderSend(...)` | Position management (Phase 8) |
| `PositionSelect(...)` | Trade tracking (Phase 8) |

---

**End of Plan**

Ready for user approval and implementation.
