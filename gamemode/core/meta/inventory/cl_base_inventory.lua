local Inventory = lia.Inventory

net.Receive("liaInventoryData", function()
    local id = net.ReadType()
    local key = net.ReadString()
    local value = net.ReadType()
    local instance = lia.inventory.instances[id]

    if not instance then
        ErrorNoHalt("Got data " .. key .. " for non-existent instance " .. id)

        return
    end

    local oldValue = instance.data[key]
    instance.data[key] = value
    instance:onDataChanged(key, oldValue, value)
    hook.Run("InventoryDataChanged", instance, key, oldValue, value)
end)

net.Receive("liaInventoryInit", function()
    local id = net.ReadType()
    local typeID = net.ReadString()
    local data = net.ReadTable()
    local instance = lia.inventory.new(typeID)
    instance.id = id
    instance.data = data
    instance.items = {}
    local length = net.ReadUInt(32)
    local data2 = net.ReadData(length)
    local uncompressed_data = util.Decompress(data2)
    local items = util.JSONToTable(uncompressed_data)

    local function readItem(I)
        local c = items[I] -- i

        return c.i, c.u, c.d, c.q
    end

    local datatable = items
    local expectedItems = #datatable

    for i = 1, expectedItems do
        local itemID, itemType, data, quantity = readItem(i)
        local item = lia.item.new(itemType, itemID)
        item.data = table.Merge(item.data, data)
        item.invID = instance.id
        item.quantity = quantity
        instance.items[itemID] = item
        hook.Run("ItemInitialized", item)
    end

    lia.inventory.instances[instance.id] = instance
    hook.Run("InventoryInitialized", instance)

    for _, character in pairs(lia.char.loaded) do
        for index, inventory in pairs(character.vars.inv) do
            if inventory:getID() == id then
                character.vars.inv[index] = instance
            end
        end
    end
end)

net.Receive("liaInventoryAdd", function()
    local itemID = net.ReadUInt(32)
    local invID = net.ReadType()
    local item = lia.item.instances[itemID]
    local inventory = lia.inventory.instances[invID]

    if item and inventory then
        inventory.items[itemID] = item
        hook.Run("InventoryItemAdded", inventory, item)
    end
end)

net.Receive("liaInventoryRemove", function()
    local itemID = net.ReadUInt(32)
    local invID = net.ReadType()
    local item = lia.item.instances[itemID]
    local inventory = lia.inventory.instances[invID]

    if item and inventory and inventory.items[itemID] then
        inventory.items[itemID] = nil
        item.invID = 0
        hook.Run("InventoryItemRemoved", inventory, item)
    end
end)

net.Receive("liaInventoryDelete", function()
    local invID = net.ReadType()
    local instance = lia.inventory.instances[invID]

    if instance then
        hook.Run("InventoryDeleted", instance)
    end

    if invID then
        lia.inventory.instances[invID] = nil
    end
end)

function Inventory:show(parent)
    return lia.inventory.show(self, parent)
end

net.Receive("ixInventoryData", function()
    local id = net.ReadType()
    local key = net.ReadString()
    local value = net.ReadType()
    local instance = lia.inventory.instances[id]

    if not instance then
        ErrorNoHalt("Got data " .. key .. " for non-existent instance " .. id)

        return
    end

    local oldValue = instance.data[key]
    instance.data[key] = value
    instance:onDataChanged(key, oldValue, value)
    hook.Run("InventoryDataChanged", instance, key, oldValue, value)
end)

net.Receive("ixInventoryInit", function()
    local id = net.ReadType()
    local typeID = net.ReadString()
    local data = net.ReadTable()
    local instance = lia.inventory.new(typeID)
    instance.id = id
    instance.data = data
    instance.items = {}
    local length = net.ReadUInt(32)
    local data2 = net.ReadData(length)
    local uncompressed_data = util.Decompress(data2)
    local items = util.JSONToTable(uncompressed_data)

    local function readItem(I)
        local c = items[I] -- i

        return c.i, c.u, c.d, c.q
    end

    local datatable = items
    local expectedItems = #datatable

    for i = 1, expectedItems do
        local itemID, itemType, data, quantity = readItem(i)
        local item = lia.item.new(itemType, itemID)
        item.data = table.Merge(item.data, data)
        item.invID = instance.id
        item.quantity = quantity
        instance.items[itemID] = item
        hook.Run("ItemInitialized", item)
    end

    lia.inventory.instances[instance.id] = instance
    hook.Run("InventoryInitialized", instance)

    for _, character in pairs(lia.char.loaded) do
        for index, inventory in pairs(character.vars.inv) do
            if inventory:getID() == id then
                character.vars.inv[index] = instance
            end
        end
    end
end)

net.Receive("ixInventoryAdd", function()
    local itemID = net.ReadUInt(32)
    local invID = net.ReadType()
    local item = lia.item.instances[itemID]
    local inventory = lia.inventory.instances[invID]

    if item and inventory then
        inventory.items[itemID] = item
        hook.Run("InventoryItemAdded", inventory, item)
    end
end)

net.Receive("ixInventoryRemove", function()
    local itemID = net.ReadUInt(32)
    local invID = net.ReadType()
    local item = lia.item.instances[itemID]
    local inventory = lia.inventory.instances[invID]

    if item and inventory and inventory.items[itemID] then
        inventory.items[itemID] = nil
        item.invID = 0
        hook.Run("InventoryItemRemoved", inventory, item)
    end
end)

net.Receive("ixInventoryDelete", function()
    local invID = net.ReadType()
    local instance = lia.inventory.instances[invID]

    if instance then
        hook.Run("InventoryDeleted", instance)
    end

    if invID then
        lia.inventory.instances[invID] = nil
    end
end)

function Inventory:Show(parent)
    return lia.inventory.show(self, parent)
end