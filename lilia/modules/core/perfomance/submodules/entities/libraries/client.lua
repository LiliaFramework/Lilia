function EntityPerfomance:PostGamemodeLoaded()
    scripted_ents.GetStored("base_gmodentity").t.Think = nil
end

function EntityPerfomance:GrabEarAnimation()
    return nil
end

function EntityPerfomance:MouthMoveAnimation()
    return nil
end

function EntityPerfomance:ClientsideInitializedModules()
    if not self.DrawEntityShadows then return end
    for _, v in ipairs(ents.FindByClass("prop_door_rotating")) do
        if IsValid(v) and v:isDoor() then v:DrawShadow(false) end
    end
end

function EntityPerfomance:ClientOnEntityCreated(entity)
    if not self.DrawEntityShadows then return end
    entity:DrawShadow(false)
end

