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
end