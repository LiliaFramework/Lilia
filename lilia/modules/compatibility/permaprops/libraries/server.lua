---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:CanTool(client, _, tool)
    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local entity = client:GetTracedEntity()
    local validEntity = IsValid(entity)
    if validEntity and tool == "permaprops" and ((client:getChar():hasFlags("t") or client:isStaffOnDuty()) or CAMI.PlayerHasAccess(client, privilege, nil)) then
        if not (string.StartsWith(entity:GetClass(), "lia_") and table.HasValue(PermissionCore.CanNotPermaProp, entity:GetClass())) then
            return true
        else
            return false
        end
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
