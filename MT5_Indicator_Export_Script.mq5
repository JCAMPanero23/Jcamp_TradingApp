//+------------------------------------------------------------------+
//|                                    MT5_Indicator_Export_Script.mq5 |
//|                                          Python Validation Export |
//|                                                                    |
//| PURPOSE: Export MT5 indicator values for Python validation        |
//| USAGE: Run this script in MT5 Strategy Tester                     |
//| OUTPUT: Indicator values printed to Experts log (copy to CSV)     |
//+------------------------------------------------------------------+
#property copyright "Jcamp Forex Trading System"
#property version   "1.00"
#property strict
#property script_show_inputs

// Script inputs
input ENUM_TIMEFRAMES ExportTimeframe = PERIOD_H1; // Timeframe
input datetime StartDate = D'2024.12.01';       // Start date
input datetime EndDate = D'2024.12.07';         // End date
input int MaxBars = 200;                        // Maximum bars to export

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   // Use the current chart's symbol (handles broker suffixes like .sml)
   string ExportSymbol = _Symbol;

   Print("======================================================================");
   Print("PYTHON VALIDATION - Exporting MT5 Indicator Values");
   Print("Symbol: ", ExportSymbol);
   Print("Timeframe: ", EnumToString(ExportTimeframe));
   Print("Date Range: ", TimeToString(StartDate, TIME_DATE), " to ", TimeToString(EndDate, TIME_DATE));
   Print("======================================================================");

   // Get indicator handles
   int atr_handle = iATR(ExportSymbol, ExportTimeframe, 14);
   int ema20_handle = iMA(ExportSymbol, ExportTimeframe, 20, 0, MODE_EMA, PRICE_CLOSE);
   int ema50_handle = iMA(ExportSymbol, ExportTimeframe, 50, 0, MODE_EMA, PRICE_CLOSE);
   int ema100_handle = iMA(ExportSymbol, ExportTimeframe, 100, 0, MODE_EMA, PRICE_CLOSE);
   int adx_handle = iADX(ExportSymbol, ExportTimeframe, 14);
   int rsi_handle = iRSI(ExportSymbol, ExportTimeframe, 14, PRICE_CLOSE);

   // Check handles
   if(atr_handle == INVALID_HANDLE || ema20_handle == INVALID_HANDLE ||
      ema50_handle == INVALID_HANDLE || ema100_handle == INVALID_HANDLE ||
      adx_handle == INVALID_HANDLE || rsi_handle == INVALID_HANDLE)
   {
      Print("ERROR: Failed to create indicator handles");
      return;
   }

   // Wait for indicators to calculate
   Sleep(100);

   // Find start bar
   int start_bar = iBarShift(ExportSymbol, ExportTimeframe, StartDate);
   int end_bar = iBarShift(ExportSymbol, ExportTimeframe, EndDate);

   if(start_bar < 0 || end_bar < 0)
   {
      Print("ERROR: Could not find bars for date range");
      Print("Start bar: ", start_bar, ", End bar: ", end_bar);
      return;
   }

   // Limit number of bars
   int bars_to_export = MathMin(start_bar - end_bar + 1, MaxBars);

   Print("\nExporting ", bars_to_export, " bars...");
   Print("\nCSV FORMAT (copy lines below):");
   Print("Timestamp,Close,ATR,EMA20,EMA50,EMA100,ADX,+DI,-DI,RSI");

   // Prepare arrays
   double atr_buffer[];
   double ema20_buffer[];
   double ema50_buffer[];
   double ema100_buffer[];
   double adx_buffer[];
   double plus_di_buffer[];
   double minus_di_buffer[];
   double rsi_buffer[];
   MqlRates rates[];

   ArraySetAsSeries(atr_buffer, true);
   ArraySetAsSeries(ema20_buffer, true);
   ArraySetAsSeries(ema50_buffer, true);
   ArraySetAsSeries(ema100_buffer, true);
   ArraySetAsSeries(adx_buffer, true);
   ArraySetAsSeries(plus_di_buffer, true);
   ArraySetAsSeries(minus_di_buffer, true);
   ArraySetAsSeries(rsi_buffer, true);
   ArraySetAsSeries(rates, true);

   // Copy all data at once
   CopyBuffer(atr_handle, 0, 0, bars_to_export, atr_buffer);
   CopyBuffer(ema20_handle, 0, 0, bars_to_export, ema20_buffer);
   CopyBuffer(ema50_handle, 0, 0, bars_to_export, ema50_buffer);
   CopyBuffer(ema100_handle, 0, 0, bars_to_export, ema100_buffer);
   CopyBuffer(adx_handle, 0, 0, bars_to_export, adx_buffer);           // ADX main line
   CopyBuffer(adx_handle, 1, 0, bars_to_export, plus_di_buffer);       // +DI line
   CopyBuffer(adx_handle, 2, 0, bars_to_export, minus_di_buffer);      // -DI line
   CopyBuffer(rsi_handle, 0, 0, bars_to_export, rsi_buffer);
   CopyRates(ExportSymbol, ExportTimeframe, 0, bars_to_export, rates);

   // Print data (most recent first)
   for(int i = 0; i < bars_to_export; i++)
   {
      datetime bar_time = rates[i].time;
      double close = rates[i].close;

      string timestamp = TimeToString(bar_time, TIME_DATE|TIME_MINUTES);

      // Print CSV line
      PrintFormat("%s,%.5f,%.5f,%.5f,%.5f,%.5f,%.2f,%.2f,%.2f,%.2f",
                  timestamp,
                  close,
                  atr_buffer[i],
                  ema20_buffer[i],
                  ema50_buffer[i],
                  ema100_buffer[i],
                  adx_buffer[i],
                  plus_di_buffer[i],
                  minus_di_buffer[i],
                  rsi_buffer[i]);
   }

   Print("\n======================================================================");
   Print("Export complete! ", bars_to_export, " bars exported.");
   Print("NEXT STEPS:");
   Print("1. Copy the CSV lines above (from 'Timestamp,Close...' onwards)");
   Print("2. Paste into: tests/fixtures/mt5_reference_data.csv");
   Print("3. Run: python tests/test_indicator_accuracy.py");
   Print("======================================================================");

   // Release handles
   IndicatorRelease(atr_handle);
   IndicatorRelease(ema20_handle);
   IndicatorRelease(ema50_handle);
   IndicatorRelease(ema100_handle);
   IndicatorRelease(adx_handle);
   IndicatorRelease(rsi_handle);
}
//+------------------------------------------------------------------+
