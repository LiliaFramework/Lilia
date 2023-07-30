function GM:LoadLiliaFonts(font, genericFont)
    local oldFont, oldGenericFont = font, genericFont
    local scale = math.Round(lia.config.get("fontScale", 1), 2)

    surface.CreateFont("liaCrossIcons", {
        font = "nsicons",
        size = ScreenScale(11),
        extended = true,
    })

    surface.CreateFont("liaSmallChatFont", {
        font = font,
        size = math.max(ScreenScale(6), 17),
        extended = true,
        weight = 750
    })

    surface.CreateFont("liaItalicsChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17),
        extended = true,
        weight = 600,
        italic = true
    })

    surface.CreateFont("liaMediumChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17),
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaBigChatFont", {
        font = font,
        size = math.max(ScreenScale(8), 17),
        extended = true,
        weight = 200
    })

    surface.CreateFont("lia3D2DFont", {
        font = font,
        size = 2048,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaTitleFont", {
        font = font,
        size = ScreenScale(30) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaSubTitleFont", {
        font = font,
        size = ScreenScale(18) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaMenuButtonFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMenuButtonLightFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaToolTipText", {
        font = font,
        size = 20,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaDynFontSmall", {
        font = font,
        size = ScreenScale(22) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaDynFontMedium", {
        font = font,
        size = ScreenScale(28) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaDynFontBig", {
        font = font,
        size = ScreenScale(48) * scale,
        extended = true,
        weight = 1000
    })

    -- The more readable font.
    font = genericFont

    surface.CreateFont("liaCleanTitleFont", {
        font = font,
        size = 200 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaHugeFont", {
        font = font,
        size = 72 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaBigFont", {
        font = font,
        size = 36 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumLightFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaGenericFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaGenericLightFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaChatFontItalics", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200,
        italic = true
    })

    surface.CreateFont("liaChatFontBold", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 800,
    })

    surface.CreateFont("liaSmallFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaItemDescFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        shadow = true,
        weight = 500
    })

    surface.CreateFont("liaSmallBoldFont", {
        font = font,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("liaItemBoldFont", {
        font = font,
        shadow = true,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("liaIconsSmall", {
        font = "fontello",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaIconsMedium", {
        font = "fontello",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("liaIconsBig", {
        font = "fontello",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("liaIconsSmallNew", {
        font = "nsicons",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaIconsMediumNew", {
        font = "nsicons",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("liaIconsBigNew", {
        font = "nsicons",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("liaNoticeFont", {
        font = genericFont,
        size = 22,
        weight = 500,
        extended = true,
        antianuts = true
    })

    surface.CreateFont("lia3D2DFont", {
        font = font,
        size = 2048,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaTitleFont", {
        font = font,
        size = ScreenScale(30) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaSubTitleFont", {
        font = font,
        size = ScreenScale(18) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaMenuButtonFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMenuButtonLightFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaToolTipText", {
        font = font,
        size = 20,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaDynFontSmall", {
        font = font,
        size = ScreenScale(22) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaDynFontMedium", {
        font = font,
        size = ScreenScale(28) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaDynFontBig", {
        font = font,
        size = ScreenScale(48) * scale,
        extended = true,
        weight = 1000
    })

    -- The more readable font.
    font = genericFont

    surface.CreateFont("liaCleanTitleFont", {
        font = font,
        size = 200 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaHugeFont", {
        font = font,
        size = 72 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaBigFont", {
        font = font,
        size = 36 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumLightFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaGenericFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaGenericLightFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaChatFontItalics", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200,
        italic = true
    })

    surface.CreateFont("liaChatFontBold", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 800,
    })

    surface.CreateFont("liaSmallFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaItemDescFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        shadow = true,
        weight = 500
    })

    surface.CreateFont("liaSmallBoldFont", {
        font = font,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("liaItemBoldFont", {
        font = font,
        shadow = true,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("liaIconsSmall", {
        font = "fontello",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaIconsMedium", {
        font = "fontello",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("liaIconsBig", {
        font = "fontello",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("liaIconsSmallNew", {
        font = "nsicons",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaIconsMediumNew", {
        font = "nsicons",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("liaIconsBigNew", {
        font = "nsicons",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("liaNoticeFont", {
        font = genericFont,
        size = 22,
        weight = 500,
        extended = true,
        antialias = true
    })

    surface.CreateFont("MAIN_Font32", {
        font = "Roboto Condensed",
        extended = false,
        size = 24,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antianuts = true,
    })

    surface.CreateFont("MAIN_Font24", {
        font = "Roboto",
        extended = false,
        size = 24,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = true,
    })

    surface.CreateFont("nutSmallChatFont", {
        font = font,
        size = math.max(ScreenScale(6), 17),
        extended = true,
        weight = 750
    })

    surface.CreateFont("nutItalicsChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17),
        extended = true,
        weight = 600,
        italic = true
    })

    surface.CreateFont("nutMediumChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17),
        extended = true,
        weight = 200
    })

    surface.CreateFont("nutBigChatFont", {
        font = font,
        size = math.max(ScreenScale(8), 17),
        extended = true,
        weight = 200
    })

    surface.CreateFont("nut3D2DFont", {
        font = font,
        size = 2048,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutTitleFont", {
        font = font,
        size = ScreenScale(30) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutSubTitleFont", {
        font = font,
        size = ScreenScale(18) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutMenuButtonFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutMenuButtonLightFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("nutToolTipText", {
        font = font,
        size = 20,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutDynFontSmall", {
        font = font,
        size = ScreenScale(22) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutDynFontMedium", {
        font = font,
        size = ScreenScale(28) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutDynFontBig", {
        font = font,
        size = ScreenScale(48) * scale,
        extended = true,
        weight = 1000
    })

    -- The more readable font.
    font = genericFont

    surface.CreateFont("nutCleanTitleFont", {
        font = font,
        size = 200 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutHugeFont", {
        font = font,
        size = 72 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutBigFont", {
        font = font,
        size = 36 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutMediumFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutMediumLightFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("nutGenericFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutGenericLightFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("nutChatFontItalics", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200,
        italic = true
    })

    surface.CreateFont("nutChatFontBold", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 800,
    })

    surface.CreateFont("nutSmallFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutItemDescFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        shadow = true,
        weight = 500
    })

    surface.CreateFont("nutSmallBoldFont", {
        font = font,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("nutItemBoldFont", {
        font = font,
        shadow = true,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("nutIconsSmall", {
        font = "fontello",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutIconsMedium", {
        font = "fontello",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("nutIconsBig", {
        font = "fontello",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("nutIconsSmallNew", {
        font = "nsicons",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutIconsMediumNew", {
        font = "nsicons",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("nutIconsBigNew", {
        font = "nsicons",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("nutNoticeFont", {
        font = genericFont,
        size = 22,
        weight = 500,
        extended = true,
        antianuts = true
    })

    surface.CreateFont("nut3D2DFont", {
        font = font,
        size = 2048,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutTitleFont", {
        font = font,
        size = ScreenScale(30) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutSubTitleFont", {
        font = font,
        size = ScreenScale(18) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutMenuButtonFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutMenuButtonLightFont", {
        font = font,
        size = ScreenScale(14) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("nutToolTipText", {
        font = font,
        size = 20,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutDynFontSmall", {
        font = font,
        size = ScreenScale(22) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutDynFontMedium", {
        font = font,
        size = ScreenScale(28) * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutDynFontBig", {
        font = font,
        size = ScreenScale(48) * scale,
        extended = true,
        weight = 1000
    })

    -- The more readable font.
    font = genericFont

    surface.CreateFont("nutCleanTitleFont", {
        font = font,
        size = 200 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutHugeFont", {
        font = font,
        size = 72 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutBigFont", {
        font = font,
        size = 36 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutMediumFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutMediumLightFont", {
        font = font,
        size = 25 * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("nutGenericFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("nutGenericLightFont", {
        font = font,
        size = 20 * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("nutChatFontItalics", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200,
        italic = true
    })

    surface.CreateFont("nutChatFontBold", {
        font = font,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 800,
    })

    surface.CreateFont("nutSmallFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutItemDescFont", {
        font = font,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        shadow = true,
        weight = 500
    })

    surface.CreateFont("nutSmallBoldFont", {
        font = font,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("nutItemBoldFont", {
        font = font,
        shadow = true,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("nutIconsSmall", {
        font = "fontello",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutIconsMedium", {
        font = "fontello",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("nutIconsBig", {
        font = "fontello",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("nutIconsSmallNew", {
        font = "nsicons",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("nutIconsMediumNew", {
        font = "nsicons",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("nutIconsBigNew", {
        font = "nsicons",
        extended = true,
        size = 48,
        weight = 500
    })

    surface.CreateFont("nutNoticeFont", {
        font = genericFont,
        size = 22,
        weight = 500,
        extended = true,
        antialias = true
    })

    surface.CreateFont("ix3D2DFont", {
        font = font,
        size = 128,
        extended = true,
        weight = 100
    })

    surface.CreateFont("ix3D2DMediumFont", {
        font = font,
        size = 48,
        extended = true,
        weight = 100
    })

    surface.CreateFont("ix3D2DSmallFont", {
        font = font,
        size = 24,
        extended = true,
        weight = 400
    })

    surface.CreateFont("ixTitleFont", {
        font = font,
        size = ScreenScale(30),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixSubTitleFont", {
        font = font,
        size = ScreenScale(16),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixMenuMiniFont", {
        font = "Roboto",
        size = math.max(ScreenScale(4), 18),
        weight = 300,
    })

    surface.CreateFont("ixMenuButtonFont", {
        font = "Roboto Th",
        size = ScreenScale(14),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixMenuButtonFontSmall", {
        font = "Roboto Th",
        size = ScreenScale(10),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixMenuButtonFontThick", {
        font = "Roboto",
        size = ScreenScale(14),
        extended = true,
        weight = 300
    })

    surface.CreateFont("ixMenuButtonLabelFont", {
        font = "Roboto Th",
        size = 28,
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixMenuButtonHugeFont", {
        font = "Roboto Th",
        size = ScreenScale(24),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixToolTipText", {
        font = font,
        size = 20,
        extended = true,
        weight = 500
    })

    surface.CreateFont("ixMonoSmallFont", {
        font = "Consolas",
        size = 12,
        extended = true,
        weight = 800
    })

    surface.CreateFont("ixMonoMediumFont", {
        font = "Consolas",
        size = 22,
        extended = true,
        weight = 800
    })

    -- The more readable font.
    font = genericFont

    surface.CreateFont("ixBigFont", {
        font = font,
        size = 36,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("ixMediumFont", {
        font = font,
        size = 25,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("ixNoticeFont", {
        font = font,
        size = math.max(ScreenScale(8), 18),
        weight = 100,
        extended = true,
        antialias = true
    })

    surface.CreateFont("ixMediumLightFont", {
        font = font,
        size = 25,
        extended = true,
        weight = 200
    })

    surface.CreateFont("ixMediumLightBlurFont", {
        font = font,
        size = 25,
        extended = true,
        weight = 200,
        blursize = 4
    })

    surface.CreateFont("ixGenericFont", {
        font = font,
        size = 20,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("ixChatFont", {
        font = font,
        size = math.max(ScreenScale(7), 17) * 1,
        extended = true,
        weight = 600,
        antialias = true
    })

    surface.CreateFont("ixChatFontItalics", {
        font = font,
        size = math.max(ScreenScale(7), 17) * 1,
        extended = true,
        weight = 600,
        antialias = true,
        italic = true
    })

    surface.CreateFont("ixSmallTitleFont", {
        font = "Roboto Th",
        size = math.max(ScreenScale(12), 24),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixMinimalTitleFont", {
        font = "Roboto",
        size = math.max(ScreenScale(8), 22),
        extended = true,
        weight = 800
    })

    surface.CreateFont("ixSmallFont", {
        font = font,
        size = math.max(ScreenScale(6), 17),
        extended = true,
        weight = 500
    })

    surface.CreateFont("ixItemDescFont", {
        font = font,
        size = math.max(ScreenScale(6), 17),
        extended = true,
        shadow = true,
        weight = 500
    })

    surface.CreateFont("ixSmallBoldFont", {
        font = font,
        size = math.max(ScreenScale(8), 20),
        extended = true,
        weight = 800
    })

    surface.CreateFont("ixItemBoldFont", {
        font = font,
        shadow = true,
        size = math.max(ScreenScale(8), 20),
        extended = true,
        weight = 800
    })

    -- Introduction fancy font.
    font = "Roboto Th"

    surface.CreateFont("ixIntroTitleFont", {
        font = font,
        size = math.min(ScreenScale(128), 128),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixIntroTitleBlurFont", {
        font = font,
        size = math.min(ScreenScale(128), 128),
        extended = true,
        weight = 100,
        blursize = 4
    })

    surface.CreateFont("ixIntroSubtitleFont", {
        font = font,
        size = ScreenScale(24),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixIntroSmallFont", {
        font = font,
        size = ScreenScale(14),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixIconsSmall", {
        font = "fontello",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("ixSmallTitleIcons", {
        font = "fontello",
        size = math.max(ScreenScale(11), 23),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixIconsMedium", {
        font = "fontello",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("ixIconsMenuButton", {
        font = "fontello",
        size = ScreenScale(14),
        extended = true,
        weight = 100
    })

    surface.CreateFont("ixIconsBig", {
        font = "fontello",
        extended = true,
        size = 48,
        weight = 500
    })

    hook.Run("LoadFonts", oldFont, oldGenericFont)
end