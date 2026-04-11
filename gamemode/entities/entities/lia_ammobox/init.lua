local function getHeldAmmoInfo(client)
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) then return end
    local ammoTypeID = weapon:GetPrimaryAmmoType()
    if not isnumber(ammoTypeID) or ammoTypeID < 0 then return end
    local ammoType = game.GetAmmoName(ammoTypeID)
    if not isstring(ammoType) or ammoType == "" then return end
    return weapon, ammoTypeID, ammoType
end

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:SetUseType(SIMPLE_USE)
    local physObj = self:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:EnableMotion(true)
        physObj:Wake()
    else
        local min, max = Vector(-8, -8, -8), Vector(8, 8, 8)
        self:PhysicsInitBox(min, max)
        self:SetCollisionBounds(min, max)
    end
end

function ENT:Use(activator)
    if self.liaUsed then return end
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if not activator:getChar() then return end
    if hook.Run("CanPlayerUseAmmoBox", activator, self) == false then return end
    local weapon, ammoTypeID, ammoType = getHeldAmmoInfo(activator)
    if not weapon then
        activator:notifyErrorLocalized("liaAmmoBoxInvalidWeapon")
        return
    end

    self.liaUsed = true
    local ammoBefore = activator:GetAmmoCount(ammoTypeID)
    activator:GiveAmmo(self:getAmmoAmount(weapon), ammoType, true)
    local givenAmount = math.max(activator:GetAmmoCount(ammoTypeID) - ammoBefore, 0)
    if givenAmount <= 0 then
        self.liaUsed = nil
        activator:notifyErrorLocalized("liaAmmoBoxFull")
        return
    end

    activator:EmitSound("items/ammo_pickup.wav", 80)
    hook.Run("OnAmmoBoxUsed", activator, self, weapon, ammoType, givenAmount)
    SafeRemoveEntity(self)
end
