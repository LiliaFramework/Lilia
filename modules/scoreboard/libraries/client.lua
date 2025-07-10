function MODULE:ScoreboardHide()
    if IsValid(lia.gui.score) then
        lia.gui.score:SetVisible(false)
        CloseDermaMenus()
    end

    gui.EnableScreenClicker(false)
    return true
end

function MODULE:ScoreboardShow()
    local pimEnabled = lia.module.list.interactionmenu:checkInteractionPossibilities()
    if IsValid(lia.gui.score) then
        lia.gui.score:SetVisible(true)
    elseif not pimEnabled then
        vgui.Create("liaScoreboard")
    end

    gui.EnableScreenClicker(true)
    return true
end

function MODULE:OnReloaded()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
end

function MODULE:ShouldShowPlayerOnScoreboard(client)
    local faction = lia.faction.indices[client:Team()]
    if faction and faction.ScoreboardHidden then return false end
end
