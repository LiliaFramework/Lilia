# Inventory Meta

This page documents methods available on the `Inventory` meta table, representing inventory containers in the Lilia framework.

---

## Overview

The `Inventory` meta table provides comprehensive inventory management functionality including item storage, retrieval, networking, persistence, and access control. These methods form the foundation for character inventories, storage containers, and item management systems within the Lilia framework, supporting both server-side data persistence and client-side synchronization.

---

### getData

**Purpose**

Retrieves data associated with the inventory by key.

**Parameters**

* `key` (*string*): The data key to retrieve.
* `default` (*any*): Default value if the key doesn't exist.

**Returns**

* `value` (*any*): The data value or default.

**Realm**

Shared.

**Example Usage**

```lua
local function getInventoryInfo(inventory, player)
    local name = inventory:getData("name", "Unnamed Inventory")
    local capacity = inventory:getData("capacity", 100)
    
    if IsValid(player) then
        player:ChatPrint("Inventory: " .. name .. " (Capacity: " .. capacity .. ")")
    end
end

concommand.Add("inventory_info", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            getInventoryInfo(inv, ply)
        end
    end
end)
```

---

### extend

**Purpose**

Creates a new inventory class that extends the base inventory functionality.

**Parameters**

* `className` (*string*): The name of the new inventory class.

**Returns**

* `subClass` (*table*): The new inventory class.

**Realm**

Shared.

**Example Usage**

```lua
local function createCustomInventoryClass()
    local CustomInventory = lia.Inventory:extend("CustomInventory")
    
    function CustomInventory:configure(config)
        config.data = config.data or {}
        config.data.maxWeight = 1000
        config.data.specialSlots = 5
    end
    
    function CustomInventory:canAccess(action, context)
        if action == "transfer" then
            return context.client:hasFlags("a")
        end
        return true
    end
    
    CustomInventory:register("custom")
    return CustomInventory
end

hook.Add("Initialize", "CreateCustomInventory", createCustomInventoryClass)
```

---

### configure

**Purpose**

Configures the inventory with default settings and rules.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupInventoryConfiguration(inventory)
    inventory:configure()
    print("Inventory configured with default settings.")
end

hook.Add("InventoryCreated", "SetupConfiguration", function(inventory)
    setupInventoryConfiguration(inventory)
end)
```

---

### addDataProxy

**Purpose**

Adds a data change proxy to monitor specific data keys.

**Parameters**

* `key` (*string*): The data key to monitor.
* `onChange` (*function*): Function to call when the data changes.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupInventoryDataProxy(inventory)
    inventory:addDataProxy("capacity", function(oldValue, newValue)
        print("Inventory capacity changed from " .. tostring(oldValue) .. " to " .. tostring(newValue))
    end)
end

hook.Add("InventoryCreated", "SetupDataProxy", function(inventory)
    setupInventoryDataProxy(inventory)
end)
```

---

### getItemsByUniqueID

**Purpose**

Retrieves all items in the inventory with a specific unique ID.

**Parameters**

* `uniqueID` (*string*): The unique ID to search for.
* `onlyMain` (*boolean|nil*): Whether to only search main inventory items.

**Returns**

* `items` (*table*): Array of items with the specified unique ID.

**Realm**

Shared.

**Example Usage**

```lua
local function findItemsByType(inventory, itemType, player)
    local items = inventory:getItemsByUniqueID(itemType)
    if IsValid(player) then
        player:ChatPrint("Found " .. #items .. " items of type: " .. itemType)
        for i, item in ipairs(items) do
            player:ChatPrint("  " .. i .. ". " .. item:getName() .. " (ID: " .. item:getID() .. ")")
        end
    end
end

concommand.Add("find_items", function(ply, cmd, args)
    local char = ply:getChar()
    local itemType = args[1]
    if char and itemType then
        local inv = char:getInv()
        if inv then
            findItemsByType(inv, itemType, ply)
        end
    end
end)
```

---

### register

**Purpose**

Registers the inventory class as a new inventory type.

**Parameters**

* `typeID` (*string*): The unique type identifier for the inventory.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function registerCustomInventoryType()
    local CustomInventory = lia.Inventory:extend("CustomInventory")
    
    function CustomInventory:configure(config)
        config.data = config.data or {}
        config.data.maxWeight = 500
    end
    
    CustomInventory:register("custom_storage")
    print("Custom inventory type registered: custom_storage")
end

