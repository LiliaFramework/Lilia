--------------------------------------------------------------------------------------------------------------------------
local function ScreenScale(size)
    return size * (ScrH() / 900) + 10
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:LoadFonts(font)
    surface.CreateFont(
        "liaCharTitleFont",
        {
            font = font,
            weight = 200,
            size = ScreenScale(70),
            additive = true
        }
    )

    surface.CreateFont(
        "liaCharDescFont",
        {
            font = font,
            weight = 200,
            size = ScreenScale(24),
            additive = true
        }
    )

    surface.CreateFont(
        "liaCharSubTitleFont",
        {
            font = font,
            weight = 200,
            size = ScreenScale(12),
            additive = true
        }
    )

    surface.CreateFont(
        "liaCharButtonFont",
        {
            font = font,
            weight = 200,
            size = ScreenScale(24),
            additive = true
        }
    )

    surface.CreateFont(
        "liaCharSmallButtonFont",
        {
            font = font,
            weight = 200,
            size = ScreenScale(22),
            additive = true
        }
    )
end
--------------------------------------------------------------------------------------------------------------------------
