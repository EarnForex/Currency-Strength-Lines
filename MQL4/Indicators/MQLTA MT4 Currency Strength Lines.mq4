#property link          "https://www.earnforex.com/metatrader-indicators/currency-strength-lines/"
#property version       "1.18"
#property strict
#property copyright     "EarnForex.com - 2019-2023"
#property description   "This indicator analyses the strength of a currency and its trend"
#property description   "comparing different values across multiple pairs."
#property description   " "
#property description   "WARNING : You use this software at your own risk."
#property description   "The creator of these plugins cannot be held responsible for damage or loss."
#property description   " "
#property description   "Find More on EarnForex.com"
#property icon          "\\Files\\EF-Icon-64x64px.ico"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrBlue
#property indicator_color2  clrRed
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrMagenta
#property indicator_color5  clrLightSalmon
#property indicator_color6  clrPurple
#property indicator_color7  clrDarkGreen
#property indicator_color8  clrSpringGreen
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1

enum Enum_CalculationMode
{
    Mode_RSITot = 2,                    //RSI TOT
    Mode_RSITotMA = 3,                  //RSI TOT MA
    Mode_ROC = 4,                       //ROC TOT
    Mode_ROCMA = 5,                     //ROC TOT MA
};

enum ENUM_ZONETYPE
{
    ZONE_BUY = 1,                       //BUY ZONE
    ZONE_SELL = 2,                      //SELL ZONE
    ZONE_NEUTRAL = 3,                   //NEUTRAL ZONE
};

enum ENUM_CORNER
{
    TopLeft = CORNER_LEFT_UPPER,        //TOP LEFT
    TopRight = CORNER_RIGHT_UPPER,      //TOP RIGHT
    BottomLeft = CORNER_LEFT_LOWER,     //BOTTOM LEFT
    BottomRight = CORNER_RIGHT_LOWER,   //BOTTOM RIGHT
};

enum enum_candle_to_check
{
    Current,
    Previous
};

input string comment_0 = "==========";    // CSI Indicator
input string IndicatorName = "MQLTA-CSL"; // Indicator's Name

input string comment_2 = "=========="; // Calculation Options
input Enum_CalculationMode CalculationMode = Mode_RSITot; // Calculation Mode
input int ROCPeriod = 5;               // ROC Period (if using ROC Mode)
input int RSIPeriod = 14;              // ASI Period
input int SmoothingPeriod = 5;         // Smoothing (if using TOT MA)
input ENUM_TIMEFRAMES LinesTimeFrame = PERIOD_CURRENT; // Strength Lines Time Frame

input string comment_3 = "=========="; // Signals Options
input bool DrawAllCurrencies = false;  // Draw All Currency Strength
input bool ShowSignals = true;         // Show Arrow Signals
input bool AboveBelow = true;          // Draw when a currency is above the other
input bool OppositeZeros = false;      // Draw if lines are opposite to the zero

input color BuyColor = clrGreen;       // Buy signal color
input color SellColor = clrRed;        // Sell signal color
input color NeutralColor = clrDimGray; // Neutral signal color

input string comment_5 = "====================";         //Notification Options
input bool EnableNotify = false;       // Enable Notifications feature
input bool SendAlert = true;           // Send Alert Notification
input bool SendApp = false;            // Send Notification to Mobile
input bool SendEmail = false;          // Send Notification via Email
input enum_candle_to_check TriggerCandle = Previous;

input string comment_9 = "=========="; // Indicator Visibility
bool LimitBars = true;                 // Limit the number of bars to calculate
input int MaxBars = 1000;              // Number of bars to calculate
input int MinimumRefreshInterval = 5;  // Minimum Refresh Interval (Seconds)

input string comment_7 = "=========="; // Pairs Prefix and Suffix
input string CurrencyPrefix = "";      // Pairs Prefix
input string CurrencySuffix = "";      // Pairs Suffix

input string comment_1 = "=========="; // Currencies to Analyse
input bool UseEUR = true;              // EUR
input bool UseUSD = true;              // USD
input bool UseGBP = true;              // GBP
input bool UseJPY = true;              // JPY
input bool UseAUD = true;              // AUD
input bool UseNZD = true;              // NZD
input bool UseCAD = true;              // CAD
input bool UseCHF = true;              // CHF

input string comment_1b = "==========";   // Currencies Colors and Width
input ENUM_CORNER Corner = TopLeft;       // Corner to show the labels
input int XOffset = 0;                    // Horizontal offset (pixels)
input int YOffset = 0;                    // Vertical offset (pixels)
input color LabelColor = clrBlack;        // Label Color
input color EURColor = clrBlue;           // EUR
input color USDColor = clrRed;            // USD
input color GBPColor = clrDeepSkyBlue;    // GBP
input color JPYColor = clrMagenta;        // JPY
input color AUDColor = clrLightSalmon;    // AUD
input color NZDColor = clrPurple;         // NZD
input color CADColor = clrDarkGreen;      // CAD
input color CHFColor = clrMediumSeaGreen; // CHF
input int NormalWidth = 1;                // Width for Currencies not on chart
input int SelectedWidth = 3;              // Width for Currencies on chart
input bool DrawPanel = true;              // Draw Panel

