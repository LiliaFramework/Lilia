--------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------
function ENT:Initialize()
    self:SetModel("models/props_junk/watermelon01.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self.health = 50
    local physObj = self:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:EnableMotion(true)
        physObj:Wake()
    end

    hook.Run("OnItemSpawned", self)
end
--------------------------------------------------------------------------------------------------------
function ENT:setHealth(amount)
    self.health = amount
end
--------------------------------------------------------------------------------------------------------
function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    self:setHealth(self.health - damage)
    if self.health <= 0 and not self.breaking then
        self.breaking = true
        self:Remove()
    end
end
--------------------------------------------------------------------------------------------------------
function ENT:setItem(itemID)
    local itemTable = lia.item.instances[itemID]
    if not itemTable then return self:Remove() end
    itemTable:sync()
    local model = itemTable.onGetDropModel and itemTable:onGetDropModel(self) or itemTable:getModel() or itemTable.model
    if itemTable.worldModel then
        model = itemTable.worldModel == true and "models/props_junk/cardboard_box004a.mdl" or itemTable.worldModel
    end

    self:SetModel(model)
    self:SetSkin(itemTable.skin or 0)
    self:SetMaterial(itemTable.material or "")
    self:SetColor(itemTable.color or Color(255, 255, 255))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:setNetVar("id", itemTable.uniqueID)
    self:setNetVar("instanceID", itemTable.id)
    self.liaItemID = itemID
    if table.Count(itemTable.data) > 0 then
        self:setNetVar("data", itemTable.data)
    end

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

    if itemTable.onEntityCreated then
        itemTable:onEntityCreated(self)
    end
end
--------------------------------------------------------------------------------------------------------
function ENT:breakEffects()
    self:EmitSound("physics/cardboard/cardboard_box_break" .. math.random(1, 3) .. ".wav")
    local position = self:LocalToWorld(self:OBBCenter())
    local effect = EffectData()
    effect:SetStart(position)
    effect:SetOrigin(position)
    effect:SetScale(3)
    util.Effect("GlassImpact", effect)
end
--------------------------------------------------------------------------------------------------------
function ENT:OnRemove()
    local itemTable = self:getItemTable()
    if self.breaking then
        self:breakEffects()
        if itemTable and itemTable.onDestroyed then
            itemTable:onDestroyed(self)
        end

        self.breaking = false
    end

    if not lia.shuttingDown and not self.liaIsSafe and self.liaItemID then
        lia.item.deleteByID(self.liaItemID)
    end
end
--------------------------------------------------------------------------------------------------------
function ENT:Think()
    local itemTable = self:getItemTable()
    if itemTable and itemTable.think then return itemTable:think(self) end
    self:NextThink(CurTime() + 1)

    return true
end
--------------------------------------------------------------------------------------------------------