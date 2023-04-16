local ITEM = lia.meta.item or {}
debug.getregistry().Item = lia.meta.item -- for FindMetaTable.
ITEM.__index = ITEM
ITEM.name = "INVALID ITEM"
ITEM.description = ITEM.desc or "[[INVALID ITEM]]"
ITEM.desc = ITEM.desc or "[[INVALID ITEM]]"
ITEM.id = ITEM.id or 0
ITEM.uniqueID = "undefined"
ITEM.isItem = true
ITEM.isStackable = false
ITEM.quantity = 1
ITEM.maxQuantity = 1
ITEM.canSplit = true

function ITEM:getQuantity()
    if self.id == 0 then return self.maxQuantity end -- for display purpose.

    return self.quantity
end

function ITEM:GetQuantity()
    if self.id == 0 then return self.maxQuantity end -- for display purpose.

    return self.quantity
end

function ITEM:__eq(other)
    return self:getID() == other:getID()
end

function ITEM:__tostring()
    return "item[" .. self.uniqueID .. "][" .. self.id .. "]"
end

function ITEM:getID()
    return self.id
end

function ITEM:GetID()
    return self.id
end

if SERVER then
    function ITEM:GetName()
        return self.name
    end

    function ITEM:GetDesc()
        return self.desc
    end

    function ITEM:getName()
        return self.name
    end

    function ITEM:getDesc()
        return self.desc
    end
else
    function ITEM:GetName()
        return L(self.name)
    end

    function ITEM:GetDesc()
        return L(self.desc)
    end

    function ITEM:getName()
        return L(self.name)
    end

    function ITEM:getDesc()
        return L(self.desc)
    end
end

function ITEM:GetModel()
    return self.model
end

function ITEM:getModel()
    return self.model
end

function ITEM:GetSkin()
    return self.skin
end

function ITEM:getSkin()
    return self.skin
end

function ITEM:GetPrice()
    local price = self.price

    if self.calcPrice then
        price = self:calcPrice(self.price)
    end

    return price or 0
end

function ITEM:getPrice()
    local price = self.price

    if self.calcPrice then
        price = self:calcPrice(self.price)
    end

    return price or 0
end

function ITEM:Call(method, client, entity, ...)
    local oldPlayer, oldEntity = self.player, self.entity
    self.player = client or self.player
    self.entity = entity or self.entity

    if type(self[method]) == "function" then
        local results = {self[method](self, ...)}

        self.player = oldPlayer
        self.entity = oldEntity

        return unpack(results)
    end

    self.player = oldPlayer
    self.entity = oldEntity
end

function ITEM:call(method, client, entity, ...)
    local oldPlayer, oldEntity = self.player, self.entity
    self.player = client or self.player
    self.entity = entity or self.entity

    if type(self[method]) == "function" then
        local results = {self[method](self, ...)}

        self.player = oldPlayer
        self.entity = oldEntity

        return unpack(results)
    end

    self.player = oldPlayer
    self.entity = oldEntity
end

function ITEM:GetOwner()
    local inventory = lia.inventory.instances[self.invID]
    if inventory and SERVER then return inventory:getRecipients()[1] end
    local id = self:getID()

    for _, v in ipairs(player.GetAll()) do
        local character = v:getChar()
        if character and character:getInv() and character:getInv().items[id] then return v end
    end
end

function ITEM:getOwner()
    local inventory = lia.inventory.instances[self.invID]
    if inventory and SERVER then return inventory:getRecipients()[1] end
    local id = self:getID()

    for _, v in ipairs(player.GetAll()) do
        local character = v:getChar()
        if character and character:getInv() and character:getInv().items[id] then return v end
    end
end

function ITEM:GetData(key, default)
    self.data = self.data or {}
    -- Overload that allows the user to get all the data.
    if key == true then return self.data end
    -- Try to get the data stored in the item.
    local value = self.data[key]
    if value ~= nil then return value end

    -- If that didn't work, back up to getting the data from its entity.
    if IsValid(self.entity) then
        local data = self.entity:getNetVar("data", {})
        local value = data[key]
        if value ~= nil then return value end
    end
    -- All no data was found, return the default (nil if not set).

    return default
end

function ITEM:getData(key, default)
    self.data = self.data or {}
    -- Overload that allows the user to get all the data.
    if key == true then return self.data end
    -- Try to get the data stored in the item.
    local value = self.data[key]
    if value ~= nil then return value end

    -- If that didn't work, back up to getting the data from its entity.
    if IsValid(self.entity) then
        local data = self.entity:getNetVar("data", {})
        local value = data[key]
        if value ~= nil then return value end
    end
    -- All no data was found, return the default (nil if not set).

    return default
end

function ITEM:Hook(name, func)
    if name then
        self.hooks[name] = func
    end
end

function ITEM:hook(name, func)
    if name then
        self.hooks[name] = func
    end
end

function ITEM:PostHook(name, func)
    if name then
        self.postHooks[name] = func
    end
end

function ITEM:postHook(name, func)
    if name then
        self.postHooks[name] = func
    end
end

-- Called after Lilia has stored this item into the list of valid items.
function ITEM:onRegistered()
end

function ITEM:OnRegistered()
end

lia.meta.item = ITEM
lia.util.include("item/sv_item.lua")
lia.util.include("item/sh_item_debug.lua")