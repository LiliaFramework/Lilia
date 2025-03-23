MODULE.name = "Main Menu Derma Panels"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "The Main Menu Derma Panels."
lia.util.includeDir(MODULE.path .. "/derma/steps", true)
if CLIENT then
    local function ScreenScale(size)
        return size * (ScrH() / 900) + 10
    end

    function MODULE:LoadFonts(font)
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
    end

    function MODULE:LiliaLoaded()
        vgui.Create("liaCharacter")
    end

    function MODULE:KickedFromChar(_, isCurrentChar)
        if isCurrentChar then vgui.Create("liaCharacter") end
    end

    function MODULE:CreateMenuButtons(tabs)
        tabs["characters"] = function()
            if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
            vgui.Create("liaCharacter")
        end
    end
end
