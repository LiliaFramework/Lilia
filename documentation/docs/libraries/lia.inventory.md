# Inventory Library

This page documents the functions for working with inventories and item storage.

---

## Overview

The inventory library (`lia.inventory`) provides a comprehensive system for managing inventories, item storage, and container management in the Lilia framework, serving as the core item management system for all player possessions and storage containers. This library handles sophisticated inventory management with support for multiple inventory types including player inventories, storage containers, vehicle cargo holds, and specialized storage systems with unique properties and restrictions. The system features advanced item management with support for item stacking, durability systems, item condition tracking, and complex item interactions including combining, splitting, and transforming items. It includes comprehensive storage systems with configurable capacity limits, weight restrictions, item filtering, and access control mechanisms to create realistic and balanced inventory management. The library provides robust container functionality with support for different container types, locking mechanisms, ownership systems, and integration with the framework's economy and trading systems. Additional features include inventory synchronization across network connections, automatic item sorting and organization tools, item search and filtering capabilities, and integration with other framework systems for creating immersive and functional item management experiences that enhance roleplay and gameplay depth.

---

### lia.inventory.newType

**Purpose**

Creates a new inventory type.

**Parameters**

* `typeName` (*string*): The name of the inventory type.
* `inventoryData` (*table*): The inventory data table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Create a new inventory type
local function createInventoryType(typeName, inventoryData)
    lia.inventory.newType(typeName, inventoryData)
end

-- Use in a function
local function createPlayerInventory()
    lia.inventory.newType("player", {
        name = "Player Inventory",
        width = 10,
        height = 6,
        slots = 60
    })
    print("Player inventory type created")
end

-- Use in a function
local function createStorageInventory()
    lia.inventory.newType("storage", {
        name = "Storage Container",
        width = 8,
        height = 8,
        slots = 64
    })
    print("Storage inventory type created")
end

-- Use in a function
local function createTrunkInventory()
    lia.inventory.newType("trunk", {
        name = "Vehicle Trunk",
        width = 6,
        height = 4,
        slots = 24
    })
    print("Trunk inventory type created")
end
```

---

### lia.inventory.new

**Purpose**

Creates a new inventory instance.

**Parameters**

* `typeName` (*string*): The inventory type name.
* `data` (*table*): The inventory data.

**Returns**

* `inventory` (*Inventory*): The created inventory instance.

**Realm**

Server.

**Example Usage**

```lua
-- Create a new inventory
local function createInventory(typeName, data)
    return lia.inventory.new(typeName, data)
end

-- Use in a function
local function createPlayerInventory(client)
    local inventory = lia.inventory.new("player", {
        owner = client:SteamID(),
        character = client:getChar():getID()
    })
    print("Player inventory created for " .. client:Name())
    return inventory
end

-- Use in a function
local function createStorageInventory(position)
    local inventory = lia.inventory.new("storage", {
        position = position,
        name = "Storage Container"
    })
    print("Storage inventory created at " .. tostring(position))
    return inventory
end

-- Use in a function
local function createTrunkInventory(vehicle)
    local inventory = lia.inventory.new("trunk", {
        vehicle = vehicle,
        name = "Vehicle Trunk"
    })
    print("Trunk inventory created for vehicle")
    return inventory
end
```

---

### lia.inventory.loadByID

**Purpose**

Loads an inventory by its ID.

**Parameters**

* `inventoryID` (*string*): The inventory ID.

**Returns**

* `inventory` (*Inventory*): The loaded inventory or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Load inventory by ID
local function loadInventory(inventoryID)
    return lia.inventory.loadByID(inventoryID)
end

-- Use in a function
local function getPlayerInventory(client)
    local character = client:getChar()
    if character then
        local inventory = lia.inventory.loadByID(character:getInventoryID())
        if inventory then
            print("Player inventory loaded for " .. client:Name())
            return inventory
        end
    end
    return nil
end

-- Use in a function
local function loadStorageInventory(storageID)
    local inventory = lia.inventory.loadByID(storageID)
    if inventory then
        print("Storage inventory loaded: " .. storageID)
        return inventory
    else
        print("Failed to load storage inventory: " .. storageID)
        return nil
    end
end

-- Use in a function
local function checkInventoryExists(inventoryID)
    local inventory = lia.inventory.loadByID(inventoryID)
    return inventory ~= nil
end
```

---

### lia.inventory.loadFromDefaultStorage

**Purpose**

Loads an inventory from default storage.

