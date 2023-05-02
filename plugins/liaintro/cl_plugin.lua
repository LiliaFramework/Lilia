function PLUGIN:LoadFonts()
    -- Introduction fancy font.
    local font = lia.config.get("introFont", "Cambria")

    surface.CreateFont("liaIntroTitleFont", {
        font = font,
        size = 200,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaIntroBigFont", {
        font = font,
        size = 48,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaIntroMediumFont", {
        font = font,
        size = 28,
        extended = true,
        weight = 1000
    })

    surface.CreateFont("liaIntroSmallFont", {
        font = font,
        size = 22,
        extended = true,
        weight = 1000
    })
end

function PLUGIN:CreateIntroduction()
    if lia.config.get("introEnabled") then return vgui.Create("liaIntro") end
end