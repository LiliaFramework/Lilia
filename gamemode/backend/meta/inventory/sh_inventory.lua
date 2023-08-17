--------------------------------------------------------------------------------------------------------
local Inventory = lia.Inventory or {}
--------------------------------------------------------------------------------------------------------
Inventory.__index = Inventory
lia.Inventory = Inventory
Inventory.data = {}
Inventory.items = {}
Inventory.id = -1
--------------------------------------------------------------------------------------------------------
function Inventory:getData(key, default)
    local value = self.data[key]
    if value == nil then return default end

    return value
end
--------------------------------------------------------------------------------------------------------
function Inventory:extend(className)
    local base = debug.getregistry()[className] or {}
    table.Empty(base)
    base.className = className
    local subClass = table.Inherit(base, self)
    subClass.__index = subClass

    return subClass
end
--------------------------------------------------------------------------------------------------------
function Inventory:configure(config)
end
--------------------------------------------------------------------------------------------------------
function Inventory:addDataProxy(key, onChange)
    local dataConfig = self.config.data[key] or {}
    dataConfig.proxies[#dataConfig.proxies + 1] = onChange
    self.config.data[key] = dataConfig
end
--------------------------------------------------------------------------------------------------------
function Inventory:register(typeID)
    assert(isstring(typeID), "Expected argument #1 of " .. self.className .. ".register to be a string")
    self.typeID = typeID

    self.config = {
        data = {}
    }

    if SERVER then
        self.config.persistent = true
        self.config.accessRules = {}
    end

    self:configure(self.config)
    lia.inventory.newType(self.typeID, self)
end
--------------------------------------------------------------------------------------------------------
function Inventory:new()
    return lia.inventory.new(self.typeID)
end
--------------------------------------------------------------------------------------------------------
function Inventory:__tostring()
    return self.className .. "[" .. tostring(self.id) .. "]"
end
--------------------------------------------------------------------------------------------------------
function Inventory:getType()
    return lia.inventory.types[self.typeID]
end
--------------------------------------------------------------------------------------------------------
function Inventory:onDataChanged(key, oldValue, newValue)
    local keyData = self.config.data[key]

    if keyData and keyData.proxies then
        for _, proxy in pairs(keyData.proxies) do
            proxy(oldValue, newValue)
        end
    end
end
--------------------------------------------------------------------------------------------------------
function Inventory:getItems()
    return self.items
end
--------------------------------------------------------------------------------------------------------
function Inventory:getItemsOfType(itemType)
    local items = {}

    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then
            items[#items + 1] = item
        end
    end

    return items
end
--------------------------------------------------------------------------------------------------------
function Inventory:getFirstItemOfType(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return item end
    end
end
--------------------------------------------------------------------------------------------------------
function Inventory:hasItem(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return true end
    end

    return false
end
--------------------------------------------------------------------------------------------------------
function Inventory:getItemCount(itemType)
    local count = 0

    for _, item in pairs(self:getItems()) do
        if itemType == nil and true or item.uniqueID == itemType then
            count = count + item:getQuantity()
        end
    end

    return count
end
--------------------------------------------------------------------------------------------------------
function Inventory:getID()
    return self.id
end
--------------------------------------------------------------------------------------------------------
function Inventory:__eq(other)
    return self:getID() == other:getID()
end
------------------------------------------------------------------------------------------------------