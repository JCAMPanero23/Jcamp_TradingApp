# Phase 8.6 - UI Bug Fixes Implementation Guide
**Date:** January 14, 2026
**Status:** Ready for Implementation

---

## Overview

This document provides detailed implementation steps for the 3 UI bugs identified during Phase 8.5 testing:

1. **BUG #6:** UI Text Contrast Issues (calendars, window tabs)
2. **BUG #7:** Dynamic Pair Tabs (remove hardcoded USDJPY, show only selected pairs)
3. **BUG #8:** Display Broker Suffix (.sml) in pair names

---

## BUG #6: UI Text Contrast Issues 🎨

### Problem
- Calendar date picker text is hard to read on dark backgrounds
- Window tab text may have insufficient contrast
- Affects usability in dark theme

### Solution
Apply proper foreground/background styles to ensure WCAG AA contrast ratio (4.5:1 minimum)

### Implementation

**File:** `CSMMonitor/JcampForexTrader/BacktestWindow.xaml`

The calendar styles already exist (lines 11-56) but may need enhancement:

```xml
<!-- Enhanced DatePicker Style for Dark Theme -->
<Style TargetType="DatePicker">
    <Setter Property="Foreground" Value="White"/>
    <Setter Property="Background" Value="#2D2D30"/>
    <Setter Property="BorderBrush" Value="#3E3E42"/>
    <Setter Property="CalendarStyle">
        <Setter.Value>
            <Style TargetType="Calendar">
                <Setter Property="Foreground" Value="White"/>
                <Setter Property="Background" Value="#2D2D30"/>
                <Setter Property="BorderBrush" Value="#3E3E42"/>
            </Style>
        </Setter.Value>
    </Setter>
</Style>

<!-- Calendar Day Button Style - FIXED CONTRAST -->
<Style TargetType="{x:Type CalendarDayButton}">
    <Setter Property="Background" Value="#2D2D30"/>
    <Setter Property="Foreground" Value="#FFFFFF"/>  <!-- White text -->
    <Setter Property="BorderBrush" Value="#3E3E42"/>
    <Setter Property="FontSize" Value="12"/>
    <Setter Property="FontWeight" Value="Normal"/>

    <Style.Triggers>
        <!-- Hover state -->
        <Trigger Property="IsMouseOver" Value="True">
            <Setter Property="Background" Value="#3E3E42"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
        </Trigger>

        <!-- Selected state -->
        <Trigger Property="IsSelected" Value="True">
            <Setter Property="Background" Value="#007ACC"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontWeight" Value="Bold"/>
        </Trigger>

        <!-- Today's date -->
        <Trigger Property="IsToday" Value="True">
            <Setter Property="Background" Value="#3E3E42"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#007ACC"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Trigger>

        <!-- Inactive dates (other months) -->
        <Trigger Property="IsInactive" Value="True">
            <Setter Property="Foreground" Value="#808080"/>  <!-- Gray but still readable -->
        </Trigger>

        <!-- Disabled dates -->
        <Trigger Property="IsEnabled" Value="False">
            <Setter Property="Foreground" Value="#555555"/>
        </Trigger>
    </Style.Triggers>
</Style>

<!-- Calendar Month/Year Button Style - FIXED CONTRAST -->
<Style TargetType="{x:Type CalendarButton}">
    <Setter Property="Background" Value="#2D2D30"/>
    <Setter Property="Foreground" Value="#FFFFFF"/>  <!-- White text -->
    <Setter Property="BorderBrush" Value="#3E3E42"/>
    <Setter Property="FontSize" Value="12"/>

    <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True">
            <Setter Property="Background" Value="#3E3E42"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
        </Trigger>

        <Trigger Property="IsSelected" Value="True">
            <Setter Property="Background" Value="#007ACC"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="FontWeight" Value="Bold"/>
        </Trigger>
    </Style.Triggers>
</Style>
```

**File:** `CSMMonitor/JcampForexTrader/ChartViewerWindow.xaml`

