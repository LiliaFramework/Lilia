MODULE.name = "HUD"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "Stock"
MODULE.desc = "Implements Lilia HUD Elements."
if CLIENT then
    function MODULE:LoadFonts(font)
        surface.CreateFont("WB_Small", {
            font = font,
            size = 17
        })

        surface.CreateFont("WB_Medium", {
            font = font,
            size = 20
        })

        surface.CreateFont("WB_Large", {
            font = font,
            size = 24,
            weight = 800
        })

        surface.CreateFont("WB_XLarge", {
            font = font,
            size = 35,
            weight = 800
        })

        surface.CreateFont("WB_Enormous", {
            font = font,
            size = 54
        })

        surface.CreateFont("wolficon_enormous", {
            font = font,
            size = 50,
            weight = 400,
            antialias = true
        })

        surface.CreateFont("wolficon_big", {
            font = font,
            size = 34,
            weight = 400,
            antialias = true
        })

        surface.CreateFont("wolficon_normal", {
            font = font,
            size = 25,
            weight = 400,
            antialias = true
        })

        surface.CreateFont("wolficon_small", {
            font = font,
            size = 18,
            weight = 400,
            antialias = true
        })

        surface.CreateFont("FPSFont", {
            font = font,
            size = 27,
            weight = 500,
            antialias = true,
        })
    end

    lia.option.add("fpsDraw", "FPS Draw", "Enable FPS display on the HUD", false, nil, {
        category = "HUD",
    })

    lia.option.add("descriptionWidth", "Description Width", "Adjust the description width on the HUD", 0.5, nil, {
        category = "HUD",
        min = 0.1,
        max = 1,
        decimals = 2
    })
end