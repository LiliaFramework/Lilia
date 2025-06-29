CAMI.ULX_TOKEN = "ULX"
local camiHooks = {{"CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess"}, {"CAMI.SteamIDHasAccess", "ULXCamiSteamidHasAccess"}, {"CAMI.OnUsergroupRegistered", "ULXCamiGroupRegistered"}, {"CAMI.OnUsergroupUnregistered", "ULXCamiGroupRemoved"}, {"CAMI.SteamIDUsergroupChanged", "ULXCamiSteamidUserGroupChanged"}, {"CAMI.PlayerUsergroupChanged", "ULXCamiPlayerUserGroupChanged"}, {"CAMI.OnPrivilegeRegistered", "ULXCamiPrivilegeRegistered"}}
for _, hookInfo in ipairs(camiHooks) do
    hook.Remove(hookInfo[1], hookInfo[2])
end

local function playerHasAccess(_, actorPly, privilegeName, callback)
    local priv = privilegeName:lower()
    local result = ULib.ucl.query(actorPly, priv, true)
    callback(not not result)
    return true
end

hook.Add("CAMI.PlayerHasAccess", "liaULX", playerHasAccess)
local function steamIDHasAccess(_, actorSteam, privilegeName, callback, targetSteam, extraInfoTbl)
    local steamid = actorSteam:upper()
    if not ULib.isValidSteamID(steamid) then return end
    local connectedPly = ULib.getPlyByID(steamid)
    if connectedPly then return playerHasAccess(nil, connectedPly, privilegeName, callback, targetSteam, extraInfoTbl) end
end

hook.Add("CAMI.SteamIDHasAccess", "liaULX", steamIDHasAccess)
if CLIENT then return end
local function onGroupRegistered(camiGroup, originToken)
    if originToken == CAMI.ULX_TOKEN then return end
    if ULib.findInTable({"superadmin", "admin", "user"}, camiGroup.Name) then return end
    if not ULib.ucl.groups[camiGroup.Name] then ULib.ucl.addGroup(camiGroup.Name, nil, camiGroup.Inherits, true) end
end

hook.Add("CAMI.OnUsergroupRegistered", "liaULX", onGroupRegistered)
local function onGroupRemoved(camiGroup, originToken)
    if originToken == CAMI.ULX_TOKEN then return end
    if ULib.findInTable({"superadmin", "admin", "user"}, camiGroup.Name) then return end
    ULib.ucl.removeGroup(camiGroup.Name, true)
end

hook.Add("CAMI.OnUsergroupUnregistered", "liaULX", onGroupRemoved)
local function onSteamIDUserGroupChanged(id, _, newGroup, originToken)
    if originToken == CAMI.ULX_TOKEN then return end
    if newGroup == ULib.ACCESS_ALL then
        if ULib.ucl.users[id] then ULib.ucl.removeUser(id, true) end
    else
        if not ULib.ucl.groups[newGroup] then
            local camiGroup = CAMI.GetUsergroup(newGroup)
            local inherits = camiGroup and camiGroup.Inherits
            ULib.ucl.addGroup(newGroup, nil, inherits, true)
        end

        ULib.ucl.addUser(id, nil, nil, newGroup, true)
    end
end

hook.Add("CAMI.SteamIDUsergroupChanged", "liaULX", onSteamIDUserGroupChanged)
local function onPlayerUserGroupChanged(ply, oldGroup, newGroup, originToken)
    if not ply or not ply:IsValid() then return end
    if originToken == CAMI.ULX_TOKEN then return end
    local id = ULib.ucl.getUserRegisteredID(ply) or ply:SteamID()
    onSteamIDUserGroupChanged(id, oldGroup, newGroup, originToken)
end

hook.Add("CAMI.PlayerUsergroupChanged", "liaULX", onPlayerUserGroupChanged)
local function onPrivilegeRegistered(camiPriv)
    local priv = camiPriv.Name:lower()
    ULib.ucl.registerAccess(priv, camiPriv.MinAccess, "A privilege from CAMI", "CAMI")
end

hook.Add("CAMI.OnPrivilegeRegistered", "liaULX", onPrivilegeRegistered)
for _, camiPriv in pairs(CAMI.GetPrivileges()) do
    onPrivilegeRegistered(camiPriv)
end

for _, camiGroup in pairs(CAMI.GetUsergroups()) do
    onGroupRegistered(camiGroup)
end

for name, data in pairs(ULib.ucl.groups) do
    if not ULib.findInTable({"superadmin", "admin", "user"}, name) then
        CAMI.RegisterUsergroup({
            Name = name,
            Inherits = data.inherit_from or "user"
        }, CAMI.ULX_TOKEN)
    end
end

hook.Add("RunAdminSystemCommand", "liaULX", function(cmd, exec, victim, dur, reason)
    if cmd == "kick" then
        ULib.kick(victim, reason or "", exec)
        return true
    elseif cmd == "ban" then
        ULib.ban(victim, dur or 0, reason or "", exec)
        return true
    elseif cmd == "unban" then
        ULib.unban(isstring(victim) and victim or victim:SteamID())
        return true
    elseif cmd == "mute" then
        RunConsoleCommand("ulx", "mute", victim:SteamID())
        return true
    elseif cmd == "unmute" then
        RunConsoleCommand("ulx", "unmute", victim:SteamID())
        return true
    elseif cmd == "gag" then
        RunConsoleCommand("ulx", "gag", victim:SteamID())
        return true
    elseif cmd == "ungag" then
        RunConsoleCommand("ulx", "ungag", victim:SteamID())
        return true
    elseif cmd == "freeze" then
        RunConsoleCommand("ulx", "freeze", victim:SteamID())
        return true
    elseif cmd == "unfreeze" then
        RunConsoleCommand("ulx", "unfreeze", victim:SteamID())
        return true
    elseif cmd == "slay" then
        RunConsoleCommand("ulx", "slay", victim:SteamID())
        return true
    elseif cmd == "bring" then
        RunConsoleCommand("ulx", "bring", victim:SteamID())
        return true
    elseif cmd == "goto" then
        RunConsoleCommand("ulx", "goto", victim:SteamID())
        return true
    elseif cmd == "return" then
        RunConsoleCommand("ulx", "return", victim:SteamID())
        return true
    elseif cmd == "jail" then
        RunConsoleCommand("ulx", "jail", victim:SteamID(), tostring(dur or 0))
        return true
    elseif cmd == "unjail" then
        RunConsoleCommand("ulx", "unjail", victim:SteamID())
        return true
    elseif cmd == "cloak" then
        RunConsoleCommand("ulx", "cloak", victim:SteamID())
        return true
    elseif cmd == "uncloak" then
        RunConsoleCommand("ulx", "uncloak", victim:SteamID())
        return true
    elseif cmd == "god" then
        RunConsoleCommand("ulx", "god", victim:SteamID())
        return true
    elseif cmd == "ungod" then
        RunConsoleCommand("ulx", "ungod", victim:SteamID())
        return true
    elseif cmd == "ignite" then
        RunConsoleCommand("ulx", "ignite", victim:SteamID(), tostring(dur or 0))
        return true
    elseif cmd == "extinguish" or cmd == "unignite" then
        RunConsoleCommand("ulx", "unignite", victim:SteamID())
        return true
    elseif cmd == "strip" then
        RunConsoleCommand("ulx", "strip", victim:SteamID())
        return true
    end
end)