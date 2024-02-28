---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:ScoreboardHide()
    if IsValid(lia.gui.menu) then lia.gui.menu:remove() end
    return true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:ScoreboardShow()
    if LocalPlayer():getChar() and (PIM and not PIM:CheckPossibilities()) then
        local liaMenu = vgui.Create("liaMenu")
        liaMenu:setActiveTab("Scoreboard")
        return true
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:OnReloaded()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:CreateMenuButtons(tabs)
    tabs["Scoreboard"] = function(panel) panel:Add("liaScoreboard") end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:ShowPlayerOptions(client, options)
    if CAMI.PlayerHasAccess(LocalPlayer(), "Staff Permissions - Can Access Scoreboard Info Out Of Staff") or (CAMI.PlayerHasAccess(LocalPlayer(), "Staff Permissions - Can Access Scoreboard Admin Options") and LocalPlayer():isStaffOnDuty()) then
        for text, info in pairs(self.PlayerOptions) do
            options[text] = {info.icon, function() if IsValid(client) then info.command(client) end end}
        end
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
