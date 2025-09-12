# Item Library

This page documents the functions for working with items and item management.

---

## Overview

The item library (`lia.item`) provides a comprehensive system for managing items, item creation, item data, and item operations in the Lilia framework, serving as the foundation for all item-related functionality and gameplay mechanics. This library handles sophisticated item management with support for complex item hierarchies, inheritance systems, and modular item components that can be combined to create unique items with specialized properties and behaviors. The system features advanced item creation tools with visual editors, template systems, and procedural generation capabilities for creating diverse and interesting item collections. It includes comprehensive item data management with support for custom properties, metadata systems, and dynamic item behavior based on player actions and environmental conditions. The library provides robust item operations including spawning, despawning, item transformation, and complex interaction systems that integrate with the framework's physics, networking, and persistence systems. Additional features include item validation and integrity checking, performance optimization for large item collections, item search and categorization tools, and integration with the framework's economy, crafting, and trading systems, making it essential for creating rich and engaging item-based gameplay experiences that drive player interaction and economic activity.

---

### lia.item.get

**Purpose**

Gets an item by its unique ID.

**Parameters**

* `itemID` (*string*): The unique item ID.

**Returns**

* `item` (*Item*): The item instance or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get an item by ID
local function getItem(itemID)
    return lia.item.get(itemID)
end

-- Use in a function
local function checkItemExists(itemID)
    local item = lia.item.get(itemID)
    if item then
        print("Item exists: " .. item:getName())
        return true
    else
        print("Item not found: " .. itemID)
        return false
    end
end

-- Use in a function
local function getItemInfo(itemID)
    local item = lia.item.get(itemID)
    if item then
        print("Item: " .. item:getName())
        print("Description: " .. item:getDescription())
        print("Weight: " .. item:getWeight())
        return item
    else
        print("Item not found")
        return nil
    end
end

-- Use in a command
lia.command.add("iteminfo", {
    arguments = {
        {name = "itemid", type = "string"}
    },
    onRun = function(client, arguments)
        local item = lia.item.get(arguments[1])
        if item then
            client:notify("Item: " .. item:getName() .. " - " .. item:getDescription())
        else
            client:notify("Item not found")
        end
    end
})
```

---

### lia.item.getItemByID

**Purpose**

Gets an item by its item type ID.

**Parameters**

* `itemTypeID` (*string*): The item type ID.

**Returns**

* `item` (*Item*): The item instance or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get item by type ID
local function getItemByType(itemTypeID)
    return lia.item.getItemByID(itemTypeID)
end

-- Use in a function
local function createItemFromType(itemTypeID)
    local item = lia.item.getItemByID(itemTypeID)
    if item then
        print("Item created: " .. item:getName())
        return item
    else
        print("Item type not found: " .. itemTypeID)
        return nil
    end
end

-- Use in a function
local function checkItemTypeExists(itemTypeID)
    local item = lia.item.getItemByID(itemTypeID)
    return item ~= nil
end

-- Use in a function
local function getItemTypeInfo(itemTypeID)
    local item = lia.item.getItemByID(itemTypeID)
    if item then
        print("Item Type: " .. item:getName())
        print("Category: " .. item:getCategory())
        print("Rarity: " .. item:getRarity())
        return item
    else
        print("Item type not found")
        return nil
    end
end
```

---

### lia.item.getInstancedItemByID

**Purpose**

Gets an instanced item by its unique ID.

**Parameters**

* `itemID` (*string*): The unique item ID.

**Returns**

* `item` (*Item*): The instanced item or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get instanced item by ID
local function getInstancedItem(itemID)
    return lia.item.getInstancedItemByID(itemID)
end

-- Use in a function
local function checkInstancedItemExists(itemID)
    local item = lia.item.getInstancedItemByID(itemID)
    if item then
        print("Instanced item exists: " .. item:getName())
        return true
    else
        print("Instanced item not found: " .. itemID)
        return false
    end
end

-- Use in a function
local function getInstancedItemData(itemID)
    local item = lia.item.getInstancedItemByID(itemID)
    if item then
        print("Instanced Item: " .. item:getName())
        print("Data: " .. util.TableToJSON(item:getData()))
        return item
    else
        print("Instanced item not found")
        return nil
    end
end

-- Use in a function
local function updateInstancedItemData(itemID, newData)
    local item = lia.item.getInstancedItemByID(itemID)
    if item then
        item:setData(newData)
        print("Item data updated")
        return true
    else
        print("Item not found")
        return false
    end
end
```

---

### lia.item.getItemDataByID

**Purpose**

Gets item data by its item type ID.

**Parameters**

* `itemTypeID` (*string*): The item type ID.

**Returns**

* `itemData` (*table*): The item data table or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get item data by type ID
local function getItemData(itemTypeID)
    return lia.item.getItemDataByID(itemTypeID)
end

-- Use in a function
local function showItemData(itemTypeID)
    local itemData = lia.item.getItemDataByID(itemTypeID)
    if itemData then
        print("Item Data for " .. itemTypeID .. ":")
        for key, value in pairs(itemData) do
            print("- " .. key .. ": " .. tostring(value))
        end
        return itemData
    else
        print("Item data not found")
        return nil
    end
end

-- Use in a function
local function checkItemDataExists(itemTypeID)
    local itemData = lia.item.getItemDataByID(itemTypeID)
    return itemData ~= nil
end

-- Use in a function
local function getItemProperty(itemTypeID, property)
    local itemData = lia.item.getItemDataByID(itemTypeID)
    return itemData and itemData[property] or nil
end
```

---

### lia.item.load

**Purpose**

Loads an item from the database.

**Parameters**

* `itemID` (*string*): The unique item ID.

**Returns**

* `item` (*Item*): The loaded item or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Load item from database
local function loadItem(itemID)
    return lia.item.load(itemID)
end

-- Use in a function
local function loadPlayerItem(client, itemID)
    local item = lia.item.load(itemID)
    if item then
        print("Item loaded for " .. client:Name())
        return item
    else
        print("Failed to load item: " .. itemID)
        return nil
    end
end

-- Use in a function
local function loadStorageItem(storageID, itemID)
    local item = lia.item.load(itemID)
    if item then
        print("Item loaded from storage: " .. storageID)
        return item
    else
        print("Failed to load item from storage")
        return nil
    end
end

-- Use in a function
local function loadAllPlayerItems(client)
    local character = client:getChar()
    if character then
        local inventory = character:getInventory()
        if inventory then
            local items = inventory:getItems()
            for _, item in ipairs(items) do
                lia.item.load(item:getID())
            end
            print("All player items loaded")
        end
    end
