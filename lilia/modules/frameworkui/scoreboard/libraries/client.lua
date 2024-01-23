function ScoreboardCore:ScoreboardHide()
    if IsValid(lia.gui.menu) then lia.gui.menu:remove() end
    return true
end

function ScoreboardCore:ScoreboardShow()
    if LocalPlayer():getChar() then
        local liaMenu = vgui.Create("liaMenu")
        liaMenu:setActiveTab("scoreboard")
    end
    return true
end

function ScoreboardCore:OnReloaded()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
end

function ScoreboardCore:CreateMenuButtons(tabs)
    tabs["scoreboard"] = function(panel) panel:Add("liaScoreboard") end
end

function ScoreboardCore:ShowPlayerOptions(client, options)
    if CAMI.PlayerHasAccess(LocalPlayer(), "Staff Permissions - Can Access Scoreboard Info Out Of Staff") or (CAMI.PlayerHasAccess(LocalPlayer(), "Staff Permissions - Can Access Scoreboard Admin Options") and LocalPlayer():isStaffOnDuty()) then
        options["Player Profile"] = {"icon16/user.png", function() if IsValid(client) then client:ShowProfile() end end}
        options["Player Steam ID"] = {"icon16/user.png", function() if IsValid(client) then SetClipboardText(client:SteamID()) end end}
        options["Move To Player"] = {"icon16/wand.png", function() LocalPlayer():ConCommand("say !goto " .. client:SteamID()) end}
        options["Bring Player"] = {"icon16/arrow_down.png", function() if IsValid(client) then LocalPlayer():ConCommand("say !bring " .. client:SteamID()) end end}
        options["Return Player"] = {"icon16/arrow_down.png", function() if IsValid(client) then LocalPlayer():ConCommand("say !return " .. client:SteamID()) end end}
        options["Slay Player"] = {"icon16/arrow_down.png", function() if IsValid(client) then LocalPlayer():ConCommand("say !slay " .. client:SteamID()) end end}
        options["Respawn Player"] = {"icon16/arrow_down.png", function() if IsValid(client) then LocalPlayer():ConCommand("say !respawn " .. client:SteamID()) end end}
    end
end