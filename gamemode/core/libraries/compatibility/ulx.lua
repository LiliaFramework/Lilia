hook.Add("ULibGroupAccessChanged", "liaULXCAMI", function(group_name, access, revoke)
    if not group_name or not access then return end
    if not revoke then
        if CAMI and not CAMI.GetPrivilege(access) then
            CAMI.RegisterPrivilege({
                Name = access,
                MinAccess = "admin"
            })
        end

        if SERVER then lia.admin.addPermission(group_name, access, true) end
    else
        if SERVER then lia.admin.removePermission(group_name, access, true) end
    end
end)

local ulxCommands = {
    kick = function(id, _, reason) RunConsoleCommand("ulx", "kick", id, reason or "") end,
    ban = function(id, dur, reason) RunConsoleCommand("ulx", "banid", id, tostring(dur or 0), reason or "") end,
    unban = function(id) RunConsoleCommand("ulx", "unban", id) end,
    mute = function(id) RunConsoleCommand("ulx", "mute", id) end,
    unmute = function(id) RunConsoleCommand("ulx", "unmute", id) end,
    gag = function(id) RunConsoleCommand("ulx", "gag", id) end,
    ungag = function(id) RunConsoleCommand("ulx", "ungag", id) end,
    freeze = function(id) RunConsoleCommand("ulx", "freeze", id) end,
    unfreeze = function(id) RunConsoleCommand("ulx", "unfreeze", id) end,
    slay = function(id) RunConsoleCommand("ulx", "slay", id) end,
    bring = function(id) RunConsoleCommand("ulx", "bring", id) end,
    ["goto"] = function(id) RunConsoleCommand("ulx", "goto", id) end,
    ["return"] = function(id) RunConsoleCommand("ulx", "return", id) end,
    jail = function(id, dur) RunConsoleCommand("ulx", "jail", id, tostring(dur or 0)) end,
    unjail = function(id) RunConsoleCommand("ulx", "unjail", id) end,
    cloak = function(id) RunConsoleCommand("ulx", "cloak", id) end,
    uncloak = function(id) RunConsoleCommand("ulx", "uncloak", id) end,
    god = function(id) RunConsoleCommand("ulx", "god", id) end,
    ungod = function(id) RunConsoleCommand("ulx", "ungod", id) end,
    ignite = function(id) RunConsoleCommand("ulx", "ignite", id) end,
    extinguish = function(id) RunConsoleCommand("ulx", "unignite", id) end,
    unignite = function(id) RunConsoleCommand("ulx", "unignite", id) end,
    strip = function(id) RunConsoleCommand("ulx", "strip", id) end
}

hook.Add("RunAdminSystemCommand", "liaULX", function(cmd, admin, target, dur, reason)
    local id = isstring(target) and target or IsValid(target) and target:SteamID()
    if not id then return end
    local commandFunc = ulxCommands[cmd]
    if commandFunc then
        commandFunc(id, dur, reason)
        return true, function() end
    end
end)

hook.Add("OnSetUsergroup", "liaULXSetUserGroup", function(steamID, group)
    if not ULib then return end
    if not steamID or steamID == "" or not group or group == "" then return end
    RunConsoleCommand("ulx", "adduserid", steamID, group)
end)
