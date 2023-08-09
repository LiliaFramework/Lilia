------------------------------------------------------------------------------------------------------------------------
local MODULE = MODULE
------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnNPC(client, npcType, weapon)
    if not client:getChar() then return end
    if not lia.config.CustomPermissions then return end
    local permission = lia.config.PermissionTable["PlayerSpawnNPC"]
    if permission.IsAdmin and client:IsAdmin() then
        return true
    elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
        return true
    elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
        if permission.CustomCheck(client) then
            return true
        else
            client:ChatPrint("You don't have permission to spawn NPCs.")
            return false
        end
    else
        client:ChatPrint("You don't have permission to spawn NPCs.")
        return false
    end
end
------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnProp(client, weapon, info)
    if not client:getChar() then return end
    if not lia.config.CustomPermissions then return end
    local permission = lia.config.PermissionTable["PlayerSpawnProp"]
    if permission.IsAdmin and client:IsAdmin() then
        return true
    elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
        return true
    elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
        if permission.CustomCheck(client) then
            return true
        else
            client:ChatPrint("You don't have permission to spawn Props.")
            return false
        end
    else
        client:ChatPrint("You don't have permission to spawn Props.")
        return false
    end
end
------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnRagdoll(client, weapon, info)
    if not client:getChar() then return end
    if not lia.config.CustomPermissions then return end
    local permission = lia.config.PermissionTable["PlayerSpawnRagdoll"]
    if permission.IsAdmin and client:IsAdmin() then
        return true
    elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
        return true
    elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
        if permission.CustomCheck(client) then
            return true
        else
            client:ChatPrint("You don't have permission to spawn Props.")
            return false
        end
    else
        client:ChatPrint("You don't have permission to spawn Props.")
        return false
    end
end
------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnSWEP(client, weapon, info)
    if not client:getChar() then return end
    if not lia.config.CustomPermissions then return end
    local permission = lia.config.PermissionTable["PlayerSpawnSWEP"]
    if permission.IsAdmin and client:IsAdmin() then
        return true
    elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
        return true
    elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
        if permission.CustomCheck(client) then
            return true
        else
            client:ChatPrint("You don't have permission to spawn SWEPs.")
            return false
        end
    else
        client:ChatPrint("You don't have permission to spawn SWEPs.")
        return false
    end
end
------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnEffect(client, weapon, info)
    if not client:getChar() then return end
    if not lia.config.CustomPermissions then return end
    local permission = lia.config.PermissionTable["PlayerSpawnEffect"]
    if permission.IsAdmin and client:IsAdmin() then
        return true
    elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
        return true
    elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
        if permission.CustomCheck(client) then
            return true
        else
            client:ChatPrint("You don't have permission to spawn Effects.")
            return false
        end
    else
        client:ChatPrint("You don't have permission to spawn Effects.")
        return false
    end
end
------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnSENT(client, weapon, info)
    if not client:getChar() then return end
    if not lia.config.CustomPermissions then return end
    local permission = lia.config.PermissionTable["PlayerSpawnSENT"]
    if permission.IsAdmin and client:IsAdmin() then
        return true
    elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
        return true
    elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
        if permission.CustomCheck(client) then
            return true
        else
            client:ChatPrint("You don't have permission to spawn SENTs.")
            return false
        end
    else
        client:ChatPrint("You don't have permission to spawn SENTs.")
        return false
    end
end
------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSpawnVehicle(client, weapon, info)
    if not client:getChar() then return end
    if not lia.config.CustomPermissions then return end
    local permission = lia.config.PermissionTable["PlayerSpawnVehicle"]
    if permission.IsAdmin and client:IsAdmin() then
        return true
    elseif permission.IsSuperAdmin and client:IsSuperAdmin() then
        return true
    elseif permission.CustomCheck and type(permission.CustomCheck) == "function" then
        if permission.CustomCheck(client) then
            return true
        else
            client:ChatPrint("You don't have permission to spawn Vehicles.")
            return false
        end
    else
        client:ChatPrint("You don't have permission to spawn Vehicles.")
        return false
    end
end

------------------------------------------------------------------------------------------------------------------------