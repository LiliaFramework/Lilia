--[[
    Removes ULX's default CAMI integration hooks so that the custom
    registration functions defined below can take over without conflict.
]]
local hooksToRemove = {
    {"CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess"},
    {"CAMI.SteamIDHasAccess", "ULXCamiSteamidHasAccess"},
    {"CAMI.OnUsergroupRegistered", "ULXCamiGroupRegistered"},
    {"CAMI.OnUsergroupUnregistered", "ULXCamiGroupRemoved"},
    {"CAMI.SteamIDUsergroupChanged", "ULXCamiSteamidUserGroupChanged"},
    {"CAMI.PlayerUsergroupChanged", "ULXCamiPlayerUserGroupChanged"},
    {"CAMI.OnPrivilegeRegistered", "ULXCamiPrivilegeRegistered"},
    {"PlayerSay", "ULXMeCheck"}
}
for _, hookPair in ipairs(hooksToRemove) do
    hook.Remove(hookPair[1], hookPair[2])
end

local oldAddGroup = ULib.ucl.addGroup
--[[
    ULib.ucl.addGroup(name, password, inherit, save)

    Description:
        Overrides ULX's addGroup function to also register a CAMI
        usergroup so third-party systems can query permissions.

    Parameters:
        name (string) – Name of the ULX group.
        password (string) – Optional group password.
        inherit (string) – Group to inherit permissions from.
        save (boolean) – Whether the group should be persisted.

    Realm:
        Shared

    Returns:
        table – The group table returned by the original ULX function.
]]
ULib.ucl.addGroup = function(name, password, inherit, save)
    local grp = oldAddGroup(name, password, inherit, save)
    CAMI.RegisterUsergroup({
        Name = name,
        Inherits = inherit or "user"
    }, CAMI.ULX_TOKEN)
    return grp
end

local oldRemoveGroup = ULib.ucl.removeGroup
--[[
    ULib.ucl.removeGroup(name, save)

    Description:
        Unregisters the matching CAMI usergroup whenever a ULX group
        is removed, keeping both systems synchronized.

    Parameters:
        name (string) – Group being removed.
        save (boolean) – Whether the deletion should be persisted.

    Realm:
        Shared

    Returns:
        boolean – True when the group was removed successfully.
]]
ULib.ucl.removeGroup = function(name, save)
    local ok = oldRemoveGroup(name, save)
    if ok then CAMI.UnregisterUsergroup(name, CAMI.ULX_TOKEN) end
    return ok
end

-- sync ULib privileges to our CAMI
local oldRegisterAccess = ULib.ucl.registerAccess
--[[
    ULib.ucl.registerAccess(name, minaccess, description, registeredBy)

    Description:
        When ULX registers a new privilege, a CAMI privilege with the
        same name is also created so that other addons can check it.

    Parameters:
        name (string) – Name of the privilege.
        minaccess (string) – Lowest usergroup that can access it.
        description (string) – Human readable description.
        registeredBy (string) – Addon registering the privilege.

    Realm:
        Shared

    Returns:
        None
]]
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
    --[[
        ULib.ucl.unregisterAccess(name, save)

        Description:
            Removes the matching CAMI privilege when ULX forgets a
            privilege. This keeps CAMI and ULX in sync.

        Parameters:
            name (string) – Privilege name to remove.
            save (boolean) – Whether the deletion should be persisted.

        Realm:
            Shared

        Returns:
            boolean – True if the privilege was removed.
    ]]
    ULib.ucl.unregisterAccess = function(name, save)
        local ok = oldUnregisterAccess(name, save)
        if ok then CAMI.UnregisterPrivilege(name:upper()) end
        return ok
    end
end

--[[
    hook.Add("CAMI.PlayerHasAccess")

    Description:
        Delegates CAMI permission checks to ULX so both systems
        return the same results.

    Parameters:
        ply (Player) – Player whose access is being tested.
        priv (string) – Privilege name.
        cb (function) – Callback receiving the result and provider.

    Realm:
        Shared

    Returns:
        None
]]
hook.Add("CAMI.PlayerHasAccess", "ULXCamiPlayerHasAccess", function(_, ply, priv, cb)
    local result = ULib.ucl.query(ply, priv:lower(), true)
    cb(result, "ULX")
end)

--[[
    hook.Add("CAMI.SteamIDHasAccess")

    Description:
        Performs an access check by SteamID using ULX and returns the
        result back to CAMI for compatibility.

    Parameters:
        steam (string) – SteamID64 to check.
        priv (string) – Privilege being queried.
        cb (function) – Callback receiving the outcome.

    Realm:
        Shared

    Returns:
        None
]]
hook.Add("CAMI.SteamIDHasAccess", "ULXCamiSteamIDHasAccess", function(_, steam, priv, cb)
    if not ULib.isValidSteamID(steam) then return end
    local ply = ULib.getPlyByID(steam)
    if ply then
        local result = ULib.ucl.query(ply, priv:lower(), true)
        cb(result, "ULX")
    end
end)
