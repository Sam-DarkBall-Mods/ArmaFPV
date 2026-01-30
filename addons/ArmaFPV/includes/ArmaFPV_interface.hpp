class RscText;
class ctrlControlsGroupNoScrollBars;
class ctrlControlsGroup;
class ctrlStaticBackground;
class ctrlStaticPicture;
class ctrlStructuredText;

#define GRID_W( num ) ( num * ( pixelGridNoUIScale * pixelW * 2 ))
#define GRID_H( num ) ( num * ( pixelGridNoUIScale * pixelH * 2 ))

#define LINE_WIDTH (safeZoneW * 0.15)
#define LINE_HEIGHT (safeZoneH)

#define WX_POS (safeZoneXAbs + LINE_WIDTH)
#define WY_POS (safeZoneY)
#define W_WIDTH (safeZoneWAbs - 2*LINE_WIDTH)
#define W_HEIGHT (safeZoneH)

class RscTitles
{
    class ArmaFPV_Dialog
    {
        idd = -1;
        duration = 1e+038;
        movingEnable = false;
        enableSimulation = true;

        class controlsBackground
        {
            class LeftHudMask : ctrlStaticBackground
            {
                idc = -1;
                colorBackground[] = {0, 0, 0, 1};

                x = safeZoneXAbs;
                y = safeZoneY;
                w = LINE_WIDTH;
                h = safeZoneH;
            };

            class RightHudMask : ctrlStaticBackground
            {
                idc = -1;
                colorBackground[] = {0, 0, 0, 1};

                x = safeZoneXAbs + safeZoneWAbs - LINE_WIDTH;
                y = safeZoneY;
                w = LINE_WIDTH;
                h = safeZoneH;
            };
        };

        class controls
        {
            class TopLeftText : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "left";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.2);
                text = "";

                x = WX_POS + GRID_W(1);
                y = WY_POS + GRID_H(6.2);
                w = GRID_W(10);
                h = GRID_H(1.4);
            };

            class TopLeftIcon : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_signal.paa";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_SignalPicture"", _this # 0];";