hook.Add("Initialize", "RegisterCustomInventory", registerCustomInventoryType)
```

---

### new

**Purpose**

Creates a new instance of the inventory type.

**Parameters**

*None.*

**Returns**

* `inventory` (*Inventory*): The new inventory instance.

**Realm**

Shared.

**Example Usage**

```lua
local function createNewInventory(inventoryType, player)
    local inventory = lia.inventory.types[inventoryType]:new()
    if IsValid(player) then
        player:ChatPrint("Created new " .. inventoryType .. " inventory!")
    end
    return inventory
end

concommand.Add("create_inventory", function(ply, cmd, args)
    local inventoryType = args[1]
    if inventoryType and lia.inventory.types[inventoryType] then
        createNewInventory(inventoryType, ply)
    end
end)
```

---

### tostring

**Purpose**

Returns a string representation of the inventory.

**Parameters**

*None.*

**Returns**

* `representation` (*string*): String representation of the inventory.

**Realm**

Shared.

**Example Usage**

```lua
local function displayInventoryInfo(inventory, player)
    local info = inventory:tostring()
    if IsValid(player) then
        player:ChatPrint("Inventory: " .. info)
    end
end

concommand.Add("inventory_string", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            displayInventoryInfo(inv, ply)
        end
    end
end)
```

---

### getType

**Purpose**

Gets the inventory type definition.

**Parameters**

*None.*

**Returns**

* `type` (*table*): The inventory type definition.

**Realm**

Shared.

**Example Usage**

```lua
local function getInventoryTypeInfo(inventory, player)
    local type = inventory:getType()
    if IsValid(player) and type then
        player:ChatPrint("Inventory type: " .. (type.className or "Unknown"))
    end
end

concommand.Add("inventory_type", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            getInventoryTypeInfo(inv, ply)
        end
    end
end)
```

---

### onDataChanged

**Purpose**

Handles data changes and triggers associated proxies.

**Parameters**

* `key` (*string*): The data key that changed.
* `oldValue` (*any*): The previous value.
* `newValue` (*any*): The new value.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupInventoryDataChangeHandler(inventory)
    function inventory:onDataChanged(key, oldValue, newValue)
        print("Data changed: " .. key .. " from " .. tostring(oldValue) .. " to " .. tostring(newValue))
        -- Call parent method
        lia.Inventory.onDataChanged(self, key, oldValue, newValue)
    end
end

hook.Add("InventoryCreated", "SetupDataChangeHandler", function(inventory)
    setupInventoryDataChangeHandler(inventory)
end)
```

---

### getItems

**Purpose**

Retrieves all items in the inventory.

**Parameters**

*None.*

**Returns**

* `items` (*table*): Table of all items in the inventory.

**Realm**

Shared.

**Example Usage**

```lua
local function listAllItems(inventory, player)
    local items = inventory:getItems()
    if IsValid(player) then
        player:ChatPrint("Inventory contains " .. table.Count(items) .. " items:")
        for itemID, item in pairs(items) do
            player:ChatPrint("  " .. item:getName() .. " (ID: " .. itemID .. ")")
        end
    end
end

concommand.Add("list_items", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            listAllItems(inv, ply)
        end
    end
end)
```

---

### getItemsOfType

**Purpose**

Retrieves all items in the inventory with a specific unique ID.

**Parameters**

* `itemType` (*string*): The unique ID to search for.

**Returns**

* `items` (*table*): Array of items with the specified unique ID.

**Realm**

Shared.

**Example Usage**

```lua
local function countItemsOfType(inventory, itemType, player)
    local items = inventory:getItemsOfType(itemType)
    if IsValid(player) then
        player:ChatPrint("You have " .. #items .. " " .. itemType .. " items.")
    end
end

concommand.Add("count_items", function(ply, cmd, args)
    local char = ply:getChar()
    local itemType = args[1]
    if char and itemType then
        local inv = char:getInv()
        if inv then
            countItemsOfType(inv, itemType, ply)
        end
    end
end)
```

---

### getFirstItemOfType

**Purpose**

Retrieves the first item in the inventory with a specific unique ID.

**Parameters**

* `itemType` (*string*): The unique ID to search for.

**Returns**

* `item` (*Item|nil*): The first item with the specified unique ID, or nil if not found.

**Realm**

Shared.

**Example Usage**

```lua
local function useFirstItemOfType(inventory, itemType, player)
    local item = inventory:getFirstItemOfType(itemType)
    if item then
        if IsValid(player) then
            player:ChatPrint("Using " .. item:getName())
        end
        item:call("onUse", player)
    else
        if IsValid(player) then
            player:ChatPrint("No " .. itemType .. " items found.")
        end
    end
end

concommand.Add("use_item", function(ply, cmd, args)
    local char = ply:getChar()
    local itemType = args[1]
    if char and itemType then
        local inv = char:getInv()
        if inv then
            useFirstItemOfType(inv, itemType, ply)
        end
    end
end)
```

