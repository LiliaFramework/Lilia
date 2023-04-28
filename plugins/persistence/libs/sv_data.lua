local PLUGIN = PLUGIN

lia.log.addType("persistedEntity", function(client, entity)
    return string.format("%s has persisted '%s'.", client:Name(), entity)
end)

lia.log.addType("unpersistedEntity", function(client, entity)
    return string.format("%s has removed persistence from '%s'.", client:Name(), entity)
end)

-- Prevent from picking up persisted entities
function PLUGIN:PhysgunPickup(client, entity)
    if entity:getNetVar("persistent", false) then return false end
end

function PLUGIN:SaveData()
    local data = {}

    for k, v in ipairs(self.entities) do
        if IsValid(v) then
            local entData = {}
            entData.class = v:GetClass()
            entData.pos = v:GetPos()
            entData.angles = v:GetAngles()
            entData.model = v:GetModel()
            entData.skin = v:GetSkin()
            entData.color = v:GetColor()
            entData.material = v:GetMaterial()
            entData.bodygroups = v:GetBodyGroups()
            local physicsObject = v:GetPhysicsObject()

            if IsValid(physicsObject) then
                entData.moveable = physicsObject:IsMoveable()
            end

            data[#data + 1] = entData
        end
    end

    self:setData(data)
end

function PLUGIN:LoadData()
    for k, v in pairs(self:getData() or {}) do
        local ent = ents.Create(v.class)
        ent:SetPos(v.pos)
        ent:SetAngles(v.angles)
        ent:SetModel(v.model)
        ent:SetSkin(v.skin)
        ent:SetColor(v.color)
        ent:SetMaterial(v.material)
        ent:Spawn()
        ent:Activate()

        for _, data in pairs(v.bodygroups) do
            ent:SetBodygroup(data.id, data.num)
        end

        local physicsObject = ent:GetPhysicsObject()

        if IsValid(physicsObject) then
            physicsObject:EnableMotion(ent.moveable or false)
        end

        ent:setNetVar("persistent", true)
        self.entities[#self.entities + 1] = ent
    end
end