--------------------------------------------------------------------------------------------------------
if not serverguard then return end
--------------------------------------------------------------------------------------------------------
serverguard.plugin:Toggle("restrictions", false)
--------------------------------------------------------------------------------------------------------
local function OnPrivilegeRegistered(privilege)
    local permission = privilege.Name
    serverguard.permission:Add(permission)
    if SERVER then
        local defaultRank = privilege.MinAccess
        defaultRank = defaultRank:sub(1, 1):upper() .. defaultRank:sub(2)
        for rank, _ in pairs(serverguard.ranks:GetStored()) do
            if serverguard.ranks:HasPermission(rank, permission) == nil and (defaultRank == "User" or serverguard.ranks:HasPermission(rank, defaultRank)) then
                serverguard.ranks:GivePermission(rank, permission)
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------
local function RegisterPrivileges()
    if CAMI then
        for _, v in pairs(CAMI.GetPrivileges()) do
            OnPrivilegeRegistered(v)
        end
    end
end

--------------------------------------------------------------------------------------------------------
hook.Add("CAMI.OnPrivilegeRegistered", "serverguard.CAMI.OnPrivilegeRegistered", OnPrivilegeRegistered)
hook.Add(
    "CAMI.PlayerHasAccess",
    "serverguard.CAMI.PlayerHasAccess",
    function(client, privilege, callback)
        callback(not not serverguard.player:HasPermission(client, privilege), "serverguard")

        return true
    end
)

--------------------------------------------------------------------------------------------------------
if SERVER then
    hook.Add("serverguard.RanksLoaded", "serverguard.RanksLoaded", RegisterPrivileges)
else
    RegisterPrivileges()
end
--------------------------------------------------------------------------------------------------------