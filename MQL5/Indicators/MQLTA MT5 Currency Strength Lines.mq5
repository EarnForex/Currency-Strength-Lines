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
#property description   "Find more on www.EarnForex.com"
#property icon          "\\Files\\EF-Icon-64x64px.ico"

#include <MQLTA ErrorHandling.mqh>
#include <MQLTA Utils.mqh>

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots 8
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
#property indicator_type1  DRAW_LINE
#property indicator_type2  DRAW_LINE
#property indicator_type3  DRAW_LINE
#property indicator_type4  DRAW_LINE
#property indicator_type5  DRAW_LINE
#property indicator_type6  DRAW_LINE
#property indicator_type7  DRAW_LINE
#property indicator_type8  DRAW_LINE
#property indicator_level1 DRAW_LINE

enum Enum_CalculationMode
{
    Mode_ASITot = 2,                    //ASI TOT
    Mode_ASITotMA = 3,                  //ASI TOT MA
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
input Enum_CalculationMode CalculationMode = Mode_ASITot; // Calculation Mode
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

string comment_1 = "=========="; // Currencies to Analyse
bool UseEUR = true;              // EUR
bool UseUSD = true;              // USD
bool UseGBP = true;              // GBP
bool UseJPY = true;              // JPY
bool UseAUD = true;              // AUD
bool UseNZD = true;              // NZD
bool UseCAD = true;              // CAD
bool UseCHF = true;              // CHF

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
input bool ErrorLog = false;              // Enable Verbose Logging
input bool DrawPanel = true;              // Draw Panel

string Font = "Consolas";

//--- indicator buffers
double EUR[];
double USD[];
double GBP[];
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
int RefreshCount = 0;
datetime LastTotalRefresh = TimeCurrent();
ENUM_TIMEFRAMES LinesTF = LinesTimeFrame;

bool HistoricalOK = true;
bool MissingHistoricalNotified = false;
string MissingHistoricalPair = "";
int MissingHistoricalPeriod = 0;

const int IndicatorDigits = 4;

const int PAIRS_COUNT = 28;
int RSIHandle[28];
double RSIValue[][28];

string LastAlertDirection = ""; // Signal that was alerted on previous alert.
datetime LastNotification = 0;
bool FirstRun = true; // For alerts only.

int LabelX, LabelY, InnerPaddingX, InnerPaddingY, InnerPaddingModelX, InnerPaddingModelY, MissingHistoricalLabelX, MissingHistoricalLabelY;
double DPIScale; // Scaling parameter for the panel based on the screen DPI.

int GlobalPrevCalculated = 0;

int OnInit()
{
    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);

    if ((LinesTF == PERIOD_CURRENT) || ((LinesTF != PERIOD_CURRENT) && (LinesTF < Period()))) LinesTF = Period();
    else LinesTF = LinesTimeFrame;

    CurrPrefix = CurrencyPrefix;
    CurrSuffix = CurrencySuffix;

    SetAllPairs();
    if (!CheckAllPairs()) return INIT_FAILED;

