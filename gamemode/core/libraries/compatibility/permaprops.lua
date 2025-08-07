local spawnedPositions = {}
local radiusSqr = 16
local lastSaver
hook.Add("CanTool", "liaPermaProps", function(ply, trace, tool)
    local entity = trace.Entity
    if not IsValid(entity) then return end
    if tool ~= "permaprops" then return end
    local entClass = entity:GetClass()
    local canPersist = hook.Run("CanPersistEntity", entity)
    if canPersist ~= false and (string.StartWith(entClass, "lia_") or entity:isLiliaPersistent() or entity:CreatedByMap()) then
        ply:notifyLocalized("toolCantUseEntity", tool)
        return false
    end
end)

hook.Add("PermaProps.OnEntityCreated", "liaPermaPropsOverlapWarning", function(entity)
    if not IsValid(entity) then return end
    local pos = entity:GetPos()
    for _, existing in ipairs(spawnedPositions) do
        if pos:DistToSqr(existing) <= radiusSqr then
            lia.notices.notifyLocalized("permaPropOverlapWarning")
            break
        end
    end

    table.insert(spawnedPositions, pos)
end)

hook.Add("PermaProps.CanPermaProp", "liaTrackPermaPropSaver", function(ply) lastSaver = ply end)
hook.Add("PermaProps.OnEntitySaved", "liaLogPermaPropSaved", function(ent)
    if not lastSaver then return end
    if not IsValid(ent) or ent.PermaProps then
        lastSaver = nil
        return
    end

    lia.log.add(lastSaver, "permaPropSaved", ent:GetClass(), ent:GetModel(), tostring(ent:GetPos()))
    lastSaver = nil
end)

hook.Add("PostCleanupMap", "liaPermaPropsClearList", function() spawnedPositions = {} end)
lia.log.addType("permaPropSaved", function(client, class, model, pos) return L("permaPropSavedLog", client:Name(), class, model, pos) end, L("categoryPermaProps"))
lia.log.addType("permaPropOverlap", function(_, pos, other) return L("permaPropOverlapLog", pos, other) end, L("categoryPermaProps"))
