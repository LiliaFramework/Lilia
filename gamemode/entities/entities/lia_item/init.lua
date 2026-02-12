function ENT:Initialize()
    self:SetModel("models/props_junk/cardboard_box002b.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self.health = 100
    local physObj = self:GetPhysicsObject()
    if IsValid(physObj) then physObj:EnableMotion(false) end
    timer.Simple(3, function()
        if IsValid(physObj) then
            physObj:EnableMotion(true)
            physObj:Wake()
        end
    end)

    hook.Run("OnItemSpawned", self)
end

function ENT:OnTakeDamage(dmginfo)
    local itemTable = self:getItemTable()
    if not itemTable or not itemTable.CanBeDestroyed then return end
    local damage = dmginfo:GetDamage()
    self.health = self.health - damage
    if self.health <= 0 and not self.breaking then
        self.breaking = true
        SafeRemoveEntity(self)
    end
end

function ENT:setItem(itemID)
    local itemTable = lia.item.instances[itemID]
    if not itemTable then return SafeRemoveEntity(self) end
    itemTable:sync()
    local model = hook.Run("GetItemDropModel", itemTable, self) or itemTable:getModel() or itemTable.model
    if not model or model == "" then model = "models/props_junk/cardboard_box002b.mdl" end
    self:SetModel(model)
    self:SetSkin(itemTable.skin or 0)
    self.health = itemTable.health or 100
    local paintMat = hook.Run("PaintItem", itemTable)
    if isstring(paintMat) and paintMat ~= "" then
        self:SetMaterial(paintMat)
    else
        self:SetMaterial(itemTable.material or "")
    end

    self:SetColor(itemTable.color or color_white)
    if itemTable.scale and itemTable.scale ~= 1 then self:SetModelScale(itemTable.scale) end
    if itemTable.bodygroups and istable(itemTable.bodygroups) then
        for k, v in pairs(itemTable.bodygroups) do
            local bodygroupID
            if isnumber(k) then
                bodygroupID = k
            elseif isstring(k) then
                bodygroupID = self:FindBodygroupByName(k)
            end

            if bodygroupID and bodygroupID >= 0 then self:SetBodygroup(bodygroupID, v) end
        end
    end

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:setNetVar("id", itemTable.uniqueID)
    self:setNetVar("instanceID", itemTable.id)
    self.liaItemID = itemID
    if table.Count(itemTable.data) > 0 then self:setNetVar("data", itemTable.data) end
    local physObj = self:GetPhysicsObject()
    if not IsValid(physObj) then
        local min, max = Vector(-8, -8, -8), Vector(8, 8, 8)
        self:PhysicsInitBox(min, max)
        self:SetCollisionBounds(min, max)
    end

    if IsValid(physObj) then
        physObj:EnableMotion(true)
        physObj:Wake()
    end

    if not itemTable.temp then
        local shouldSave = hook.Run("ShouldSaveItem", itemTable, self)
        if shouldSave ~= false then
            local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
            local map = lia.data.getEquivalencyMap(game.GetMap())
            local condition = "schema = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map) .. " AND itemID = " .. tonumber(itemID)
            lia.db.delete("saveditems", condition):next(function()
                lia.db.insertTable({
                    schema = gamemode,
                    map = map,
                    itemID = itemID,
                    pos = lia.data.encodetable(self:GetPos()),
                    angles = lia.data.encodetable(self:GetAngles())
                }, nil, "saveditems")
            end)
        end
    end

    hook.Run("OnItemCreated", itemTable, self)
end

function ENT:breakEffects()
    self:EmitSound("physics/cardboard/cardboard_box_break" .. math.random(1, 3) .. ".wav")
    local position = self:LocalToWorld(self:OBBCenter())
    local effect = EffectData()
    effect:SetStart(position)
    effect:SetOrigin(position)
    effect:SetScale(3)
    util.Effect("GlassImpact", effect)
end

function ENT:OnRemove()
    local itemTable = self:getItemTable()
    if self.breaking then
        self:breakEffects()
        if itemTable and itemTable.onDestroyed then itemTable:onDestroyed(self) end
        self.breaking = false
    end

    if not lia.shuttingDown and not self.liaIsSafe and self.liaItemID then lia.item.deleteByID(self.liaItemID) end
    if SERVER and not lia.shuttingDown and self.liaItemID then
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = lia.data.getEquivalencyMap(game.GetMap())
        local condition = "schema = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map) .. " AND itemID = " .. tonumber(self.liaItemID)
        lia.db.delete("saveditems", condition)
    end
end

function ENT:Think()
    local itemTable = self:getItemTable()
    if itemTable and itemTable.think then return itemTable:think(self) end
    self:NextThink(CurTime() + 1)
    return true
end