    IndicatorSetInteger(INDICATOR_DIGITS, IndicatorDigits);
    CleanChart();
    DetectCurrencies();

    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);

    IndicatorSetInteger(INDICATOR_LEVELS, 1);
    IndicatorSetDouble(INDICATOR_LEVELVALUE, indicator_level1, 0);
    IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_DOT);
    IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrGray);

    int Width = NormalWidth;
    int DrawStyle = DRAW_LINE;
    for (int i = 0; i < ArraySize(AllCurrencies); i++)
    {
        if (StringFind(Symbol(), AllCurrencies[i], 0) >= 0)
        {
            Width = SelectedWidth;
        }
        else
        {
            Width = NormalWidth;
        }
        if ((StringFind(Symbol(), AllCurrencies[i], 0) >= 0) || (DrawAllCurrencies))
        {
            DrawStyle = DRAW_LINE;
        }
        else
        {
            DrawStyle = DRAW_NONE;
        }
        if (AllCurrencies[i] == "EUR")
        {
            SetIndex(i, DrawStyle, STYLE_SOLID, Width, EURColor, AllCurrencies[i]);
            SetIndexBuffer(i, EUR, INDICATOR_DATA);
        }
        if (AllCurrencies[i] == "USD")
        {
            SetIndex(i, DrawStyle, STYLE_SOLID, Width, USDColor, AllCurrencies[i]);
            SetIndexBuffer(i, USD, INDICATOR_DATA);
        }
        if (AllCurrencies[i] == "GBP")
        {
            SetIndex(i, DrawStyle, STYLE_SOLID, Width, GBPColor, AllCurrencies[i]);
            SetIndexBuffer(i, GBP, INDICATOR_DATA);
        }
        if (AllCurrencies[i] == "JPY")
        {
            SetIndex(i, DrawStyle, STYLE_SOLID, Width, JPYColor, AllCurrencies[i]);
            SetIndexBuffer(i, JPY, INDICATOR_DATA);
        }
        if (AllCurrencies[i] == "AUD")
        {
            SetIndex(i, DrawStyle, STYLE_SOLID, Width, AUDColor, AllCurrencies[i]);
            SetIndexBuffer(i, AUD, INDICATOR_DATA);
        }
        if (AllCurrencies[i] == "NZD")
        {
            SetIndex(i, DrawStyle, STYLE_SOLID, Width, NZDColor, AllCurrencies[i]);
            SetIndexBuffer(i, NZD, INDICATOR_DATA);
        }
        if (AllCurrencies[i] == "CAD")
        {
            SetIndex(i, DrawStyle, STYLE_SOLID, Width, CADColor, AllCurrencies[i]);
            SetIndexBuffer(i, CAD, INDICATOR_DATA);
        }
        if (AllCurrencies[i] == "CHF")
        {
            SetIndex(i, DrawStyle, STYLE_SOLID, Width, CHFColor, AllCurrencies[i]);
            SetIndexBuffer(i, CHF, INDICATOR_DATA);
        }
        if (ErrorLog) Print("Created index ", i, " for ", AllCurrencies[i]);
    }

    ArraySetAsSeries(EUR, true);
    ArraySetAsSeries(USD, true);
    ArraySetAsSeries(GBP, true);
    ArraySetAsSeries(JPY, true);
    ArraySetAsSeries(AUD, true);
    ArraySetAsSeries(NZD, true);
    ArraySetAsSeries(CAD, true);
    ArraySetAsSeries(CHF, true);
    ArraySetAsSeries(Base, true);
    ArraySetAsSeries(Quote, true);

    ArrayInitialize(EUR, EMPTY_VALUE);
    ArrayInitialize(USD, EMPTY_VALUE);
    ArrayInitialize(GBP, EMPTY_VALUE);
    ArrayInitialize(JPY, EMPTY_VALUE);
    ArrayInitialize(AUD, EMPTY_VALUE);
    ArrayInitialize(NZD, EMPTY_VALUE);
    ArrayInitialize(CAD, EMPTY_VALUE);
    ArrayInitialize(CHF, EMPTY_VALUE);
    ArrayInitialize(Base, EMPTY_VALUE);
    ArrayInitialize(Quote, EMPTY_VALUE);

    if (!GetRSIHandle()) return INIT_FAILED;

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

    int limit = iBars(Symbol(), Period()) - GlobalPrevCalculated;
    if (GlobalPrevCalculated > 0)
    {
        if (LinesTF != Period())
        {
            limit = PeriodSeconds(LinesTF) / PeriodSeconds(Period());
        }
        limit += 2;
    }
    HistoricalOK = true;

    if (!GetRSIValue(limit)) HistoricalOK = false;
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

    if (limit == iBars(Symbol(), Period())) limit--; // Avoid array out of range.
    if (ShowSignals) DrawArrows(limit);
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

    if (DrawPanel) CreateLabels();
    if (prev_calculated == 0)
    {
        ArrayInitialize(EUR, EMPTY_VALUE);
        ArrayInitialize(USD, EMPTY_VALUE);
        ArrayInitialize(GBP, EMPTY_VALUE);
        ArrayInitialize(JPY, EMPTY_VALUE);
        ArrayInitialize(AUD, EMPTY_VALUE);
        ArrayInitialize(NZD, EMPTY_VALUE);
        ArrayInitialize(CAD, EMPTY_VALUE);
        ArrayInitialize(CHF, EMPTY_VALUE);
    }

    int limit = rates_total - prev_calculated;
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
    if (!GetRSIValue(limit)) HistoricalOK = false;
    if (HistoricalOK) CalculateBuffers(limit);
    if (!HistoricalOK)
    {
        if (DrawPanel) DrawMissingHistorical();
        return 0;
    }
    else
    {
        RemoveMissingHistorical();
    }

    if (limit == rates_total) limit--; // Avoid array out of range.
    if (ShowSignals) DrawArrows(limit - 1);

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
    else if (id == CHARTEVENT_CHART_CHANGE)
    {
        SignalWidth = (int)ChartGetInteger(0, CHART_SCALE, 0);
        if (ShowSignals) DrawArrows(Bars(Symbol(), Period()) - 1);
    }
}

