MODULE.options = MODULE.options or {}
function MODULE:AddOption(name, data)
    self.options[name] = data
end

function MODULE:CheckPossibilities()
    local client = LocalPlayer()
    for _, v in pairs(self.options) do
        if not client:GetTracedEntity():IsPlayer() then return end
        if v.shouldShow(client, client:GetTracedEntity()) then return true end
    end
    return false
end

function MODULE:InitializedModules()
    hook.Run("AddPIMOption", self.options)
end

function MODULE:CheckDistance(client, entity)
    return entity:GetPos():DistToSqr(client:GetPos()) < self.MaxInteractionDistance
end