end
```

---

### lia.item.isItem

**Purpose**

Checks if an object is an item.

**Parameters**

* `object` (*any*): The object to check.

**Returns**

* `isItem` (*boolean*): True if the object is an item.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if object is an item
local function isItem(object)
    return lia.item.isItem(object)
end

-- Use in a function
local function validateItem(object)
    if lia.item.isItem(object) then
        print("Object is a valid item")
        return true
    else
        print("Object is not an item")
        return false
    end
end

-- Use in a function
local function processItemList(items)
    local validItems = {}
    for _, item in ipairs(items) do
        if lia.item.isItem(item) then
            table.insert(validItems, item)
        end
    end
    print("Valid items: " .. #validItems .. " out of " .. #items)
    return validItems
end

-- Use in a function
local function checkInventoryItems(inventory)
    local items = inventory:getItems()
    for _, item in ipairs(items) do
        if not lia.item.isItem(item) then
            print("Invalid item found in inventory")
            return false
        end
    end
    print("All inventory items are valid")
    return true
end
```

---

### lia.item.getInv

**Purpose**

Gets the inventory for an item.

**Parameters**

* `item` (*Item*): The item to get the inventory for.

**Returns**

* `inventory` (*Inventory*): The item's inventory or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get item inventory
local function getItemInventory(item)
    return lia.item.getInv(item)
end

-- Use in a function
local function checkItemInventory(item)
    local inventory = lia.item.getInv(item)
    if inventory then
        print("Item has inventory: " .. inventory:getName())
        return inventory
    else
        print("Item has no inventory")
        return nil
    end
end