string Font = "Consolas";

//--- indicator buffers
double EUR[];
double GBP[];
double USD[];
double JPY[];
double AUD[];
double NZD[];
double CAD[];
double CHF[];

double PreChecks = false;

string AllPairs[] =
{
    "AUDCAD",
    "AUDCHF",
    "AUDJPY",
    "AUDNZD",
    "AUDUSD",
    "CADCHF",
    "CADJPY",
    "CHFJPY",
    "EURAUD",
    "EURCAD",
    "EURCHF",
    "EURGBP",
    "EURJPY",
    "EURNZD",
    "EURUSD",
    "GBPAUD",
    "GBPCAD",
    "GBPCHF",
    "GBPJPY",
    "GBPNZD",
    "GBPUSD",
    "NZDCAD",
    "NZDCHF",
    "NZDJPY",
    "NZDUSD",
    "USDCAD",
    "USDCHF",
    "USDJPY"
};

// List all the currencies.
string AllCurrencies[] =
{
    "EUR",
    "USD",
    "GBP",
    "JPY",
    "AUD",
    "NZD",
    "CAD",
    "CHF"
};

string CurrBase;
string CurrQuote;
string CurrPrefix;
string CurrSuffix;
double Base[];
double Quote[];
int CurrenciesUsed = 8;
ENUM_TIMEFRAMES LinesTF = LinesTimeFrame;

const int PAIRS_COUNT = 28;

bool HistoricalOK = true;
bool MissingHistoricalNotified = false;
string MissingHistoricalPair = "";
int MissingHistoricalPeriod = 0;

string LastAlertDirection = ""; // Signal that was alerted on previous alert.
datetime LastNotification = 0;
bool FirstRun = true; // For alerts only.

int LabelX, LabelY, InnerPaddingX, InnerPaddingY, InnerPaddingModelX, InnerPaddingModelY, MissingHistoricalLabelX, MissingHistoricalLabelY;
double DPIScale; // Scaling parameter for the panel based on the screen DPI.

int GlobalPrevCalculated = 0; // For OnTimer().

