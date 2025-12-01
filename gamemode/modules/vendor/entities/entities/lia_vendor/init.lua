function ENT:SpawnFunction(client, trace)
    local angles = (trace.HitPos - client:GetPos()):Angle()
    angles.r = 0
    angles.p = 0
    angles.y = angles.y + 180
    local entity = ents.Create("lia_vendor")
    entity:SetPos(trace.HitPos)
    entity:SetAngles(angles)
    entity:Spawn()
    return entity
end

function ENT:Use(activator)
    if not hook.Run("CanPlayerAccessVendor", activator, self) then
        if self.messages[VENDOR_NOTRADE] then activator:notifyErrorLocalized("vendorMessageFormat", lia.vendor.getVendorProperty(self, "name"), L(self.messages[VENDOR_NOTRADE], activator)) end
        return
    end

    lia.log.add(activator, "vendorAccess", lia.vendor.getVendorProperty(self, "name"))
    self.receivers = self.receivers or {}
    self.receivers[#self.receivers + 1] = activator
    activator.liaVendor = self
    hook.Run("PlayerAccessVendor", activator, self)
end

function ENT:setStock(itemType, value)
    if not lia.item.list[itemType] then return end
    if not isnumber(value) or value < 0 then value = nil end
    self.items[itemType] = self.items[itemType] or {}
    if not self.items[itemType][VENDOR_MAXSTOCK] then self:setMaxStock(itemType, value) end
    self.items[itemType][VENDOR_STOCK] = math.Clamp(value, 0, self.items[itemType][VENDOR_MAXSTOCK])
    net.Start("liaVendorStock")
    net.WriteString(itemType)
    net.WriteUInt(value, 32)
    net.Broadcast()
end

function ENT:addStock(itemType, value)
    if not lia.item.list[itemType] then return end
    local current = self:getStock(itemType)
    if not current then return end
    self:setStock(itemType, self:getStock(itemType) + (value or 1))
end

function ENT:takeStock(itemType, value)
    if not lia.item.list[itemType] then return end
    if not self.items[itemType] or not self.items[itemType][VENDOR_MAXSTOCK] then return end
    self:addStock(itemType, -(value or 1))
end

function ENT:setMaxStock(itemType, value)
    if value == 0 or not isnumber(value) then value = 0 end
    self.items[itemType] = self.items[itemType] or {}
    self.items[itemType][VENDOR_MAXSTOCK] = value
    net.Start("liaVendorMaxStock")
    net.WriteString(itemType)
    net.WriteUInt(value, 32)
    net.Broadcast()
end

function ENT:setFactionAllowed(factionID, isAllowed)
    if not isnumber(factionID) then return end
    if isAllowed then
        self.factions[factionID] = true
    else
        self.factions[factionID] = nil
    end

    net.Start("liaVendorAllowFaction")
    net.WriteUInt(factionID, 8)
    net.WriteBool(self.factions[factionID])
    net.Broadcast()
    if self.receivers then
        for _, client in ipairs(self.receivers) do
            if not hook.Run("CanPlayerAccessVendor", client, self) then self:removeReceiver(client) end
        end
    end
end

function ENT:setClassAllowed(classID, isAllowed)
    if not isnumber(classID) then return end
    if isAllowed then
        self.classes[classID] = true
    else
        self.classes[classID] = nil
    end

    net.Start("liaVendorAllowClass")
    net.WriteUInt(classID, 8)
    net.WriteBool(self.classes[classID])
    net.Broadcast()
end

function ENT:removeReceiver(client, requestedByPlayer)
    if self.receivers then table.RemoveByValue(self.receivers, client) end
    if client.liaVendor == self then client.liaVendor = nil end
    if requestedByPlayer then return end
    if not lia.shuttingDown then
        net.Start("liaVendorExit")
        net.Send(client)
        lia.log.add(client, "vendorExit", lia.vendor.getVendorProperty(self, "name"))
    end
end

local ALLOWED_MODES = {
    [VENDOR_SELLANDBUY] = true,
    [VENDOR_SELLONLY] = true,
    [VENDOR_BUYONLY] = true
}

function ENT:setName(name)
    lia.vendor.setVendorProperty(self, "name", name)
    net.Start("liaVendorEdit")
    net.WriteString("name")
    net.Broadcast()
end

function ENT:setTradeMode(itemType, mode)
    if not lia.item.list[itemType] then return end
    if not ALLOWED_MODES[mode] then mode = nil end
    self.items[itemType] = self.items[itemType] or {}
    self.items[itemType][VENDOR_MODE] = mode
    net.Start("liaVendorMode")
    net.WriteString(itemType)
    net.WriteInt(mode or -1, 8)
    net.Broadcast()
end

function ENT:setItemPrice(itemType, value)
    if not lia.item.list[itemType] then return end
    if not isnumber(value) or value < 0 then value = nil end
    self.items[itemType] = self.items[itemType] or {}
    self.items[itemType][VENDOR_PRICE] = value
    net.Start("liaVendorPrice")
    net.WriteString(itemType)
    net.WriteInt(value or -1, 32)
    net.Broadcast()
end

function ENT:setItemStock(itemType, value)
    if not lia.item.list[itemType] then return end
    if not isnumber(value) or value < 0 then value = nil end
    self.items[itemType] = self.items[itemType] or {}
    self.items[itemType][VENDOR_STOCK] = value
    net.Start("liaVendorStock")
    net.WriteString(itemType)
    net.WriteInt(value, 32)
    net.Broadcast()
end

function ENT:setItemMaxStock(itemType, value)
    if not lia.item.list[itemType] then return end
    if not isnumber(value) or value < 0 then value = nil end
    self.items[itemType] = self.items[itemType] or {}
    self.items[itemType][VENDOR_MAXSTOCK] = value
    net.Start("liaVendorMaxStock")
    net.WriteString(itemType)
    net.WriteInt(value, 32)
    net.Broadcast()
end

function ENT:OnRemove()
    LiliaVendors[self:EntIndex()] = nil
    if not lia.shuttingDown then
        net.Start("liaVendorExit")
        if self.receivers and #self.receivers > 0 then
            net.Send(self.receivers)
        else
            net.Broadcast()
        end
    end

    if lia.shuttingDown or self.liaIsSafe then return end
end

function ENT:setModel(model)
    assert(isstring(model), L("vendorModelString"))
    model = model:lower()
    self:SetModel(model)
    if self:isReadyForAnim() then self:setAnim() end
    hook.Run("UpdateEntityPersistence", self)
    net.Start("liaVendorEdit")
    net.WriteString("model")
    net.Broadcast()
end

function ENT:setSkin(skin)
    skin = tonumber(skin) or 0
    self:SetSkin(skin)
    hook.Run("UpdateEntityPersistence", self)
    net.Start("liaVendorEdit")
    net.WriteString("skin")
    net.Broadcast()
end

function ENT:setBodyGroup(id, value)
    id = tonumber(id) or 0
    value = tonumber(value) or 0
    self:SetBodygroup(id, value)
    hook.Run("UpdateEntityPersistence", self)
    net.Start("liaVendorEdit")
    net.WriteString("bodygroup")
    net.Broadcast()
end

function ENT:setAnimation(animation)
    lia.vendor.setVendorProperty(self, "animation", animation or "")
    if self:isReadyForAnim() then self:setAnim() end
    hook.Run("UpdateEntityPersistence", self)
    net.Start("liaVendorEdit")
    net.WriteString("animation")
    net.Broadcast()
end

function ENT:loadPreset(name)
    name = string.lower(name)
    if name == "none" then
        self.items = {}
        hook.Run("UpdateEntityPersistence", self)
        self:syncToAll()
        return
    end

    local preset = lia.vendor and lia.vendor.getPreset(name)
    if not preset then return end
    self.items = {}
    for itemType, itemData in pairs(preset) do
        if lia.item.list[itemType] and istable(itemData) then
            self.items[itemType] = {}
            if itemData[VENDOR_PRICE] ~= nil then self.items[itemType][VENDOR_PRICE] = tonumber(itemData[VENDOR_PRICE]) end
            if itemData[VENDOR_STOCK] ~= nil then self.items[itemType][VENDOR_STOCK] = tonumber(itemData[VENDOR_STOCK]) end
            if itemData[VENDOR_MAXSTOCK] ~= nil then self.items[itemType][VENDOR_MAXSTOCK] = tonumber(itemData[VENDOR_MAXSTOCK]) end
            if itemData[VENDOR_MODE] ~= nil then self.items[itemType][VENDOR_MODE] = tonumber(itemData[VENDOR_MODE]) end
        end
    end

    hook.Run("UpdateEntityPersistence", self)
    self:syncToAll()
end

function ENT:sync(client)
    net.Start("liaVendorSync")
    net.WriteEntity(self)
    net.WriteUInt(table.Count(self.items), 16)
    for itemType, item in pairs(self.items) do
        net.WriteString(itemType)
        net.WriteInt(item[VENDOR_PRICE] or -1, 32)
        net.WriteInt(item[VENDOR_STOCK] or -1, 32)
        net.WriteInt(item[VENDOR_MAXSTOCK] or -1, 32)
        net.WriteInt(item[VENDOR_MODE] or -1, 8)
    end

    net.Send(client)
end

function ENT:syncToAll()
    net.Start("liaVendorSync")
    net.WriteEntity(self)
    net.WriteUInt(table.Count(self.items), 16)
    for itemType, item in pairs(self.items) do
        net.WriteString(itemType)
        net.WriteInt(item[VENDOR_PRICE] or -1, 32)
        net.WriteInt(item[VENDOR_STOCK] or -1, 32)
        net.WriteInt(item[VENDOR_MAXSTOCK] or -1, 32)
        net.WriteInt(item[VENDOR_MODE] or -1, 8)
    end

    net.Broadcast()
end

function ENT:addReceiver(client, noSync)
    self.receivers = self.receivers or {}
    if not table.HasValue(self.receivers, client) then self.receivers[#self.receivers + 1] = client end
    if noSync then return end
    self:sync(client)
end
