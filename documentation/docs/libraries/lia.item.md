# Item Library

This page documents the functions for working with items and item management.

---

## Overview

The item library (`lia.item`) provides a comprehensive system for managing items, item creation, item data, and item operations in the Lilia framework. It includes item registration, spawning, data management, and inventory integration functionality.

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
```