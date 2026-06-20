function ENT:Initialize()
    self:SetModel(lia.config.get("ModelTweakerModel"))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:DrawShadow(true)
    local physicsObject = self:GetPhysicsObject()
    if IsValid(physicsObject) then
        physicsObject:EnableMotion(false)
        physicsObject:Sleep()
    end
end

local function appendWardrobeModels(models, seen, source)
    if not istable(source) then return end
    for modelKey, modelData in pairs(source) do
        local parsed = lia.faction.getModelData(modelKey, modelData)
        if parsed and lia.faction.isModelUsable(parsed.model) then
            local lowered = string.lower(parsed.model)
            if not seen[lowered] then
                seen[lowered] = true
                models[#models + 1] = parsed.model
            end
        elseif istable(modelData) then
            appendWardrobeModels(models, seen, modelData)
        end
    end
end

function ENT:Use(client)
    local character = client:getChar()
    if not character then return end
    local models = {}
    local seen = {}
    if lia.config.get("WardrobeEnableFactionModels", true) then
        local factionData = lia.faction.indices[character:getFaction()]
        appendWardrobeModels(models, seen, factionData and factionData.models)
    end

    if lia.config.get("WardrobeEnableClassModels", true) then
        local classData = lia.class.list[character:getClass()]
        appendWardrobeModels(models, seen, classData and classData.models)
    end

    if #models == 0 then
        client:notifyLocalized("wardrobeNoModels")
        return
    end

    net.Start("SeeModelTable")
    net.WriteTable(models)
    net.Send(client)
end
