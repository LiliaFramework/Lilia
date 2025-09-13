local function OnPrivilegeRegistered(privilege)
    local permission = privilege.Name
    serverguard.permission:Add(permission)
    if SERVER then
        local defaultRank = privilege.MinAccess
        defaultRank = defaultRank:sub(1, 1):upper() .. defaultRank:sub(2)
        for rank, _ in pairs(serverguard.ranks:GetStored()) do
            if serverguard.ranks:HasPermission(rank, permission) == nil and (defaultRank == "User" or serverguard.ranks:HasPermission(rank, defaultRank)) then serverguard.ranks:GivePermission(rank, permission) end
        end
    end
end

local function RegisterPrivileges()
    if CAMI then
        for _, v in pairs(CAMI.GetPrivileges()) do
            OnPrivilegeRegistered(v)
        end
    end
end

function serverguard.permission:Add(identifier, priv)
    if isstring(identifier) then
        if not self.stored[identifier] then
            self.stored[identifier] = true
            if priv then
                CAMI.RegisterPrivilege({
                    Name = identifier,
                    MinAccess = "invalid"
                })

                if lia.administrator and lia.administrator.registerPrivilege then
                    lia.administrator.registerPrivilege({
                        Name = identifier,
                        ID = identifier,
                        MinAccess = "admin",
                        Category = "categoryServerGuard"
                    })
                end
            end
        end
    elseif istable(identifier) then
        for _, v in pairs(identifier) do
            if isstring(v) then self:Add(v) end
        end
    end
end

function serverguard.permission:Remove(identifier)
    if isstring(identifier) and self.stored[identifier] then
        self.stored[identifier] = nil
        if lia.administrator and lia.administrator.unregisterPrivilege then lia.administrator.unregisterPrivilege(identifier) end
    end
end

if SERVER then
    hook.Add("serverguard.RanksLoaded", "serverguard.RanksLoaded", RegisterPrivileges)
else
    RegisterPrivileges()
    hook.Add("RunAdminSystemCommand", "liaServerGuard", function(cmd, _, target, dur, reason)
        local id = isstring(target) and target or IsValid(target) and target:SteamID()
        if not id then return end
        if cmd == "kick" then
            RunConsoleCommand("serverguard", "kick", id, reason or "")
            return true
        elseif cmd == "ban" then
            RunConsoleCommand("serverguard", "ban", id, tostring(dur or 0), reason or "")
            return true
        elseif cmd == "unban" then
            RunConsoleCommand("serverguard", "unban", id)
            return true
        elseif cmd == "mute" then
            RunConsoleCommand("serverguard", "mute", id, tostring(dur or 0))
            return true
        elseif cmd == "unmute" then
            RunConsoleCommand("serverguard", "unmute", id)
            return true
        elseif cmd == "gag" then
            RunConsoleCommand("serverguard", "gag", id, tostring(dur or 0))
            return true
        elseif cmd == "ungag" then
            RunConsoleCommand("serverguard", "ungag", id)
            return true
        elseif cmd == "freeze" then
            RunConsoleCommand("serverguard", "freeze", id, tostring(dur or 0))
            return true
        elseif cmd == "unfreeze" then
            RunConsoleCommand("serverguard", "unfreeze", id)
            return true
        elseif cmd == "slay" then
            RunConsoleCommand("serverguard", "slay", id)
            return true
        elseif cmd == "bring" then
            RunConsoleCommand("serverguard", "bring", id)
            return true
        elseif cmd == "goto" then
            RunConsoleCommand("serverguard", "goto", id)
            return true
        elseif cmd == "return" then
            RunConsoleCommand("serverguard", "return", id)
            return true
        elseif cmd == "jail" then
            RunConsoleCommand("serverguard", "jail", id, tostring(dur or 0))
            return true
        elseif cmd == "unjail" then
            RunConsoleCommand("serverguard", "unjail", id)
            return true
        elseif cmd == "cloak" then
            RunConsoleCommand("serverguard", "cloak", id)
            return true
        elseif cmd == "uncloak" then
            RunConsoleCommand("serverguard", "uncloak", id)
            return true
        elseif cmd == "god" then
            RunConsoleCommand("serverguard", "god", id)
            return true
        elseif cmd == "ungod" then
            RunConsoleCommand("serverguard", "ungod", id)
            return true
        elseif cmd == "ignite" then
            RunConsoleCommand("serverguard", "ignite", id, tostring(dur or 0))
            return true
        elseif cmd == "extinguish" or cmd == "unignite" then
            RunConsoleCommand("serverguard", "extinguish", id)
            return true
        elseif cmd == "strip" then
            RunConsoleCommand("serverguard", "strip", id)
            return true
        end
    end)
end

hook.Add("serverguard.RankPermissionGiven", "liaServerGuardHandlePermissionGiven", function(rankName, permission)
    if not rankName or not permission then return end
    if CAMI and not CAMI.GetPrivilege(permission) then
        CAMI.RegisterPrivilege({
            Name = permission,
            MinAccess = "admin"
        })
    end

    if SERVER then lia.administrator.addPermission(rankName, permission, true) end
end)

hook.Add("serverguard.RankPermissionTaken", "liaServerGuardHandlePermissionTaken", function(rankName, permission)
    if not rankName or not permission then return end
    if SERVER then lia.administrator.removePermission(rankName, permission, true) end
end)

hook.Add("CAMI.OnPrivilegeRegistered", "serverguard.CAMI.OnPrivilegeRegistered", OnPrivilegeRegistered)
hook.Add("CAMI.PlayerHasAccess", "serverguard.CAMI.PlayerHasAccess", function(client, privilege, callback)
    callback(not not serverguard.player:HasPermission(client, privilege), "serverguard")
    return true
end)