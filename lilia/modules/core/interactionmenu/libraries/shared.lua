MODULE.Options = MODULE.Options or {}
MODULE.SelfOptions = MODULE.SelfOptions or {}
function MODULE:AddOption(name, data)
    self.Options[name] = data
    LiliaInformation("[PIM] Added PIM Interaction " .. name)
end

function MODULE:AddLocalOption(name, data)
    self.SelfOptions[name] = data
    LiliaInformation("[Local PIM] Added Local PIM Interaction " .. name)
end

function MODULE:CheckPossibilities()
    local client = LocalPlayer()
    for _, v in pairs(self.Options) do
        if not client:GetTracedEntity():IsPlayer() then return end
        if v.shouldShow(client, client:GetTracedEntity()) then return true end
    end
    return false
end

function MODULE:InitializedModules()
    hook.Run("AddPIMOption", self.Options)
    hook.Run("AddLocalPIMOption", self.SelfOptions)
end

function MODULE:CheckDistance(client, entity)
    return entity:GetPos():DistToSqr(client:GetPos()) < self.MaxInteractionDistance
end
