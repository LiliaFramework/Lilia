---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PermaPropsCompatibility:CanTool(client, _, tool)
    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local entity = client:GetTracedEntity()
    local validEntity = IsValid(entity)
    if validEntity and tool == "permaprops" and IsValid(client) and (client:getChar():hasFlags("t") or client:isStaffOnDuty()) and CAMI.PlayerHasAccess(client, privilege, nil) and not (string.StartWith(entity:GetClass(), "lia_") and table.HasValue(PermissionCore.CanNotPermaProp, entity:GetClass())) then return true end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------