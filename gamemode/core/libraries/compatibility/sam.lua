hook.Remove("PostGamemodeLoaded", "SAM.DarkRP")
hook.Add("RunAdminSystemCommand", "liaSam", function(cmd, _, victim, dur, reason)
    local id = isstring(victim) and victim or IsValid(victim) and victim:SteamID()
    if not id then return end
    if cmd == "kick" then
        RunConsoleCommand("sam", "kick", id, reason or "")
        return true
    elseif cmd == "ban" then
        RunConsoleCommand("sam", "ban", id, tostring(dur or 0), reason or "")
        return true
    elseif cmd == "unban" then
        RunConsoleCommand("sam", "unban", id)
        return true
    elseif cmd == "mute" then
        RunConsoleCommand("sam", "mute", id, tostring(dur or 0), reason or "")
        return true
    elseif cmd == "unmute" then
        RunConsoleCommand("sam", "unmute", id)
        return true
    elseif cmd == "gag" then
        RunConsoleCommand("sam", "gag", id, tostring(dur or 0), reason or "")
        return true
    elseif cmd == "ungag" then
        RunConsoleCommand("sam", "ungag", id)
        return true
    elseif cmd == "freeze" then
        RunConsoleCommand("sam", "freeze", id, tostring(dur or 0))
        return true
    elseif cmd == "unfreeze" then
        RunConsoleCommand("sam", "unfreeze", id)
        return true
    elseif cmd == "slay" then
        RunConsoleCommand("sam", "slay", id)
        return true
    elseif cmd == "bring" then
        RunConsoleCommand("sam", "bring", id)
        return true
    elseif cmd == "goto" then
        RunConsoleCommand("sam", "goto", id)
        return true
    elseif cmd == "return" then
        RunConsoleCommand("sam", "return", id)
        return true
    elseif cmd == "jail" then
        RunConsoleCommand("sam", "jail", id, tostring(dur or 0))
        return true
    elseif cmd == "unjail" then
        RunConsoleCommand("sam", "unjail", id)
        return true
    elseif cmd == "cloak" then
        RunConsoleCommand("sam", "cloak", id)
        return true
    elseif cmd == "uncloak" then
        RunConsoleCommand("sam", "uncloak", id)
        return true
    elseif cmd == "god" then
        RunConsoleCommand("sam", "god", id)
        return true
    elseif cmd == "ungod" then
        RunConsoleCommand("sam", "ungod", id)
        return true
    elseif cmd == "ignite" then
        RunConsoleCommand("sam", "ignite", id, tostring(dur or 0))
        return true
    elseif cmd == "extinguish" or cmd == "unignite" then
        RunConsoleCommand("sam", "extinguish", id)
        return true
    elseif cmd == "strip" then
        RunConsoleCommand("sam", "strip", id)
        return true
    end
end)
hook.Add("SAM.CanRunCommand", "liaSAM", function(client, _, _, cmd)
    if type(client) ~= "Player" then return true end
    if lia.config.get("SAMEnforceStaff", false) then
        if cmd.permission and not client:HasPermission(cmd.permission) then
            client:notifyErrorLocalized("staffPermissionDenied")
            return false
        end
        if client:hasPrivilege("canBypassSAMFactionWhitelist") or client:isStaffOnDuty() then
            return true
        else
            client:notifyErrorLocalized("staffRestrictedCommand")
            return false
        end
    end
end)
if SERVER then
    sam.command.new("blind"):SetPermission("blind", "superadmin"):AddArg("player"):Help(L("blindCommandHelp")):OnExecute(function(client, targets)
        for i = 1, #targets do
            local target = targets[i]
            net.Start("blindTarget")
            net.WriteBool(true)
            net.Send(target)
        end
        if not sam.is_command_silent then
            client:sam_send_message(L("samBlindedTargets"), {
                A = client,
                T = targets
            })
        end
    end):End()
    sam.command.new("unblind"):SetPermission("blind", "superadmin"):AddArg("player"):Help(L("unblindCommandHelp")):OnExecute(function(client, targets)
        for i = 1, #targets do
            local target = targets[i]
            net.Start("blindTarget")
            net.WriteBool(false)
            net.Send(target)
        end
        if not sam.is_command_silent then
            client:sam_send_message(L("samUnblindedTargets"), {
                A = client,
                T = targets
            })
        end
    end):End()
    hook.Add("InitializedModules", "SAM_InitializedModules", function() hook.Remove("PlayerSay", "SAM.Chat.Asay") end)
end
local function CanReadNotifications(client)
    if not lia.config.get("AdminOnlyNotification", true) then return true end
    return client:hasPrivilege("canSeeSAMNotificationsOutsideStaff") or client:isStaffOnDuty()
end
function sam.player.send_message(client, msg, tbl)
    if SERVER then
        if sam.isconsole(client) then
            local result = sam.format_message(msg, tbl)
            sam.print(unpack(result, 1, result.__cnt))
        else
            return sam.netstream.Start(client, "send_message", msg, tbl)
        end
    else
        if not CanReadNotifications(LocalPlayer()) then return end
        local prefix_result = sam.format_message(sam.config.get("ChatPrefix", ""))
        local prefix_n = #prefix_result
        local result = sam.format_message(msg, tbl, prefix_result, prefix_n)
        chat.AddText(unpack(result, 1, result.__cnt))
    end
end
hook.Add("SAM.RankPermissionGiven", "liaSAMHandlePermissionGiven", function(rankName, permission)
    if not rankName or not permission then return end
    if CAMI and not CAMI.GetPrivilege(permission) then
        CAMI.RegisterPrivilege({
            Name = permission,
            MinAccess = "admin"
        })
    end
    if SERVER then lia.administrator.addPermission(rankName, permission, true) end
end)
hook.Add("SAM.RankPermissionTaken", "liaSAMHandlePermissionTaken", function(rankName, permission)
    if not rankName or not permission then return end
    if SERVER then lia.administrator.removePermission(rankName, permission, true) end
end)
lia.command.add("cleardecals", {
    adminOnly = true,
    desc = "cleardecalsDesc",
    onRun = function()
        for _, v in player.Iterator() do
            v:ConCommand("r_cleardecals")
        end
    end
})
lia.config.add("AdminOnlyNotification", "adminOnlyNotifications", true, nil, {
    desc = "adminOnlyNotificationsDesc",
    category = "categorySAM",
    type = "Boolean"
})
lia.config.add("SAMEnforceStaff", "samEnforceStaff", true, nil, {
    desc = "samEnforceStaffDesc",
    category = "categorySAM",
    type = "Boolean"
})
sam.config.set("Restrictions.Tool", false)
sam.config.set("Restrictions.Spawning", false)
sam.config.set("Restrictions.Limits", false)
hook.Add("getPlayTime", "liaSAM", function(client) return client:sam_get_play_time() end)