int OnInit()
{
    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);

    if ((LinesTF == PERIOD_CURRENT) || ((LinesTF != PERIOD_CURRENT) && (LinesTF < Period()))) LinesTF = (ENUM_TIMEFRAMES)Period();
    else LinesTF = LinesTimeFrame;

    CurrPrefix = CurrencyPrefix;
    CurrSuffix = CurrencySuffix;

    SetAllPairs();
    if (!CheckAllPairs()) return INIT_FAILED;

    IndicatorDigits(4);
    CleanChart();
    DetectCurrencies();

    IndicatorShortName(IndicatorName);

    IndicatorSetInteger(INDICATOR_LEVELS, 1);
    IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 0);
    IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_DOT);
    IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrGray);

    int Width = NormalWidth;
    int DrawStyle = DRAW_LINE;
    if (StringFind(Symbol(), "EUR", 0) >= 0)
    {
        Width = SelectedWidth;
    }
    else
    {
        Width = NormalWidth;
    }
    if ((StringFind(Symbol(), "EUR", 0) >= 0) || (DrawAllCurrencies))
    {
        DrawStyle = DRAW_LINE;
    }
    else
    {
        DrawStyle = DRAW_NONE;
    }
    SetIndexStyle(0, DrawStyle, STYLE_SOLID, Width, EURColor);
    SetIndexBuffer(0, EUR);
    SetIndexLabel(0, "EUR");

    if (StringFind(Symbol(), "GBP", 0) >= 0)
    {
        Width = SelectedWidth;
    }
    else
    {
        Width = NormalWidth;
    }
    if ((StringFind(Symbol(), "GBP", 0) >= 0) || (DrawAllCurrencies))
    {
        DrawStyle = DRAW_LINE;
    }
    else
    {
        DrawStyle = DRAW_NONE;
    }
    SetIndexStyle(1, DrawStyle, STYLE_SOLID, Width, GBPColor);
    SetIndexBuffer(1, GBP);
    SetIndexLabel(1, "GBP");

    if (StringFind(Symbol(), "USD", 0) >= 0)
    {
        Width = SelectedWidth;
    }
    else
    {
        Width = NormalWidth;
    }
    if ((StringFind(Symbol(), "USD", 0) >= 0) || (DrawAllCurrencies))
    {
        DrawStyle = DRAW_LINE;
    }
    else
    {
        DrawStyle = DRAW_NONE;
    }
    SetIndexStyle(2, DrawStyle, STYLE_SOLID, Width, USDColor);
    SetIndexBuffer(2, USD);
    SetIndexLabel(2, "USD");

    if (StringFind(Symbol(), "JPY", 0) >= 0)
    {
        Width = SelectedWidth;
    }
    else
    {
        Width = NormalWidth;
    }
    if ((StringFind(Symbol(), "JPY", 0) >= 0) || (DrawAllCurrencies))
    {
        DrawStyle = DRAW_LINE;
    }
    else
    {
        DrawStyle = DRAW_NONE;
    }
    SetIndexStyle(3, DrawStyle, STYLE_SOLID, Width, JPYColor);
    SetIndexBuffer(3, JPY);
    SetIndexLabel(3, "JPY");

    if (StringFind(Symbol(), "AUD", 0) >= 0)
    {
        Width = SelectedWidth;
    }
    else
    {
        Width = NormalWidth;
    }
    if ((StringFind(Symbol(), "AUD", 0) >= 0) || (DrawAllCurrencies))
    {
        DrawStyle = DRAW_LINE;
    }
    else
    {
        DrawStyle = DRAW_NONE;
    }
    SetIndexStyle(4, DrawStyle, STYLE_SOLID, Width, AUDColor);
    SetIndexBuffer(4, AUD);
    SetIndexLabel(4, "AUD");

    if (StringFind(Symbol(), "NZD", 0) >= 0)
    {
        Width = SelectedWidth;
    }
    else
    {
        Width = NormalWidth;
    }
    if ((StringFind(Symbol(), "NZD", 0) >= 0) || (DrawAllCurrencies))
    {
        DrawStyle = DRAW_LINE;
    }
    else
    {
        DrawStyle = DRAW_NONE;
    }
    SetIndexStyle(5, DrawStyle, STYLE_SOLID, Width, NZDColor);
    SetIndexBuffer(5, NZD);
    SetIndexLabel(5, "NZD");

    if (StringFind(Symbol(), "CAD", 0) >= 0)
    {
        Width = SelectedWidth;
    }
    else
    {
        Width = NormalWidth;
    }
    if ((StringFind(Symbol(), "CAD", 0) >= 0) || (DrawAllCurrencies))
    {
        DrawStyle = DRAW_LINE;
    }
    else
    {
        DrawStyle = DRAW_NONE;
    }
    SetIndexStyle(6, DrawStyle, STYLE_SOLID, Width, CADColor);
    SetIndexBuffer(6, CAD);
    SetIndexLabel(6, "CAD");

    if (StringFind(Symbol(), "CHF", 0) >= 0)
    {
        Width = SelectedWidth;
    }
    else
    {
        Width = NormalWidth;
    }
    if ((StringFind(Symbol(), "CHF", 0) >= 0) || (DrawAllCurrencies))
    {
        DrawStyle = DRAW_LINE;
    }
    else
    {
        DrawStyle = DRAW_NONE;
    }
    SetIndexStyle(7, DrawStyle, STYLE_SOLID, Width, CHFColor);
    SetIndexBuffer(7, CHF);
    SetIndexLabel(7, "CHF");

    DPIScale = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0;
    LabelX = (int)MathRound(290 * DPIScale);
    LabelY = (int)MathRound(35 * DPIScale);
    InnerPaddingX = (int)MathRound(10 * DPIScale);
    InnerPaddingY = (int)MathRound(20 * DPIScale);
    InnerPaddingModelX = (int)MathRound(15 * DPIScale);
    InnerPaddingModelY = (int)MathRound(40 * DPIScale);
    MissingHistoricalLabelX = (int)MathRound(286 * DPIScale);
    MissingHistoricalLabelY = (int)MathRound(26 * DPIScale);

    HistoricalOK = true;
    EventSetTimer(MinimumRefreshInterval);
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    EventKillTimer();
    CleanChart();
}

void OnTimer()
{
    if (DrawPanel) CreateLabels();

    int limit;

    limit = Bars - GlobalPrevCalculated;
    if (GlobalPrevCalculated > 0)
    {
        if (LinesTF != Period())
        {
            limit = PeriodSeconds(LinesTF) / PeriodSeconds(Period());
        }
        limit += 2;
    }
    HistoricalOK = true;

    if ((LimitBars) && (limit > MaxBars)) limit = MaxBars;
    if (Bars < limit + RSIPeriod) limit = Bars;

    if (HistoricalOK) CalculateBuffers(limit);
    if (!HistoricalOK)
    {
        if (DrawPanel) DrawMissingHistorical();
        return;
    }
    else
    {
        RemoveMissingHistorical();
    }

    if (limit == Bars) limit--; // Avoid array out of range.
    if (ShowSignals) DrawArrows(limit - 1);
}

int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
{
    CreateLabels();

    int limit;

    limit = rates_total - prev_calculated;
    if (prev_calculated > 0)
    {
        if (LinesTF != Period())
        {
            limit = PeriodSeconds(LinesTF) / PeriodSeconds(Period());
        }
        limit += 2;
    }
    HistoricalOK = true;

    if ((LimitBars) && (limit > MaxBars)) limit = MaxBars;
    if (rates_total < limit + RSIPeriod) limit = rates_total;

    CalculateBuffers(limit);
    if (!HistoricalOK)
    {
        DrawMissingHistorical();
        return 0;
    }
    else
    {
        RemoveMissingHistorical();
    }

    if (limit == rates_total) limit--; // Avoid array out of range.
    if (ShowSignals) DrawArrows(limit);

    GlobalPrevCalculated = prev_calculated;
    return rates_total;
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_CLICK)
    {
        if (sparam == MissingHistoricalGoTo)
        {
            GoToMissing(MissingHistoricalPair);
        }
    }
    if (id == CHARTEVENT_CHART_CHANGE)
    {
        if (SignalWidth != (int)ChartGetInteger(0, CHART_SCALE, 0))
        {
            SignalWidth = (int)ChartGetInteger(0, CHART_SCALE, 0);
            if (ShowSignals) DrawArrows(Bars - 1);
        }
    }
}

