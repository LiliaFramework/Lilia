MODULE.Options = MODULE.Options or {}
MODULE.SelfOptions = MODULE.SelfOptions or {}
local MaxInteractionDistance = 250 * 250
local function AddOption(name)
    LiliaBootstrap("Player Interaction Menu", "Added P2P Action: " .. name)
end

local function AddLocalOption(name)
    LiliaBootstrap("Action Menu", "Added Personal Action: " .. name)
end

function MODULE:AddOption(name, data)
    self.Options[name] = data
    AddOption(name)
end

function MODULE:AddLocalOption(name, data)
    self.SelfOptions[name] = data
    AddLocalOption(name)
end

function MODULE:CheckPossibilities()
    local client = LocalPlayer()
    for _, v in pairs(self.Options) do
        if not client:getTracedEntity():IsPlayer() then return end
        if v.shouldShow(client, client:getTracedEntity()) then return true end
    end
    return false
end

function MODULE:InitializedModules()
    hook.Run("AddPIMOption", self.Options)
    hook.Run("AddLocalPIMOption", self.SelfOptions)
end

function MODULE:CheckDistance(client, entity)
    return entity:GetPos():DistToSqr(client:GetPos()) < MaxInteractionDistance
end