---

### hasItem

**Purpose**

Checks if the inventory contains any items with a specific unique ID.

**Parameters**

* `itemType` (*string*): The unique ID to check for.

**Returns**

* `hasItem` (*boolean*): True if the inventory contains the item type.

**Realm**

Shared.

**Example Usage**

```lua
local function checkItemAvailability(inventory, itemType, player)
    if inventory:hasItem(itemType) then
        if IsValid(player) then
            player:ChatPrint("You have " .. itemType .. " items available!")
        end
        return true
    else
        if IsValid(player) then
            player:ChatPrint("You don't have any " .. itemType .. " items.")
        end
        return false
    end
end

concommand.Add("check_item", function(ply, cmd, args)
    local char = ply:getChar()
    local itemType = args[1]
    if char and itemType then
        local inv = char:getInv()
        if inv then
            checkItemAvailability(inv, itemType, ply)
        end
    end
end)
```

---

### getItemCount

**Purpose**

Gets the total quantity of items with a specific unique ID, or all items if no type specified.

**Parameters**

* `itemType` (*string|nil*): The unique ID to count, or nil for all items.

**Returns**

* `count` (*number*): The total quantity of items.

**Realm**

Shared.

**Example Usage**

```lua
local function displayItemCount(inventory, itemType, player)
    local count = inventory:getItemCount(itemType)
    if IsValid(player) then
        if itemType then
            player:ChatPrint("You have " .. count .. " " .. itemType .. " items.")
        else
            player:ChatPrint("You have " .. count .. " total items.")
        end
    end
end

concommand.Add("item_count", function(ply, cmd, args)
    local char = ply:getChar()
    local itemType = args[1]
    if char then
        local inv = char:getInv()
        if inv then
            displayItemCount(inv, itemType, ply)
        end
    end
end)
```

---

### getID

**Purpose**

Gets the unique identifier of the inventory.

**Parameters**

*None.*

**Returns**

* `id` (*number*): The inventory's unique ID.

**Realm**

Shared.

**Example Usage**

```lua
local function displayInventoryID(inventory, player)
    local id = inventory:getID()
    if IsValid(player) then
        player:ChatPrint("Inventory ID: " .. id)
    end
end

concommand.Add("inventory_id", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            displayInventoryID(inv, ply)
        end
    end
end)
```

---

### eq

**Purpose**

Checks if two inventories are equal by comparing their IDs.

**Parameters**

* `other` (*Inventory*): The other inventory to compare with.

**Returns**

* `isEqual` (*boolean*): True if the inventories are equal.

**Realm**

Shared.

**Example Usage**

```lua
local function compareInventories(inventory1, inventory2, player)
    if inventory1:eq(inventory2) then
        if IsValid(player) then
            player:ChatPrint("These are the same inventory!")
        end
        return true
    else
        if IsValid(player) then
            player:ChatPrint("These are different inventories.")
        end
        return false
    end
end

concommand.Add("compare_inventories", function(ply)
    local char = ply:getChar()
    if char then
        local inv1 = char:getInv()
        local inv2 = char:getInv()
        if inv1 and inv2 then
            compareInventories(inv1, inv2, ply)
        end
    end
end)
```

---

### addItem

**Purpose**

Adds an item to the inventory and handles database persistence.

**Parameters**

* `item` (*Item*): The item to add to the inventory.
* `noReplicate` (*boolean|nil*): Whether to skip replication.

**Returns**

* `inventory` (*Inventory*): The inventory instance for chaining.

**Realm**

Server.

**Example Usage**

```lua
local function addItemToInventory(inventory, item, player)
    inventory:addItem(item)
    if IsValid(player) then
        player:ChatPrint("Added " .. item:getName() .. " to inventory!")
    end
end

concommand.Add("add_item", function(ply, cmd, args)
    local char = ply:getChar()
    local itemType = args[1]
    if char and itemType then
        local inv = char:getInv()
        local item = lia.item.new(itemType)
        if inv and item then
            addItemToInventory(inv, item, ply)
        end
    end
end)
```

---

### add

**Purpose**

Alias for addItem method.

**Parameters**

* `item` (*Item*): The item to add to the inventory.

**Returns**

* `inventory` (*Inventory*): The inventory instance for chaining.

**Realm**

Server.

