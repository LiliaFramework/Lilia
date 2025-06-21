local hooksToRemove = {{"CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess"}, {"CAMI.SteamIDHasAccess", "ULXCamiSteamidHasAccess"}, {"CAMI.OnUsergroupRegistered", "ULXCamiGroupRegistered"}, {"CAMI.OnUsergroupUnregistered", "ULXCamiGroupRemoved"}, {"CAMI.SteamIDUsergroupChanged", "ULXCamiSteamidUserGroupChanged"}, {"CAMI.PlayerUsergroupChanged", "ULXCamiPlayerUserGroupChanged"}, {"CAMI.OnPrivilegeRegistered", "ULXCamiPrivilegeRegistered"}, {"PlayerSay", "ULXMeCheck"},}
for _, hookPair in ipairs(hooksToRemove) do
    hook.Remove(hookPair[1], hookPair[2])
end

local oldAddGroup = ULib.ucl.addGroup
ULib.ucl.addGroup = function(name, password, inherit, save)
    local grp = oldAddGroup(name, password, inherit, save)
    CAMI.RegisterUsergroup({
        Name = name,
        Inherits = inherit or "user"
    }, CAMI.ULX_TOKEN)
    return grp
end

local oldRemoveGroup = ULib.ucl.removeGroup
ULib.ucl.removeGroup = function(name, save)
    local ok = oldRemoveGroup(name, save)
    if ok then CAMI.UnregisterUsergroup(name, CAMI.ULX_TOKEN) end
    return ok
end

-- sync ULib privileges to our CAMI
local oldRegisterAccess = ULib.ucl.registerAccess
ULib.ucl.registerAccess = function(name, minaccess, description, registeredBy)
    oldRegisterAccess(name, minaccess, description, registeredBy)
    CAMI.RegisterPrivilege({
        Name = name:upper(),
        MinAccess = minaccess,
        HasAccess = nil
    })
end

local oldUnregisterAccess = ULib.ucl.unregisterAccess
if oldUnregisterAccess then
    ULib.ucl.unregisterAccess = function(name, save)
        local ok = oldUnregisterAccess(name, save)
        if ok then CAMI.UnregisterPrivilege(name:upper()) end
        return ok
    end
end

hook.Add("CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess", function(_, ply, priv, cb)
    local result = ULib.ucl.query(ply, priv:lower(), true)
    cb(result, "ULX")
end)

hook.Add("CAMI.SteamIDHasAccess", "ULXCamiSteamIDHasAccess", function(_, steam, priv, cb)
    if not ULib.isValidSteamID(steam) then return end
    local ply = ULib.getPlyByID(steam)
    if ply then
        local result = ULib.ucl.query(ply, priv:lower(), true)
        cb(result, "ULX")
    end
end)