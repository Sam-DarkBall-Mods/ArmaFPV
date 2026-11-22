class RscText;
class ctrlStaticBackground;
class ctrlStaticPicture;

#define UI_EXPR_INNER(value) #value
#define UI_EXPR(value) UI_EXPR_INNER(value)

#define OSD_W ((safeZoneH * 4 / 3 * pixelW / pixelH) min safeZoneW)
#define OSD_X (safeZoneX + (safeZoneW - OSD_W) / 2)
#define CELL_W (OSD_W / 30)
#define CELL_H (safeZoneH / 16)

#define OSD_CELL(COL,ROW,COLS) \
    x = UI_EXPR(OSD_X + COL * CELL_W); \
    y = UI_EXPR(safeZoneY + ROW * CELL_H); \
    w = UI_EXPR(COLS * CELL_W); \
    h = UI_EXPR(CELL_H)

class ArmaFPV_OSDText: RscText
{
    idc = -1;
    style = 0;
    font = "ArmaFPV_OSD";
    sizeEx = UI_EXPR(CELL_H);
    shadow = 0;
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0};
    text = "";
};

class ArmaFPV_FXLayer: ctrlStaticPicture
{
    idc = -1;
    text = "";
    colorText[] = {1, 1, 1, 0};
    x = UI_EXPR(OSD_X);
    y = UI_EXPR(safeZoneY);
    w = UI_EXPR(OSD_W);
    h = UI_EXPR(safeZoneH);
};

class RscTitles
{
    class ArmaFPV_Dialog
    {
        idd = -1;
        duration = 1e+038;
        movingEnable = 0;
        enableSimulation = 1;
        onLoad = "uiNamespace setVariable ['ArmaFPV_Display', _this # 0];";
        onUnload = "uiNamespace setVariable ['ArmaFPV_Display', displayNull];";

        class controlsBackground
        {
            class LeftMask: ctrlStaticBackground
            {
                idc = -1;
                colorBackground[] = {0, 0, 0, 1};
                x = UI_EXPR(safeZoneXAbs);
                y = UI_EXPR(safeZoneY);
                w = UI_EXPR(OSD_X - safeZoneXAbs);
                h = UI_EXPR(safeZoneH);
            };
            class RightMask: LeftMask
            {
                x = UI_EXPR(OSD_X + OSD_W);
                w = UI_EXPR(safeZoneXAbs + safeZoneWAbs - OSD_X - OSD_W);
            };
        };

        class controls
        {
            class SignalSentinel: ctrlStaticPicture
            {
                idc = -1;
                text = "";
                x = 0;
                y = 0;
                w = 0;
                h = 0;
                onLoad = "(_this # 0) ctrlShow false; uiNamespace setVariable ['ArmaFPV_SignalPicture', _this # 0];";
            };
            class Vignette: ArmaFPV_FXLayer
            {
                text = "\ArmaFPV\pictures\fx\vignette_ca.paa";
                colorText[] = {1, 1, 1, 1};
            };
            class LinkQuality: ArmaFPV_OSDText
            {
                OSD_CELL(1,1,7);
                onLoad = "uiNamespace setVariable ['ArmaFPV_OSD_LQ', _this # 0];";
            };
            class Rssi: ArmaFPV_OSDText
            {
                OSD_CELL(24,1,6);
                onLoad = "uiNamespace setVariable ['ArmaFPV_OSD_Rssi', _this # 0];";
            };
            class Crosshair: ArmaFPV_OSDText
            {
                x = UI_EXPR(OSD_X + OSD_W / 2 - 1.5 * CELL_W);
                y = UI_EXPR(safeZoneY + safeZoneH / 2 - CELL_H / 2);
                w = UI_EXPR(3 * CELL_W);
                h = UI_EXPR(CELL_H);
                onLoad = "uiNamespace setVariable ['ArmaFPV_OSD_Cross', _this # 0];";
            };
            class Warnings: ArmaFPV_OSDText
            {
                style = 2;
                OSD_CELL(0,10,30);
                onLoad = "uiNamespace setVariable ['ArmaFPV_OSD_Warn', _this # 0];";
            };
            class Altitude: ArmaFPV_OSDText
            {
                OSD_CELL(1,13,8);
                onLoad = "uiNamespace setVariable ['ArmaFPV_OSD_Alt', _this # 0];";
            };
            class Voltage: ArmaFPV_OSDText
            {
                OSD_CELL(1,14,8);
                onLoad = "uiNamespace setVariable ['ArmaFPV_OSD_Volt', _this # 0];";
            };
            class MahDrawn: ArmaFPV_OSDText
            {
                OSD_CELL(1,15,8);
                onLoad = "uiNamespace setVariable ['ArmaFPV_OSD_Mah', _this # 0];";
            };
            class CraftName: ArmaFPV_OSDText
            {
                style = 2;
                OSD_CELL(9,15,12);
                onLoad = "uiNamespace setVariable ['ArmaFPV_DefaultText', _this # 0];";
            };
            class Current: ArmaFPV_OSDText
            {
                OSD_CELL(22,14,8);
                onLoad = "uiNamespace setVariable ['ArmaFPV_OSD_Amp', _this # 0];";
            };
            class FlyTime: ArmaFPV_OSDText
            {
                OSD_CELL(23,15,7);
                onLoad = "uiNamespace setVariable ['ArmaFPV_OSD_Time', _this # 0];";
            };
            class SyncBar: ctrlStaticBackground
            {
                idc = -1;
                colorBackground[] = {0, 0, 0, 1};
                x = UI_EXPR(OSD_X);
                y = UI_EXPR(safeZoneY);
                w = UI_EXPR(OSD_W);
                h = UI_EXPR(safeZoneH * 0.07);
                onLoad = "(_this # 0) ctrlShow false; uiNamespace setVariable ['ArmaFPV_FX_Bar', _this # 0];";
            };
            class Spark1: ArmaFPV_FXLayer
            {
                onLoad = "uiNamespace setVariable ['ArmaFPV_FX_Spark1', _this # 0];";
            };
            class Spark2: Spark1
            {
                onLoad = "uiNamespace setVariable ['ArmaFPV_FX_Spark2', _this # 0];";
            };
            class Spark3: Spark1
            {
                onLoad = "uiNamespace setVariable ['ArmaFPV_FX_Spark3', _this # 0];";
            };
            class Snow: ArmaFPV_FXLayer
            {
                onLoad = "uiNamespace setVariable ['ArmaFPV_FX_Snow', _this # 0];";
            };
        };
    };
};
