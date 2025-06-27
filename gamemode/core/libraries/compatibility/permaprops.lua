--[[
    Compatibility layer for the PermaProps tool.
    Prevents saving Lilia's persistent entities or
    map-created props as permanent to avoid conflicts.
]]

hook.Add("CanTool", "liaPermaProps", function(client, _, tool)
    local entity = client:getTracedEntity()
    local entClass = entity:GetClass()
    if IsValid(entity) and tool == "permaprops" and hook.Run("CanPersistEntity", entity) ~= false and (string.StartWith(entClass, "lia_") or entity:isLiliaPersistent() or entity:CreatedByMap()) then
        client:notifyLocalized("toolCantUseEntity", tool)
        return false
    end
end)
