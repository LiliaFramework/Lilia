MODULE.options = MODULE.options or {}
function MODULE:AddOption(name, data)
    self.options[name] = data
end

function MODULE:CheckPossibilities(traceEnt)
    for _, v in pairs(self.options) do
        if IsValid(traceEnt) and v.shouldShow(LocalPlayer(), traceEnt) then return true end
    end
    return false
end

function MODULE:InitializedModules()
    hook.Run("AddPIMOption", self.options)
end

function MODULE:CheckDistance(client, entity)
    return entity:GetPos():DistToSqr(client:GetPos()) < self.MaxInteractionDistance
end
