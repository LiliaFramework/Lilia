CAMI.ULX_TOKEN = "ULX"
local camiHooks = {{"CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess"}, {"CAMI.SteamIDHasAccess", "ULXCamiSteamidHasAccess"}, {"CAMI.OnUsergroupRegistered", "ULXCamiGroupRegistered"}, {"CAMI.OnUsergroupUnregistered", "ULXCamiGroupRemoved"}, {"CAMI.SteamIDUsergroupChanged", "ULXCamiSteamidUserGroupChanged"}, {"CAMI.PlayerUsergroupChanged", "ULXCamiPlayerUserGroupChanged"}, {"CAMI.OnPrivilegeRegistered", "ULXCamiPrivilegeRegistered"}}
for _, hookInfo in ipairs(camiHooks) do
    hook.Remove(hookInfo[1], hookInfo[2])
end

local function playerHasAccess(_, actorPly, privilegeName, callback, targetPly, extraInfoTbl)
    local priv = privilegeName:lower()
    local result = ULib.ucl.query(actorPly, priv, true)
    callback(not not result)
    return true
end

hook.Add("CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess", playerHasAccess)
local function steamIDHasAccess(_, actorSteam, privilegeName, callback, targetSteam, extraInfoTbl)
    local priv = privilegeName:lower()
    local steamid = actorSteam:upper()
    if not ULib.isValidSteamID(steamid) then return end
    local connectedPly = ULib.getPlyByID(steamid)
    if connectedPly then return playerHasAccess(nil, connectedPly, privilegeName, callback, targetSteam, extraInfoTbl) end
end

hook.Add("CAMI.SteamIDHasAccess", "ULXCamiSteamidHasAccess", steamIDHasAccess)
if CLIENT then return end
local function onGroupRegistered(camiGroup, originToken)
    if originToken == CAMI.ULX_TOKEN then return end
    if ULib.findInTable({"superadmin", "admin", "user"}, camiGroup.Name) then return end
    if not ULib.ucl.groups[camiGroup.Name] then ULib.ucl.addGroup(camiGroup.Name, nil, camiGroup.Inherits, true) end
end

hook.Add("CAMI.OnUsergroupRegistered", "ULXCamiGroupRegistered", onGroupRegistered)
local function onGroupRemoved(camiGroup, originToken)
    if originToken == CAMI.ULX_TOKEN then return end
    if ULib.findInTable({"superadmin", "admin", "user"}, camiGroup.Name) then return end
    ULib.ucl.removeGroup(camiGroup.Name, true)
end

hook.Add("CAMI.OnUsergroupUnregistered", "ULXCamiGroupRemoved", onGroupRemoved)
local function onSteamIDUserGroupChanged(id, oldGroup, newGroup, originToken)
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

hook.Add("CAMI.SteamIDUsergroupChanged", "ULXCamiSteamidUserGroupChanged", onSteamIDUserGroupChanged)
local function onPlayerUserGroupChanged(ply, oldGroup, newGroup, originToken)
    if not ply or not ply:IsValid() then return end
    if originToken == CAMI.ULX_TOKEN then return end
    local id = ULib.ucl.getUserRegisteredID(ply) or ply:SteamID()
    onSteamIDUserGroupChanged(id, oldGroup, newGroup, originToken)
end

hook.Add("CAMI.PlayerUsergroupChanged", "ULXCamiPlayerUserGroupChanged", onPlayerUserGroupChanged)
local function onPrivilegeRegistered(camiPriv)
    local priv = camiPriv.Name:lower()
    ULib.ucl.registerAccess(priv, camiPriv.MinAccess, "A privilege from CAMI", "CAMI")
end

hook.Add("CAMI.OnPrivilegeRegistered", "ULXCamiPrivilegeRegistered", onPrivilegeRegistered)
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
