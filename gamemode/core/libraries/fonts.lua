lia.font = lia.font or {
    stored = {}
}

function lia.font.register(fontName, fontData)
    if not fontName or not fontData then return lia.error("[Font] Invalid font name or data provided.") end
    surface.CreateFont(fontName, fontData)
    lia.font.stored[fontName] = fontData
end

lia.font.register("ConfigFont", {
    font = lia.config.get("Font"),
    size = 26,
    weight = 500,
    extended = true,
    antialias = true
})

lia.font.register("MediumConfigFont", {
    font = lia.config.get("Font"),
    size = 30,
    weight = 1000,
    extended = true,
    antialias = true
})

lia.font.register("SmallConfigFont", {
    font = lia.config.get("Font"),
    size = math.max(ScreenScale(8), 20),
    weight = 500,
    extended = true,
    antialias = true
})

lia.font.register("ConfigFontBold", {
    font = lia.config.get("Font"),
    size = 26,
    weight = 1000,
    extended = true,
    antialias = true
})

lia.font.register("ConfigFontLarge", {
    font = lia.config.get("Font"),
    size = 36,
    weight = 700,
    extended = true,
    antialias = true
})

lia.font.register("DescriptionFontLarge", {
    font = lia.config.get("Font"),
    size = 24,
    weight = 500,
    extended = true,
    antialias = true
})

lia.font.register("ticketsystem", {
    font = lia.config.get("Font"),
    size = 15,
    weight = 400
})

lia.font.register("VendorButtonFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = 40
})

lia.font.register("VendorMediumFont", {
    font = lia.config.get("Font"),
    weight = 500,
    size = 22
})

lia.font.register("VendorSmallFont", {
    font = lia.config.get("Font"),
    weight = 500,
    size = 22
})

lia.font.register("VendorTinyFont", {
    font = lia.config.get("Font"),
    weight = 500,
    size = 15
})

lia.font.register("VendorLightFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = 22
})

lia.font.register("VendorItemNameFont", {
    font = lia.config.get("Font"),
    size = 24,
    weight = 700,
})

lia.font.register("VendorItemDescFont", {
    font = lia.config.get("Font"),
    size = 18,
    weight = 500,
})

lia.font.register("VendorItemStatsFont", {
    font = lia.config.get("Font"),
    size = 16,
    weight = 500,
})

lia.font.register("VendorItemPriceFont", {
    font = lia.config.get("Font"),
    size = 20,
    weight = 600,
})

lia.font.register("VendorActionButtonFont", {
    font = lia.config.get("Font"),
    size = 18,
    weight = 600,
})

lia.font.register("liaCharTitleFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = ScreenScale(70),
    additive = true
})

lia.font.register("liaCharDescFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = ScreenScale(24),
    additive = true
})

lia.font.register("liaCharSubTitleFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = ScreenScale(12),
    additive = true
})

lia.font.register("liaCharButtonFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = ScreenScale(24),
    additive = true
})

lia.font.register("liaCharSmallButtonFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = ScreenScale(22),
    additive = true
})

local scale = math.Round(1, 2)
lia.font.register("liaCharLargeFont", {
    font = lia.config.get("GenericFont"),
    size = 36 * scale,
    extended = true,
    weight = 700,
    antialias = true
})

lia.font.register("liaCharMediumFont", {
    font = lia.config.get("GenericFont"),
    size = 28 * scale,
    extended = true,
    weight = 600,
    antialias = true
})

lia.font.register("liaCharSmallFont", {
    font = lia.config.get("GenericFont"),
    size = 20 * scale,
    extended = true,
    weight = 500,
    antialias = true
})

lia.font.register("liaCharSubTitleFont", {
    font = lia.config.get("GenericFont"),
    size = 16 * scale,
    extended = true,
    weight = 500,
    antialias = true
})

lia.font.register("DarkSkinSmall", {
    font = "Roboto",
    size = 14,
    weight = 400
})

lia.font.register("Roboto.20", {
    font = "Roboto",
    size = 20,
})

lia.font.register("Roboto.15", {
    font = "Roboto",
    size = 15,
})

lia.font.register("Roboto.22", {
    font = "Roboto",
    size = 22,
})

lia.font.register("DarkSkinRegular", {
    font = "Roboto",
    size = 18,
    weight = 400
})

lia.font.register("DarkSkinMedium", {
    font = "Roboto",
    size = 24,
    weight = 400
})

lia.font.register("DarkSkinLarge", {
    font = "Roboto",
    size = 32,
    weight = 400
})

lia.font.register("DarkSkinHuge", {
    font = "Roboto",
    size = 56,
    weight = 400
})

lia.font.register("lia3D2DFont", {
    font = lia.config.get("Font"),
    size = 2048,
    extended = true,
    weight = 1000
})

lia.font.register("liaTitleFont", {
    font = lia.config.get("Font"),
    size = ScreenScale(30) * scale,
    extended = true,
    weight = 1000
})

lia.font.register("liaSubTitleFont", {
    font = lia.config.get("Font"),
    size = ScreenScale(18) * scale,
    extended = true,
    weight = 500
})

lia.font.register("liaMenuButtonFont", {
    font = lia.config.get("Font"),
    size = ScreenScale(14),
    extended = true,
    weight = 1000
})