Check all TabControl instances and ensure contrast:

```xml
<!-- Example: Fix all TabItem headers -->
<TabControl Background="#1E1E1E" BorderThickness="0">
    <TabItem Header="Active Trades"
             Background="#2D2D30"
             Foreground="#FFFFFF"  <!-- Ensure White text -->
             FontSize="13">
        <!-- Content -->
    </TabItem>

    <TabItem Header="Indicators"
             Background="#2D2D30"
             Foreground="#FFFFFF"
             FontSize="13">
        <!-- Content -->
    </TabItem>
</TabControl>
```

**Testing Checklist:**
- [ ] Open BacktestWindow DatePicker dropdown
- [ ] Verify all dates are clearly readable (white text on dark background)
- [ ] Check hover states (should highlight)
- [ ] Check selected date (should be bold with blue background)
- [ ] Verify inactive dates (other months) are dimmed but readable
- [ ] Check all TabControl tabs in ChartViewerWindow
- [ ] Verify tab headers are white on dark gray background

**Estimated Effort:** 1-2 hours

---

## BUG #7: Dynamic Pair Tabs (Remove Hardcoded USDJPY) 🔧

### Problem
**File:** `CSMMonitor/JcampForexTrader/ChartViewerWindow.xaml` (lines 304-315)

Pair tabs are hardcoded in XAML:
```xml
<TabControl x:Name="PairTabControl" ...>
    <TabItem Header="EURUSD" ... />
    <TabItem Header="GBPUSD" ... />
    <TabItem Header="USDJPY" ... />  <!-- ← Shows even if not selected! -->
</TabControl>
```

