function GM:LoadLiliaFonts(font, genericFont)
    local oldFont, oldGenericFont = font, genericFont
    local scale = math.Round(lia.config.FontScale, 2)

    surface.CreateFont("liaIntroTitleFont", {
        font = lia.config.IntroFont,
        size = 200,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaIntroBigFont", {
        font = lia.config.IntroFont,
        size = 48,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaIntroMediumFont", {
        font = lia.config.IntroFont,
        size = 28,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaIntroSmallFont", {
        font = lia.config.IntroFont,
        size = 22,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaVendorButtonFont", {
        font = font,
        weight = 200,
        size = 40
    })

    surface.CreateFont("liaVendorSmallFont", {
        font = font,
        weight = 500,
        size = 22
    })

    surface.CreateFont("liaVendorLightFont", {
        font = font,
        weight = 200,
        size = 22
    })

    surface.CreateFont("liaCharTitleFont", {
        font = font,
        weight = 200,
        size = ScreenScale(70),
        additive = true
    })

    surface.CreateFont("liaCharDescFont", {
        font = font,
        weight = 200,
        size = ScreenScale(24),
        additive = true
    })

    surface.CreateFont("liaCharSubTitleFont", {
        font = font,
        weight = 200,
        size = ScreenScale(12),
        additive = true
    })

    surface.CreateFont("liaCharButtonFont", {
        font = font,
        weight = 200,
        size = ScreenScale(24),
        additive = true
    })

    surface.CreateFont("liaCharSmallButtonFont", {
        font = font,
        weight = 200,
        size = ScreenScale(22),
        additive = true
    })

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

    hook.Run("LoadFonts", oldFont, oldGenericFont)
end