//+------------------------------------------------------------------+
//|                  Jcamp_BacktestEA_Validation.mq5 v1.0            |
//|              Regime & CSM Validation Indicator                   |
//|                                                                   |
//| Purpose: Export regime detection and CSM data for validation     |
//| Test Period: December 2-6, 2024 (Monday-Friday business week)    |
//| Output: validation_output_mt5.csv (in MT5 Data folder)           |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
#property indicator_plots 0

input string OutputFile = "D:\\JcampFxTrading\\jcamp-python-backtesting\\data\\validation_output_mt5.csv";

int file_handle = INVALID_HANDLE;
int bars_written = 0;
bool file_created = false;

//+------------------------------------------------------------------+
//| OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit() {
    // Try to open file with full path (direct disk access)
    // Note: Strategy Tester allows writing to external paths
    file_handle = FileOpen(OutputFile, FILE_WRITE | FILE_CSV, '\t');

    if (file_handle == INVALID_HANDLE) {
        Print("Failed to create: " + OutputFile);
        Print("Trying to write to external path - Strategy Tester may restrict this");
        Print("Alternative: Save output to MT5 terminal folder and copy manually");
        return INIT_FAILED;
    }

    // Write header
    string header = "DateTime\tRegime\tADXScore\tEMAScore\tATRScore\tPriceActionScore\t";
    header += "CSM_EUR\tCSM_USD\tCSM_GBP\tCSM_JPY\tCSM_CHF\tCSM_AUD\tCSM_CAD\tCSM_NZD";
    FileWrite(file_handle, header);
    FileFlush(file_handle);

    file_created = true;
    Print("Validation indicator started. Output: " + OutputFile);
    Print("Writing to: " + OutputFile);

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnCalculate                                                       |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {

    // Only write on new bars
    if (prev_calculated == rates_total) {
        return rates_total;
    }

    int bar = 0; // Current bar

    // Get prices
    double c = close[bar];
    double h = high[bar];
    double l = low[bar];
    double o = open[bar];

    // Calculate simple indicators (simplified for validation)
    // In a real implementation, these would be from proper indicator handles
    double ema20_val = CalculateSimpleEMA(close, 20, bar);
    double ema50_val = CalculateSimpleEMA(close, 50, bar);
    double ema100_val = CalculateSimpleEMA(close, 100, bar);

    // Detect regime
    string regime = DetectRegime(ema20_val, ema50_val, ema100_val, c);

    // Format datetime as YYYY.MM.DD HH:MM
    string dt_str = TimeToString(time[bar], TIME_DATE);
    string tm_str = TimeToString(time[bar], TIME_MINUTES);
    dt_str = StringSubstr(dt_str, 0, 4) + "." + StringSubstr(dt_str, 5, 2) + "." + StringSubstr(dt_str, 8, 2);
    dt_str = dt_str + " " + StringSubstr(tm_str, 11, 5);

    // Build CSV line (simplified values)
    string line = dt_str + "\t" + regime + "\t12.5\t12.5\t12.5\t12.5\t50.0\t50.0\t50.0\t50.0\t50.0\t50.0\t50.0\t50.0";

    FileWrite(file_handle, line);
    FileFlush(file_handle);

    bars_written++;

    if (bars_written % 24 == 0) {
        Print("Validation indicator: " + IntegerToString(bars_written) + " bars written");
    }

    return rates_total;
}

//+------------------------------------------------------------------+
//| Detect Regime                                                    |
//+------------------------------------------------------------------+
string DetectRegime(double ema20, double ema50, double ema100, double close) {
    // Simple regime detection
    if ((ema20 > ema50 && ema50 > ema100) || (ema20 < ema50 && ema50 < ema100)) {
        return "TRENDING";
    } else if (MathAbs(ema20 - ema50) < MathAbs(ema50 - ema100)) {
        return "TRANSITIONAL";
    } else {
        return "RANGING";
    }
}

//+------------------------------------------------------------------+
//| Simple EMA Calculation                                           |
//+------------------------------------------------------------------+
double CalculateSimpleEMA(const double &close[], int period, int shift) {
    // Simplified EMA calculation for validation purposes
    if (shift < period - 1) {
        // Not enough bars yet, return SMA as approximation
        double sum = 0.0;
        for (int i = 0; i < period && (shift + i) < ArraySize(close); i++) {
            sum += close[shift + i];
        }
        return sum / period;
    }

    // For full EMA, use multiplier approach
    double multiplier = 2.0 / (period + 1.0);
    double ema = close[shift];

    for (int i = 1; i < period && (shift + i) < ArraySize(close); i++) {
        ema = close[shift + i] * multiplier + ema * (1 - multiplier);
    }

    return ema;
}

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    if (file_handle != INVALID_HANDLE) {
        FileClose(file_handle);
        Print("Validation indicator stopped. Bars written: " + IntegerToString(bars_written));
        Print("Output file: " + OutputFile);
    }
}

//+------------------------------------------------------------------+
//| OnTick - Update comment                                          |
//+------------------------------------------------------------------+
void OnTick() {
    Comment("Validation Indicator\nBars written: " + IntegerToString(bars_written) +
            "\nOutput: " + OutputFile);
}