**Current behavior:**
- User selects EURUSD + GBPUSD only
- ChartViewer shows 3 tabs: EURUSD, GBPUSD, USDJPY
- USDJPY tab has no data (shouldn't exist)

### Solution
Generate tabs dynamically based on `_pairData` dictionary

### Implementation

**Step 1: Remove hardcoded tabs from XAML**

**File:** `CSMMonitor/JcampForexTrader/ChartViewerWindow.xaml` (lines 304-315)

**BEFORE:**
```xml
<TabControl x:Name="PairTabControl" Grid.Row="2" Background="#1E1E1E" BorderThickness="0" Padding="5,0"
           SelectionChanged="PairTabControl_SelectionChanged">
    <TabItem Header="EURUSD" Background="#2D2D30" Foreground="White" IsSelected="True" FontSize="12">
    </TabItem>
    <TabItem Header="GBPUSD" Background="#2D2D30" Foreground="#888888" FontSize="12">
    </TabItem>
    <TabItem Header="USDJPY" Background="#2D2D30" Foreground="#888888" FontSize="12">
    </TabItem>
</TabControl>
```

**AFTER:**
```xml
<!-- Dynamic Pair Tabs (generated in code-behind) -->
<TabControl x:Name="PairTabControl" Grid.Row="2"
            Background="#1E1E1E"
            BorderThickness="0"
            Padding="5,0"
            SelectionChanged="PairTabControl_SelectionChanged">
    <!-- Tabs will be added dynamically via GeneratePairTabs() -->
</TabControl>
```

**Step 2: Implement GeneratePairTabs() method**

**File:** `CSMMonitor/JcampForexTrader/ChartViewerWindow.xaml.cs` (line 217)

**BEFORE:**
```csharp
private void GeneratePairTabs(List<string> pairs)
{
    // TODO: Dynamically create tabs in PairTabControl (XAML bottom panel)
    // For now, this is a placeholder - actual tab generation will be done in XAML binding
    System.Diagnostics.Debug.WriteLine($"Multi-pair mode: {pairs.Count} pairs loaded - {string.Join(", ", pairs)}");
}
```

**AFTER:**
```csharp
private void GeneratePairTabs(List<string> pairs)
{
    System.Diagnostics.Debug.WriteLine($"[PAIR TABS] Generating tabs for {pairs.Count} pairs: {string.Join(", ", pairs)}");

    // Clear any existing tabs
    PairTabControl.Items.Clear();

    bool isFirstTab = true;

    foreach (string pair in pairs)
    {
        // Create new TabItem
        var tabItem = new System.Windows.Controls.TabItem
        {
            Header = pair,  // Display pair name (EURUSD, GBPUSD, etc.)
            Background = new System.Windows.Media.SolidColorBrush(
                (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#2D2D30")),
            Foreground = new System.Windows.Media.SolidColorBrush(
                isFirstTab
                    ? System.Windows.Media.Colors.White
                    : (System.Windows.Media.Color)System.Windows.Media.ColorConverter.ConvertFromString("#888888")),
            FontSize = 12,
            IsSelected = isFirstTab,  // First tab selected by default
            Tag = pair  // Store pair name in Tag for easy access
        };

        // Add tab to control
        PairTabControl.Items.Add(tabItem);

        System.Diagnostics.Debug.WriteLine($"[PAIR TABS] Created tab for {pair} (Selected: {isFirstTab})");

        isFirstTab = false;
    }

    System.Diagnostics.Debug.WriteLine($"[PAIR TABS] Total tabs created: {PairTabControl.Items.Count}");
}
```

**Step 3: Update PairTabControl_SelectionChanged handler**

**File:** `CSMMonitor/JcampForexTrader/ChartViewerWindow.xaml.cs` (line 470)

**BEFORE:**
```csharp
private void PairTabControl_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
{
    if (PairTabControl.SelectedItem is System.Windows.Controls.TabItem selectedTab)
    {
        string pairName = selectedTab.Header.ToString();
        System.Diagnostics.Debug.WriteLine($"[PAIR TAB] User selected: {pairName}");
        SwitchToPairTab(pairName);
    }
}
```

**AFTER:**
```csharp
private void PairTabControl_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
{
    if (PairTabControl.SelectedItem is System.Windows.Controls.TabItem selectedTab)
    {
        // Get pair name from Tab's Tag (more reliable) or Header
        string pairName = selectedTab.Tag?.ToString() ?? selectedTab.Header.ToString();

        System.Diagnostics.Debug.WriteLine($"[PAIR TAB] User selected: {pairName}");

        // Verify pair exists in loaded data
        if (!_pairData.ContainsKey(pairName))
        {
            System.Diagnostics.Debug.WriteLine($"[PAIR TAB ERROR] Pair '{pairName}' not found in loaded data!");
            return;
        }

        SwitchToPairTab(pairName);
    }
}
```

**Testing Checklist:**
- [ ] Select only EURUSD in BacktestWindow → Verify 1 tab created
- [ ] Select EURUSD + GBPUSD → Verify 2 tabs created
- [ ] Select EURUSD + GBPUSD + USDJPY → Verify 3 tabs created
- [ ] Verify first tab is selected by default (white text)
- [ ] Verify other tabs are dimmed (gray text)
- [ ] Click tabs to switch pairs → Verify SwitchToPairTab() called correctly
- [ ] Verify no USDJPY tab when not selected

**Estimated Effort:** 2-3 hours

---

## BUG #8: Display Broker Suffix (.sml) in Pair Names 🏷️

### Problem
- Python backend uses `EURUSD_sml` folder paths (broker suffix)
- C# displays `EURUSD` (no suffix)
- User wants to see full pair name with suffix for clarity

### Solution
Display broker suffix in UI while maintaining internal logic

### Implementation Strategy

**Option A: Add suffix in C# display logic (Recommended)**
- Keep API responses clean (EURUSD, GBPUSD)
- Add suffix only in UI display layer
- Easier to change suffix per broker

**Option B: Include suffix in API responses**
- Python API returns "EURUSD_sml"
- More work to change across multiple files
- May break existing logic

**Recommendation:** Option A

### Implementation (Option A)

**Step 1: Create display name helper method**

**File:** `CSMMonitor/JcampForexTrader/ChartViewerWindow.xaml.cs`

Add new helper method:

```csharp
/// <summary>
/// Get display name for pair (adds broker suffix)
/// </summary>
private string GetPairDisplayName(string pair)
{
    // Configuration: Broker suffix
    const string BROKER_SUFFIX = "_sml";

    // Add suffix for display only
    return pair + BROKER_SUFFIX;
}
```

**Step 2: Update GeneratePairTabs() to show suffix**

**File:** `CSMMonitor/JcampForexTrader/ChartViewerWindow.xaml.cs` (GeneratePairTabs method)

**BEFORE:**
```csharp
var tabItem = new System.Windows.Controls.TabItem
{
    Header = pair,  // EURUSD
    Tag = pair      // EURUSD (internal identifier)
};
```

**AFTER:**
```csharp
var tabItem = new System.Windows.Controls.TabItem
{
    Header = GetPairDisplayName(pair),  // EURUSD_sml (for display)
    Tag = pair  // EURUSD (internal identifier - no suffix)
};
```

**Step 3: Update header/title displays**

**File:** `CSMMonitor/JcampForexTrader/ChartViewerWindow.xaml.cs`

Find all places where pair names are displayed:

**A. Chart Title (UpdateSymbolInfo method):**
```csharp
private void UpdateSymbolInfo()
{
    // Display pair name with suffix
    Title = $"Chart Viewer - {GetPairDisplayName(_currentPair)}";

    // Update pair label if it exists
    if (PairNameTextBlock != null)
    {
        PairNameTextBlock.Text = GetPairDisplayName(_currentPair);
    }
}
```

**B. BacktestWindow Summary Tab:**

**File:** `CSMMonitor/JcampForexTrader/BacktestWindow.xaml.cs`

Find where pair names are displayed in summary:

```csharp
// In DisplayMultiPairResults() or similar method
foreach (var kvp in pairBreakdown)
{
    string pair = kvp.Key;
    var stats = kvp.Value;

    // Display with suffix
    string displayName = pair + "_sml";

    // Add to UI (example)
    var row = new TextBlock { Text = $"{displayName}: {stats.Trades} trades" };
}
```

**C. Trade List Display:**

If trades show pair names, add suffix there too:

```csharp
// In PopulateTradesList() or similar
foreach (var trade in trades)
{
    string displayPair = trade.Symbol + "_sml";

    // Add to DataGrid or ListBox
    var item = new TradeListItem
    {
        Pair = displayPair,  // Show EURUSD_sml
        EntryTime = trade.EntryTime,
        // ...
    };
}
```

**Step 4: Configuration Management (Optional Enhancement)**

For flexibility, store broker suffix in settings:

**File:** `CSMMonitor/JcampForexTrader/App.config` or settings class

```xml
<appSettings>
    <add key="BrokerSuffix" value="_sml"/>
</appSettings>
```

Then read in code:

```csharp
private static string GetBrokerSuffix()
{
    return System.Configuration.ConfigurationManager.AppSettings["BrokerSuffix"] ?? "";
}

private string GetPairDisplayName(string pair)
{
    return pair + GetBrokerSuffix();
}
```

**Testing Checklist:**
- [ ] Launch multi-pair backtest (EURUSD + GBPUSD)
- [ ] Verify tabs show: "EURUSD_sml", "GBPUSD_sml"
- [ ] Verify window title shows: "Chart Viewer - EURUSD_sml"
- [ ] Verify pair header shows suffix
- [ ] Verify summary statistics show suffix
- [ ] Verify trade list shows suffix (if applicable)
- [ ] Click tabs → Verify switching still works (uses Tag without suffix)
- [ ] Verify API calls still use "EURUSD" (no suffix in requests)

**Estimated Effort:** 2-3 hours

---

## Summary

### Total Implementation Time
- **BUG #6** (UI Contrast): 1-2 hours
- **BUG #7** (Dynamic Tabs): 2-3 hours
- **BUG #8** (Broker Suffix): 2-3 hours
- **Total:** 5-8 hours

### Files to Modify

**XAML Files:**
1. `CSMMonitor/JcampForexTrader/BacktestWindow.xaml` (calendar styles)
2. `CSMMonitor/JcampForexTrader/ChartViewerWindow.xaml` (remove hardcoded tabs, tab contrast)

**C# Files:**
3. `CSMMonitor/JcampForexTrader/ChartViewerWindow.xaml.cs` (GeneratePairTabs, GetPairDisplayName, UpdateSymbolInfo)
4. `CSMMonitor/JcampForexTrader/BacktestWindow.xaml.cs` (display suffix in summary)

### Implementation Order (Recommended)

**Session 1 (2-3 hours): Dynamic Tabs**
1. Remove hardcoded tabs from XAML
2. Implement GeneratePairTabs()
3. Update PairTabControl_SelectionChanged
4. Test with various pair combinations

**Session 2 (2-3 hours): Broker Suffix**
1. Add GetPairDisplayName() helper
2. Update GeneratePairTabs() to use suffix
3. Update UpdateSymbolInfo() for title/header
4. Update trade displays (if needed)
5. Test tab switching still works

**Session 3 (1-2 hours): UI Contrast**
1. Enhance calendar styles in BacktestWindow.xaml
2. Check all TabControl foreground colors
3. Test date picker readability
4. Test tab header readability

---

## Validation Test Plan

After implementing all 3 fixes, run this complete test:

### Test Case 1: Two-Pair Backtest
**Config:** EURUSD + GBPUSD, Jan 2-10, 2024, Both Strategies

**Expected Results:**
- [ ] BacktestWindow date picker: All dates clearly readable (white text)
- [ ] BacktestWindow tabs: White text on dark background
- [ ] ChartViewer launches with 2 tabs: "EURUSD_sml", "GBPUSD_sml"
- [ ] First tab (EURUSD_sml) selected by default (white text)
- [ ] Second tab (GBPUSD_sml) dimmed (gray text)
- [ ] Window title shows: "Chart Viewer - EURUSD_sml"
- [ ] Click GBPUSD_sml tab → switches pairs, title updates
- [ ] No USDJPY tab visible
- [ ] All tab text clearly readable (white on dark gray)

### Test Case 2: Three-Pair Backtest
**Config:** EURUSD + GBPUSD + USDJPY, Jan 2-5, 2024

**Expected Results:**
- [ ] 3 tabs created: EURUSD_sml, GBPUSD_sml, USDJPY_sml
- [ ] All tabs show broker suffix
- [ ] Tab switching works for all 3 pairs
- [ ] Each pair shows correct chart data

### Test Case 3: Single-Pair Backtest
**Config:** GBPUSD only, Jan 2-31, 2024

**Expected Results:**
- [ ] Only 1 tab created: "GBPUSD_sml"
- [ ] Tab is selected by default
- [ ] Window title: "Chart Viewer - GBPUSD_sml"
- [ ] No extra tabs visible

---

## Commit Message Template

```
fix(ui): Dynamic pair tabs + broker suffix display + contrast improvements

FIXES:
- BUG #6: Enhanced calendar and tab contrast for dark theme
- BUG #7: Dynamically generate pair tabs based on selection (no hardcoded USDJPY)
- BUG #8: Display broker suffix (_sml) in pair names for clarity

CHANGES:
- ChartViewerWindow.xaml: Removed hardcoded pair tabs
- ChartViewerWindow.xaml.cs: Implemented GeneratePairTabs() to create tabs dynamically
- ChartViewerWindow.xaml.cs: Added GetPairDisplayName() to append broker suffix
- BacktestWindow.xaml: Enhanced calendar styles for better text contrast
- BacktestWindow.xaml: Improved TabControl foreground colors

TESTING:
- Tested 1-pair, 2-pair, 3-pair backtests
- Verified tabs match selected pairs exactly
- Verified broker suffix displayed in all UI elements
- Verified calendar dates clearly readable
- Verified tab switching works correctly

Resolves: Phase 8.6 UI bugs #6, #7, #8
```

---

*Document Complete: January 14, 2026*
