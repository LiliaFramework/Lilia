function ENT:Initialize()
    self:SetModel(hook.Run("GetMoneyModel", self:getAmount()) or lia.config.get("MoneyModel"))
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
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
    local character = activator:getChar()
    if not character then return end
    if self.client == activator and character:getID() ~= self.charID then
        activator:notifyErrorLocalized("cantUseThisOnSameChar")
        return
    end
    if hook.Run("CanPickupMoney", activator, self) ~= false then
        activator:getChar():giveMoney(self:getAmount())
        hook.Run("OnPickupMoney", activator, self)
        SafeRemoveEntity(self)
    end
end
function ENT:setAmount(amount)
    self:setNetVar("amount", amount)
end