-- Use in a function
local function getItemInventoryItems(item)
    local inventory = lia.item.getInv(item)
    if inventory then
        local items = inventory:getItems()
        print("Item inventory contains " .. #items .. " items")
        return items
    else
        print("Item has no inventory")
        return {}
    end
end

-- Use in a function
local function checkItemInventorySpace(item)
    local inventory = lia.item.getInv(item)
    if inventory then
        local freeSlots = inventory:getFreeSlots()
        print("Item inventory has " .. freeSlots .. " free slots")
        return freeSlots
    else
        print("Item has no inventory")
        return 0
    end
end
```

---

### lia.item.register

**Purpose**

Registers a new item type.

**Parameters**

* `itemData` (*table*): The item data table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register a new item type
local function registerItem(itemData)
    lia.item.register(itemData)
end

-- Use in a function
local function createBasicItem(name, description, weight)
    lia.item.register({
        name = name,
        description = description,
        weight = weight,
        category = "Misc"
    })
    print("Basic item registered: " .. name)
end

-- Use in a function
local function createWeaponItem(name, description, weaponClass)
    lia.item.register({
        name = name,
        description = description,
        weight = 2.5,
        category = "Weapons",
        weaponClass = weaponClass,
        onUse = function(item, client)
            client:Give(weaponClass)
            client:notify("Weapon given: " .. name)
        end
    })
    print("Weapon item registered: " .. name)
end

-- Use in a function
local function createFoodItem(name, description, hungerRestore)
    lia.item.register({
        name = name,
        description = description,
        weight = 0.5,
        category = "Food",
        onUse = function(item, client)
            local character = client:getChar()
            if character then
                character:setHunger(character:getHunger() + hungerRestore)
                client:notify("Hunger restored: " .. hungerRestore)
            end
        end
    })
    print("Food item registered: " .. name)
end
```

---

### lia.item.loadFromDir

**Purpose**

Loads items from a directory.

**Parameters**

* `directory` (*string*): The directory path to load from.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load items from directory
local function loadItems(directory)
    lia.item.loadFromDir(directory)
end

-- Use in a function
local function loadAllItems()
    lia.item.loadFromDir("gamemode/items/")
    print("All items loaded from directory")
end

-- Use in a function
local function reloadItems()
    lia.item.loadFromDir("gamemode/items/")
    print("Items reloaded")
end

-- Use in a hook
hook.Add("Initialize", "LoadItems", function()
    lia.item.loadFromDir("gamemode/items/")
end)
```

---

### lia.item.new

**Purpose**

Creates a new item instance.

**Parameters**

* `itemTypeID` (*string*): The item type ID.
* `data` (*table*): The item data.

**Returns**

* `item` (*Item*): The created item instance.

**Realm**

Server.

**Example Usage**

```lua
-- Create a new item instance
local function createItem(itemTypeID, data)
    return lia.item.new(itemTypeID, data)
end

-- Use in a function
local function giveItemToPlayer(client, itemTypeID, amount)
    local item = lia.item.new(itemTypeID, {
        owner = client:SteamID(),
        character = client:getChar():getID()
    })
    if item then
        local character = client:getChar()
        if character then
            character:getInventory():add(item, amount)
            client:notify("Item given: " .. item:getName())
        end
    end
    return item
end

-- Use in a function
local function createStorageItem(storageID, itemTypeID)
    local item = lia.item.new(itemTypeID, {
        storage = storageID
    })
    if item then
        print("Item created in storage: " .. storageID)
        return item
    else
        print("Failed to create item in storage")
        return nil
    end
end

-- Use in a function
local function createItemWithData(itemTypeID, customData)
    local item = lia.item.new(itemTypeID, customData)
    if item then
        print("Item created with custom data")
        return item
    else
        print("Failed to create item with custom data")
        return nil
    end
end
```

---

### lia.item.registerInv

**Purpose**

Registers an inventory type for items.

**Parameters**

* `invType` (*string*): The inventory type name.
* `invData` (*table*): The inventory data table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register item inventory type
local function registerItemInventory(invType, invData)
    lia.item.registerInv(invType, invData)
end

-- Use in a function
local function createBackpackInventory()
    lia.item.registerInv("backpack", {
        name = "Backpack",
        width = 6,
        height = 4,
        slots = 24
    })
    print("Backpack inventory registered")
end

-- Use in a function
local function createPocketInventory()
    lia.item.registerInv("pocket", {
        name = "Pocket",
        width = 2,
        height = 2,
        slots = 4
    })
    print("Pocket inventory registered")
end

-- Use in a function
local function createToolboxInventory()
    lia.item.registerInv("toolbox", {
        name = "Toolbox",
        width = 4,
        height = 3,
        slots = 12
    })
    print("Toolbox inventory registered")
end
```

---

### lia.item.newInv

**Purpose**

Creates a new item inventory instance.

**Parameters**

* `invType` (*string*): The inventory type name.
* `data` (*table*): The inventory data.

**Returns**

* `inventory` (*Inventory*): The created inventory instance.

**Realm**

Server.

**Example Usage**

```lua
-- Create item inventory instance
local function createItemInventory(invType, data)
    return lia.item.newInv(invType, data)
end

-- Use in a function
local function createBackpackForItem(item)
    local inventory = lia.item.newInv("backpack", {
        owner = item:getOwner(),
        item = item:getID()
    })
    if inventory then
        item:setInventory(inventory)
        print("Backpack created for item")
    end
    return inventory
end

-- Use in a function
local function createPocketForItem(item)
    local inventory = lia.item.newInv("pocket", {
        owner = item:getOwner(),
        item = item:getID()
    })
    if inventory then
        item:setInventory(inventory)
        print("Pocket created for item")
    end
    return inventory
end

-- Use in a function
local function createToolboxForItem(item)
    local inventory = lia.item.newInv("toolbox", {
        owner = item:getOwner(),
        item = item:getID()
    })
    if inventory then
        item:setInventory(inventory)
        print("Toolbox created for item")
    end
    return inventory
end
```

---

### lia.item.createInv

**Purpose**

Creates an inventory for an item.

**Parameters**

* `item` (*Item*): The item to create an inventory for.
* `invType` (*string*): The inventory type name.

**Returns**

* `inventory` (*Inventory*): The created inventory or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Create inventory for item
local function createItemInventory(item, invType)
    return lia.item.createInv(item, invType)
end

-- Use in a function
local function addInventoryToItem(item, invType)
    local inventory = lia.item.createInv(item, invType)
    if inventory then
        print("Inventory added to item: " .. item:getName())
        return inventory
    else
        print("Failed to add inventory to item")
        return nil
    end
end

-- Use in a function
local function makeItemContainer(item, invType)
    local inventory = lia.item.createInv(item, invType)
    if inventory then
        item:setData("container", true)
        print("Item made into container")
        return inventory
    else
        print("Failed to make item into container")
        return nil
    end
end

-- Use in a function
local function upgradeItemWithInventory(item, invType)
    if not item:hasInventory() then
        local inventory = lia.item.createInv(item, invType)
        if inventory then
            print("Item upgraded with inventory")
            return inventory
        end
    else
        print("Item already has inventory")
        return item:getInventory()
    end
end
```

---

### lia.item.addWeaponOverride

**Purpose**

Adds a weapon override for an item.

**Parameters**

* `itemTypeID` (*string*): The item type ID.
* `weaponClass` (*string*): The weapon class.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add weapon override
local function addWeaponOverride(itemTypeID, weaponClass)
    lia.item.addWeaponOverride(itemTypeID, weaponClass)
end

-- Use in a function
local function createWeaponItem(itemTypeID, weaponClass)
    lia.item.register({
        name = "Custom Weapon",
        description = "A custom weapon",
        weight = 2.0,
        category = "Weapons"
    })
    lia.item.addWeaponOverride(itemTypeID, weaponClass)
    print("Weapon item created with override")
end

-- Use in a function
local function addMultipleWeaponOverrides(overrides)
    for itemTypeID, weaponClass in pairs(overrides) do
        lia.item.addWeaponOverride(itemTypeID, weaponClass)
    end
    print("Multiple weapon overrides added")
end

-- Use in a function
local function createWeaponFromItem(itemTypeID, weaponClass)
    local item = lia.item.getItemByID(itemTypeID)
    if item then
        lia.item.addWeaponOverride(itemTypeID, weaponClass)
        print("Weapon override added for " .. item:getName())
    else
        print("Item not found: " .. itemTypeID)
    end
end
```

---

### lia.item.addWeaponToBlacklist

**Purpose**

Adds a weapon to the blacklist.

**Parameters**

* `weaponClass` (*string*): The weapon class to blacklist.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add weapon to blacklist
local function blacklistWeapon(weaponClass)
    lia.item.addWeaponToBlacklist(weaponClass)
end

-- Use in a function
local function blacklistOPWeapons()
    local weapons = {"weapon_rpg", "weapon_c4", "weapon_slam"}
    for _, weapon in ipairs(weapons) do
        lia.item.addWeaponToBlacklist(weapon)
    end
    print("OP weapons blacklisted")
end

-- Use in a function
local function blacklistWeaponByItem(itemTypeID)
    local item = lia.item.getItemByID(itemTypeID)
    if item and item.weaponClass then
        lia.item.addWeaponToBlacklist(item.weaponClass)
        print("Weapon blacklisted: " .. item.weaponClass)
    else
        print("Item not found or has no weapon class")
    end
end

-- Use in a function
local function blacklistWeaponsFromList(weaponList)
    for _, weapon in ipairs(weaponList) do
        lia.item.addWeaponToBlacklist(weapon)
    end
    print("Weapons blacklisted from list")
end
```

---

### lia.item.generateWeapons

**Purpose**

Generates weapon items from registered weapons.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Generate weapon items
local function generateWeapons()
    lia.item.generateWeapons()
end

-- Use in a function
local function createWeaponItems()
    lia.item.generateWeapons()
    print("Weapon items generated")
end

-- Use in a function
local function reloadWeaponItems()
    lia.item.generateWeapons()
    print("Weapon items reloaded")
end

-- Use in a hook
hook.Add("Initialize", "GenerateWeapons", function()
    lia.item.generateWeapons()
end)
```

---

### lia.item.generateAmmo

**Purpose**

Generates ammo items from registered ammo types.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Generate ammo items
local function generateAmmo()
    lia.item.generateAmmo()
end

-- Use in a function
local function createAmmoItems()
    lia.item.generateAmmo()
    print("Ammo items generated")
end

-- Use in a function
local function reloadAmmoItems()
    lia.item.generateAmmo()
    print("Ammo items reloaded")
end

-- Use in a hook
hook.Add("Initialize", "GenerateAmmo", function()
    lia.item.generateAmmo()
end)
```

---

### lia.item.setItemDataByID

**Purpose**

Sets item data by item type ID.

**Parameters**

* `itemTypeID` (*string*): The item type ID.
* `data` (*table*): The data to set.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set item data by type ID
local function setItemData(itemTypeID, data)
    lia.item.setItemDataByID(itemTypeID, data)
end

-- Use in a function
local function updateItemData(itemTypeID, newData)
    lia.item.setItemDataByID(itemTypeID, newData)
    print("Item data updated: " .. itemTypeID)
end

-- Use in a function
local function modifyItemProperties(itemTypeID, properties)
    local currentData = lia.item.getItemDataByID(itemTypeID)
    if currentData then
        for key, value in pairs(properties) do
            currentData[key] = value
        end
        lia.item.setItemDataByID(itemTypeID, currentData)
        print("Item properties modified: " .. itemTypeID)
    else
        print("Item not found: " .. itemTypeID)
    end
end

-- Use in a function
local function resetItemData(itemTypeID)
    local defaultData = {
        name = "Unknown Item",
        description = "An unknown item",
        weight = 1.0,
        category = "Misc"
    }
    lia.item.setItemDataByID(itemTypeID, defaultData)
    print("Item data reset: " .. itemTypeID)
end
```

---

### lia.item.instance

**Purpose**

Creates an item instance from item data.

**Parameters**

* `itemData` (*table*): The item data table.

**Returns**

* `item` (*Item*): The created item instance.

**Realm**

Server.

**Example Usage**

```lua
-- Create item instance from data
local function createItemInstance(itemData)
    return lia.item.instance(itemData)
end

-- Use in a function
local function createItemFromData(itemTypeID, customData)
    local itemData = lia.item.getItemDataByID(itemTypeID)
    if itemData then
        for key, value in pairs(customData) do
            itemData[key] = value
        end
        local item = lia.item.instance(itemData)
        print("Item instance created from data")
        return item
    else
        print("Item data not found")
        return nil
    end
end

-- Use in a function
local function createCustomItem(itemData)
    local item = lia.item.instance(itemData)
    if item then
        print("Custom item created: " .. item:getName())
        return item
    else
        print("Failed to create custom item")
        return nil
    end
end

-- Use in a function
local function createItemWithID(itemData, itemID)
    itemData.id = itemID
    local item = lia.item.instance(itemData)
    if item then
        print("Item created with ID: " .. itemID)
        return item
    else
        print("Failed to create item with ID")
        return nil
    end
end
```

---

### lia.item.deleteByID

**Purpose**

Deletes an item by its unique ID.

**Parameters**

* `itemID` (*string*): The unique item ID.

**Returns**

* `success` (*boolean*): True if deletion was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Delete item by ID
local function deleteItem(itemID)
    return lia.item.deleteByID(itemID)
end

-- Use in a function
local function removeItemFromPlayer(client, itemID)
    local success = lia.item.deleteByID(itemID)
    if success then
        client:notify("Item removed")
        print("Item removed from " .. client:Name())
    else
        client:notify("Failed to remove item")
        print("Failed to remove item from " .. client:Name())
    end
    return success
end

-- Use in a function
local function deleteItemFromStorage(storageID, itemID)
    local success = lia.item.deleteByID(itemID)
    if success then
        print("Item deleted from storage: " .. storageID)
    else
        print("Failed to delete item from storage")
    end
    return success
end

-- Use in a function
local function cleanupOldItems()
    local oldItems = {"old_item_1", "old_item_2", "old_item_3"}
    for _, itemID in ipairs(oldItems) do
        lia.item.deleteByID(itemID)
    end
    print("Old items cleaned up")
end
```

---

### lia.item.loadItemByID

**Purpose**

Loads an item by its unique ID from the database.

**Parameters**

* `itemID` (*string*): The unique item ID.

**Returns**

* `item` (*Item*): The loaded item or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Load item by ID from database
local function loadItemFromDB(itemID)
    return lia.item.loadItemByID(itemID)
end

-- Use in a function
local function loadPlayerItemFromDB(client, itemID)
    local item = lia.item.loadItemByID(itemID)
    if item then
        print("Item loaded from database for " .. client:Name())
        return item
    else
        print("Failed to load item from database")
        return nil
    end
end

-- Use in a function
local function loadStorageItemFromDB(storageID, itemID)
    local item = lia.item.loadItemByID(itemID)
    if item then
        print("Item loaded from database for storage: " .. storageID)
        return item
    else
        print("Failed to load item from database for storage")
        return nil
    end
end

-- Use in a function
local function checkItemExistsInDB(itemID)
    local item = lia.item.loadItemByID(itemID)
    return item ~= nil
end
```

---

### lia.item.spawn

**Purpose**

Spawns an item in the world.

**Parameters**

* `itemTypeID` (*string*): The item type ID.
* `position` (*Vector*): The spawn position.
* `data` (*table*): Optional item data.

**Returns**

* `item` (*Item*): The spawned item or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Spawn item in world
local function spawnItem(itemTypeID, position, data)
    return lia.item.spawn(itemTypeID, position, data)
end

-- Use in a function
local function spawnItemAtPlayer(client, itemTypeID)
    local position = client:GetPos() + client:GetForward() * 50
    local item = lia.item.spawn(itemTypeID, position)
    if item then
        client:notify("Item spawned: " .. item:getName())
        print("Item spawned for " .. client:Name())
    end
    return item
end

-- Use in a function
local function spawnItemAtPosition(itemTypeID, position)
    local item = lia.item.spawn(itemTypeID, position)
    if item then
        print("Item spawned at position: " .. tostring(position))
        return item
    else
        print("Failed to spawn item at position")
        return nil
    end
end

-- Use in a function
local function spawnItemWithData(itemTypeID, position, customData)
    local item = lia.item.spawn(itemTypeID, position, customData)
    if item then
        print("Item spawned with custom data")
        return item
    else
        print("Failed to spawn item with custom data")
        return nil
    end
end
```

---

### lia.item.restoreInv

**Purpose**

Restores an inventory for an item.

**Parameters**

* `item` (*Item*): The item to restore the inventory for.

**Returns**

* `inventory` (*Inventory*): The restored inventory or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Restore item inventory
local function restoreItemInventory(item)
    return lia.item.restoreInv(item)
end

-- Use in a function
local function restoreItemContainer(item)
    local inventory = lia.item.restoreInv(item)
    if inventory then
        print("Item container restored: " .. item:getName())
        return inventory
    else
        print("Failed to restore item container")
        return nil
    end
end

-- Use in a function
local function restoreAllItemContainers()
    local items = lia.item.getAll()
    for _, item in ipairs(items) do
        if item:shouldHaveInventory() then
            lia.item.restoreInv(item)
        end
    end
    print("All item containers restored")
end

-- Use in a function
local function restoreItemInventoryIfNeeded(item)
    if item:shouldHaveInventory() and not item:hasInventory() then
        local inventory = lia.item.restoreInv(item)
        if inventory then
            print("Item inventory restored: " .. item:getName())
        end
    end
end

---

## Definitions

# Item Fields

This document describes all configurable `ITEM` fields in the codebase. Use these to customize item behavior, appearance, interactions, and metadata.

Unspecified fields will use sensible defaults.

---

## Overview

The global `ITEM` table defines per-item settings such as sounds, inventory dimensions, restrictions, stats, and hooks. Unspecified fields will use sensible defaults.

---

## Field Summary

| Field | Type | Default | Description |
|---|---|---|---|
| `BagSound` | `table` | `nil` | Sound played when moving items to/from the bag. |
| `DropOnDeath` | `boolean` | `false` | Deletes the item upon player death. |
| `noDrop` | `boolean` | `false` | Prevents dropping or giving the item. |
| `FactionWhitelist` | `table` | `nil` | Allowed faction indices for vendor interaction. |
| `RequiredSkillLevels` | `table` | `nil` | Skill requirements needed to use the item. |
| `SteamIDWhitelist` | `table` | `nil` | Allowed Steam IDs for vendor interaction. |
| `UsergroupWhitelist` | `table` | `nil` | Allowed user groups for vendor interaction. |
| `VIPWhitelist` | `boolean` | `false` | Restricts usage to VIP players. |
| `ammo` | `string` | `""` | Ammo type provided. |
| `armor` | `number` | `0` | Armor value granted when equipped. |
| `attribBoosts` | `table` | `{}` | Attribute boosts applied when equipped. |
| `base` | `string` | `""` | Base item this item derives from. |
| `canSplit` | `boolean` | `true` | Whether the item stack can be divided. |
| `category` | `string` | `"Miscellaneous"` | Inventory grouping category. |
| `class` | `string` | `""` | Weapon entity class. |
| `contents` | `string` | `""` | HTML contents of a readable book. |
| `desc` | `string` | `"No Description"` | Short description shown to players. |
| `entityid` | `string` | `""` | Entity class spawned by the item. |
| `equipSound` | `string` | `""` | Sound played when equipping. |
| `useSound` | `string` | `""` | Sound played when using the item. |
| `forceRender` | `boolean` | `false` | Always regenerate the spawn icon. |
| `functions` | `table` | `DefaultFunctions` | Table of interaction functions. |
| `health` | `number` | `0` | Amount of health restored when used. |
| `height` | `number` | `1` | Height in inventory grid. |
| `id` | `any` | `0` | Database identifier. |
| `iconCam` | `table` | `nil` | Custom spawn icon camera settings. |
| `invHeight` | `number` | `0` | Internal bag inventory height. |
| `invWidth` | `number` | `0` | Internal bag inventory width. |
| `isBag` | `boolean` | `false` | Marks the item as a bag providing extra inventory. |
| `isBase` | `boolean` | `false` | Indicates the table is a base item. |
| `isOutfit` | `boolean` | `false` | Marks the item as an outfit. |
| `isStackable` | `boolean` | `false` | Enables stacking and merging of item quantities. |
| `isWeapon` | `boolean` | `false` | Marks the item as a weapon. |
| `maxQuantity` | `number` | `1` | Maximum stack size for stackable items. |
| `model` | `string` | `""` | 3D model path for the item. |
| `name` | `string` | `"INVALID NAME"` | Displayed name of the item. |
| `newSkin` | `number` | `0` | Skin index applied to the player model. |
| `outfitCategory` | `string` | `""` | Slot or category for the outfit. |
| `pacData` | `table` | `{}` | PAC3 customization information. |
| `visualData` | `table` | `{}` | Model, skin, and bodygroup overrides for outfits. |
| `bodyGroups` | `table` | `nil` | Bodygroup values applied when equipped. |
| `hooks` | `table` | `{}` | Table of hook callbacks. |
| `postHooks` | `table` | `{}` | Table of post-hook callbacks. |
| `price` | `number` | `0` | Item cost for trading or selling. |
| `quantity` | `number` | `1` | Current amount in the item stack. |
| `rarity` | `string` | `""` | Rarity level affecting vendor color. |
| `replacements` | `string` | `""` | Model replacements when equipped. |
| `unequipSound` | `string` | `""` | Sound played when unequipping. |
| `uniqueID` | `string` | `"undefined"` | Overrides the automatically generated unique identifier. |
| `url` | `string` | `""` | Web address opened when using the item. |
| `weaponCategory` | `string` | `""` | Slot category for the weapon. |
| `width` | `number` | `1` | Width in inventory grid. |
| `scale` | `number` | `1` | Scale factor for item rendering. |
| `skin` | `number` | `0` | Skin index for the item model. |
| `isItem` | `boolean` | `true` | Indicates the table is an item. |
| `calcPrice` | `function` | `nil` | Function to calculate dynamic pricing. |

---

## Field Details

### Audio & Interaction

#### `BagSound`

**Type:**

`table`

**Description:**

Sound played when moving items to/from the bag; specified as `{path, volume}`.

**Example Usage:**

```lua
ITEM.BagSound = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
```

---

#### `equipSound`

**Type:**

`string`

**Description:**

Sound played when equipping the item.

**Example Usage:**

```lua
ITEM.equipSound = "items/ammo_pickup.wav"
```

---

#### `unequipSound`

**Type:**

`string`

**Description:**

Sound played when unequipping the item.

**Example Usage:**

```lua
ITEM.unequipSound = "items/ammo_pickup.wav"
```

---

#### `useSound`

**Type:**

`string`

**Description:**

Sound played when using the item.

**Example Usage:**

```lua
ITEM.useSound = "items/ammo_pickup.wav"
```

---

### Restrictions & Whitelists

#### `DropOnDeath`

**Type:**

`boolean`

**Description:**

Deletes the item upon player death.

**Example Usage:**

```lua
ITEM.DropOnDeath = true
```

---

#### `noDrop`

**Type:**

`boolean`

**Description:**

Prevents the item from being dropped or given to another player.

**Example Usage:**

```lua
ITEM.noDrop = true
```

---

#### `FactionWhitelist`

**Type:**

`table`

**Description:**

Allowed faction indices for vendor interaction.

**Example Usage:**

```lua
ITEM.FactionWhitelist = {FACTION_CITIZEN}
```

---

#### `RequiredSkillLevels`

**Type:**

`table`

**Description:**

Skill requirements needed to use the item.

**Example Usage:**

```lua
ITEM.RequiredSkillLevels = {Strength = 5}
```

---

#### `SteamIDWhitelist`

**Type:**

`table`

**Description:**

Allowed Steam IDs for vendor interaction.

**Example Usage:**

```lua
ITEM.SteamIDWhitelist = {"STEAM_0:1:123"}
```

---

#### `UsergroupWhitelist`

**Type:**

`table`

**Description:**

Allowed user groups for vendor interaction.

**Example Usage:**

```lua
ITEM.UsergroupWhitelist = {"admin"}
```

---

#### `VIPWhitelist`

**Type:**

`boolean`

**Description:**

Restricts usage to VIP players.

**Example Usage:**

```lua
ITEM.VIPWhitelist = true
```

---

### Inventory & Stacking

#### `isBag`

**Type:**

`boolean`

**Description:**

Marks the item as a bag providing extra inventory.

**Example Usage:**

```lua
ITEM.isBag = true
```

---

#### `invWidth`

**Type:**

`number`

**Description:**

Internal bag inventory width.

**Example Usage:**

```lua
ITEM.invWidth = 2
```

---

#### `invHeight`

**Type:**

`number`

**Description:**

Internal bag inventory height.

**Example Usage:**

```lua
ITEM.invHeight = 2
```

---

#### `width`

**Type:**

`number`

**Description:**

Width in the external inventory grid.

**Example Usage:**

```lua
ITEM.width = 2
```

---

#### `height`

**Type:**

`number`

**Description:**

Height in the external inventory grid.

**Example Usage:**

```lua
ITEM.height = 1
```

---

#### `canSplit`

**Type:**

`boolean`

**Description:**

Whether the item stack can be divided.

**Example Usage:**

```lua
ITEM.canSplit = true
```

---

#### `isStackable`

**Type:**

`boolean`

**Description:**

Enables stacking of the item. Combine with `maxQuantity` to cap the stack size and `canSplit` to allow dividing stacks.

**Example Usage:**

```lua
ITEM.isStackable = true
```

---

#### `maxQuantity`

**Type:**

`number`

**Description:**

Maximum stack size for stackable items.

**Example Usage:**

```lua
ITEM.maxQuantity = 10
```

---

#### `quantity`

**Type:**

`number`

**Description:**

Current amount in the item stack; managed with `item:getQuantity()` and `item:setQuantity()`.

**Example Usage:**

```lua
print(item:getQuantity())
```

---

### Categorization & Metadata

#### `isItem`

**Type:**

`boolean`

**Description:**

Indicates the table is an item. This is automatically set to `true` for all items and is used for type checking.

**Example Usage:**

```lua
-- This is automatically set, no need to define manually
ITEM.isItem = true
```

---

#### `base`

**Type:**

`string`

**Description:**

Base item this item derives from.

**Example Usage:**

```lua
ITEM.base = "base_weapons"
```

When loading items from a folder such as `items/weapons/`, the framework

automatically sets `ITEM.base` to match that folder (e.g. `base_weapons`).

Ideally you should organize item files under directories named after the base

they inherit from so this assignment happens automatically.

---

#### `isBase`

**Type:**

`boolean`

**Description:**

Indicates the table is a base item.

**Example Usage:**

```lua
ITEM.isBase = true
```

---

#### `category`

**Type:**

`string`

**Description:**

Inventory grouping category.

**Example Usage:**

```lua
ITEM.category = "Storage"
```

---

#### `name`

**Type:**

`string`

**Description:**

Displayed name of the item.

**Example Usage:**

```lua
ITEM.name = "Example Item"
```

---

#### `desc`

**Type:**

`string`

**Description:**

Short description shown to players.

**Example Usage:**

```lua
ITEM.desc = "An example item"
```

---

#### `uniqueID`

**Type:**

`string`

**Description:**

String identifier used to register the item. When omitted it is derived

from the file path, but you may override it to provide a custom ID.

**Example Usage:**

```lua
ITEM.uniqueID = "custom_unique_id"
```

---

#### `id`

**Type:**

`any`

**Description:**

Unique numeric identifier assigned by the inventory system. Instances

use this to reference the item in the database and it should not be

manually set.

**Example Usage:**

```lua
print(item.id)
```

---

### Equipment & Stats

#### `armor`

**Type:**

`number`

**Description:**

Armor value granted when equipped.

**Example Usage:**

```lua
ITEM.armor = 50
```

---

#### `health`

**Type:**

`number`

**Description:**

Amount of health restored when used.

**Example Usage:**

```lua
ITEM.health = 50
```

---

#### `attribBoosts`

**Type:**

`table`

**Description:**

Attribute boosts applied on equip.

**Example Usage:**

```lua
ITEM.attribBoosts = {strength = 5}
```

---

#### `isOutfit`

**Type:**

`boolean`

**Description:**

Marks the item as an outfit.

**Example Usage:**

```lua
ITEM.isOutfit = true
```

---

#### `newSkin`

**Type:**

`number`

**Description:**

Skin index applied to the player model.

**Example Usage:**

```lua
ITEM.newSkin = 1
```

---

#### `outfitCategory`

**Type:**

`string`

**Description:**

Slot or category for the outfit.

**Example Usage:**

```lua
ITEM.outfitCategory = "body"
```

---

#### `pacData`

**Type:**

`table`

**Description:**

PAC3 customization information.

**Example Usage:**

```lua
-- This attaches an HGIBS gib model to the player's eyes bone
ITEM.pacData = {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["Angles"] = Angle(12.919322967529, 6.5696062847564e-006, -1.0949343050015e-005),
					["Position"] = Vector(-2.099609375, 0.019973754882813, 1.0180969238281),
					["UniqueID"] = "4249811628",
					["Size"] = 1.25,
					["Bone"] = "eyes",
					["Model"] = "models/Gibs/HGIBS.mdl",
					["ClassName"] = "model",
				},
			},
		},
		["self"] = {
			["ClassName"] = "group",
			["UniqueID"] = "907159817",
			["EditorExpand"] = true,
		},
	},
}
```

#### `visualData`

**Type:**

`table`

**Description:**

Model, skin, and bodygroup overrides applied when an outfit is equipped. The table is populated automatically and normally does not need manual editing.

**Example Usage:**

```lua
ITEM.visualData = {
    model = {},
    skin = {},
    bodygroups = {}
}
```

---

#### `bodyGroups`

**Type:**

`table`

**Description:**

Bodygroup values applied when the outfit is equipped.

**Example Usage:**

```lua
ITEM.bodyGroups = { head = 1, torso = 2 }
```

---

#### `replacements`

**Type:**

`string`

**Description:**

Model replacements when equipped.

**Example Usage:**

```lua
-- This will change a certain part of the model.
ITEM.replacements = {"group01", "group02"}
-- This will change the player's model completely.
ITEM.replacements = "models/manhack.mdl"
-- This will have multiple replacements.
ITEM.replacements = {
	{"male", "female"},
	{"group01", "group02"}
}
```

---

### Combat & Ammo

#### `class`

**Type:**

`string`

**Description:**

Weapon entity class. Also used by grenade items to determine the weapon entity spawned.

**Example Usage:**

```lua