string CalculationModeDesc()
{
    string Text = "";
    if (CalculationMode == Mode_RSITot) Text = "RSI TOT";
    if (CalculationMode == Mode_RSITotMA) Text = "RSI TOT MA";
    if (CalculationMode == Mode_ROC) Text = "ROC TOT";
    if (CalculationMode == Mode_ROCMA) Text = "ROC TOT MA";
    return Text;
}

bool SetAllPairs()
{
    if ((CurrPrefix == "") && (CurrSuffix == "")) return true;
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        AllPairs[i] = CurrPrefix + AllPairs[i] + CurrSuffix;
    }
    return true;
}

// Checks if all required pairs are in the Market Watch, selecting it in the process. If cannot be found at all, return false to signal a critical error.
bool CheckAllPairs()
{
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (!SymbolSelect(AllPairs[i], true)) // Failed to select a necessary currency pair.
        {
            Alert("Error: " + AllPairs[i] + " not found. Cannot proceed.");
            return false;
        }
    }
    return true;
}

void CalculateBuffers(int limit)
{
    if (limit > ArraySize(EUR)) limit = ArraySize(EUR);
    for(int i = 0; i < limit; i++)
    {
        switch(CalculationMode)
        {
        case 2:
            CalculateRSITot(i);
            break;
        case 3:
            CalculateRSITotMA(i);
            break;
        case 4:
            CalculateROCTot(i);
            break;
        case 5:
            CalculateROCTotMA(i);
            break;
        }
    }
    CopyBaseQuote();
}

void CreateLabels()
{
    int Labels = 0;
    int Window = WindowFind(IndicatorName);
    if (Window == -1) Window = 0;

    string BaseLabel = StringConcatenate(IndicatorName, "-BaseLabel");
    ObjectCreate(ChartID(), BaseLabel, OBJ_RECTANGLE_LABEL, Window, 0, 0);
    ObjectSet(BaseLabel, OBJPROP_XDISTANCE, XOffset + InnerPaddingX);
    ObjectSet(BaseLabel, OBJPROP_YDISTANCE, YOffset + InnerPaddingY);
    ObjectSetInteger(0, BaseLabel, OBJPROP_XSIZE, LabelX);
    ObjectSetInteger(0, BaseLabel, OBJPROP_YSIZE, LabelY);
    ObjectSetInteger(0, BaseLabel, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, BaseLabel, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, BaseLabel, OBJPROP_STATE, false);
    ObjectSetInteger(0, BaseLabel, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, BaseLabel, OBJPROP_FONTSIZE, 8);
    ObjectSet(BaseLabel, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, BaseLabel, OBJPROP_COLOR, clrBlack);

    if (UseEUR)
    {
        CreateLabel("EUR", EURColor, Window, Labels);
        Labels++;
    }
    if (UseUSD)
    {
        CreateLabel("USD", USDColor, Window, Labels);
        Labels++;
    }
    if (UseGBP)
    {
        CreateLabel("GBP", GBPColor, Window, Labels);
        Labels++;
    }
    if (UseJPY)
    {
        CreateLabel("JPY", JPYColor, Window, Labels);
        Labels++;
    }
    if (UseAUD)
    {
        CreateLabel("AUD", AUDColor, Window, Labels);
        Labels++;
    }
    if (UseNZD)
    {
        CreateLabel("NZD", NZDColor, Window, Labels);
        Labels++;
    }
    if (UseCAD)
    {
        CreateLabel("CAD", CADColor, Window, Labels);
        Labels++;
    }
    if (UseCHF)
    {
        CreateLabel("CHF", CHFColor, Window, Labels);
        Labels++;
    }

    string CalcModeLabel = StringConcatenate(IndicatorName, "-CalculationMode");
    ObjectCreate(ChartID(), CalcModeLabel, OBJ_LABEL, Window, 0, 0);
    ObjectSet(CalcModeLabel, OBJPROP_CORNER, Corner);
    ObjectSet(CalcModeLabel, OBJPROP_XDISTANCE, XOffset + InnerPaddingModelX);
    ObjectSet(CalcModeLabel, OBJPROP_YDISTANCE, YOffset + InnerPaddingModelY);
    string PeriodDesc = "";
    switch (LinesTF)
    {
    case PERIOD_M1:
        PeriodDesc = "M1";
        break;
    case PERIOD_M5:
        PeriodDesc = "M5";
        break;
    case PERIOD_M15:
        PeriodDesc = "M15";
        break;
    case PERIOD_M30:
        PeriodDesc = "M30";
        break;
    case PERIOD_H1:
        PeriodDesc = "H1";
        break;
    case PERIOD_H4:
        PeriodDesc = "H4";
        break;
    case PERIOD_D1:
        PeriodDesc = "D1";
        break;
    case PERIOD_W1:
        PeriodDesc = "W1";
        break;
    case PERIOD_MN1:
        PeriodDesc = "MN1";
        break;
    }
    ObjectSetText(CalcModeLabel, "Period : " + PeriodDesc + " - Calculation Mode : " + CalculationModeDesc(), 8, Font, LabelColor);
}

