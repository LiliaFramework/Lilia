local version = 20211019
if CAMI and CAMI.Version >= version then return end
CAMI = CAMI or {}
CAMI.Version = 20211019
local CAMI_PRIVILEGE = {}
function CAMI_PRIVILEGE:HasAccess(actor, target)
end

local usergroups = CAMI.GetUsergroups and CAMI.GetUsergroups() or {
    user = {
        Name = "user",
        Inherits = "user",
        CAMI_Source = "Garry's Mod",
    },
    admin = {
        Name = "admin",
        Inherits = "user",
        CAMI_Source = "Garry's Mod",
    },
    superadmin = {
        Name = "superadmin",
        Inherits = "admin",
        CAMI_Source = "Garry's Mod",
    }
}

local privileges = CAMI.GetPrivileges and CAMI.GetPrivileges() or {}
function CAMI.RegisterUsergroup(usergroup, source)
    if source then usergroup.CAMI_Source = tostring(source) end
    usergroups[usergroup.Name] = usergroup
    hook.Run("CAMI.OnUsergroupRegistered", usergroup, source)
    return usergroup
end

function CAMI.UnregisterUsergroup(usergroupName, source)
    if not usergroups[usergroupName] then return false end
    local usergroup = usergroups[usergroupName]
    usergroups[usergroupName] = nil
    hook.Run("CAMI.OnUsergroupUnregistered", usergroup, source)
    return true
end

function CAMI.GetUsergroups()
    return usergroups
end

function CAMI.GetUsergroup(usergroupName)
    return usergroups[usergroupName]
end

function CAMI.UsergroupInherits(usergroupName, potentialAncestor)
    repeat
        if usergroupName == potentialAncestor then return true end
        usergroupName = usergroups[usergroupName] and usergroups[usergroupName].Inherits or usergroupName
    until not usergroups[usergroupName] or usergroups[usergroupName].Inherits == usergroupName
    return usergroupName == potentialAncestor or potentialAncestor == "user"
end

function CAMI.InheritanceRoot(usergroupName)
    if not usergroups[usergroupName] then return end
    local inherits = usergroups[usergroupName].Inherits
    while inherits ~= usergroups[usergroupName].Inherits do
        usergroupName = usergroups[usergroupName].Inherits
    end
    return usergroupName
end

function CAMI.RegisterPrivilege(privilege)
    privileges[privilege.Name] = privilege
    if lia.admin and lia.admin.registerPrivilege then lia.admin.registerPrivilege(privilege) end
    hook.Run("CAMI.OnPrivilegeRegistered", privilege)
    return privilege
end

function CAMI.UnregisterPrivilege(privilegeName)
    if not privileges[privilegeName] then return false end
    local privilege = privileges[privilegeName]
    privileges[privilegeName] = nil
    if lia.admin and lia.admin.privileges then lia.admin.privileges[privilegeName] = nil end
    hook.Run("CAMI.OnPrivilegeUnregistered", privilege)
    return true
end

function CAMI.GetPrivileges()
    return privileges
end

function CAMI.GetPrivilege(privilegeName)
    return privileges[privilegeName]
end

local defaultAccessHandler = {
    ["CAMI.PlayerHasAccess"] = function(_, actorPly, privilegeName, callback, targetPly, extraInfoTbl)
        if not IsValid(actorPly) then return callback(true, "Fallback.") end
        local priv = privileges[privilegeName]
        local fallback = extraInfoTbl and (not extraInfoTbl.Fallback and actorPly:IsAdmin() or extraInfoTbl.Fallback == "user" and true or extraInfoTbl.Fallback == "admin" and actorPly:IsAdmin() or extraInfoTbl.Fallback == "superadmin" and actorPly:IsSuperAdmin())
        if not priv then return callback(fallback, "Fallback.") end
        local hasAccess = priv.MinAccess == "user" or priv.MinAccess == "admin" and actorPly:IsAdmin() or priv.MinAccess == "superadmin" and actorPly:IsSuperAdmin()
        if hasAccess and priv.HasAccess then hasAccess = priv:HasAccess(actorPly, targetPly) end
        callback(hasAccess, "Fallback.")
    end,
    ["CAMI.SteamIDHasAccess"] = function(_, _, _, callback) callback(false, "No information available.") end
}

function CAMI.PlayerHasAccess(actorPly, privilegeName, callback, targetPly, extraInfoTbl)
    local hasAccess, reason = nil, nil
    local callback_ = callback or function(hA, r) hasAccess, reason = hA, r end
    if not IsValid(actorPly) then return end
    if actorPly:IsBot() then return true end
    hook.Run("CAMI.PlayerHasAccess", defaultAccessHandler, actorPly, privilegeName, callback_, targetPly, extraInfoTbl)
    if callback ~= nil then return end
    if hasAccess == nil then
        local priv = privileges[privilegeName]
        if priv then
            if priv.MinAccess == "user" then
                hasAccess = true
                reason = "Defaulted to 'user' permissions."
            elseif priv.MinAccess == "admin" then
                hasAccess = false
                reason = "Insufficient permissions. Defaulted to 'user' permissions."
            elseif priv.MinAccess == "superadmin" then
                hasAccess = false
                reason = "Insufficient permissions. Defaulted to 'user' permissions."
            else
                hasAccess = false
                reason = "Undefined privilege level. Defaulted to 'user' permissions."
            end
        else
            if extraInfoTbl then
                if not extraInfoTbl.Fallback then
                    hasAccess = actorPly:IsAdmin()
                    reason = "No fallback specified. Defaulted to 'user' permissions."
                elseif extraInfoTbl.Fallback == "user" then
                    hasAccess = true
                    reason = "Fallback to 'user' permissions."
                elseif extraInfoTbl.Fallback == "admin" then
                    hasAccess = actorPly:IsAdmin()
                    reason = "Fallback to 'admin' permissions."
                elseif extraInfoTbl.Fallback == "superadmin" then
                    hasAccess = actorPly:IsSuperAdmin()
                    reason = "Fallback to 'superadmin' permissions."
                else
                    hasAccess = false
                    reason = "Invalid fallback specified. Defaulted to 'user' permissions."
                end
            else
                hasAccess = true
                reason = "No privilege found. Defaulted to 'user' permissions."
            end
        end
    end
    return hasAccess, reason
end

function CAMI.GetPlayersWithAccess(privilegeName, callback, targetPly, extraInfoTbl)
    local allowedPlys = {}
    local countdown = player.GetCount()
    local function onResult(client, hasAccess, _)
        countdown = countdown - 1
        if hasAccess then table.insert(allowedPlys, client) end
        if countdown == 0 then callback(allowedPlys) end
    end

    for _, client in player.Iterator() do
        CAMI.PlayerHasAccess(client, privilegeName, function(...) onResult(client, ...) end, targetPly, extraInfoTbl)
    end
end

function CAMI.SteamIDHasAccess(actorSteam, privilegeName, callback, targetSteam, extraInfoTbl)
    hook.Run("CAMI.SteamIDHasAccess", defaultAccessHandler, actorSteam, privilegeName, callback, targetSteam, extraInfoTbl)
end

function CAMI.SignalUserGroupChanged(client, old, new, source)
    hook.Run("CAMI.PlayerUsergroupChanged", client, old, new, source)
end

function CAMI.SignalSteamIDUserGroupChanged(steamId, old, new, source)
    hook.Run("CAMI.SteamIDUsergroupChanged", steamId, old, new, source)
end