ITEM.class = "weapon_pistol"

```

---

#### `isWeapon`

**Type:**

`boolean`

**Description:**

Marks the item as a weapon.

**Example Usage:**

```lua

ITEM.isWeapon = true

```

---

#### `ammo`

**Type:**

`string`

**Description:**

Ammo type provided.

**Example Usage:**

```lua

ITEM.ammo = "pistol"

```

---

#### `weaponCategory`

**Type:**

`string`

**Description:**

Slot category for the weapon.

**Example Usage:**

```lua

ITEM.weaponCategory = "sidearm"

```

---

### Visuals & Models

#### `scale`

**Type:**

`number`

**Description:**

Scale factor for item rendering. Affects the size of the item when displayed.

**Example Usage:**

```lua
ITEM.scale = 1.5
```

---

#### `skin`

**Type:**

`number`

**Description:**

Skin index for the item model. Used to change the appearance of the model.

**Example Usage:**

```lua
ITEM.skin = 1
```

---

#### `model`

**Type:**

`string`

**Description:**

3D model path for the item.

**Example Usage:**

```lua

ITEM.model = "models/props_c17/oildrum001.mdl"

```

#### `iconCam`

**Type:**

`table`

**Description:**

Custom camera parameters used when rendering the item's spawn icon. Contains `pos`, `ang`, and `fov` keys.

**Example Usage:**

```lua