void CreateLabel(string Curr, color Color, int Window, int L)
{
    string LabelName = StringConcatenate(IndicatorName, "-", Curr, "Label");
    int Offset = L * 35;
    ObjectCreate(ChartID(), LabelName, OBJ_LABEL, Window, 0, 0);
    ObjectSet(LabelName, OBJPROP_CORNER, Corner);
    ObjectSet(LabelName, OBJPROP_XDISTANCE, XOffset + (int)MathRound((Offset + 15) * DPIScale));
    ObjectSet(LabelName, OBJPROP_YDISTANCE, YOffset + InnerPaddingY);
    ObjectSetText(LabelName, Curr, 12, Font, Color);
}

string MissingHistoricalBase = IndicatorName + "-MISSHISTORY-BAS";
string MissingHistoricalLabel = IndicatorName + "-MISSHISTORY-LAB";
string MissingHistoricalGoTo = IndicatorName + "-MISSHISTORY-GOTO";
int MissingHistoricalRecX = LabelX;
void DrawMissingHistorical()
{
    RemoveMissingHistorical();
    int Window = WindowFind(IndicatorName);
    if (Window == -1) Window = 0;

    int MissingHistoricalXStart = XOffset + InnerPaddingX;
    int MissingHistoricalYStart = YOffset + LabelY + MissingHistoricalLabelY;

    ObjectCreate(0, MissingHistoricalBase, OBJ_RECTANGLE_LABEL, Window, 0, 0);
    ObjectSet(MissingHistoricalBase, OBJPROP_XDISTANCE, MissingHistoricalXStart);
    ObjectSet(MissingHistoricalBase, OBJPROP_YDISTANCE, MissingHistoricalYStart + 2);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_XSIZE, MissingHistoricalRecX);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_YSIZE, (MissingHistoricalLabelY + 2) * 2 + 1);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_FONTSIZE, 8);
    ObjectSet(MissingHistoricalBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, MissingHistoricalLabel, OBJ_EDIT, Window, 0, 0);
    ObjectSet(MissingHistoricalLabel, OBJPROP_XDISTANCE, MissingHistoricalXStart + 2);
    ObjectSet(MissingHistoricalLabel, OBJPROP_YDISTANCE, MissingHistoricalYStart + 4);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_XSIZE, MissingHistoricalLabelX);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_YSIZE, MissingHistoricalLabelY);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_STATE, false);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_READONLY, true);
    ObjectSetString(0, MissingHistoricalLabel, OBJPROP_TOOLTIP, "PLEASE DOWNLOAD HISTORICAL DATA FOR ALL PAIRS");
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, MissingHistoricalLabel, OBJPROP_TEXT, "HISTORICAL DATA NEEDED");
    ObjectSetString(0, MissingHistoricalLabel, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_FONTSIZE, 10);
    ObjectSet(MissingHistoricalLabel, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_BGCOLOR, clrRed);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, MissingHistoricalGoTo, OBJ_EDIT, Window, 0, 0);
    ObjectSet(MissingHistoricalGoTo, OBJPROP_XDISTANCE, MissingHistoricalXStart + 2);
    ObjectSet(MissingHistoricalGoTo, OBJPROP_YDISTANCE, MissingHistoricalYStart + MissingHistoricalLabelY + (int)MathRound(5 * DPIScale));
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_XSIZE, MissingHistoricalLabelX);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_YSIZE, MissingHistoricalLabelY);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_STATE, false);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_READONLY, true);
    ObjectSetString(0, MissingHistoricalGoTo, OBJPROP_TOOLTIP, "CLICK TO GO TO THE MISSING HISTORICAL DATA");
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, MissingHistoricalGoTo, OBJPROP_TEXT, "GO TO - " + MissingHistoricalPair);
    ObjectSetString(0, MissingHistoricalGoTo, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_FONTSIZE, 10);
    ObjectSet(MissingHistoricalGoTo, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_BGCOLOR, clrGreen);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_BORDER_COLOR, clrBlack);
}

void RemoveMissingHistorical()
{
    ObjectsDeleteAll(ChartID(), IndicatorName + "-MISSHISTORY-");
}

void GoToMissing(string Pair)
{
    ChartSetSymbolPeriod(0, Pair, PERIOD_CURRENT);
    ChartNavigate(0, CHART_END, -(MaxBars + 1));
}

void CleanChart()
{
    ObjectsDeleteAll(ChartID(), IndicatorName);
}

