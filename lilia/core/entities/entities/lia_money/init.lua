--------------------------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------------------------
function ENT:Initialize()
    self:SetModel(hook.Run("GetMoneyModel", self:getAmount()) or lia.config.MoneyModel)
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

--------------------------------------------------------------------------------------------------------------------------
function ENT:Use(activator)
    local character = activator:getChar()
    if not character then return end
    if self.client == activator and character:getID() ~= self.charID then
        activator:notifyLocalized("logged")
        return
    end

    if hook.Run("OnPickupMoney", activator, self) ~= false then self:Remove() end
end
--------------------------------------------------------------------------------------------------------------------------
