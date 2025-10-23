hook.Remove("PostGamemodeLoaded", "SAM.DarkRP")
local samCommands = {
    kick = function(id, _, reason) RunConsoleCommand("sam", "kick", id, reason or "") end,
    ban = function(id, dur, reason) RunConsoleCommand("sam", "ban", id, tostring(dur or 0), reason or "") end,
    unban = function(id) RunConsoleCommand("sam", "unban", id) end,
    mute = function(id, dur, reason) RunConsoleCommand("sam", "mute", id, tostring(dur or 0), reason or "") end,
    unmute = function(id) RunConsoleCommand("sam", "unmute", id) end,
    gag = function(id, dur, reason) RunConsoleCommand("sam", "gag", id, tostring(dur or 0), reason or "") end,
    ungag = function(id) RunConsoleCommand("sam", "ungag", id) end,
    freeze = function(id, dur) RunConsoleCommand("sam", "freeze", id, tostring(dur or 0)) end,
    unfreeze = function(id) RunConsoleCommand("sam", "unfreeze", id) end,
    slay = function(id) RunConsoleCommand("sam", "slay", id) end,
    bring = function(id) RunConsoleCommand("sam", "bring", id) end,
    ["goto"] = function(id) RunConsoleCommand("sam", "goto", id) end,
    ["return"] = function(id) RunConsoleCommand("sam", "return", id) end,
    jail = function(id, dur) RunConsoleCommand("sam", "jail", id, tostring(dur or 0)) end,
    unjail = function(id) RunConsoleCommand("sam", "unjail", id) end,
    cloak = function(id) RunConsoleCommand("sam", "cloak", id) end,
    uncloak = function(id) RunConsoleCommand("sam", "uncloak", id) end,
    god = function(id) RunConsoleCommand("sam", "god", id) end,
    ungod = function(id) RunConsoleCommand("sam", "ungod", id) end,
    ignite = function(id, dur) RunConsoleCommand("sam", "ignite", id, tostring(dur or 0)) end,
    extinguish = function(id) RunConsoleCommand("sam", "extinguish", id) end,
    unignite = function(id) RunConsoleCommand("sam", "extinguish", id) end,
    strip = function(id) RunConsoleCommand("sam", "strip", id) end
}

hook.Add("RunAdminSystemCommand", "liaSam", function(cmd, _, victim, dur, reason)
    local id = isstring(victim) and victim or IsValid(victim) and victim:SteamID()
    if not id then return end
    local commandFunc = samCommands[cmd]
    if commandFunc then
        commandFunc(id, dur, reason)
        return true, function() end
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
            net.Start("liaBlindTarget")
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
            net.Start("liaBlindTarget")
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
    if not IsValid(client) then return false end
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
hook.Add("GetPlayTime", "liaSAM", function(client) return client:sam_get_play_time() end)