**Parameters**

* `storageType` (*string*): The storage type.

**Returns**

* `inventory` (*Inventory*): The loaded inventory or nil.

**Realm**

Server.

**Example Usage**

```lua
-- Load inventory from default storage
local function loadFromDefaultStorage(storageType)
    return lia.inventory.loadFromDefaultStorage(storageType)
end

-- Use in a function
local function loadPlayerDefaultInventory()
    local inventory = lia.inventory.loadFromDefaultStorage("player")
    if inventory then
        print("Player default inventory loaded")
        return inventory
    else
        print("Failed to load player default inventory")
        return nil
    end
end

-- Use in a function
local function loadStorageDefaultInventory()
    local inventory = lia.inventory.loadFromDefaultStorage("storage")
    if inventory then
        print("Storage default inventory loaded")
        return inventory
    else
        print("Failed to load storage default inventory")
        return nil
    end
end

-- Use in a function
local function loadTrunkDefaultInventory()
    local inventory = lia.inventory.loadFromDefaultStorage("trunk")
    if inventory then
        print("Trunk default inventory loaded")
        return inventory
    else
        print("Failed to load trunk default inventory")
        return nil
    end
end
```

---

### lia.inventory.instance

**Purpose**

Gets an inventory instance by ID.

**Parameters**

* `inventoryID` (*string*): The inventory ID.

**Returns**

* `inventory` (*Inventory*): The inventory instance or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get inventory instance
local function getInventoryInstance(inventoryID)
    return lia.inventory.instance(inventoryID)
end

-- Use in a function
local function checkInventoryAccess(client, inventoryID)
    local inventory = lia.inventory.instance(inventoryID)
    if inventory then
        if inventory:canAccess(client) then
            print("Player can access inventory")
            return true
        else
            print("Player cannot access inventory")
            return false
        end
    else
        print("Inventory not found")
        return false
    end
end

-- Use in a function
local function getInventoryInfo(inventoryID)
    local inventory = lia.inventory.instance(inventoryID)
    if inventory then
        print("Inventory: " .. inventory:getName())
        print("Slots: " .. inventory:getSlotCount())
        print("Items: " .. inventory:getItemCount())
        return inventory
    else
        print("Inventory not found")
        return nil
    end
end

-- Use in a function
local function checkInventoryExists(inventoryID)
    local inventory = lia.inventory.instance(inventoryID)
    return inventory ~= nil
end
```

---

### lia.inventory.loadAllFromCharID

**Purpose**

Loads all inventories for a character.

**Parameters**

* `characterID` (*string*): The character ID.

**Returns**

* `inventories` (*table*): Table of character inventories.

**Realm**

Server.

**Example Usage**

```lua
-- Load all character inventories
local function loadCharacterInventories(characterID)
    return lia.inventory.loadAllFromCharID(characterID)
end

