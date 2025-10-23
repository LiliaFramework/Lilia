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
    local sgCommands = {
        kick = function(id, _, reason) RunConsoleCommand("serverguard", "kick", id, reason or "") end,
        ban = function(id, dur, reason) RunConsoleCommand("serverguard", "ban", id, tostring(dur or 0), reason or "") end,
        unban = function(id) RunConsoleCommand("serverguard", "unban", id) end,
        mute = function(id, dur) RunConsoleCommand("serverguard", "mute", id, tostring(dur or 0)) end,
        unmute = function(id) RunConsoleCommand("serverguard", "unmute", id) end,
        gag = function(id, dur) RunConsoleCommand("serverguard", "gag", id, tostring(dur or 0)) end,
        ungag = function(id) RunConsoleCommand("serverguard", "ungag", id) end,
        freeze = function(id, dur) RunConsoleCommand("serverguard", "freeze", id, tostring(dur or 0)) end,
        unfreeze = function(id) RunConsoleCommand("serverguard", "unfreeze", id) end,
        slay = function(id) RunConsoleCommand("serverguard", "slay", id) end,
        bring = function(id) RunConsoleCommand("serverguard", "bring", id) end,
        ["goto"] = function(id) RunConsoleCommand("serverguard", "goto", id) end,
        ["return"] = function(id) RunConsoleCommand("serverguard", "return", id) end,
        jail = function(id, dur) RunConsoleCommand("serverguard", "jail", id, tostring(dur or 0)) end,
        unjail = function(id) RunConsoleCommand("serverguard", "unjail", id) end,
        cloak = function(id) RunConsoleCommand("serverguard", "cloak", id) end,
        uncloak = function(id) RunConsoleCommand("serverguard", "uncloak", id) end,
        god = function(id) RunConsoleCommand("serverguard", "god", id) end,
        ungod = function(id) RunConsoleCommand("serverguard", "ungod", id) end,
        ignite = function(id, dur) RunConsoleCommand("serverguard", "ignite", id, tostring(dur or 0)) end,
        extinguish = function(id) RunConsoleCommand("serverguard", "extinguish", id) end,
        unignite = function(id) RunConsoleCommand("serverguard", "extinguish", id) end,
        strip = function(id) RunConsoleCommand("serverguard", "strip", id) end
    }

    hook.Add("RunAdminSystemCommand", "liaServerGuard", function(cmd, _, target, dur, reason)
        local id = isstring(target) and target or IsValid(target) and target:SteamID()
        if not id then return end
        local commandFunc = sgCommands[cmd]
        if commandFunc then
            commandFunc(id, dur, reason)
            return true, function() end
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