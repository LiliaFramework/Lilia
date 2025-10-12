LiliaVendors = LiliaVendors or {}
ENT.Type = "anim"
ENT.PrintName = L("entityVendorName")
ENT.Author = "Samael"
ENT.Contact = "@liliaplayer"
ENT.Category = "Lilia"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.isVendor = true
ENT.NoPhysgun = true
ENT.NoRemover = true
ENT.DrawEntityInfo = true
ENT.IsPersistent = true
function ENT:setupVars()
    if SERVER then
        self:setNetVar("name", L("vendorDefaultName"))
        self:setNetVar("preset", "none")
        self:setNetVar("animation", "")
    end

    self.receivers = self.receivers or {}
    self.items = {}
    self.factions = {}
    self.messages = {}
    self.classes = {}
    self.hasSetupVars = true
end

function ENT:Initialize()
    if CLIENT then
        timer.Simple(1, function()
            if not IsValid(self) then return end
            if self:isReadyForAnim() then
                self:setAnim()
            else
                timer.Simple(2, function() if IsValid(self) and self:isReadyForAnim() then self:setAnim() end end)
                timer.Simple(5, function() if IsValid(self) and self:isReadyForAnim() then self:setAnim() end end)
            end
        end)
        return
    end

    self.receivers = self.receivers or {}
    self:SetModel("models/mossman.mdl")
    self:SetUseType(SIMPLE_USE)
    self:SetMoveType(MOVETYPE_NONE)
    self:DrawShadow(true)
    self:SetSolid(SOLID_BBOX)
    self:PhysicsInit(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    self:setupVars()
    local physObj = self:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:EnableMotion(false)
        physObj:Sleep()
    end

    LiliaVendors[self:EntIndex()] = self
    timer.Simple(0.5, function() if IsValid(self) then if self:isReadyForAnim() then self:setAnim() end end end)
end

function ENT:getWelcomeMessage()
    return self:getNetVar("welcomeMessage", L("vendorWelcomeMessage"))
end

function ENT:getStock(uniqueID)
    if self.items[uniqueID] and self.items[uniqueID][VENDOR_MAXSTOCK] then return self.items[uniqueID][VENDOR_STOCK] or 0, self.items[uniqueID][VENDOR_MAXSTOCK] end
end

function ENT:getMaxStock(itemType)
    if self.items[itemType] then return self.items[itemType][VENDOR_MAXSTOCK] end
end

function ENT:isItemInStock(itemType, amount)
    amount = amount or 1
    assert(isnumber(amount), L("vendorAmountNumber"))
    local info = self.items[itemType]
    if not info then return false end
    if not info[VENDOR_MAXSTOCK] then return true end
    return info[VENDOR_STOCK] >= amount
end

function ENT:getPrice(uniqueID, isSellingToVendor)
    local price = lia.item.list[uniqueID] and self.items[uniqueID] and self.items[uniqueID][VENDOR_PRICE] or lia.item.list[uniqueID]:getPrice()
    local overridePrice = hook.Run("getPriceOverride", self, uniqueID, price, isSellingToVendor)
    if overridePrice then
        price = overridePrice
    else
        if isSellingToVendor then price = math.floor(price * self:getSellScale()) end
    end
    return price
end

function ENT:getTradeMode(itemType)
    if self.items[itemType] then return self.items[itemType][VENDOR_MODE] end
end

function ENT:isClassAllowed(classID)
    local class = lia.class.list[classID]
    if not class then return false end
    local faction = lia.faction.indices[class.faction]
    if faction and self:isFactionAllowed(faction.index) then return true end
    return self.classes[classID]
end

function ENT:isFactionAllowed(factionID)
    return self.factions[factionID]
end

function ENT:getSellScale()
    local scale = lia.config.get("vendorSaleScale", 0.5)
    local hookScale = hook.Run("GetVendorSaleScale", self)
    if hookScale ~= nil and hookScale ~= false then
        local numHookScale = tonumber(hookScale)
        if numHookScale then return math.Clamp(numHookScale, 0.1, 2.0) end
    end

    local finalScale = tonumber(scale) or 0.5
    return math.Clamp(finalScale, 0.1, 2.0)
end

function ENT:getName()
    return self:getNetVar("name", "")
end

function ENT:getPreset()
    return self:getNetVar("preset", "none")
end

function ENT:isReadyForAnim()
    local model = self:GetModel()
    local sequenceList = self:GetSequenceList()
    local sequenceCount = self:GetSequenceCount()
    local ready = model and model ~= "" and sequenceList and sequenceCount and sequenceCount > 0
    return ready
end

function ENT:setAnim()
    if not self:isReadyForAnim() then return end
    local customAnim = self:getNetVar("animation", "")
    local sequenceList = self:GetSequenceList()
    if customAnim and customAnim ~= "" then
        for k, v in ipairs(sequenceList) do
            if string.find(string.lower(v), string.lower(customAnim)) or v:lower() == customAnim:lower() then
                self:SetSequence(k)
                self:SetCycle(0)
                self:SetPlaybackRate(1)
                return
            end
        end
    end

    for k, v in ipairs(sequenceList) do
        local lowerV = v:lower()
        if lowerV:find("idle") and not lowerV:find("idlenoise") then
            self:SetSequence(k)
            self:SetCycle(0)
            self:SetPlaybackRate(1)
            return
        end
    end

    for k, v in ipairs(sequenceList) do
        local lowerV = v:lower()
        if lowerV:find("relaxed") or lowerV:find("alert") then
            self:SetSequence(k)
            self:SetCycle(0)
            self:SetPlaybackRate(1)
            return
        end
    end

    for k, v in ipairs(sequenceList) do
        local lowerV = v:lower()
        if not lowerV:find("body") and not lowerV:find("spine") and not lowerV:find("neck") and not lowerV:find("head") and not lowerV:find("trans") then
            self:SetSequence(k)
            self:SetCycle(0)
            self:SetPlaybackRate(1)
            return
        end
    end

    if self:GetSequenceCount() > 0 then
        self:SetSequence(1)
        self:SetCycle(0)
        self:SetPlaybackRate(1)
    end
end