ITEM.iconCam = {

    pos = Vector(0, 0, 32),

    ang = Angle(0, 180, 0),

    fov = 45

}

```

#### `forceRender`

**Type:**

`boolean`

**Description:**

When `true`, forces the spawn icon to regenerate even if an icon for the model already exists.

**Example Usage:**

```lua

ITEM.forceRender = true

```

---

### Entity & Content

#### `entityid`

**Type:**

`string`

**Description:**

Entity class spawned by the item.

**Example Usage:**

```lua

ITEM.entityid = "item_suit"

```

---

#### `contents`

**Type:**

`string`

**Description:**

HTML contents of a readable book.

**Example Usage:**

```lua

ITEM.contents = "<h1>Book</h1>"

```

---

### Economic & Pricing

#### `calcPrice`

**Type:**

`function`

**Description:**

Function to calculate dynamic pricing. If defined, this function will be called instead of using the static `price` field. The function receives the base price as a parameter and should return the calculated price.

**Example Usage:**

```lua
ITEM.calcPrice = function(basePrice)
    return basePrice * 1.5 -- 50% markup
end
```

---

#### `price`

**Type:**

`number`

**Description:**

Item cost for trading or selling.

**Example Usage:**

```lua

ITEM.price = 100

```

#### `rarity`

**Type:**

`string`

**Description:**

Rarity level affecting vendor color.

**Example Usage:**

```lua