**Example Usage**

```lua
local function addItemToInventory(inventory, item, player)
    inventory:add(item)
    if IsValid(player) then
        player:ChatPrint("Added " .. item:getName() .. " to inventory!")
    end
end

concommand.Add("add_item_simple", function(ply, cmd, args)
    local char = ply:getChar()
    local itemType = args[1]
    if char and itemType then
        local inv = char:getInv()
        local item = lia.item.new(itemType)
        if inv and item then
            addItemToInventory(inv, item, ply)
        end
    end
end)
```

---

### syncItemAdded

**Purpose**

Synchronizes an added item with clients.

**Parameters**

* `item` (*Item*): The item that was added.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function addAndSyncItem(inventory, item, player)
    inventory:addItem(item)
    inventory:syncItemAdded(item)
    if IsValid(player) then
        player:ChatPrint("Item added and synchronized!")
    end
end

concommand.Add("add_sync_item", function(ply, cmd, args)
    local char = ply:getChar()
    local itemType = args[1]
    if char and itemType then
        local inv = char:getInv()
        local item = lia.item.new(itemType)
        if inv and item then
            addAndSyncItem(inv, item, ply)
        end
    end
end)
```

---

### initializeStorage

**Purpose**

Initializes the inventory storage in the database.

**Parameters**

* `initialData` (*table*): Initial data for the inventory.

**Returns**

* `promise` (*Promise*): Promise that resolves with the inventory ID.

**Realm**

Server.

**Example Usage**

```lua
local function createInventoryWithData(inventoryType, initialData, player)
    local inventory = lia.inventory.types[inventoryType]:new()
    inventory:initializeStorage(initialData):next(function(id)
        if IsValid(player) then
            player:ChatPrint("Inventory created with ID: " .. id)
        end
    end)
end

concommand.Add("create_inventory_with_data", function(ply, cmd, args)
    local inventoryType = args[1]
    local initialData = {
        name = "Test Inventory",
        capacity = 100
    }
    if inventoryType then
        createInventoryWithData(inventoryType, initialData, ply)
    end
end)
```

---

### restoreFromStorage

**Purpose**

Restores inventory data from storage (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setupInventoryRestore(inventory)
    function inventory:restoreFromStorage()
        print("Restoring inventory " .. self:getID() .. " from storage...")
        -- Custom restoration logic here
    end
end

hook.Add("InventoryCreated", "SetupRestore", function(inventory)
    setupInventoryRestore(inventory)
end)
```

---

### removeItem

**Purpose**

Removes an item from the inventory by ID.

**Parameters**

* `itemID` (*number*): The ID of the item to remove.
* `preserveItem` (*boolean|nil*): Whether to preserve the item instance.

**Returns**

* `promise` (*Promise*): Promise that resolves when removal is complete.

**Realm**

Server.

**Example Usage**

```lua
local function removeItemFromInventory(inventory, itemID, player)
    inventory:removeItem(itemID):next(function()
        if IsValid(player) then
            player:ChatPrint("Item removed from inventory!")
        end
    end)
end

concommand.Add("remove_item", function(ply, cmd, args)
    local char = ply:getChar()
    local itemID = tonumber(args[1])
    if char and itemID then
        local inv = char:getInv()
        if inv then
            removeItemFromInventory(inv, itemID, ply)
        end
    end
end)
```

---

### remove

**Purpose**

Alias for removeItem method.

**Parameters**

* `itemID` (*number*): The ID of the item to remove.

**Returns**

* `promise` (*Promise*): Promise that resolves when removal is complete.

**Realm**

Server.

**Example Usage**

```lua
local function removeItemFromInventory(inventory, itemID, player)
    inventory:remove(itemID):next(function()
        if IsValid(player) then
            player:ChatPrint("Item removed from inventory!")
        end
    end)
end

concommand.Add("remove_item_simple", function(ply, cmd, args)
    local char = ply:getChar()
    local itemID = tonumber(args[1])
    if char and itemID then
        local inv = char:getInv()
        if inv then
            removeItemFromInventory(inv, itemID, ply)
        end
    end
end)
```

---

### setData

**Purpose**

Sets data for the inventory and handles persistence.

**Parameters**

* `key` (*string*): The data key to set.
* `value` (*any*): The value to set.

**Returns**

* `inventory` (*Inventory*): The inventory instance for chaining.

**Realm**

Server.

**Example Usage**