string CalculationModeDesc()
{
    string Text = "";
    if (CalculationMode == Mode_ASITot) Text = "ASI TOT";
    if (CalculationMode == Mode_ASITotMA) Text = "ASI TOT MA";
    if (CalculationMode == Mode_ROC) Text = "ROC TOT";
    if (CalculationMode == Mode_ROCMA) Text = "ROC TOT MA";
    return Text;
}

bool SetAllPairs()
{
    if ((CurrPrefix == "") && (CurrSuffix == "")) return true;
    if (ErrorLog) Print("Found Prefix = ", CurrPrefix, " and Suffix = ", CurrSuffix);
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

bool GetRSIHandle()
{
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        RSIHandle[i] = iRSI(AllPairs[i], LinesTF, RSIPeriod, PRICE_CLOSE);
        if (ErrorLog) Print("RSI handle for ", AllPairs[i], " = ", RSIHandle[i]);
        if (RSIHandle[i] == INVALID_HANDLE)
        {
            if(ErrorLog) Print("Handle initialization failed for ", AllPairs[i]);
            return false;
        }
    }
    return true;
}

bool GetRSIValue(int Max)
{
    ArrayResize(RSIValue, PAIRS_COUNT * Max, 0);
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        double RSIValueTemp[];
        ArrayResize(RSIValueTemp, Max, 0);
        ArrayInitialize(RSIValueTemp, NULL);
        ArraySetAsSeries(RSIValueTemp, true);
        int c = CopyBuffer(RSIHandle[i], 0, 0, Max, RSIValueTemp);
        if (ErrorLog) Print("Copied for ", AllPairs[i], " ", c, " values");
        if (c < 0)
        {
            if (ErrorLog) Print("Error copying ", AllPairs[i], " data - ", GetLastErrorText(GetLastError()), " - ", GetLastError(), " - index: ", i);
            return false;
        }
        if (c < Max)
        {
            if (ErrorLog) Print("Not enough values for ", AllPairs[i], " data - ", GetLastErrorText(GetLastError()), " - ", GetLastError(), " - index: ", i, " found only ", c);
            HistoricalOK = false;
            MissingHistoricalPair = AllPairs[i];
            return false;
        }
        for (int j = 0; j < ArraySize(RSIValueTemp); j++)
        {
            if ((RSIValueTemp[j] == NULL) || (RSIValueTemp[j] == EMPTY_VALUE))
            {
                if (ErrorLog) Print("Value not valid for for ", AllPairs[i], " value - ", RSIValueTemp[j], " - shift ", j, " - index: ", i);
                HistoricalOK = false;
                MissingHistoricalPair = AllPairs[i];
                return false;
            }
            RSIValue[j][i] = RSIValueTemp[j];
        }
    }
    return true;
}