void DetectCurrencies()
{
    string Curr1 = "";
    string Curr2 = "";
    int Curr1Pos = -1, Curr2Pos = -1;
    for (int i = 0; i < ArraySize(AllCurrencies); i++)
    {
        int Curr1PosTmp = StringFind(Symbol(), AllCurrencies[i], 0);
        int Curr2PosTmp = StringFind(Symbol(), AllCurrencies[i], 0);
        if ((Curr1 == "") && (Curr1PosTmp != -1))
        {
            Curr1 = AllCurrencies[i];
            Curr1Pos = Curr1PosTmp;
        }
        if ((Curr1 != "") && (Curr2PosTmp != -1))
        {
            Curr2 = AllCurrencies[i];
            Curr2Pos = Curr2PosTmp;
        }
    }
    if (Curr1Pos < Curr2Pos)
    {
        CurrBase = Curr1;
        CurrQuote = Curr2;
    }
    else
    {
        CurrBase = Curr2;
        CurrQuote = Curr1;
    }
}

void CalculateROCTot(int i)
{
    if (UseEUR) EUR[i] = ROCTot("EUR", i);
    if (UseGBP) GBP[i] = ROCTot("GBP", i);
    if (UseUSD) USD[i] = ROCTot("USD", i);
    if (UseJPY) JPY[i] = ROCTot("JPY", i);
    if (UseAUD) AUD[i] = ROCTot("AUD", i);
    if (UseNZD) NZD[i] = ROCTot("NZD", i);
    if (UseCAD) CAD[i] = ROCTot("CAD", i);
    if (UseCHF) CHF[i] = ROCTot("CHF", i);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateROCTotMA(int i)
{
    if (UseEUR) EUR[i] = ROCTotMA("EUR", i);
    if (UseGBP) GBP[i] = ROCTotMA("GBP", i);
    if (UseUSD) USD[i] = ROCTotMA("USD", i);
    if (UseJPY) JPY[i] = ROCTotMA("JPY", i);
    if (UseAUD) AUD[i] = ROCTotMA("AUD", i);
    if (UseNZD) NZD[i] = ROCTotMA("NZD", i);
    if (UseCAD) CAD[i] = ROCTotMA("CAD", i);
    if (UseCHF) CHF[i] = ROCTotMA("CHF", i);
}

void CalculateRSITot(int i)
{
    if (UseEUR) EUR[i] = RSITot("EUR", i);
    if (UseGBP) GBP[i] = RSITot("GBP", i);
    if (UseUSD) USD[i] = RSITot("USD", i);
    if (UseJPY) JPY[i] = RSITot("JPY", i);
    if (UseAUD) AUD[i] = RSITot("AUD", i);
    if (UseNZD) NZD[i] = RSITot("NZD", i);
    if (UseCAD) CAD[i] = RSITot("CAD", i);
    if (UseCHF) CHF[i] = RSITot("CHF", i);
}

void CalculateRSITotMA(int i)
{
    if (UseEUR) EUR[i] = RSITotMA("EUR", i);
    if (UseGBP) GBP[i] = RSITotMA("GBP", i);
    if (UseUSD) USD[i] = RSITotMA("USD", i);
    if (UseJPY) JPY[i] = RSITotMA("JPY", i);
    if (UseAUD) AUD[i] = RSITotMA("AUD", i);
    if (UseNZD) NZD[i] = RSITotMA("NZD", i);
    if (UseCAD) CAD[i] = RSITotMA("CAD", i);
    if (UseCHF) CHF[i] = RSITotMA("CHF", i);
}

double ROCTot(string Curr, int j)
{
    double Tot = 0;
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (StringFind(AllPairs[i], Curr, 0) < 0) continue;
        int k = j;
        if (LinesTF != Period()) k = iBarShift(AllPairs[i], LinesTF, Time[j], false);
        double EndValue = iClose(AllPairs[i], LinesTF, k);
        double StartValue = iClose(AllPairs[i], LinesTF, k + ROCPeriod);
        double SValue = 0;
        if (StartValue > 0) SValue = (EndValue / StartValue - 1) * 100;
        if ((StartValue == 0) || (EndValue == 0))
        {
            HistoricalOK = false;
            MissingHistoricalPair = AllPairs[i];
            return 0;
        }
        if (StringFind(AllPairs[i], Curr, 0) < 3)
        {
            Tot += SValue;
        }
        else
        {
            Tot -= SValue;
        }
    }
    return Tot;
}

double ROCTotMA(string Curr, int j)
{
    double Tot = 0;
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (StringFind(AllPairs[i], Curr, 0) < 0) continue;
        double SValue = 0;
        for (int h = 0; h < SmoothingPeriod; h++)
        {
            int k = j;
            if (LinesTF != Period()) k = iBarShift(AllPairs[i], LinesTF, Time[j], false);
            double EndValue = iClose(AllPairs[i], LinesTF, k + h);
            double StartValue = iClose(AllPairs[i], LinesTF, k + ROCPeriod + h);
            if (StartValue > 0) SValue += (EndValue / StartValue - 1) * 100;
            if ((StartValue == 0) || (EndValue == 0))
            {
                HistoricalOK = false;
                MissingHistoricalPair = AllPairs[i];
                return 0;
            }
        }
        SValue = SValue / SmoothingPeriod;
        if (StringFind(AllPairs[i], Curr, 0) < 3)
        {
            Tot += SValue;
        }
        else
        {
            Tot -= SValue;
        }
    }
    return Tot;
}