```lua
local function setInventoryData(inventory, key, value, player)
    inventory:setData(key, value)
    if IsValid(player) then
        player:ChatPrint("Set " .. key .. " to " .. tostring(value))
    end
end

concommand.Add("set_inventory_data", function(ply, cmd, args)
    local char = ply:getChar()
    local key = args[1]
    local value = args[2]
    if char and key and value then
        local inv = char:getInv()
        if inv then
            setInventoryData(inv, key, value, ply)
        end
    end
end)
```

---

### canAccess

**Purpose**

Checks if a client can perform a specific action on the inventory.

**Parameters**

* `action` (*string*): The action to check access for.
* `context` (*table|nil*): Additional context for the access check.

**Returns**

* `canAccess` (*boolean*): True if the client can perform the action.
* `reason` (*string|nil*): Reason for denial if access is denied.

**Realm**

Server.

**Example Usage**

```lua
local function checkInventoryAccess(inventory, player, action)
    local canAccess, reason = inventory:canAccess(action, {client = player})
    if canAccess then
        player:ChatPrint("You have access to " .. action .. " this inventory!")
    else
        player:ChatPrint("Access denied: " .. (reason or "No reason provided"))
    end
end

concommand.Add("check_inventory_access", function(ply, cmd, args)
    local char = ply:getChar()
    local action = args[1]
    if char and action then
        local inv = char:getInv()
        if inv then
            checkInventoryAccess(inv, ply, action)
        end
    end
end)
```

---

### addAccessRule

**Purpose**

Adds an access rule to the inventory.

**Parameters**

* `rule` (*function*): The access rule function.
* `priority` (*number|nil*): Priority for the rule (higher = earlier evaluation).

**Returns**

* `inventory` (*Inventory*): The inventory instance for chaining.

**Realm**

Server.

**Example Usage**

```lua
local function setupInventoryAccessRules(inventory)
    inventory:addAccessRule(function(inv, action, context)
        if action == "transfer" and context.client:hasFlags("a") then
            return true
        end
        return nil
    end)
    
    inventory:addAccessRule(function(inv, action, context)
        if action == "view" then
            return true
        end
        return nil
    end)
end

hook.Add("InventoryCreated", "SetupAccessRules", function(inventory)
    setupInventoryAccessRules(inventory)
end)
```

---

### removeAccessRule

**Purpose**

Removes an access rule from the inventory.

**Parameters**

* `rule` (*function*): The access rule function to remove.

**Returns**

* `inventory` (*Inventory*): The inventory instance for chaining.

**Realm**

Server.

**Example Usage**

```lua
local function removeInventoryAccessRule(inventory, rule, player)
    inventory:removeAccessRule(rule)
    if IsValid(player) then
        player:ChatPrint("Access rule removed!")
    end
end

concommand.Add("remove_access_rule", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            -- Remove a specific rule (would need to store reference)
            -- removeInventoryAccessRule(inv, someRule, ply)
        end
    end
end)
```

---

### getRecipients

**Purpose**

Gets all clients that should receive inventory updates.

**Parameters**

*None.*

**Returns**

* `recipients` (*table*): Array of player entities that can access the inventory.

**Realm**

Server.

**Example Usage**

```lua
local function notifyInventoryRecipients(inventory, message)
    local recipients = inventory:getRecipients()
    for _, player in ipairs(recipients) do
        if IsValid(player) then
            player:ChatPrint(message)
        end
    end
end

concommand.Add("notify_inventory", function(ply, cmd, args)
    local char = ply:getChar()
    local message = table.concat(args, " ")
    if char and message then
        local inv = char:getInv()
        if inv then
            notifyInventoryRecipients(inv, message)
        end
    end
end)
```

---

### onInstanced

**Purpose**

