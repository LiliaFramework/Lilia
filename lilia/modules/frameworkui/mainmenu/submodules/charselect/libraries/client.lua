---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function CharacterSelectionCore:LiliaLoaded()
    vgui.Create("liaCharacter")
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function CharacterSelectionCore:KickedFromCharacter(_, isCurrentChar)
    if isCurrentChar then vgui.Create("liaCharacter") end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function CharacterSelectionCore:CreateMenuButtons(tabs)
    tabs["characters"] = function(_)
        if IsValid(lia.gui.menu) then lia.gui.menu:Remove() end
        if self.KickOnEnteringMainMenu then netstream.Start("liaCharKickSelf") end
        vgui.Create("liaCharacter")
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
