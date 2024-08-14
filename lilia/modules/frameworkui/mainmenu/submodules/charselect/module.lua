MODULE.name = "Main Menu - Character Selection"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "Stock"
MODULE.desc = "Adds the derma for the characters options."
lia.includeDir(MODULE.path .. "/derma/steps", true)
if CLIENT then
    function MODULE:LiliaLoaded()
        print("LOADED")
        vgui.Create("liaCharacter")
    end

    function MODULE:KickedFromChar(_, isCurrentChar)
        if isCurrentChar then vgui.Create("liaCharacter") end
    end

    function MODULE:CreateMenuButtons(tabs)
        tabs["characters"] = function()
            if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
            if F1MenuCore.KickOnEnteringMainMenu then netstream.Start("liaCharKickSelf") end
            vgui.Create("liaCharacter")
        end
    end
end