Called when the inventory is instantiated (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setupInventoryInstance(inventory)
    function inventory:onInstanced()
        print("Inventory " .. self:getID() .. " has been instantiated!")
        -- Custom instantiation logic here
    end
end

hook.Add("InventoryCreated", "SetupInstance", function(inventory)
    setupInventoryInstance(inventory)
end)
```

---

### onLoaded

**Purpose**

Called when the inventory is loaded from storage (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setupInventoryLoaded(inventory)
    function inventory:onLoaded()
        print("Inventory " .. self:getID() .. " has been loaded!")
        -- Custom loading logic here
    end
end

hook.Add("InventoryCreated", "SetupLoaded", function(inventory)
    setupInventoryLoaded(inventory)
end)
```

---

### loadItems

**Purpose**

Loads items from the database for the inventory.

**Parameters**

*None.*

**Returns**

* `promise` (*Promise*): Promise that resolves with the loaded items.

**Realm**

Server.

**Example Usage**

```lua
local function loadInventoryItems(inventory, player)
    inventory:loadItems():next(function(items)
        if IsValid(player) then
            player:ChatPrint("Loaded " .. table.Count(items) .. " items from database!")
        end
    end)
end

concommand.Add("load_inventory_items", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            loadInventoryItems(inv, ply)
        end
    end
end)
```

---

### onItemsLoaded

**Purpose**

Called when items are loaded from the database (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setupItemsLoaded(inventory)
    function inventory:onItemsLoaded(items)
        print("Items loaded for inventory " .. self:getID() .. ": " .. table.Count(items))
        -- Custom items loaded logic here
    end
end

hook.Add("InventoryCreated", "SetupItemsLoaded", function(inventory)
    setupItemsLoaded(inventory)
end)
```

---

### instance

**Purpose**

Creates a new instance of the inventory type with initial data.

**Parameters**

* `initialData` (*table*): Initial data for the inventory.

**Returns**

* `inventory` (*Inventory*): The new inventory instance.

**Realm**

Server.

**Example Usage**

```lua
local function createInventoryInstance(inventoryType, initialData, player)
    local inventory = lia.inventory.types[inventoryType]:instance(initialData)
    if IsValid(player) then
        player:ChatPrint("Created inventory instance with ID: " .. inventory:getID())
    end
    return inventory
end

concommand.Add("create_inventory_instance", function(ply, cmd, args)
    local inventoryType = args[1]
    local initialData = {
        name = "Test Instance",
        capacity = 50
    }
    if inventoryType then
        createInventoryInstance(inventoryType, initialData, ply)
    end
end)
```

---

### syncData

**Purpose**

Synchronizes inventory data with clients.

**Parameters**

* `key` (*string*): The data key to sync.
* `recipients` (*table|nil*): Specific recipients to sync with.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function syncInventoryData(inventory, key, player)
    inventory:syncData(key, {player})
    if IsValid(player) then
        player:ChatPrint("Inventory data synchronized!")
    end
end

concommand.Add("sync_inventory_data", function(ply, cmd, args)
    local char = ply:getChar()
    local key = args[1]
    if char and key then
        local inv = char:getInv()
        if inv then
            syncInventoryData(inv, key, ply)
        end
    end
end)
```

---

### sync

**Purpose**

Synchronizes the entire inventory with clients.

**Parameters**

* `recipients` (*table|nil*): Specific recipients to sync with.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function syncInventory(inventory, player)
    inventory:sync({player})
    if IsValid(player) then
        player:ChatPrint("Inventory synchronized!")
    end
end

concommand.Add("sync_inventory", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            syncInventory(inv, ply)
        end
    end
end)
```

---

### delete

**Purpose**

Deletes the inventory from the database.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function deleteInventory(inventory, player)
    inventory:delete()
    if IsValid(player) then
        player:ChatPrint("Inventory deleted!")
    end
end

concommand.Add("delete_inventory", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            deleteInventory(inv, ply)
        end
    end
end)
```

---

### destroy

**Purpose**

Destroys the inventory instance and removes it from memory.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function destroyInventory(inventory, player)
    inventory:destroy()
    if IsValid(player) then
        player:ChatPrint("Inventory destroyed!")
    end
end

concommand.Add("destroy_inventory", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            destroyInventory(inv, ply)
        end
    end
end)
```

---

### show

**Purpose**

Shows the inventory interface to the client.

**Parameters**

* `parent` (*Panel|nil*): Parent panel for the inventory interface.

**Returns**

* `panel` (*Panel*): The inventory interface panel.

**Realm**

Client.

**Example Usage**

```lua
local function showInventoryInterface(inventory, parent)
    local panel = inventory:show(parent)
    if panel then
        print("Inventory interface shown!")
    end
end

concommand.Add("show_inventory", function(ply)
    local char = ply:getChar()
    if char then
        local inv = char:getInv()
        if inv then
            showInventoryInterface(inv)
        end
    end
end)
```

---

### getWidth

**Purpose**

Gets the width of the grid inventory.

**Parameters**

*None.*

**Returns**

* `width` (*number*): The width of the inventory grid.

**Realm**

Shared.

**Example Usage**

```lua
local function checkInventorySize(inv)
    if inv:getType() == "GridInv" then
        local width = inv:getWidth()
        local height = inv:getHeight()
        print("Inventory size: " .. width .. "x" .. height)
    end
end
```

---

### getHeight

**Purpose**

Gets the height of the grid inventory.

**Parameters**

*None.*

**Returns**

* `height` (*number*): The height of the inventory grid.

**Realm**

Shared.

**Example Usage**

```lua
local function createCustomGrid(inv, newWidth, newHeight)
    if inv:getType() == "GridInv" then
        local currentWidth = inv:getWidth()
        local currentHeight = inv:getHeight()
        
        if newWidth > currentWidth or newHeight > currentHeight then
            inv:setSize(newWidth, newHeight)
        end
    end
end
```

---

### getSize

**Purpose**

Gets both the width and height of the grid inventory.

**Parameters**

*None.*

**Returns**

* `width` (*number*): The width of the inventory grid.
* `height` (*number*): The height of the inventory grid.

**Realm**

Shared.

**Example Usage**

```lua
local function displayInventoryInfo(inv)
    if inv:getType() == "GridInv" then
        local width, height = inv:getSize()
        print("Grid inventory dimensions: " .. width .. "x" .. height)
    end
end
```

---

### canAdd

**Purpose**

Checks if an item can be added to the grid inventory based on size constraints.

**Parameters**

* `item` (*string|table*): Item type string or item table to check.

**Returns**

* `canAdd` (*boolean*): True if the item can fit in the inventory.

**Realm**

Shared.

**Example Usage**

```lua
local function tryAddItem(inv, itemType)
    if inv:getType() == "GridInv" then
        if inv:canAdd(itemType) then
            inv:add(itemType)
            print("Item added successfully")
        else
            print("Item too large for inventory")
        end
    end
end
```

---

### doesItemOverlapWithOther

**Purpose**

Checks if a test item would overlap with another item at the specified position.

**Parameters**

* `testItem` (*table*): The item to test for overlap.
* `x` (*number*): X coordinate to test.
* `y` (*number*): Y coordinate to test.
* `item` (*table*): The existing item to check against.

**Returns**

* `overlaps` (*boolean*): True if the items would overlap.

**Realm**

Shared.

**Example Usage**

```lua
local function checkItemPlacement(inv, item, x, y)
    if inv:getType() == "GridInv" then
        for _, existingItem in pairs(inv:getItems()) do
            if inv:doesItemOverlapWithOther(item, x, y, existingItem) then
                print("Item would overlap with existing item")
                return false
            end
        end
        return true
    end
end
```

---

### doesFitInventory

**Purpose**

Checks if an item can fit anywhere in the inventory, including in bag items.

**Parameters**

* `item` (*string|table*): Item type string or item table to check.

**Returns**

* `fits` (*boolean*): True if the item can fit somewhere in the inventory.

**Realm**

Shared.

**Example Usage**

```lua
local function canStoreItem(inv, itemType)
    if inv:getType() == "GridInv" then
        return inv:doesFitInventory(itemType)
    end
    return false
end
```

---

### canItemFitInInventory

**Purpose**

Checks if an item can fit at a specific position within the inventory bounds.

**Parameters**

* `item` (*table*): The item to check.
* `x` (*number*): X coordinate to check.
* `y` (*number*): Y coordinate to check.

**Returns**

* `fits` (*boolean*): True if the item fits within inventory bounds.

**Realm**

Shared.

**Example Usage**

```lua
local function validatePosition(inv, item, x, y)
    if inv:getType() == "GridInv" then
        return inv:canItemFitInInventory(item, x, y)
    end
    return false
end
```

---

### doesItemFitAtPos

**Purpose**

Checks if an item can be placed at a specific position without overlapping other items.

**Parameters**

* `testItem` (*table*): The item to test placement for.
* `x` (*number*): X coordinate to test.
* `y` (*number*): Y coordinate to test.

**Returns**

* `fits` (*boolean*): True if the item can be placed at the position.
* `blockingItem` (*table|nil*): The item that would block placement if false.

**Realm**

Shared.

**Example Usage**

```lua
local function tryPlaceItem(inv, item, x, y)
    if inv:getType() == "GridInv" then
        local fits, blockingItem = inv:doesItemFitAtPos(item, x, y)
        if fits then
            inv:add(item, x, y)
        else
            print("Cannot place item - blocked by: " .. tostring(blockingItem))
        end
    end
end
```

---

### findFreePosition

**Purpose**

Finds the first available position for an item in the inventory.

**Parameters**

* `item` (*table*): The item to find a position for.

**Returns**

* `x` (*number|nil*): X coordinate of free position, or nil if none found.
* `y` (*number|nil*): Y coordinate of free position, or nil if none found.

**Realm**

Shared.

**Example Usage**

```lua
local function autoPlaceItem(inv, itemType)
    if inv:getType() == "GridInv" then
        local item = lia.item.list[itemType]
        if item then
            local x, y = inv:findFreePosition(item)
            if x and y then
                inv:add(itemType, x, y)
            else
                print("No space available for item")
            end
        end
    end
end
```

---

### getItems

**Purpose**

Gets all items in the inventory, optionally excluding recursive bag items.

**Parameters**

* `noRecurse` (*boolean|nil*): If true, excludes items from bags.

**Returns**

* `items` (*table*): Table of items in the inventory.

**Realm**

Shared.

**Example Usage**

```lua
local function countInventoryItems(inv)
    if inv:getType() == "GridInv" then
        local items = inv:getItems(true) -- Only main inventory items
        local totalItems = table.Count(items)
        print("Main inventory contains " .. totalItems .. " items")
        
        local allItems = inv:getItems() -- Including bag items
        local totalWithBags = table.Count(allItems)
        print("Total items including bags: " .. totalWithBags)
    end
end
```

---

### setSize

**Purpose**

Sets the size of the grid inventory.

**Parameters**

* `w` (*number*): New width for the inventory.
* `h` (*number*): New height for the inventory.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function resizeInventory(inv, newWidth, newHeight)
    if inv:getType() == "GridInv" then
        inv:setSize(newWidth, newHeight)
        print("Inventory resized to " .. newWidth .. "x" .. newHeight)
    end
end
```

---

### wipeItems

**Purpose**

Removes all items from the inventory.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function clearInventory(inv)
    if inv:getType() == "GridInv" then
        inv:wipeItems()
        print("Inventory cleared of all items")
    end
end
```

---

### setOwner

**Purpose**

Sets the owner of the inventory and optionally syncs to the owner.

**Parameters**

* `owner` (*Player|number*): Player entity or character ID to set as owner.
* `fullUpdate` (*boolean|nil*): If true, syncs the inventory to the owner.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function transferInventory(inv, newOwner)
    if inv:getType() == "GridInv" then
        inv:setOwner(newOwner, true) -- Sync to new owner
        print("Inventory ownership transferred")
    end
end
```

---

### add

**Purpose**

Adds an item to the grid inventory with advanced positioning and stacking support.

**Parameters**

* `itemTypeOrItem` (*string|table*): Item type string or item table to add.
* `xOrQuantity` (*number|nil*): X coordinate or quantity for stacking.
* `yOrData` (*number|table|nil*): Y coordinate or data table.
* `noReplicate` (*boolean|nil*): If true, doesn't replicate to clients.

**Returns**

* `promise` (*Promise*): Promise that resolves with the added item(s).

**Realm**

Server.

**Example Usage**

```lua
local function addItemToGrid(inv, itemType, x, y)
    if inv:getType() == "GridInv" then
        inv:add(itemType, x, y):next(function(item)
            print("Item added at position " .. x .. "," .. y)
        end):catch(function(error)
            print("Failed to add item: " .. error)
        end)
    end
end

-- Stacking example
local function addStackedItems(inv, itemType, quantity)
    if inv:getType() == "GridInv" then
        inv:add(itemType, quantity):next(function(items)
            print("Added " .. #items .. " stacked items")
        end)
    end
end
```

---

### remove

**Purpose**

Removes items from the grid inventory by type or ID.

**Parameters**

* `itemTypeOrID` (*string|number*): Item type string or item ID to remove.
* `quantity` (*number|nil*): Number of items to remove (default: 1).

**Returns**

* `promise` (*Promise*): Promise that resolves when removal is complete.

**Realm**

Server.

**Example Usage**

```lua
local function removeItemsFromGrid(inv, itemType, quantity)
    if inv:getType() == "GridInv" then
        inv:remove(itemType, quantity):next(function()
            print("Removed " .. quantity .. " " .. itemType .. " items")
        end):catch(function(error)
            print("Failed to remove items: " .. error)
        end)
    end
end
```

---

### requestTransfer

**Purpose**

Requests a transfer of an item to another inventory at a specific position.

**Parameters**

* `itemID` (*number*): ID of the item to transfer.
* `destinationID` (*number|nil*): ID of destination inventory, or nil for world.
* `x` (*number*): X coordinate in destination inventory.
* `y` (*number*): Y coordinate in destination inventory.

**Returns**

*None.*

**Realm**

Client.

**Example Usage**

```lua
local function transferItemToInventory(inv, itemID, destInvID, x, y)
    if inv:getType() == "GridInv" then
        inv:requestTransfer(itemID, destInvID, x, y)
    end
end
```

---