void CalculateBuffers(int limit)
{
    if (limit > ArraySize(EUR)) limit = ArraySize(EUR);
    for (int i = 0; i < limit; i++)
    {
        switch(CalculationMode)
        {
        case Mode_ASITot:
            CalculateRSITot(i);
            break;
        case Mode_ASITotMA:
            CalculateRSITotMA(i);
            break;
        case Mode_ROC:
            CalculateROCTot(i);
            break;
        case Mode_ROCMA:
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
    string BaseLabel = "";
    StringConcatenate(BaseLabel, IndicatorName, "-BaseLabel");
    ObjectCreate(ChartID(), BaseLabel, OBJ_RECTANGLE_LABEL, Window, 0, 0);
    ObjectSetInteger(0, BaseLabel, OBJPROP_XDISTANCE, XOffset + InnerPaddingX);
    ObjectSetInteger(0, BaseLabel, OBJPROP_YDISTANCE, YOffset + InnerPaddingY);
    ObjectSetInteger(0, BaseLabel, OBJPROP_XSIZE, LabelX);
    ObjectSetInteger(0, BaseLabel, OBJPROP_YSIZE, LabelY);
    ObjectSetInteger(0, BaseLabel, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, BaseLabel, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, BaseLabel, OBJPROP_STATE, false);
    ObjectSetInteger(0, BaseLabel, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, BaseLabel, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, BaseLabel, OBJPROP_SELECTABLE, false);
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

    string CalcModeLabel = "";
    StringConcatenate(CalcModeLabel, IndicatorName, "-CalculationMode");
    ObjectCreate(ChartID(), CalcModeLabel, OBJ_LABEL, Window, 0, 0);
    ObjectSetInteger(0, CalcModeLabel, OBJPROP_CORNER, Corner);
    ObjectSetInteger(0, CalcModeLabel, OBJPROP_XDISTANCE, XOffset + InnerPaddingModelX);
    ObjectSetInteger(0, CalcModeLabel, OBJPROP_YDISTANCE, YOffset + InnerPaddingModelY);
    string PeriodDesc = TimeFrameDescription(LinesTF);
    ObjectSetString(0, CalcModeLabel, OBJPROP_TEXT, "Period : " + PeriodDesc + " - Calculation Mode : " + CalculationModeDesc());
    ObjectSetString(0, CalcModeLabel, OBJPROP_FONT, Font);
    ObjectSetInteger(0, CalcModeLabel, OBJPROP_COLOR, LabelColor);
    ObjectSetInteger(0, CalcModeLabel, OBJPROP_FONTSIZE, 8);
}

void CreateLabel(string Curr, color Color, int Window, int L)
{
    string LabelName = "";
    StringConcatenate(LabelName, IndicatorName, "-", Curr, "Label");
    int Offset = L * 35;
    ObjectCreate(ChartID(), LabelName, OBJ_LABEL, Window, 0, 0);
    ObjectSetInteger(0, LabelName, OBJPROP_CORNER, Corner);
    ObjectSetInteger(0, LabelName, OBJPROP_XDISTANCE, XOffset + (int)MathRound((Offset + 15) * DPIScale));
    ObjectSetInteger(0, LabelName, OBJPROP_YDISTANCE, YOffset + InnerPaddingY);
    ObjectSetString(0, LabelName, OBJPROP_TEXT, Curr);
    ObjectSetString(0, LabelName, OBJPROP_FONT, Font);
    ObjectSetInteger(0, LabelName, OBJPROP_COLOR, Color);
    ObjectSetInteger(0, LabelName, OBJPROP_FONTSIZE, 12);
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
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_XDISTANCE, MissingHistoricalXStart);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_YDISTANCE, MissingHistoricalYStart + 2);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_XSIZE, MissingHistoricalRecX);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_YSIZE, (MissingHistoricalLabelY + 2) * 2 + 1);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_BGCOLOR, clrWhite);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, MissingHistoricalBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, MissingHistoricalLabel, OBJ_EDIT, Window, 0, 0);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_XDISTANCE, MissingHistoricalXStart + 2);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_YDISTANCE, MissingHistoricalYStart + 4);
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
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_BGCOLOR, clrRed);
    ObjectSetInteger(0, MissingHistoricalLabel, OBJPROP_BORDER_COLOR, clrBlack);

    ObjectCreate(0, MissingHistoricalGoTo, OBJ_EDIT, Window, 0, 0);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_XDISTANCE, MissingHistoricalXStart + 2);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_YDISTANCE, MissingHistoricalYStart + MissingHistoricalLabelY + (int)MathRound(5 * DPIScale));
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_XSIZE, MissingHistoricalLabelX);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_YSIZE, MissingHistoricalLabelY);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_STATE, false);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_READONLY, true);
    ObjectSetString(0, MissingHistoricalGoTo, OBJPROP_TOOLTIP, "CLICK TO GO TO THE MISSING HISTORICAL DATA");
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_ALIGN, ALIGN_CENTER);
    if (StringLen(MissingHistoricalPair) == 0) ObjectSetString(0, MissingHistoricalGoTo, OBJPROP_TEXT, "LOADING");
    else ObjectSetString(0, MissingHistoricalGoTo, OBJPROP_TEXT, "GO TO - " + MissingHistoricalPair);
    ObjectSetString(0, MissingHistoricalGoTo, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_FONTSIZE, 10);
    ObjectSetInteger(0, MissingHistoricalGoTo, OBJPROP_SELECTABLE, false);
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
    int Curr1Pos = 0, Curr2Pos = 0;
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
    if (UseEUR) EUR[i] = GetROCStrength("EUR", i);
    if (UseGBP) GBP[i] = GetROCStrength("GBP", i);
    if (UseUSD) USD[i] = GetROCStrength("USD", i);
    if (UseJPY) JPY[i] = GetROCStrength("JPY", i);
    if (UseAUD) AUD[i] = GetROCStrength("AUD", i);
    if (UseNZD) NZD[i] = GetROCStrength("NZD", i);
    if (UseCAD) CAD[i] = GetROCStrength("CAD", i);
    if (UseCHF) CHF[i] = GetROCStrength("CHF", i);
}

