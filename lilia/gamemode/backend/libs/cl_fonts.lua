--------------------------------------------------------------------------------------------------------------------------
function GM:LoadLiliaFonts(font, genericFont)
    local oldFont, oldGenericFont = font, genericFont
    local scale = math.Round(1, 2)
    surface.CreateFont(
        "liaDialFont",
        {
            font = "Agency FB",
            size = 100,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaRadioFont",
        {
            font = "Lucida Sans Typewriter",
            size = math.max(ScreenScale(7), 17),
            weight = 100
        }
    )

    surface.CreateFont(
        "liaRadioFont",
        {
            font = "Lucida Sans Typewriter",
            size = math.max(ScreenScale(7), 17),
            weight = 100
        }
    )

    surface.CreateFont(
        "liaSmallCredits",
        {
            font = "Roboto",
            size = 20,
            weight = 400
        }
    )

    surface.CreateFont(
        "liaBigCredits",
        {
            font = "Roboto",
            size = 32,
            weight = 600
        }
    )

    surface.CreateFont(
        "liaCrossIcons",
        {
            font = "nsicons",
            size = ScreenScale(11),
            extended = true,
        }
    )

    surface.CreateFont(
        "liaSmallChatFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17),
            extended = true,
            weight = 750
        }
    )

    surface.CreateFont(
        "liaItalicsChatFont",
        {
            font = font,
            size = math.max(ScreenScale(7), 17),
            extended = true,
            weight = 600,
            italic = true
        }
    )

    surface.CreateFont(
        "liaMediumChatFont",
        {
            font = font,
            size = math.max(ScreenScale(7), 17),
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaBigChatFont",
        {
            font = font,
            size = math.max(ScreenScale(8), 17),
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "lia3D2DFont",
        {
            font = font,
            size = 2048,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaTitleFont",
        {
            font = font,
            size = ScreenScale(30) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaSubTitleFont",
        {
            font = font,
            size = ScreenScale(18) * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaMenuButtonFont",
        {
            font = font,
            size = ScreenScale(14) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMenuButtonLightFont",
        {
            font = font,
            size = ScreenScale(14) * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaToolTipText",
        {
            font = font,
            size = 20,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaDynFontSmall",
        {
            font = font,
            size = ScreenScale(22) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaDynFontMedium",
        {
            font = font,
            size = ScreenScale(28) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaDynFontBig",
        {
            font = font,
            size = ScreenScale(48) * scale,
            extended = true,
            weight = 1000
        }
    )

    -- The more readable font.
    font = genericFont
    surface.CreateFont(
        "liaCleanTitleFont",
        {
            font = font,
            size = 200 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaHugeFont",
        {
            font = font,
            size = 72 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaBigFont",
        {
            font = font,
            size = 36 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMediumFont",
        {
            font = font,
            size = 25 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMediumLightFont",
        {
            font = font,
            size = 25 * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaGenericFont",
        {
            font = font,
            size = 20 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaGenericLightFont",
        {
            font = font,
            size = 20 * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaChatFont",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaChatFontItalics",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 200,
            italic = true
        }
    )

    surface.CreateFont(
        "liaChatFontBold",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 800,
        }
    )

    surface.CreateFont(
        "liaSmallFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17) * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaItemDescFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17) * scale,
            extended = true,
            shadow = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaSmallBoldFont",
        {
            font = font,
            size = math.max(ScreenScale(8), 20) * scale,
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaItemBoldFont",
        {
            font = font,
            shadow = true,
            size = math.max(ScreenScale(8), 20) * scale,
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaIconsSmall",
        {
            font = "fontello",
            size = 22,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsMedium",
        {
            font = "fontello",
            extended = true,
            size = 28,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsBig",
        {
            font = "fontello",
            extended = true,
            size = 48,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsSmallNew",
        {
            font = "nsicons",
            size = 22,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsMediumNew",
        {
            font = "nsicons",
            extended = true,
            size = 28,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsBigNew",
        {
            font = "nsicons",
            extended = true,
            size = 48,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaNoticeFont",
        {
            font = genericFont,
            size = 22,
            weight = 500,
            extended = true,
            antialias = true
        }
    )

    surface.CreateFont(
        "lia3D2DFont",
        {
            font = font,
            size = 2048,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaTitleFont",
        {
            font = font,
            size = ScreenScale(30) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaSubTitleFont",
        {
            font = font,
            size = ScreenScale(18) * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaMenuButtonFont",
        {
            font = font,
            size = ScreenScale(14) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMenuButtonLightFont",
        {
            font = font,
            size = ScreenScale(14) * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaToolTipText",
        {
            font = font,
            size = 20,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaDynFontSmall",
        {
            font = font,
            size = ScreenScale(22) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaDynFontMedium",
        {
            font = font,
            size = ScreenScale(28) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaDynFontBig",
        {
            font = font,
            size = ScreenScale(48) * scale,
            extended = true,
            weight = 1000
        }
    )

    -- The more readable font.
    font = genericFont
    surface.CreateFont(
        "liaCleanTitleFont",
        {
            font = font,
            size = 200 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaHugeFont",
        {
            font = font,
            size = 72 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaBigFont",
        {
            font = font,
            size = 36 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMediumFont",
        {
            font = font,
            size = 25 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMediumLightFont",
        {
            font = font,
            size = 25 * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaGenericFont",
        {
            font = font,
            size = 20 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaGenericLightFont",
        {
            font = font,
            size = 20 * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaChatFont",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaChatFontItalics",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 200,
            italic = true
        }
    )

    surface.CreateFont(
        "liaChatFontBold",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 800,
        }
    )

    surface.CreateFont(
        "liaSmallFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17) * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaItemDescFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17) * scale,
            extended = true,
            shadow = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaSmallBoldFont",
        {
            font = font,
            size = math.max(ScreenScale(8), 20) * scale,
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaItemBoldFont",
        {
            font = font,
            shadow = true,
            size = math.max(ScreenScale(8), 20) * scale,
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaIconsSmall",
        {
            font = "fontello",
            size = 22,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsMedium",
        {
            font = "fontello",
            extended = true,
            size = 28,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsBig",
        {
            font = "fontello",
            extended = true,
            size = 48,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsSmallNew",
        {
            font = "nsicons",
            size = 22,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsMediumNew",
        {
            font = "nsicons",
            extended = true,
            size = 28,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsBigNew",
        {
            font = "nsicons",
            extended = true,
            size = 48,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaNoticeFont",
        {
            font = genericFont,
            size = 22,
            weight = 500,
            extended = true,
            antialias = true
        }
    )

    surface.CreateFont(
        "MAIN_Font32",
        {
            font = "Roboto Condensed",
            extended = false,
            size = 24,
            weight = 500,
            blursize = 0,
            scanlines = 0,
            antialias = true,
        }
    )

    surface.CreateFont(
        "MAIN_Font24",
        {
            font = "Roboto",
            extended = false,
            size = 24,
            weight = 0,
            blursize = 0,
            scanlines = 0,
            antialias = true,
        }
    )

    surface.CreateFont(
        "liaSmallChatFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17),
            extended = true,
            weight = 750
        }
    )

    surface.CreateFont(
        "liaItalicsChatFont",
        {
            font = font,
            size = math.max(ScreenScale(7), 17),
            extended = true,
            weight = 600,
            italic = true
        }
    )

    surface.CreateFont(
        "liaMediumChatFont",
        {
            font = font,
            size = math.max(ScreenScale(7), 17),
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaBigChatFont",
        {
            font = font,
            size = math.max(ScreenScale(8), 17),
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "lia3D2DFont",
        {
            font = font,
            size = 2048,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaTitleFont",
        {
            font = font,
            size = ScreenScale(30) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaSubTitleFont",
        {
            font = font,
            size = ScreenScale(18) * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaMenuButtonFont",
        {
            font = font,
            size = ScreenScale(14) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMenuButtonLightFont",
        {
            font = font,
            size = ScreenScale(14) * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaToolTipText",
        {
            font = font,
            size = 20,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaDynFontSmall",
        {
            font = font,
            size = ScreenScale(22) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaDynFontMedium",
        {
            font = font,
            size = ScreenScale(28) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaDynFontBig",
        {
            font = font,
            size = ScreenScale(48) * scale,
            extended = true,
            weight = 1000
        }
    )

    -- The more readable font.
    font = genericFont
    surface.CreateFont(
        "liaCleanTitleFont",
        {
            font = font,
            size = 200 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaHugeFont",
        {
            font = font,
            size = 72 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaBigFont",
        {
            font = font,
            size = 36 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMediumFont",
        {
            font = font,
            size = 25 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMediumLightFont",
        {
            font = font,
            size = 25 * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaGenericFont",
        {
            font = font,
            size = 20 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaGenericLightFont",
        {
            font = font,
            size = 20 * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaChatFont",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaChatFontItalics",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 200,
            italic = true
        }
    )

    surface.CreateFont(
        "liaChatFontBold",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 800,
        }
    )

    surface.CreateFont(
        "liaSmallFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17) * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaItemDescFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17) * scale,
            extended = true,
            shadow = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaSmallBoldFont",
        {
            font = font,
            size = math.max(ScreenScale(8), 20) * scale,
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaItemBoldFont",
        {
            font = font,
            shadow = true,
            size = math.max(ScreenScale(8), 20) * scale,
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaIconsSmall",
        {
            font = "fontello",
            size = 22,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsMedium",
        {
            font = "fontello",
            extended = true,
            size = 28,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsBig",
        {
            font = "fontello",
            extended = true,
            size = 48,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsSmallNew",
        {
            font = "nsicons",
            size = 22,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsMediumNew",
        {
            font = "nsicons",
            extended = true,
            size = 28,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsBigNew",
        {
            font = "nsicons",
            extended = true,
            size = 48,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaNoticeFont",
        {
            font = genericFont,
            size = 22,
            weight = 500,
            extended = true,
            antialias = true
        }
    )

    surface.CreateFont(
        "lia3D2DFont",
        {
            font = font,
            size = 2048,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaTitleFont",
        {
            font = font,
            size = ScreenScale(30) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaSubTitleFont",
        {
            font = font,
            size = ScreenScale(18) * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaMenuButtonFont",
        {
            font = font,
            size = ScreenScale(14) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMenuButtonLightFont",
        {
            font = font,
            size = ScreenScale(14) * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaToolTipText",
        {
            font = font,
            size = 20,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaDynFontSmall",
        {
            font = font,
            size = ScreenScale(22) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaDynFontMedium",
        {
            font = font,
            size = ScreenScale(28) * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaDynFontBig",
        {
            font = font,
            size = ScreenScale(48) * scale,
            extended = true,
            weight = 1000
        }
    )

    -- The more readable font.
    font = genericFont
    surface.CreateFont(
        "liaCleanTitleFont",
        {
            font = font,
            size = 200 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaHugeFont",
        {
            font = font,
            size = 72 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaBigFont",
        {
            font = font,
            size = 36 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMediumFont",
        {
            font = font,
            size = 25 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMediumLightFont",
        {
            font = font,
            size = 25 * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaGenericFont",
        {
            font = font,
            size = 20 * scale,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaGenericLightFont",
        {
            font = font,
            size = 20 * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaChatFont",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaChatFontItalics",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 200,
            italic = true
        }
    )

    surface.CreateFont(
        "liaChatFontBold",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * scale,
            extended = true,
            weight = 800,
        }
    )

    surface.CreateFont(
        "liaSmallFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17) * scale,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaItemDescFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17) * scale,
            extended = true,
            shadow = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaSmallBoldFont",
        {
            font = font,
            size = math.max(ScreenScale(8), 20) * scale,
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaItemBoldFont",
        {
            font = font,
            shadow = true,
            size = math.max(ScreenScale(8), 20) * scale,
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaIconsSmall",
        {
            font = "fontello",
            size = 22,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsMedium",
        {
            font = "fontello",
            extended = true,
            size = 28,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsBig",
        {
            font = "fontello",
            extended = true,
            size = 48,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsSmallNew",
        {
            font = "nsicons",
            size = 22,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsMediumNew",
        {
            font = "nsicons",
            extended = true,
            size = 28,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsBigNew",
        {
            font = "nsicons",
            extended = true,
            size = 48,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaNoticeFont",
        {
            font = genericFont,
            size = 22,
            weight = 500,
            extended = true,
            antialias = true
        }
    )

    surface.CreateFont(
        "lia3D2DFont",
        {
            font = font,
            size = 128,
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "lia3D2DMediumFont",
        {
            font = font,
            size = 48,
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "lia3D2DSmallFont",
        {
            font = font,
            size = 24,
            extended = true,
            weight = 400
        }
    )

    surface.CreateFont(
        "liaTitleFont",
        {
            font = font,
            size = ScreenScale(30),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaSubTitleFont",
        {
            font = font,
            size = ScreenScale(16),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaMenuMiniFont",
        {
            font = "Roboto",
            size = math.max(ScreenScale(4), 18),
            weight = 300,
        }
    )

    surface.CreateFont(
        "liaMenuButtonFont",
        {
            font = "Roboto Th",
            size = ScreenScale(14),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaMenuButtonFontSmall",
        {
            font = "Roboto Th",
            size = ScreenScale(10),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaMenuButtonFontThick",
        {
            font = "Roboto",
            size = ScreenScale(14),
            extended = true,
            weight = 300
        }
    )

    surface.CreateFont(
        "liaMenuButtonLabelFont",
        {
            font = "Roboto Th",
            size = 28,
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaMenuButtonHugeFont",
        {
            font = "Roboto Th",
            size = ScreenScale(24),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaToolTipText",
        {
            font = font,
            size = 20,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaMonoSmallFont",
        {
            font = "Consolas",
            size = 12,
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaMonoMediumFont",
        {
            font = "Consolas",
            size = 22,
            extended = true,
            weight = 800
        }
    )

    -- The more readable font.
    font = genericFont
    surface.CreateFont(
        "liaBigFont",
        {
            font = font,
            size = 36,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaMediumFont",
        {
            font = font,
            size = 25,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaNoticeFont",
        {
            font = font,
            size = math.max(ScreenScale(8), 18),
            weight = 100,
            extended = true,
            antialias = true
        }
    )

    surface.CreateFont(
        "liaMediumLightFont",
        {
            font = font,
            size = 25,
            extended = true,
            weight = 200
        }
    )

    surface.CreateFont(
        "liaMediumLightBlurFont",
        {
            font = font,
            size = 25,
            extended = true,
            weight = 200,
            blursize = 4
        }
    )

    surface.CreateFont(
        "liaGenericFont",
        {
            font = font,
            size = 20,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaChatFont",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * 1,
            extended = true,
            weight = 600,
            antialias = true
        }
    )

    surface.CreateFont(
        "liaChatFontItalics",
        {
            font = font,
            size = math.max(ScreenScale(7), 17) * 1,
            extended = true,
            weight = 600,
            antialias = true,
            italic = true
        }
    )

    surface.CreateFont(
        "liaSmallTitleFont",
        {
            font = "Roboto Th",
            size = math.max(ScreenScale(12), 24),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaMinimalTitleFont",
        {
            font = "Roboto",
            size = math.max(ScreenScale(8), 22),
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaSmallFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17),
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaItemDescFont",
        {
            font = font,
            size = math.max(ScreenScale(6), 17),
            extended = true,
            shadow = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaSmallBoldFont",
        {
            font = font,
            size = math.max(ScreenScale(8), 20),
            extended = true,
            weight = 800
        }
    )

    surface.CreateFont(
        "liaItemBoldFont",
        {
            font = font,
            shadow = true,
            size = math.max(ScreenScale(8), 20),
            extended = true,
            weight = 800
        }
    )

    -- Introduction fancy font.
    font = "Roboto Th"
    surface.CreateFont(
        "liaIntroTitleFont",
        {
            font = font,
            size = math.min(ScreenScale(128), 128),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaIntroTitleBlurFont",
        {
            font = font,
            size = math.min(ScreenScale(128), 128),
            extended = true,
            weight = 100,
            blursize = 4
        }
    )

    surface.CreateFont(
        "liaIntroSubtitleFont",
        {
            font = font,
            size = ScreenScale(24),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaIntroSmallFont",
        {
            font = font,
            size = ScreenScale(14),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaIconsSmall",
        {
            font = "fontello",
            size = 22,
            extended = true,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaSmallTitleIcons",
        {
            font = "fontello",
            size = math.max(ScreenScale(11), 23),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaIconsMedium",
        {
            font = "fontello",
            extended = true,
            size = 28,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIconsMenuButton",
        {
            font = "fontello",
            size = ScreenScale(14),
            extended = true,
            weight = 100
        }
    )

    surface.CreateFont(
        "liaIconsBig",
        {
            font = "fontello",
            extended = true,
            size = 48,
            weight = 500
        }
    )

    surface.CreateFont(
        "liaIntroTitleFont",
        {
            font = font,
            size = 200,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaIntroBigFont",
        {
            font = font,
            size = 48,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaIntroMediumFont",
        {
            font = font,
            size = 28,
            extended = true,
            weight = 1000
        }
    )

    surface.CreateFont(
        "liaIntroSmallFont",
        {
            font = font,
            size = 22,
            extended = true,
            weight = 1000
        }
    )

    hook.Run("LoadFonts", oldFont, oldGenericFont)
end
--------------------------------------------------------------------------------------------------------------------------