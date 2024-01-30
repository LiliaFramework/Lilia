---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local function OnPrivilegeRegistered(privilege)
    local permission = privilege.Name
    serverguard.permission:Add(permission)
    local defaultRank = privilege.MinAccess
    defaultRank = defaultRank:sub(1, 1):upper() .. defaultRank:sub(2)
    for rank, _ in pairs(serverguard.ranks:GetStored()) do
        if serverguard.ranks:HasPermission(rank, permission) == nil and (defaultRank == "User" or serverguard.ranks:HasPermission(rank, defaultRank)) then serverguard.ranks:GivePermission(rank, permission) end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local function RegisterPrivileges()
    if CAMI then
        for _, v in pairs(CAMI.GetPrivileges()) do
            OnPrivilegeRegistered(v)
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
hook.Add("serverguard.RanksLoaded", "serverguard.RanksLoaded", RegisterPrivileges)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
