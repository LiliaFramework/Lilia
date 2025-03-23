function MODULE:ScoreboardHide()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
    gui.EnableScreenClicker(false)
    return true
end

function MODULE:ScoreboardShow()
    local client = LocalPlayer()
    if client:getChar() and (PIM and not PIM:CheckPossibilities()) then
        vgui.Create("liaScoreboard")
        gui.EnableScreenClicker(true)
        return true
    end
    return true
end

function MODULE:OnReloaded()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
end

function MODULE:ShouldShowPlayerOnScoreboard(client)
    local faction = lia.faction.indices[client:Team()]
    if faction and faction.ScoreboardHidden then return false end
end
