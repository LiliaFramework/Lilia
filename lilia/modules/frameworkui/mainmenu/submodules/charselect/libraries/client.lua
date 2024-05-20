function MODULE:LiliaLoaded()
    vgui.Create("liaCharacter")
end

function MODULE:KickedFromChar(_, isCurrentChar)
    if isCurrentChar then vgui.Create("liaCharacter") end
end

function MODULE:CreateMenuButtons(tabs)
    tabs["characters"] = function(_)
        if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
        if self.KickOnEnteringMainMenu then netstream.Start("liaCharKickSelf") end
        vgui.Create("liaCharacter")
    end
end