                x = WX_POS + GRID_W(1);
                y = WY_POS + GRID_H(7.9);
                w = GRID_W(2);
                h = GRID_H(2);
            };

            class TopLeftValue : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "left";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.2);
                text = "75";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_SignalText"", _this # 0];";

                x = WX_POS + GRID_W(3.4);
                y = WY_POS + GRID_H(7.9);
                w = GRID_W(6);
                h = GRID_H(1.4);
            };

            class TopRightIcon : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_controller.paa";

                x = WX_POS + W_WIDTH - GRID_W(2.6);
                y = WY_POS + GRID_H(0.9);
                w = GRID_W(1.6);
                h = GRID_H(1.6);
            };
            class CompassBar : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_compass.paa";

                x = WX_POS + W_WIDTH / 2 - GRID_W(30) / 2;
                y = WY_POS + GRID_H(2.2);
                w = GRID_W(30);
                h = GRID_H(2);
            };

            class CompassLettersGroup : ctrlControlsGroupNoScrollBars
            {
                idc = -1;
                onLoad = "uiNameSpace setVariable [""ArmaFPV_CompassGroup"", _this # 0];";

                x = WX_POS + W_WIDTH / 2 - GRID_W(30) / 2;
                y = WY_POS + GRID_H(1.2);
                w = GRID_W(30);
                h = GRID_H(2);

                class controls
                {
                    class CompassLetterN : ctrlStructuredText
                    {
                        idc = -1;

                        class Attributes
                        {
                            font = "VCROSDMono";
                            align = "center";
                            shadow = 1;
                        };

                        shadow = 0;
                        size = GRID_H(1.4);
                        text = "N";
                        onLoad = "uiNameSpace setVariable [""ArmaFPV_CompassN"", _this # 0];";

                        x = GRID_W(14);
                        y = GRID_H(0);
                        w = GRID_W(2);
                        h = GRID_H(1.6);
                    };

                    class CompassLetterE : ctrlStructuredText
                    {
                        idc = -1;

                        class Attributes
                        {
                            font = "VCROSDMono";
                            align = "center";
                            shadow = 1;
                        };

                        shadow = 0;
                        size = GRID_H(1.4);
                        text = "E";
                        onLoad = "uiNameSpace setVariable [""ArmaFPV_CompassE"", _this # 0];";

                        x = GRID_W(14);
                        y = GRID_H(0);
                        w = GRID_W(2);
                        h = GRID_H(1.6);
                    };

                    class CompassLetterS : ctrlStructuredText
                    {
                        idc = -1;

                        class Attributes
                        {
                            font = "VCROSDMono";
                            align = "center";
                            shadow = 1;
                        };

                        shadow = 0;
                        size = GRID_H(1.4);
                        text = "S";
                        onLoad = "uiNameSpace setVariable [""ArmaFPV_CompassS"", _this # 0];";

                        x = GRID_W(14);
                        y = GRID_H(0);
                        w = GRID_W(2);
                        h = GRID_H(1.6);
                    };

                    class CompassLetterW : ctrlStructuredText
                    {
                        idc = -1;

                        class Attributes
                        {
                            font = "VCROSDMono";
                            align = "center";
                            shadow = 1;
                        };

                        shadow = 0;
                        size = GRID_H(1.4);
                        text = "W";
                        onLoad = "uiNameSpace setVariable [""ArmaFPV_CompassW"", _this # 0];";

                        x = GRID_W(14);
                        y = GRID_H(0);
                        w = GRID_W(2);
                        h = GRID_H(1.6);
                    };
                };
            };

            class HeadingText : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "center";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.6);
                text = "032";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_HeadingText"", _this # 0];";

                x = WX_POS + W_WIDTH / 2 - GRID_W(6) / 2;
                y = WY_POS + GRID_H(4.2);
                w = GRID_W(6);
                h = GRID_H(2);
            };

            class HeadingPointerDown : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_pointer_down.paa";

                x = WX_POS + W_WIDTH / 2 - GRID_W(0.9) / 2;
                y = WY_POS + GRID_H(3.3);
                w = GRID_W(0.9);
                h = GRID_H(0.9);
            };

            class Center_target : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_center.paa";

                x = 0.5 - GRID_W(2) / 2;
                y = 0.5 - GRID_H(2) / 2 + GRID_H(1.25);
                w = GRID_W(2);
                h = GRID_H(2);
            };

            class VBarLeft : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_vbar_left.paa";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_VBarLeft"", _this # 0];";

                x = WX_POS + GRID_W(9);
                y = WY_POS + GRID_H(12);
                w = GRID_W(1);
                h = GRID_H(16);
            };

            class VBarRight : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_vbar_right.paa";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_VBarRight"", _this # 0];";

                x = WX_POS + W_WIDTH - GRID_W(10);
                y = WY_POS + GRID_H(12);
                w = GRID_W(1);
                h = GRID_H(16);
            };

            class VPointerLeft : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_pointer_left.paa";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_VPointerLeft"", _this # 0];";

                x = WX_POS + GRID_W(10.2);
                y = WY_POS + GRID_H(19);
                w = GRID_W(1.4);
                h = GRID_H(1.4);
            };

            class VPointerRight : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_pointer_right.paa";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_VPointerRight"", _this # 0];";

                x = WX_POS + W_WIDTH - GRID_W(11.6);
                y = WY_POS + GRID_H(19);
                w = GRID_W(1.4);
                h = GRID_H(1.4);
            };

            class AltLeftText : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "left";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.3);
                text = "061";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_AltText"", _this # 0];";

                x = WX_POS + GRID_W(1);
                y = WY_POS + GRID_H(18.5);
                w = GRID_W(6);
                h = GRID_H(1.6);
            };

            class AltLeftUnit : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "left";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.1);
                text = "m";

                x = WX_POS + GRID_W(1);
                y = WY_POS + GRID_H(20.2);
                w = GRID_W(4);
                h = GRID_H(1.2);
            };

            class DistRightText : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "right";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.3);
                text = "10483";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_RightText"", _this # 0];";

                x = WX_POS + W_WIDTH - GRID_W(10);
                y = WY_POS + GRID_H(18.5);
                w = GRID_W(9);
                h = GRID_H(1.6);
            };

            class DistRightUnit : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "right";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.1);
                text = "ft/h";

                x = WX_POS + W_WIDTH - GRID_W(8);
                y = WY_POS + GRID_H(20.2);
                w = GRID_W(7);
                h = GRID_H(1.2);
            };

            class BottomDistanceText : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "center";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.3);
                text = "11861ft";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_DistText"", _this # 0];";

                x = WX_POS + W_WIDTH / 2 - GRID_W(10) / 2;
                y = WY_POS + W_HEIGHT - GRID_H(6);
                w = GRID_W(10);
                h = GRID_H(1.6);
            };

            class LeftStatusIcon : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_p_icon.paa";

                x = WX_POS + GRID_W(1);
                y = WY_POS + W_HEIGHT - GRID_H(9);
                w = GRID_W(2);
                h = GRID_H(2);
            };

            class LeftVoltText : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "left";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.2);
                text = "15.0V";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_LeftVoltText"", _this # 0];";

                x = WX_POS + GRID_W(3.4);
                y = WY_POS + W_HEIGHT - GRID_H(9);
                w = GRID_W(8);
                h = GRID_H(1.6);
            };

            class LeftCurrentText : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "left";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.2);
                text = "11.4A";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_LeftCurrentText"", _this # 0];";

                x = WX_POS + GRID_W(3.4);
                y = WY_POS + W_HEIGHT - GRID_H(7.2);
                w = GRID_W(8);
                h = GRID_H(1.6);
            };

            class LeftMahText : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "left";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.2);
                text = "2406mAh";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_LeftMahText"", _this # 0];";

                x = WX_POS + GRID_W(3.4);
                y = WY_POS + W_HEIGHT - GRID_H(5.4);
                w = GRID_W(10);
                h = GRID_H(1.6);
            };

            class RightStatusIcon : ctrlStaticPicture
            {
                idc = -1;

                text = "\ArmaFPV\pictures\osd_batt_icon.paa";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_BatteryPicture"", _this # 0];";

                x = WX_POS + W_WIDTH - GRID_W(6.5);
                y = WY_POS + W_HEIGHT - GRID_H(9);
                w = GRID_W(2);
                h = GRID_H(2);
            };

            class RightVoltText : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "left";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.2);
                text = "12.3V";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_RightVoltText"", _this # 0];";

                x = WX_POS + W_WIDTH - GRID_W(4.3);
                y = WY_POS + W_HEIGHT - GRID_H(9);
                w = GRID_W(6);
                h = GRID_H(1.6);
            };

            class RightTimeText : ctrlStructuredText
            {
                idc = -1;

                class Attributes
                {
                    font = "VCROSDMono";
                    align = "left";
                    shadow = 1;
                };

                shadow = 0;
                size = GRID_H(1.2);
                text = "11:45";
                onLoad = "uiNameSpace setVariable [""ArmaFPV_TimeText"", _this # 0];";

                x = WX_POS + W_WIDTH - GRID_W(4.3);
                y = WY_POS + W_HEIGHT - GRID_H(7.2);
                w = GRID_W(6);
                h = GRID_H(1.6);
            };
        };
    };
};
