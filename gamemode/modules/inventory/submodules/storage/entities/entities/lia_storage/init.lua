local MODULE = MODULE
function ENT:Initialize()
    self:SetModel("models/props_junk/cardboard_box002b.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self.receivers = {}
    if isfunction(self.PostInitialize) then self:PostInitialize() end
    self:PhysicsInit(SOLID_VPHYSICS)
    local physObj = self:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:EnableMotion(true)
        physObj:Wake()
    end
end
function ENT:setInventory(inventory)
    assert(inventory, L("storageInventoryMissing"))
    self:setNetVar("id", inventory:getID())
    hook.Run("StorageInventorySet", self, inventory, false)
end
function ENT:deleteInventory()
    local inventory = self:getInv()
    if inventory then
        inventory:delete()
        if not self.liaForceDelete then hook.Run("StorageEntityRemoved", self, inventory) end
        self:setNetVar("id", nil)
    end
end
function ENT:OnRemove()
    if not self.liaForceDelete then
        if not lia.entityDataLoaded or not MODULE.loadedData then return end
        if self.liaIsSafe then return end
        if lia.shuttingDown then return end
    end
    self:deleteInventory()
end
function ENT:openInv(activator)
    local inventory = self:getInv()
    local storage = self:getStorageInfo()
    if storage and isfunction(storage.onOpen) then storage.onOpen(self, activator) end
    if activator:GetPos():Distance(self:GetPos()) > 128 then
        activator.liaStorageEntity = nil
        return
    end
    self.receivers[activator] = true
    inventory:sync(activator)
    net.Start("liaStorageOpen")
    net.WriteBool(false)
    net.WriteEntity(self)
    net.Send(activator)
    local openSound = self:getStorageInfo().openSound
    self:EmitSound(openSound or "items/ammocrate_open.wav")
end
function ENT:Use(activator)
    if not activator:getChar() then return end
    if (activator.liaNextOpen or 0) > CurTime() then return end
    if IsValid(activator.liaStorageEntity) and (activator.liaNextOpen or 0) <= CurTime() then activator.liaStorageEntity = nil end
    local inventory = self:getInv()
    if not inventory then return end
    activator.liaStorageEntity = self
    if self:getNetVar("locked") then
        local info = self:getStorageInfo() or {}
        local lockSound = info.lockSound
        self:EmitSound(lockSound or "doors/default_locked.wav")
        if self.keypad then
            activator.liaStorageEntity = nil
        else
            net.Start("liaStorageUnlock")
            net.WriteEntity(self)
            net.Send(activator)
        end
    else
        if inventory then self:openInv(activator) end
    end
    activator.liaNextOpen = CurTime() + 0.7 * 1.5
end