double RSITot(string Curr, int j)
{
    double Tot = 0;
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (StringFind(AllPairs[i], Curr, 0) < 0) continue;
        int k = j;
        if (LinesTF != Period()) k = iBarShift(AllPairs[i], LinesTF, Time[j], false);
        double SValue = iRSI(AllPairs[i], LinesTF, RSIPeriod, PRICE_CLOSE, k);
        if (SValue == 0)
        {
            HistoricalOK = false;
            MissingHistoricalPair = AllPairs[i];
            return 0;
        }
        if (StringFind(AllPairs[i], Curr, 0) < 3)
        {
            Tot += (SValue - 50) / CurrenciesUsed;
        }
        else
        {
            Tot += ((100 - SValue) - 50) / CurrenciesUsed;
        }
    }
    return Tot;
}

double RSITotMA(string Curr, int j)
{
    double Tot = 0;
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (StringFind(AllPairs[i], Curr, 0) < 0) continue;
        double SValue = 0;
        for (int h = 0; h < SmoothingPeriod; h++)
        {
            int k = j;
            if (LinesTF != Period()) k = iBarShift(AllPairs[i], LinesTF, Time[j], false);
            SValue += iRSI(AllPairs[i], LinesTF, RSIPeriod, PRICE_CLOSE, k + h);
            if (SValue == 0)
            {
                HistoricalOK = false;
                MissingHistoricalPair = AllPairs[i];
                return 0;
            }
        }
        SValue = SValue / SmoothingPeriod;
        if (StringFind(AllPairs[i], Curr, 0) < 3)
        {
            Tot += (SValue - 50);
        }
        else
        {
            Tot += ((100 - SValue) - 50);
        }
    }
    return (Tot / CurrenciesUsed);
}

void CopyBaseQuote()
{
    if (StringFind(CurrBase, "EUR") >= 0) ArrayCopy(Base, EUR);
    if (StringFind(CurrBase, "USD") >= 0) ArrayCopy(Base, USD);
    if (StringFind(CurrBase, "GBP") >= 0) ArrayCopy(Base, GBP);
    if (StringFind(CurrBase, "JPY") >= 0) ArrayCopy(Base, JPY);
    if (StringFind(CurrBase, "AUD") >= 0) ArrayCopy(Base, AUD);
    if (StringFind(CurrBase, "NZD") >= 0) ArrayCopy(Base, NZD);
    if (StringFind(CurrBase, "CAD") >= 0) ArrayCopy(Base, CAD);
    if (StringFind(CurrBase, "CHF") >= 0) ArrayCopy(Base, CHF);
    if (StringFind(CurrQuote, "EUR") >= 0) ArrayCopy(Quote, EUR);
    if (StringFind(CurrQuote, "USD") >= 0) ArrayCopy(Quote, USD);
    if (StringFind(CurrQuote, "GBP") >= 0) ArrayCopy(Quote, GBP);
    if (StringFind(CurrQuote, "JPY") >= 0) ArrayCopy(Quote, JPY);
    if (StringFind(CurrQuote, "AUD") >= 0) ArrayCopy(Quote, AUD);
    if (StringFind(CurrQuote, "NZD") >= 0) ArrayCopy(Quote, NZD);
    if (StringFind(CurrQuote, "CAD") >= 0) ArrayCopy(Quote, CAD);
    if (StringFind(CurrQuote, "CHF") >= 0) ArrayCopy(Quote, CHF);
}

void DrawArrows(int limit)
{
    if (limit > ArraySize(EUR)) limit = ArraySize(EUR);
    for (int i = 0; i < limit; i++)
    {
        DrawArrow(i);
    }
    if (LastArrow != 0) FirstRun = false;

}

