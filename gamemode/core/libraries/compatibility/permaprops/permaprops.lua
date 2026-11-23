local spawnedPositions = {}
local radiusSqr = 16
local lastSaver
hook.Add("CanTool", "liaPermaProps", function(ply, trace, tool)
    local entity = trace.Entity
    if not IsValid(entity) then return end
    if tool ~= "permaprops" then return end
    local entClass = entity:GetClass()
    local canPersist = hook.Run("CanPersistEntity", entity)
    if canPersist ~= false and (string.StartWith(entClass, "lia_") or entity.IsPersistent or entity:CreatedByMap()) then
        ply:notifyError(string.format("You cannot use %s on this entity.", tool))
        return false
    end
end)

hook.Add("PermaProps.OnEntityCreated", "liaPermaPropsOverlapWarning", function(entity)
    if not IsValid(entity) then return end
    local pos = entity:GetPos()
    for _, existing in ipairs(spawnedPositions) do
        if pos:DistToSqr(existing) <= radiusSqr then
            if CLIENT then LocalPlayer():notifyWarning(string.format("Warning: perma-props spawning too close together!")) end
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

    lastSaver = nil
end)

hook.Add("PostCleanupMap", "liaPermaPropsClearList", function() spawnedPositions = {} end)