void CalculateROCTotMA(int i)
{
    if (UseEUR) EUR[i] = GetROCMAStrength("EUR", i);
    if (UseGBP) GBP[i] = GetROCMAStrength("GBP", i);
    if (UseUSD) USD[i] = GetROCMAStrength("USD", i);
    if (UseJPY) JPY[i] = GetROCMAStrength("JPY", i);
    if (UseAUD) AUD[i] = GetROCMAStrength("AUD", i);
    if (UseNZD) NZD[i] = GetROCMAStrength("NZD", i);
    if (UseCAD) CAD[i] = GetROCMAStrength("CAD", i);
    if (UseCHF) CHF[i] = GetROCMAStrength("CHF", i);
}

void CalculateRSITot(int i)
{
    if (UseEUR) EUR[i] = GetRSIStrength("EUR", i);
    if (UseGBP) GBP[i] = GetRSIStrength("GBP", i);
    if (UseUSD) USD[i] = GetRSIStrength("USD", i);
    if (UseJPY) JPY[i] = GetRSIStrength("JPY", i);
    if (UseAUD) AUD[i] = GetRSIStrength("AUD", i);
    if (UseNZD) NZD[i] = GetRSIStrength("NZD", i);
    if (UseCAD) CAD[i] = GetRSIStrength("CAD", i);
    if (UseCHF) CHF[i] = GetRSIStrength("CHF", i);
}

void CalculateRSITotMA(int i)
{
    if (UseEUR) EUR[i] = GetRSIMAStrength("EUR", i);
    if (UseGBP) GBP[i] = GetRSIMAStrength("GBP", i);
    if (UseUSD) USD[i] = GetRSIMAStrength("USD", i);
    if (UseJPY) JPY[i] = GetRSIMAStrength("JPY", i);
    if (UseAUD) AUD[i] = GetRSIMAStrength("AUD", i);
    if (UseNZD) NZD[i] = GetRSIMAStrength("NZD", i);
    if (UseCAD) CAD[i] = GetRSIMAStrength("CAD", i);
    if (UseCHF) CHF[i] = GetRSIMAStrength("CHF", i);
}

