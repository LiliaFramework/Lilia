---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:CanProperty(client, property, entity)
    if (property == "persist") or (property == "drive") or (property == "bonemanipulate") then
        client:notify("This is disabled to avoid issues with Lilia's Core Features")
        return false
    end

    if entity:GetCreator() == client and (property == "remover" or property == "collision") then return true end
    if CAMI.PlayerHasAccess(client, "Staff Permissions - Access Property " .. property:gsub("^%l", string.upper), nil) or client:isStaffOnDuty() then
        if entity:IsWorld() and IsValid(entity) then return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Property World Entities", nil) end
        if table.HasValue(PermissionCore.RemoverBlockedEntities, entity:GetClass()) or table.HasValue(PermissionCore.RestrictedEnts, entity:GetClass()) then return CAMI.PlayerHasAccess(client, "Staff Permissions - Use Entity Properties on Blocked Entities", nil) end
        return true
    end
    return false
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