int LastArrow = 0;
int SignalWidth = 0;
int DrawArrow(int i)
{
    RemoveArrowCurr(i);
    double ValueBaseCurr = 0;
    double ValueQuoteCurr = 0;
    double ValueBasePrev = 0;
    double ValueQuotePrev = 0;
    bool Buy = false;
    bool Sell = false;
    bool Neutral = false;
    if ((ArraySize(Base) == 0) || (ArraySize(Quote) == 0)) return LastArrow;
    ValueBaseCurr = Base[i];
    ValueBasePrev = Base[i + 1];
    ValueQuoteCurr = Quote[i];
    ValueQuotePrev = Quote[i + 1];

    if ((ValueBasePrev < ValueQuotePrev) && (ValueBaseCurr > ValueQuoteCurr) && (AboveBelow) && (!OppositeZeros)) Buy = true;
    if ((ValueBasePrev > ValueQuotePrev) && (ValueBaseCurr < ValueQuoteCurr) && (AboveBelow) && (!OppositeZeros)) Sell = true;
    if ((ValueBaseCurr > 0) && (ValueQuoteCurr < 0) && ((ValueQuotePrev > 0) || (ValueBasePrev < 0)) && (OppositeZeros)) Buy = true;
    if ((ValueBaseCurr < 0) && (ValueQuoteCurr > 0) && ((ValueQuotePrev < 0) || (ValueBasePrev > 0)) && (OppositeZeros)) Sell = true;
    if ((((ValueBaseCurr < 0) && (ValueQuoteCurr < 0)) || ((ValueBaseCurr > 0) && (ValueQuoteCurr > 0))) &&
            (((ValueQuotePrev > 0) && (ValueBasePrev < 0)) || ((ValueQuotePrev < 0) && (ValueBasePrev > 0))) &&
            (OppositeZeros)) Neutral = true;

    if ((Buy) || (Sell) || (Neutral))
    {
        datetime ArrowDate = iTime(Symbol(), Period(), i);
        string ArrowName = IndicatorName + "-ARWS-" + IntegerToString(ArrowDate);
        double ArrowPrice = 0;
        int ArrowType = 0;
        color ArrowColor = 0;
        int ArrowAnchor = 0;
        string ArrowDesc = "";
        if (Buy)
        {
            ArrowPrice = Low[i];
            ArrowType = OBJ_ARROW_UP;
            ArrowColor = BuyColor;
            ArrowAnchor = ANCHOR_TOP;
            LastArrow = ZONE_BUY;
            ArrowDesc = "BUY";
        }
        if (Sell)
        {
            ArrowPrice = High[i];
            ArrowType = OBJ_ARROW_DOWN;
            ArrowColor = SellColor;
            ArrowAnchor = ANCHOR_BOTTOM;
            LastArrow = ZONE_SELL;
            ArrowDesc = "SELL";
        }
        if (Neutral)
        {
            if (LastArrow == ZONE_SELL)
            {
                ArrowAnchor = ANCHOR_BOTTOM;
                ArrowPrice = High[i];
            }
            if (LastArrow == ZONE_BUY)
            {
                ArrowAnchor = ANCHOR_TOP;
                ArrowPrice = Low[i];
            }
            ArrowType = OBJ_ARROW_STOP;
            ArrowColor = NeutralColor;
            LastArrow = ZONE_NEUTRAL;
            ArrowDesc = "NEUTRAL";
        }
        ObjectCreate(0, ArrowName, ArrowType, 0, ArrowDate, ArrowPrice);
        ObjectSetInteger(0, ArrowName, OBJPROP_COLOR, ArrowColor);
        ObjectSetInteger(0, ArrowName, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, ArrowName, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, ArrowName, OBJPROP_ANCHOR, ArrowAnchor);
        SignalWidth = (int)ChartGetInteger(0, CHART_SCALE, 0);
        if (SignalWidth == 0) SignalWidth++;
        ObjectSetInteger(0, ArrowName, OBJPROP_WIDTH, SignalWidth);
        ObjectSetInteger(0, ArrowName, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, ArrowName, OBJPROP_BGCOLOR, ArrowColor);
        ObjectSetString(0, ArrowName, OBJPROP_TEXT, ArrowDesc);
        if (i == TriggerCandle) // Trigger candle.
        {
            NotifyArrow();
        }
    }
    return LastArrow;
}

void RemoveArrowCurr(int Index)
{
    datetime ArrowDate = iTime(Symbol(), Period(), Index);
    string ArrowName = IndicatorName + "-ARWS-" + IntegerToString(ArrowDate);
    ObjectDelete(0, ArrowName);
}

void NotifyArrow()
{
    if (!EnableNotify) return;
    if ((!SendAlert) && (!SendApp) && (!SendEmail)) return;
    datetime ArrowDate = iTime(Symbol(), Period(), TriggerCandle);
    string ArrowName = IndicatorName + "-ARWS-" + IntegerToString(ArrowDate);
    string ArrowDesc = ObjectGetString(0, ArrowName, OBJPROP_TEXT, 0);
    if ((LastAlertDirection == ArrowDesc) && (LastNotification == ArrowDate)) return; // Same arrow, don't alert again.
    string Setup = "";
    if (ArrowDesc == "SELL") Setup = "Possible SELL setup";
    else if(ArrowDesc == "BUY") Setup = "Possible BUY setup";
    else if(ArrowDesc == "NEUTRAL") Setup = "Possible STOP setup";
    else return;
    string EmailSubject = IndicatorName + " " + Symbol() + " Notification ";
    string EmailBody = AccountCompany() + " - " + AccountName() + " - " + IntegerToString(AccountNumber()) + "\r\n" + IndicatorName + " Notification for " + Symbol() + "\r\n";
    EmailBody += Setup;
    string AlertText = IndicatorName + " - " + Symbol() + " " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " ";
    AlertText += Setup;
    string AppText = AccountCompany() + " - " + AccountName() + " - " + IntegerToString(AccountNumber()) + " - " + IndicatorName + " - " + Symbol() + " - ";
    AppText += Setup;
    if (!FirstRun)
    {
        if (SendAlert) Alert(AlertText);
        if (SendEmail)
        {
            if (!SendMail(EmailSubject, EmailBody)) Print("Error sending email " + IntegerToString(GetLastError()));
        }
        if (SendApp)
        {
            if (!SendNotification(AppText)) Print("Error sending notification " + IntegerToString(GetLastError()));
        }
    }
    FirstRun = false;
    LastAlertDirection = ArrowDesc;
    LastNotification = ArrowDate;
}
//+------------------------------------------------------------------+