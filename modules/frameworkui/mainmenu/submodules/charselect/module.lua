MODULE.name = "Main Menu Derma Panels"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.desc = "The Main Menu Derma Panels."
lia.util.includeDir(MODULE.path .. "/derma/steps", true)
if CLIENT then
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