double GetROCStrength(string Curr, int j)
{
    double Tot = 0;
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (StringFind(AllPairs[i], Curr, 0) < 0) continue;
        int k = j;
        if (LinesTF != Period()) k = iBarShift(AllPairs[i], LinesTF, iTime(AllPairs[i], Period(), j), false);
        double EndValue = iClose(AllPairs[i], LinesTF, k);
        double StartValue = iClose(AllPairs[i], LinesTF, k + ROCPeriod);
        double SValue = 0;
        if (StartValue > 0) SValue = (EndValue / StartValue - 1) * 100;
        if ((StartValue == 0) || (EndValue == 0) || (k == -1) || (k > Bars(AllPairs[i], LinesTF)) || (iTime(AllPairs[i], Period(), j) == 0))
        {
            if (ErrorLog) Print("Value not valid for for ", AllPairs[i], " value - ", k);
            HistoricalOK = false;
            MissingHistoricalPair = AllPairs[i];
            return 0;
        }
        if (ErrorLog) Print("Using ROC value of ", SValue, " for ", AllPairs[i], " and shift ", j);
        if (StringFind(AllPairs[i], Curr, 0) < 3)
        {
            Tot += SValue;
        }
        else
        {
            Tot -= SValue;
        }
    }
    if (ErrorLog) Print("Calculated ROC strength for ", Curr, " and shift ", j, " with a value of ", Tot);
    return NormalizeDouble(Tot, IndicatorDigits);
}

double GetROCMAStrength(string Curr, int j)
{
    double Tot = 0;
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (StringFind(AllPairs[i], Curr, 0) < 0) continue;
        double SValue = 0;
        for (int h = 0; h < SmoothingPeriod; h++)
        {
            int k = j;
            if (LinesTF != Period()) k = iBarShift(AllPairs[i], LinesTF, iTime(AllPairs[i], Period(), j), false);
            double EndValue = iClose(AllPairs[i], LinesTF, k + h);
            double StartValue = iClose(AllPairs[i], LinesTF, k + ROCPeriod + h);
            if (StartValue > 0) SValue += (EndValue / StartValue - 1) * 100;
            if ((StartValue == 0) || (EndValue == 0) || (k == -1) || (k > Bars(AllPairs[i], LinesTF)) || (iTime(AllPairs[i], Period(), j) == 0))
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
    if (ErrorLog) Print("Calculated ROC strength for ", Curr, " and shift ", j, " with a value of ", Tot);
    return NormalizeDouble(Tot, IndicatorDigits);
}

double GetRSIStrength(string Curr, int j)
{
    double Tot = 0;
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (StringFind(AllPairs[i], Curr, 0) < 0) continue;
        int k = j;
        if (LinesTF != Period()) k = iBarShift(AllPairs[i], LinesTF, iTime(AllPairs[i], Period(), j), false);
        if ((k == -1) || (k > Bars(AllPairs[i], LinesTF)) || (iTime(AllPairs[i], Period(), j) == 0))
        {
            if (ErrorLog) Print("Value not valid for for ", AllPairs[i], " value - ", k);
            HistoricalOK = false;
            MissingHistoricalPair = AllPairs[i];
            return 0;
        }
        double SValue = RSIValue[k][i];
        if (ErrorLog) Print("Using RSI value of ", SValue, " for ", AllPairs[i], " and shift ", j);
        if (StringFind(AllPairs[i], Curr, 0) < 3)
        {
            Tot += (SValue - 50) / (CurrenciesUsed - 1);
        }
        else
        {
            Tot += ((100 - SValue) - 50) / (CurrenciesUsed - 1);
        }
    }
    if (ErrorLog) Print("Calculated RSI strength for ", Curr, " and shift ", j, " with a value of ", Tot);
    return NormalizeDouble(Tot, IndicatorDigits);
}

