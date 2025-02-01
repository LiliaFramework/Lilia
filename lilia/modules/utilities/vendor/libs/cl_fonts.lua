function MODULE:LoadFonts(font)
    surface.CreateFont("VendorButtonFont", {
        font = font,
        weight = 200,
        size = 40
    })

    surface.CreateFont("VendorMediumFont", {
        font = font,
        weight = 500,
        size = 22
    })

    surface.CreateFont("VendorSmallFont", {
        font = font,
        weight = 500,
        size = 22
    })

    surface.CreateFont("VendorTinyFont", {
        font = font,
        weight = 500,
        size = 15
    })

    surface.CreateFont("VendorLightFont", {
        font = font,
        weight = 200,
        size = 22
    })

    surface.CreateFont("VendorItemNameFont", {
        font = font,
        size = 24,
        weight = 700,
    })

    surface.CreateFont("VendorItemDescFont", {
        font = font,
        size = 18,
        weight = 500,
    })

    surface.CreateFont("VendorItemStatsFont", {
        font = font,
        size = 16,
        weight = 500,
    })

    surface.CreateFont("VendorItemPriceFont", {
        font = font,
        size = 20,
        weight = 600,
    })

    surface.CreateFont("VendorActionButtonFont", {
        font = font,
        size = 18,
        weight = 600,
    })
end