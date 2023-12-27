--------------------------------------------------------------------------------------------------------------------------
function VendorCore:LoadFonts(font)
    surface.CreateFont(
        "liaVendorButtonFont",
        {
            font = font,
            weight = 200,
            size = 40
        }
    )

    surface.CreateFont(
        "liaVendorSmallFont",
        {
            font = font,
            weight = 500,
            size = 22
        }
    )

    surface.CreateFont(
        "liaVendorLightFont",
        {
            font = font,
            weight = 200,
            size = 22
        }
    )
end
--------------------------------------------------------------------------------------------------------------------------