ITEM.rarity = "Legendary"

```

---

#### `url`

**Type:**

`string`

**Description:**

Web address opened when using the item.

**Example Usage:**

```lua

ITEM.url = "https://example.com"

```

---

### Behavior & Hooks

#### `functions`

**Type:**

`table`

**Description:**

Table mapping action names to definitions. Each function entry controls

button text, icons and behavior when the action is triggered.

The `name` and `tip` fields for each action are automatically passed through

the `L()` localization helper when an item is registered. Provide translation

keys instead of raw strings.

**Example Usage:**

```lua

ITEM.functions = {}

```

#### `hooks`

**Type:**

`table`

**Description:**

Callbacks triggered on specific item events. Use `ITEM:hook("event", func)` to attach them.

**Example Usage:**

```lua

ITEM:hook("drop", function(itm)

    print(itm.name .. " was dropped")

end)

```

#### `postHooks`

**Type:**

`table`

**Description:**

Table of post-hook callbacks.

**Example Usage:**

```lua

-- Defined in base_weapons

function ITEM.postHooks:drop(result)

    local ply = self.player

    if ply:HasWeapon(self.class) then

        ply:StripWeapon(self.class)

    end

end

```

Additional post hooks can be registered dynamically using `ITEM:postHook`:

```lua

ITEM:postHook("drop", function(itm, res)

    print("Post drop result: " .. tostring(res))

end)

