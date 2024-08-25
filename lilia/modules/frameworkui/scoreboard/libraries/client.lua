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
end

function MODULE:OnReloaded()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
end

function MODULE:ShouldShowPlayerOnScoreboard(client)
    local faction = lia.faction.indices[client:Team()]
    if faction and faction.ScoreboardHidden then return false end
end

function MODULE:ShowPlayerOptions(target, options)
    local client = LocalPlayer()
    if client:HasPrivilege("Staff Permissions - Can Access Scoreboard Info Out Of Staff") or (client:HasPrivilege("Staff Permissions - Can Access Scoreboard Admin Options") and client:isStaffOnDuty()) and IsValid(target) then
        options["Player Profile"] = {"icon16/user.png", function() target:ShowProfile() end}
        options["Player Steam ID"] = {"icon16/user.png", function() SetClipboardText(target:SteamID()) end}
        options["Move To Player"] = {"icon16/user.png", function() client:ConCommand("say !goto " .. target:SteamID()) end}
        options["Bring Player"] = {"icon16/user.png", function() client:ConCommand("say !bring " .. target:SteamID()) end}
        options["Return Player"] = {"icon16/user.png", function() client:ConCommand("say !return " .. target:SteamID()) end}
        options["Slay Player"] = {"icon16/user.png", function() client:ConCommand("say !slay " .. target:SteamID()) end}
        options["Respawn Player"] = {"icon16/user.png", function() client:ConCommand("say !respawn " .. target:SteamID()) end}
        options["Change Name"] = {"icon16/user.png", function() client:ConCommand("say /charsetname " .. target:SteamID()) end}
        options["Change Description"] = {"icon16/user.png", function() client:ConCommand("say /charsetdesc " .. target:SteamID()) end}
        options["Change Model"] = {"icon16/user.png", function() OpenPlayerModelUI(target) end}
        options["Check Flags"] = {"icon16/user.png", function() client:ConCommand("say /flaglist " .. target:SteamID()) end}
    end
end