-- Use in a function
local function getPlayerInventories(client)
    local character = client:getChar()
    if character then
        local inventories = lia.inventory.loadAllFromCharID(character:getID())
        print("Loaded " .. #inventories .. " inventories for " .. client:Name())
        return inventories
    end
    return {}
end

-- Use in a function
local function showCharacterInventories(characterID)
    local inventories = lia.inventory.loadAllFromCharID(characterID)
    print("Inventories for character " .. characterID .. ":")
    for _, inventory in ipairs(inventories) do
        print("- " .. inventory:getName() .. " (" .. inventory:getType() .. ")")
    end
    return inventories
end

-- Use in a function
local function getCharacterInventoryCount(characterID)
    local inventories = lia.inventory.loadAllFromCharID(characterID)
    return #inventories
end
```

---

### lia.inventory.deleteByID

**Purpose**

Deletes an inventory by its ID.

**Parameters**

* `inventoryID` (*string*): The inventory ID.

**Returns**

* `success` (*boolean*): True if deletion was successful.

**Realm**

Server.

**Example Usage**

```lua
-- Delete inventory by ID
local function deleteInventory(inventoryID)
    return lia.inventory.deleteByID(inventoryID)
end

-- Use in a function
local function deletePlayerInventory(client)
    local character = client:getChar()
    if character then
        local success = lia.inventory.deleteByID(character:getInventoryID())
        if success then
            print("Player inventory deleted for " .. client:Name())
        else
            print("Failed to delete player inventory")
        end
        return success
    end
    return false
end

-- Use in a function
local function deleteStorageInventory(storageID)
    local success = lia.inventory.deleteByID(storageID)
    if success then
        print("Storage inventory deleted: " .. storageID)
    else
        print("Failed to delete storage inventory: " .. storageID)
    end
    return success
end

-- Use in a function
local function cleanupOldInventories()
    local oldInventories = {"old_inv_1", "old_inv_2", "old_inv_3"}
    for _, inventoryID in ipairs(oldInventories) do
        lia.inventory.deleteByID(inventoryID)
    end
    print("Old inventories cleaned up")
end
```

---

### lia.inventory.cleanUpForCharacter

**Purpose**

Cleans up inventories for a character.

**Parameters**

* `characterID` (*string*): The character ID.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Clean up character inventories
local function cleanUpCharacterInventories(characterID)
    lia.inventory.cleanUpForCharacter(characterID)
end

-- Use in a function
local function cleanUpPlayerInventories(client)
    local character = client:getChar()
    if character then
        lia.inventory.cleanUpForCharacter(character:getID())
        print("Inventories cleaned up for " .. client:Name())
    end
end

-- Use in a function
local function cleanUpDeletedCharacter(characterID)
    lia.inventory.cleanUpForCharacter(characterID)
    print("Inventories cleaned up for deleted character: " .. characterID)
end

-- Use in a function
local function cleanUpAllCharacterInventories()
    local characters = lia.char.getAll()
    for _, character in ipairs(characters) do
        lia.inventory.cleanUpForCharacter(character:getID())
    end
    print("All character inventories cleaned up")
end
```

---

### lia.inventory.registerStorage

**Purpose**

Registers a storage type.

**Parameters**

* `storageType` (*string*): The storage type name.
* `storageData` (*table*): The storage data table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register storage type
local function registerStorage(storageType, storageData)
    lia.inventory.registerStorage(storageType, storageData)
end

-- Use in a function
local function createCrateStorage()
    lia.inventory.registerStorage("crate", {
        name = "Crate",
        width = 4,
        height = 4,
        slots = 16,
        model = "models/props_c17/crate01.mdl"
    })
    print("Crate storage registered")
end

-- Use in a function
local function createLockerStorage()
    lia.inventory.registerStorage("locker", {
        name = "Locker",
        width = 6,
        height = 8,
        slots = 48,
        model = "models/props_c17/lockers001a.mdl"
    })
    print("Locker storage registered")
end

-- Use in a function
local function createSafeStorage()
    lia.inventory.registerStorage("safe", {
        name = "Safe",
        width = 3,
        height = 3,
        slots = 9,
        model = "models/props_c17/safe01.mdl",
        locked = true
    })
    print("Safe storage registered")
end
```

---

### lia.inventory.getStorage

**Purpose**

Gets a storage type by name.

**Parameters**

* `storageType` (*string*): The storage type name.

**Returns**

* `storageData` (*table*): The storage data table or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get storage type
local function getStorage(storageType)
    return lia.inventory.getStorage(storageType)
end

-- Use in a function
local function showStorageInfo(storageType)
    local storage = lia.inventory.getStorage(storageType)
    if storage then
        print("Storage: " .. storage.name)
        print("Slots: " .. storage.slots)
        print("Model: " .. storage.model)
        return storage
    else
        print("Storage type not found: " .. storageType)
        return nil
    end
end

-- Use in a function
local function checkStorageExists(storageType)
    local storage = lia.inventory.getStorage(storageType)
    return storage ~= nil
end

-- Use in a function
local function getStorageSlots(storageType)
    local storage = lia.inventory.getStorage(storageType)
    return storage and storage.slots or 0
end
```

---

### lia.inventory.registerTrunk

**Purpose**

Registers a trunk type.

**Parameters**

* `trunkType` (*string*): The trunk type name.
* `trunkData` (*table*): The trunk data table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register trunk type
local function registerTrunk(trunkType, trunkData)
    lia.inventory.registerTrunk(trunkType, trunkData)
end

-- Use in a function
local function createCarTrunk()
    lia.inventory.registerTrunk("car", {
        name = "Car Trunk",
        width = 6,
        height = 4,
        slots = 24,
        model = "models/props_c17/car01.mdl"
    })
    print("Car trunk registered")
end

-- Use in a function
local function createTruckTrunk()
    lia.inventory.registerTrunk("truck", {
        name = "Truck Bed",
        width = 8,
        height = 6,
        slots = 48,
        model = "models/props_c17/truck01.mdl"
    })
    print("Truck trunk registered")
end

-- Use in a function
local function createMotorcycleTrunk()
    lia.inventory.registerTrunk("motorcycle", {
        name = "Motorcycle Storage",
        width = 3,
        height = 2,
        slots = 6,
        model = "models/props_c17/motorcycle01.mdl"
    })
    print("Motorcycle trunk registered")
end
```

---

### lia.inventory.getTrunk

**Purpose**

Gets a trunk type by name.

**Parameters**

* `trunkType` (*string*): The trunk type name.

**Returns**

* `trunkData` (*table*): The trunk data table or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get trunk type
local function getTrunk(trunkType)
    return lia.inventory.getTrunk(trunkType)
end

-- Use in a function
local function showTrunkInfo(trunkType)
    local trunk = lia.inventory.getTrunk(trunkType)
    if trunk then
        print("Trunk: " .. trunk.name)
        print("Slots: " .. trunk.slots)
        print("Model: " .. trunk.model)
        return trunk
    else
        print("Trunk type not found: " .. trunkType)
        return nil
    end
end

-- Use in a function
local function checkTrunkExists(trunkType)
    local trunk = lia.inventory.getTrunk(trunkType)
    return trunk ~= nil
end

-- Use in a function
local function getTrunkSlots(trunkType)
    local trunk = lia.inventory.getTrunk(trunkType)
    return trunk and trunk.slots or 0
end
```

---

### lia.inventory.getAllTrunks

**Purpose**

Gets all registered trunk types.

**Parameters**

*None*

**Returns**

* `trunks` (*table*): Table of all trunk types.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all trunk types
local function getAllTrunks()
    return lia.inventory.getAllTrunks()
end

-- Use in a function
local function showAllTrunks()
    local trunks = lia.inventory.getAllTrunks()
    print("Available trunk types:")
    for _, trunk in ipairs(trunks) do
        print("- " .. trunk.name .. " (" .. trunk.slots .. " slots)")
    end
end

-- Use in a function
local function getTrunkCount()
    local trunks = lia.inventory.getAllTrunks()
    return #trunks
end

-- Use in a function
local function getLargestTrunk()
    local trunks = lia.inventory.getAllTrunks()
    local largest = nil
    local maxSlots = 0
    for _, trunk in ipairs(trunks) do
        if trunk.slots > maxSlots then
            maxSlots = trunk.slots
            largest = trunk
        end
    end
    return largest
end
```

---

### lia.inventory.getAllStorage

**Purpose**

Gets all registered storage types.

**Parameters**

*None*

**Returns**

* `storageTypes` (*table*): Table of all storage types.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all storage types
local function getAllStorage()
    return lia.inventory.getAllStorage()
end

-- Use in a function
local function showAllStorage()
    local storageTypes = lia.inventory.getAllStorage()
    print("Available storage types:")
    for _, storage in ipairs(storageTypes) do
        print("- " .. storage.name .. " (" .. storage.slots .. " slots)")
    end
end

-- Use in a function
local function getStorageCount()
    local storageTypes = lia.inventory.getAllStorage()
    return #storageTypes
end

-- Use in a function
local function getLargestStorage()
    local storageTypes = lia.inventory.getAllStorage()
    local largest = nil
    local maxSlots = 0
    for _, storage in ipairs(storageTypes) do
        if storage.slots > maxSlots then
            maxSlots = storage.slots
            largest = storage
        end
    end
    return largest
end
```

---

### lia.inventory.show

**Purpose**

Shows an inventory to a player.

**Parameters**

* `client` (*Player*): The player to show the inventory to.
* `inventory` (*Inventory*): The inventory to show.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Show inventory to player
local function showInventory(client, inventory)
    lia.inventory.show(client, inventory)
end

-- Use in a function
local function openPlayerInventory(client)
    local character = client:getChar()
    if character then
        local inventory = character:getInventory()
        if inventory then
            lia.inventory.show(client, inventory)
        end
    end
end

-- Use in a function
local function openStorageInventory(client, storageID)
    local inventory = lia.inventory.loadByID(storageID)
    if inventory then
        lia.inventory.show(client, inventory)
    else
        client:notify("Storage not found")
    end
end

-- Use in a function
local function openTrunkInventory(client, vehicle)
    local inventory = vehicle:getTrunkInventory()
    if inventory then
        lia.inventory.show(client, inventory)
    else
        client:notify("Vehicle trunk not accessible")
    end
end
```