lia.font.register("liaMenuButtonLightFont", {
    font = lia.config.get("Font"),
    size = ScreenScale(14) * scale,
    extended = true,
    weight = 200
})

lia.font.register("liaToolTipText", {
    font = lia.config.get("Font"),
    size = 20,
    extended = true,
    weight = 500
})

lia.font.register("liaDynFontSmall", {
    font = lia.config.get("Font"),
    size = ScreenScale(22) * scale,
    extended = true,
    weight = 1000
})

lia.font.register("liaDynFontMedium", {
    font = lia.config.get("Font"),
    size = ScreenScale(28) * scale,
    extended = true,
    weight = 1000
})

lia.font.register("liaDynFontBig", {
    font = lia.config.get("Font"),
    size = ScreenScale(48) * scale,
    extended = true,
    weight = 1000
})

lia.font.register("liaCleanTitleFont", {
    font = lia.config.get("GenericFont"),
    size = 200 * scale,
    extended = true,
    weight = 1000
})

lia.font.register("liaHugeFont", {
    font = lia.config.get("GenericFont"),
    size = 72 * scale,
    extended = true,
    weight = 1000
})

lia.font.register("liaBigFont", {
    font = lia.config.get("GenericFont"),
    size = 36 * scale,
    extended = true,
    weight = 1000
})

lia.font.register("liaMediumFont", {
    font = lia.config.get("GenericFont"),
    size = 25 * scale,
    extended = true,
    weight = 1000
})

lia.font.register("liaMediumLightFont", {
    font = lia.config.get("GenericFont"),
    size = 25 * scale,
    extended = true,
    weight = 200
})

lia.font.register("liaGenericFont", {
    font = lia.config.get("GenericFont"),
    size = 20 * scale,
    extended = true,
    weight = 1000
})

lia.font.register("liaGenericLightFont", {
    font = lia.config.get("GenericFont"),
    size = 20 * scale,
    extended = true,
    weight = 500
})

lia.font.register("liaChatFont", {
    font = lia.config.get("GenericFont"),
    size = math.max(ScreenScale(7), 17) * scale,
    extended = true,
    weight = 200
})

lia.font.register("liaChatFontItalics", {
    font = lia.config.get("GenericFont"),
    size = math.max(ScreenScale(7), 17) * scale,
    extended = true,
    weight = 200,
    italic = true
})

lia.font.register("liaChatFontBold", {
    font = lia.config.get("GenericFont"),
    size = math.max(ScreenScale(7), 17) * scale,
    extended = true,
    weight = 800,
})

lia.font.register("liaMiniFont", {
    font = lia.config.get("GenericFont"),
    size = math.max(ScreenScale(5), 14) * scale,
    extended = true,
    weight = 400
})

lia.font.register("liaSmallFont", {
    font = lia.config.get("GenericFont"),
    size = math.max(ScreenScale(6), 17) * scale,
    extended = true,
    weight = 500
})

lia.font.register("liaItemDescFont", {
    font = lia.config.get("GenericFont"),
    size = math.max(ScreenScale(6), 17) * scale,
    extended = true,
    shadow = true,
    weight = 500
})

lia.font.register("liaSmallBoldFont", {
    font = lia.config.get("GenericFont"),
    size = math.max(ScreenScale(8), 20) * scale,
    extended = true,
    weight = 800
})

lia.font.register("liaItemBoldFont", {
    font = lia.config.get("GenericFont"),
    shadow = true,
    size = math.max(ScreenScale(8), 20) * scale,
    extended = true,
    weight = 800
})

lia.font.register("liaIconsSmall", {
    font = "fontello",
    size = 22,
    extended = true,
    weight = 500
})

lia.font.register("liaIconsMedium", {
    font = "fontello",
    extended = true,
    size = 28,
    weight = 500
})

lia.font.register("liaIconsBig", {
    font = "fontello",
    extended = true,
    size = 48,
    weight = 500
})

lia.font.register("liaIconsSmallNew", {
    font = "nsicons",
    size = 22,
    extended = true,
    weight = 500
})

lia.font.register("liaIconsMediumNew", {
    font = "nsicons",
    extended = true,
    size = 28,
    weight = 500
})

lia.font.register("liaIconsBigNew", {
    font = "nsicons",
    extended = true,
    size = 48,
    weight = 500
})

lia.font.register("liaIconsHugeNew", {
    font = "nsicons",
    extended = true,
    size = 78,
    weight = 500
})

lia.font.register("liaNoticeFont", {
    font = lia.config.get("GenericFont"),
    size = 22,
    weight = 500,
    extended = true,
    antialias = true
})

lia.font.register("roboto", {
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

lia.font.register("roboton", {
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

lia.font.register("robotoBig", {
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

lia.font.register("robotoBig2", {
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

lia.font.register("liaCharTitleFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = 70 * ScrH() / 900 + 10,
    additive = true
})

lia.font.register("liaCharDescFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = 24 * ScrH() / 900 + 10,
    additive = true
})

lia.font.register("liaCharSubTitleFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = 12 * ScrH() / 900 + 10,
    additive = true
})

lia.font.register("liaCharButtonFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = 24 * ScrH() / 900 + 10,
    additive = true
})

lia.font.register("liaCharSmallButtonFont", {
    font = lia.config.get("Font"),
    weight = 200,
    size = 22 * ScrH() / 900 + 10,
    additive = true
})

hook.Run("PostLoadFonts")