double GetRSIMAStrength(string Curr, int j)
{
    if (j >= MaxBars - SmoothingPeriod) return EMPTY_VALUE;
    double Tot = 0;
    for (int i = 0; i < ArraySize(AllPairs); i++)
    {
        if (StringFind(AllPairs[i], Curr, 0) < 0) continue;
        double SValue = 0;
        for(int h = 0; h < SmoothingPeriod; h++)
        {
            int k = j;
            if (LinesTF != Period()) k = iBarShift(AllPairs[i], LinesTF, iTime(AllPairs[i], Period(), j), false);
            if ((k == -1) || (k > Bars(AllPairs[i], LinesTF)) || (iTime(AllPairs[i], Period(), j) == 0))
            {
                if (ErrorLog) Print("Value not valid for for ", AllPairs[i], " value - ", k);
                HistoricalOK = false;
                MissingHistoricalPair = AllPairs[i];
                return false;
            }
            SValue += RSIValue[k + h][i];
        }
        SValue = SValue / SmoothingPeriod;
        if (ErrorLog) Print("Using RSI value of ", SValue, " for ", AllPairs[i], " and shift ", j);
        if (StringFind(AllPairs[i], Curr, 0) < 3)
        {
            Tot += (SValue - 50) / (CurrenciesUsed - 1);
        }
        else
        {
            Tot += ((100 - SValue) - 50) / (CurrenciesUsed - 1);
        }
    }
    if (ErrorLog) Print("Calculated RSI strength for ", Curr, " and shift ", j, " with a value of ", Tot);
    return NormalizeDouble(Tot, IndicatorDigits);
}

void CopyBaseQuote()
{
    if (ErrorLog) Print("Copy Base ", CurrBase, " and Quote ", CurrQuote);
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
    if ((ValueBaseCurr == EMPTY_VALUE) || (ValueBasePrev == EMPTY_VALUE) || (ValueQuoteCurr == EMPTY_VALUE) || (ValueQuotePrev == EMPTY_VALUE)) return LastArrow;

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
        ENUM_OBJECT ArrowType = 0;
        color ArrowColor = 0;
        int ArrowAnchor = 0;
        string ArrowDesc = "";
        if (Buy)
        {
            ArrowPrice = iLow(Symbol(), Period(), i);
            ArrowType = OBJ_ARROW_UP;
            ArrowColor = BuyColor;
            ArrowAnchor = ANCHOR_TOP;
            LastArrow = ZONE_BUY;
            ArrowDesc = "BUY";
        }
        if (Sell)
        {
            ArrowPrice = iHigh(Symbol(), Period(), i);
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
                ArrowPrice = iHigh(Symbol(), Period(), i);
            }
            if (LastArrow == ZONE_BUY)
            {
                ArrowAnchor = ANCHOR_TOP;
                ArrowPrice = iLow(Symbol(), Period(), i);
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
    string EmailSubject = IndicatorName + " " + Symbol() + " " + Setup;
    string EmailBody = AccountCompany() + " - " + AccountName() + " - " + IntegerToString(AccountNumber()) + "\r\n" + IndicatorName + " Notification for " + Symbol() + "\r\n";
    EmailBody += Setup;
    string AppText = AccountCompany() + " - " + AccountName() + " - " + IntegerToString(AccountNumber()) + " - " + IndicatorName + " - " + Symbol() + " - ";
    AppText += Setup;
    if (!FirstRun)
    {
        if (SendAlert) Alert(Setup);
        if (SendEmail)
        {
            if (!SendMail(EmailSubject, EmailBody)) Print("Error sending email " + IntegerToString(GetLastError()));
        }
        if (SendApp)
        {
            if (!SendNotification(AppText)) Print("Error sending notification " + IntegerToString(GetLastError()));
        }
    }
    LastAlertDirection = ArrowDesc;
    LastNotification = ArrowDate;
}
//+------------------------------------------------------------------+