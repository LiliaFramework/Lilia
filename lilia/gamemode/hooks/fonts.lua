local GM = GM or GAMEMODE
function GM:LoadLiliaFonts(font, genericFont)
    local oldFont, oldGenericFont = font, genericFont
    local scale = math.Round(1, 2)
    surface.CreateFont("DarkSkinSmall", {
        font = "Roboto",
        size = 14,
        weight = 400
    })

    surface.CreateFont("DarkSkinRegular", {
        font = "Roboto",
        size = 18,
        weight = 400
    })

    surface.CreateFont("DarkSkinMedium", {
        font = "Roboto",
        size = 24,
        weight = 400
    })

    surface.CreateFont("DarkSkinLarge", {
        font = "Roboto",
        size = 32,
        weight = 400
    })

    surface.CreateFont("DarkSkinHuge", {
        font = "Roboto",
        size = 56,
        weight = 400
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
        size = ScreenScale(14),
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

    surface.CreateFont("liaCleanTitleFont", {
        font = genericFont,
        size = 200 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaHugeFont", {
        font = genericFont,
        size = 72 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaBigFont", {
        font = genericFont,
        size = 36 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumFont", {
        font = genericFont,
        size = 25 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaMediumLightFont", {
        font = genericFont,
        size = 25 * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaGenericFont", {
        font = genericFont,
        size = 20 * scale,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaGenericLightFont", {
        font = genericFont,
        size = 20 * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaChatFont", {
        font = genericFont,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200
    })

    surface.CreateFont("liaChatFontItalics", {
        font = genericFont,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 200,
        italic = true
    })

    surface.CreateFont("liaChatFontBold", {
        font = genericFont,
        size = math.max(ScreenScale(7), 17) * scale,
        extended = true,
        weight = 800,
    })

    surface.CreateFont("liaSmallFont", {
        font = genericFont,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaItemDescFont", {
        font = genericFont,
        size = math.max(ScreenScale(6), 17) * scale,
        extended = true,
        shadow = true,
        weight = 500
    })

    surface.CreateFont("liaSmallBoldFont", {
        font = genericFont,
        size = math.max(ScreenScale(8), 20) * scale,
        extended = true,
        weight = 800
    })

    surface.CreateFont("liaItemBoldFont", {
        font = genericFont,
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
        font = "liaicons",
        size = 22,
        extended = true,
        weight = 500
    })

    surface.CreateFont("liaIconsMediumNew", {
        font = "liaicons",
        extended = true,
        size = 28,
        weight = 500
    })

    surface.CreateFont("liaIconsBigNew", {
        font = "liaicons",
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

    surface.CreateFont("roboto", {
        font = "Roboto Bold",
        extended = false,
        size = 25,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("roboton", {
        font = "Roboto",
        extended = false,
        size = 19,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("robotoBig", {
        font = "Roboto Bold",
        extended = false,
        size = 36,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("robotoBig2", {
        font = "Roboto Bold",
        extended = false,
        size = 150,
        weight = 0,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })

    surface.CreateFont("liaCharTitleFont", {
        font = font,
        weight = 200,
        size = 70 * (ScrH() / 900) + 10,
        additive = true
    })

    surface.CreateFont("liaCharDescFont", {
        font = font,
        weight = 200,
        size = 24 * (ScrH() / 900) + 10,
        additive = true
    })

    surface.CreateFont("liaCharSubTitleFont", {
        font = font,
        weight = 200,
        size = 12 * (ScrH() / 900) + 10,
        additive = true
    })

    surface.CreateFont("liaCharButtonFont", {
        font = font,
        weight = 200,
        size = 24 * (ScrH() / 900) + 10,
        additive = true
    })

    surface.CreateFont("liaCharSmallButtonFont", {
        font = font,
        weight = 200,
        size = 22 * (ScrH() / 900) + 10,
        additive = true
    })

    hook.Run("LoadFonts", oldFont, oldGenericFont)
end