```

---

## Base Item Functions

### Aid

- `ITEM.functions.use.onRun(item)`
  - Heals the item owner up to their maximum health using `ITEM.health`.
- `ITEM.functions.target.onRun(item)`
  - Heals the player's traced entity when it is a living player; otherwise notifies of an invalid target.
  - `ITEM.functions.target.onCanRun(item)`
    - Shows the option only when the player is looking at a valid entity.

### Ammo

- `ITEM.functions.use.onRun(item)`
  - Loads ammunition into the player and plays `ITEM.useSound`.
  - Provides multi-options to load all or fixed amounts (5, 10, or 30 rounds) when enough quantity is available.
  - Returns `true` when the stack is depleted.
- `ITEM:getDesc()` → `string`
  - Returns a localized description including the current stack quantity.
- `ITEM:paintOver(item)`
  - Draws the remaining quantity on the item icon.

### Bag

- `ITEM:onInstanced()`
  - Creates the bag's internal inventory and applies access rules.
- `ITEM:onRestored()`
  - Reloads the bag's internal inventory after server restarts.
- `ITEM:onRemoved()`
  - Deletes the bag's inventory when the item is removed.
- `ITEM:getInv()`
  - Returns the bag's internal inventory instance.
- `ITEM:onSync(recipient)`
  - Sends the internal inventory to the given player.
- `ITEM.postHooks:drop()`
  - Clears the bag inventory data when dropped.
- `ITEM:onCombine(other)`
  - Attempts to transfer the other item into the bag's inventory.

### Stackable

Items that track quantity and can merge with other stacks of the same type. Setting `isStackable` to `true` enables this behavior and allows stacks to combine or split as needed.

- `ITEM:getDesc()` → `string`
  - Returns a localized description including the current stack quantity.
- `ITEM:paintOver(item)`
  - Displays the stack quantity on the item icon.
- `ITEM:onCombine(other)` → `boolean`
  - Merges another stack of the same item. Removes the other stack if fully combined and returns `true`.

### Weapons

- `ITEM:hook("drop", function(item))`
  - When dropped, saves ammo, strips the weapon, and clears equipped data if necessary.
- `ITEM.functions.Unequip.onRun(item)`
  - Strips the weapon, stores remaining ammo, plays `ITEM.unequipSound`, and clears the equip state.
  - `ITEM.functions.Unequip.onCanRun(item)`
    - Available only when the weapon is equipped and not placed in the world.
- `ITEM.functions.Equip.onRun(item)`
  - Gives the weapon to the player if the slot is free, restores saved ammo, marks it equipped, and plays `ITEM.equipSound`.
  - `ITEM.functions.Equip.onCanRun(item)`
    - Blocks equipping if already equipped, the slot is occupied, or the player is ragdolled.
- `ITEM.postHooks:drop()`
  - Strips the weapon from the player if they still carry it after dropping the item.
- `ITEM:OnCanBeTransfered(_, newInventory)` → `boolean`
  - Blocks transferring the item while it is equipped.
- `ITEM:onLoadout()`
  - Gives the weapon and restores its ammo when the player spawns with the item equipped.
- `ITEM:OnSave()`
  - Stores the weapon's current clip in the item data.
- `ITEM:getName()` *(client)* → `string`
  - Uses the weapon's `PrintName` if available.
- `ITEM:paintOver(item, w, h)` *(client)*
  - Marks the item as equipped.

### Outfit

- `ITEM:hook("drop", function(item))`
  - Automatically calls `removeOutfit` if the item is dropped while equipped.
- `ITEM.functions.Unequip.onRun(item)`
  - Calls `removeOutfit` to revert model, skin, armor, PAC parts, and boosts.
  - `ITEM.functions.Unequip.onCanRun(item)`
    - Available only when the outfit is equipped and not in the world.
- `ITEM.functions.Equip.onRun(item)`
  - Equips the outfit after ensuring the category slot is free and applies model, skin, bodygroups, armor, PAC parts, and boosts.
  - `ITEM.functions.Equip.onCanRun(item)`
    - Disabled when already equipped or the item exists as an entity.
- `ITEM:removeOutfit(client)`
  - Reverts the player's model, skin, bodygroups, armor, PAC parts, and attribute boosts. Triggers `onTakeOff`.
- `ITEM:wearOutfit(client, isForLoadout)`
  - Applies armor, PAC parts, and attribute boosts. Triggers `onWear`.
- `ITEM:OnCanBeTransfered(_, newInventory)` → `boolean`
  - Blocks transferring the item while it is equipped.
- `ITEM:onLoadout()`
  - Reapplies the outfit on spawn if equipped.
- `ITEM:onRemoved()`
  - Automatically unequips the outfit when the item is removed.
- `ITEM:paintOver(item, w, h)` *(client)*
  - Shows an equipped indicator.

### PAC Outfit

- `ITEM:hook("drop", function(item))`
  - Removes the PAC part if the item is dropped while equipped.
- `ITEM.functions.Unequip.onRun(item)`
  - Calls `removePart` to detach the PAC part and remove boosts.
  - `ITEM.functions.Unequip.onCanRun(item)`
    - Available only when the item is equipped and not placed in the world.
- `ITEM.functions.Equip.onRun(item)`
  - Attaches the PAC part after verifying no conflicting outfit is equipped and applies attribute boosts.
  - `ITEM.functions.Equip.onCanRun(item)`
    - Blocks equipping when already equipped or the item exists in the world.
- `ITEM:removePart(client)`
  - Removes the PAC part and any attribute boosts.
- `ITEM:OnCanBeTransfered(_, newInventory)` → `boolean`
  - Blocks transferring the item while it is equipped.
- `ITEM:onLoadout()`
  - Reapplies the PAC part on spawn if equipped.
- `ITEM:onRemoved()`
  - Automatically unequips the part when the item is removed.
- `ITEM:paintOver(item, w, h)` *(client)*
  - Shows an equipped indicator.

### Book

- `ITEM.functions.Read.onClick(item)`
  - Opens a window displaying `ITEM.contents`.
- `ITEM.functions.Read.onRun()` → `boolean`
  - Always returns `false` to prevent the item from being consumed.

### Entity Spawner

- `ITEM.functions.Place.onRun(item)` → `boolean`
  - Spawns `ITEM.entityid` at the player's aim position and returns `true` on success.
- `ITEM.functions.Place.onCanRun(item)` → `boolean`
  - Only allows placement when the item is not already spawned into the world.

### Grenade

- `ITEM.functions.Use.onRun(item)` → `boolean`
  - Gives the grenade weapon specified by `ITEM.class` if the player doesn't already have it. Returns `true` when granted.

### URL Item

- `ITEM.functions.use.onRun()` → `boolean`
  - Opens `ITEM.url` in the player's browser on the client and returns `false`.

---

## Item Type Examples

Minimal definitions for each built-in item type are shown below.

### Weapon

```lua

