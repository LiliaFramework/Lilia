CAMI.ULX_TOKEN = "ULX"
hook.Remove("CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess")
hook.Remove("CAMI.SteamIDHasAccess", "ULXCamiSteamidHasAccess")
hook.Remove("CAMI.OnUsergroupRegistered", "ULXCamiGroupRegistered")
hook.Remove("CAMI.OnUsergroupUnregistered", "ULXCamiGroupRemoved")
hook.Remove("CAMI.SteamIDUsergroupChanged", "ULXCamiSteamidUserGroupChanged")
hook.Remove("CAMI.PlayerUsergroupChanged", "ULXCamiPlayerUserGroupChanged")
hook.Remove("CAMI.OnPrivilegeRegistered", "ULXCamiPrivilegeRegistered")
local function playerHasAccess(_, ply, perm, cb)
    local ok = ULib.ucl.query(ply, perm:lower(), true)
    cb(ok)
    return true
end

hook.Add("CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess", playerHasAccess)
local function steamIDHasAccess(_, sid, perm, cb, ...)
    sid = sid:upper()
    if not ULib.isValidSteamID(sid) then return end
    local ply = ULib.getPlyByID(sid)
    if ply then return playerHasAccess(nil, ply, perm, cb, ...) end
end

hook.Add("CAMI.SteamIDHasAccess", "ULXCamiSteamidHasAccess", steamIDHasAccess)
if SERVER then
    local function onGroupRegistered(g, token)
        if token == CAMI.ULX_TOKEN or ULib.findInTable({"superadmin", "admin", "user"}, g.Name) then return end
        if not ULib.ucl.groups[g.Name] then ULib.ucl.addGroup(g.Name, nil, g.Inherits, true) end
    end

    hook.Add("CAMI.OnUsergroupRegistered", CAMI.ULX_TOKEN, onGroupRegistered)
    local function onGroupRemoved(g, token)
        if token == CAMI.ULX_TOKEN or ULib.findInTable({"superadmin", "admin", "user"}, g.Name) then return end
        ULib.ucl.removeGroup(g.Name, true)
    end

    hook.Add("CAMI.OnUsergroupUnregistered", CAMI.ULX_TOKEN, onGroupRemoved)
    local function onSteamIDUserGroupChanged(id, _, grp, token)
        if token == CAMI.ULX_TOKEN then return end
        if grp == ULib.ACCESS_ALL then
            if ULib.ucl.users[id] then ULib.ucl.removeUser(id, true) end
        else
            if not ULib.ucl.groups[grp] then
                local cg = CAMI.GetUsergroup(grp)
                ULib.ucl.addGroup(grp, nil, cg and cg.Inherits, true)
            end

            ULib.ucl.addUser(id, nil, nil, grp, true)
        end
    end

    hook.Add("CAMI.SteamIDUsergroupChanged", CAMI.ULX_TOKEN, onSteamIDUserGroupChanged)
    local function onPlayerUserGroupChanged(ply, _, grp, token)
        if not IsValid(ply) or token == CAMI.ULX_TOKEN then return end
        local id = ULib.ucl.getUserRegisteredID(ply) or ply:SteamID()
        onSteamIDUserGroupChanged(id, nil, grp, token)
    end

    hook.Add("CAMI.PlayerUsergroupChanged", CAMI.ULX_TOKEN, onPlayerUserGroupChanged)
    local function onPrivilegeRegistered(p)
        ULib.ucl.registerAccess(p.Name:lower(), p.MinAccess, "A privilege from CAMI", "CAMI")
    end

    hook.Add("CAMI.OnPrivilegeRegistered", CAMI.ULX_TOKEN, onPrivilegeRegistered)
    for _, p in ipairs(CAMI.GetPrivileges()) do
        onPrivilegeRegistered(p)
    end

    for _, g in ipairs(CAMI.GetUsergroups()) do
        onGroupRegistered(g, CAMI.ULX_TOKEN)
    end

    for name, data in pairs(ULib.ucl.groups) do
        if not ULib.findInTable({"superadmin", "admin", "user"}, name) then
            CAMI.RegisterUsergroup({
                Name = name,
                Inherits = data.inherit_from or "user"
            }, CAMI.ULX_TOKEN)
        end
    end
end

hook.Add("RunAdminSystemCommand", CAMI.ULX_TOKEN, function(cmd, exec, victim, dur, reason)
    local sid = isstring(victim) and victim or victim:SteamID()
    if cmd == "kick" then
        ULib.kick(victim, reason or "", exec)
        return true
    end

    if cmd == "ban" then
        ULib.ban(victim, dur or 0, reason or "", exec)
        return true
    end

    if cmd == "unban" then
        ULib.unban(sid)
        return true
    end

    if cmd == "mute" then
        RunConsoleCommand("ulx", "mute", sid)
        return true
    end

    if cmd == "unmute" then
        RunConsoleCommand("ulx", "unmute", sid)
        return true
    end

    if cmd == "gag" then
        RunConsoleCommand("ulx", "gag", sid)
        return true
    end

    if cmd == "ungag" then
        RunConsoleCommand("ulx", "ungag", sid)
        return true
    end

    if cmd == "freeze" then
        RunConsoleCommand("ulx", "freeze", sid)
        return true
    end

    if cmd == "unfreeze" then
        RunConsoleCommand("ulx", "unfreeze", sid)
        return true
    end

    if cmd == "slay" then
        RunConsoleCommand("ulx", "slay", sid)
        return true
    end

    if cmd == "bring" then
        RunConsoleCommand("ulx", "bring", sid)
        return true
    end

    if cmd == "goto" then
        RunConsoleCommand("ulx", "goto", sid)
        return true
    end

    if cmd == "return" then
        RunConsoleCommand("ulx", "return", sid)
        return true
    end

    if cmd == "jail" then
        RunConsoleCommand("ulx", "jail", sid, tostring(dur or 0))
        return true
    end

    if cmd == "unjail" then
        RunConsoleCommand("ulx", "unjail", sid)
        return true
    end

    if cmd == "cloak" then
        RunConsoleCommand("ulx", "cloak", sid)
        return true
    end

    if cmd == "uncloak" then
        RunConsoleCommand("ulx", "uncloak", sid)
        return true
    end

    if cmd == "god" then
        RunConsoleCommand("ulx", "god", sid)
        return true
    end

    if cmd == "ungod" then
        RunConsoleCommand("ulx", "ungod", sid)
        return true
    end

    if cmd == "ignite" then
        RunConsoleCommand("ulx", "ignite", sid, tostring(dur or 0))
        return true
    end

    if cmd == "extinguish" or cmd == "unignite" then
        RunConsoleCommand("ulx", "unignite", sid)
        return true
    end

    if cmd == "strip" then
        RunConsoleCommand("ulx", "strip", sid)
        return true
    end
end)