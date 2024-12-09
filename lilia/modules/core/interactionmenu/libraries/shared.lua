MODULE.Options = MODULE.Options or {}
MODULE.SelfOptions = MODULE.SelfOptions or {}
function MODULE:AddOption(name, data)
    self.Options[name] = data
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(135, 206, 250), "[Player Interaction Menu] ", color_white, (firstLoad and "Finished Loading '" .. name .. "'\n") or "Finished Reloading '" .. name .. "'\n")
end

function MODULE:AddLocalOption(name, data)
    self.SelfOptions[name] = data
    MsgC(Color(83, 143, 239), "[Lilia] ", Color(135, 206, 250), "[Action Menu] ", color_white, (firstLoad and "Finished Loading '" .. name .. "'\n") or "Finished Reloading '" .. name .. "'\n")
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