ITEM.name = "Sub Machine Gun"

ITEM.model = "models/weapons/w_smg1.mdl"

ITEM.class = "weapon_smg1"

ITEM.weaponCategory = "primary"

ITEM.isWeapon = true

```

### Ammo

```lua

ITEM.name = "Pistol Ammo"

ITEM.model = "models/items/357ammo.mdl"

ITEM.ammo = "pistol"

ITEM.maxQuantity = 30

```

### Stackable

A minimal definition for an item that can be stacked and split.

```lua

ITEM.name = "Stack of Metal"

ITEM.model = "models/props_junk/cardboard_box001a.mdl"

ITEM.isStackable = true

ITEM.maxQuantity = 10

ITEM.canSplit = true

```

### Bag

```lua
ITEM.name = "Suitcase"
ITEM.model = "models/props_c17/suitcase001a.mdl"
ITEM.isBag = true
ITEM.invWidth = 2
ITEM.invHeight = 2
ITEM.BagSound = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
```

### Outfit

```lua

ITEM.name = "Combine Armor"

ITEM.model = "models/props_c17/BriefCase001a.mdl"

ITEM.outfitCategory = "body"

ITEM.replacements = "models/player/combine_soldier.mdl"

ITEM.newSkin = 1

```

### PAC Outfit

```lua

ITEM.name = "Skull Mask"

ITEM.outfitCategory = "hat"

ITEM.pacData = { ... }

```

### Aid Item

```lua

ITEM.name = "Bandages"

ITEM.model = "models/weapons/w_package.mdl"

ITEM.health = 50

```

### Book

```lua

ITEM.name = "Example"

ITEM.contents = "<h1>An Example</h1>"

```

### URL Item

```lua

ITEM.name = "Hi Barbie"

ITEM.url = "https://www.youtube.com/watch?v=9ezbBugUQiQ"

```

### Entity Spawner

```lua

ITEM.name = "Item Suit"

ITEM.entityid = "item_suit"

```

### Grenade

```lua

ITEM.name = "Grenade"

ITEM.class = "weapon_frag"

ITEM.DropOnDeath = true

```
```