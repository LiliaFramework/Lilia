# Inventory Library

Comprehensive inventory system management with multiple storage types for the Lilia framework.

---

Overview

The inventory library provides comprehensive functionality for managing inventory systems in the Lilia framework. It handles inventory type registration, instance creation, storage management, and database persistence. The library operates on both server and client sides, with the server managing inventory data persistence, loading, and storage registration, while the client handles inventory panel display and user interaction. It supports multiple inventory types, storage containers, vehicle trunks, and character-based inventory management. The library ensures proper data validation, caching, and cleanup for optimal performance.

---

### lia.inventory.newType

#### 📋 Purpose
Registers a new inventory type with the system

#### ⏰ When Called
During module initialization or when defining custom inventory types

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `typeID` | **string** | Unique identifier for the inventory type |
| `invTypeStruct` | **table** | Structure containing inventory type configuration |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic inventory type
    lia.inventory.newType("player", {
        className = "PlayerInventory",
        typeID    = "player",
        config    = {w = 10, h = 5}
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register inventory type with custom methods
    local playerInvType = {
        className = "PlayerInventory",
        typeID    = "player",
        config    = {w = 10, h = 5},
        add       = function(self, item) -- custom add method
            -- custom logic here
        end
    }
    lia.inventory.newType("player", playerInvType)

```

#### ⚙️ High Complexity
```lua
    -- High: Register complex inventory type with validation
    local complexInvType = {
        className = "ComplexInventory",
        typeID    = "complex",
        config    = {
            w            = 20,
            h            = 10,
            maxWeight    = 100,
            restrictions = {"weapons", "drugs"}
        },
        add    = function(self, item)
            if self:canAddItem(item) then
                return self:doAddItem(item)
            end
            return false
        end,
        remove = function(self, item)
            return self:doRemoveItem(item)
        end
    }
    lia.inventory.newType("complex", complexInvType)

```

---

### lia.inventory.new

#### 📋 Purpose
Creates a new inventory instance of the specified type

#### ⏰ When Called
When creating inventory instances for players, storage containers, or vehicles

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `typeID` | **string** | The inventory type identifier to create an instance of |

#### ↩️ Returns
* Inventory instance (table) with items and config properties

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create a basic player inventory
    local playerInv = lia.inventory.new("player")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create inventory and configure it
    local storageInv = lia.inventory.new("storage")
    storageInv.config.w = 15
    storageInv.config.h = 8

```

#### ⚙️ High Complexity
```lua
    -- High: Create inventory with custom configuration
    local customInv = lia.inventory.new("player")
    customInv.config.w = 12
    customInv.config.h = 6
    customInv.config.maxWeight = 50
    customInv.items = {}

```

---

### lia.inventory.loadByID

#### 📋 Purpose
Loads an inventory instance by its ID from storage or cache

#### ⏰ When Called
When accessing an existing inventory that may be cached or needs to be loaded from database

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The inventory ID to load |
| `noCache` | **boolean, optional** | If true, bypasses cache and forces reload from storage |

#### ↩️ Returns
* Deferred promise that resolves to inventory instance

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load inventory by ID
    lia.inventory.loadByID(123):next(function(inv)
        print("Loaded inventory:", inv.id)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load inventory with error handling
    lia.inventory.loadByID(123):next(function(inv)
        if inv then
            print("Successfully loaded inventory:", inv.id)
        end
    end):catch(function(err)
        print("Failed to load inventory:", err)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Load inventory with cache bypass and validation
    local function loadInventorySafely(id)
        return lia.inventory.loadByID(id, true):next(function(inv)
            if not inv then
                return deferred.reject("Inventory not found")
            end
            -- Validate inventory data
            if not inv.data or not inv.items then
                return deferred.reject("Invalid inventory data")
            end
            return inv
        end)
    end

```

---

### lia.inventory.loadFromDefaultStorage

#### 📋 Purpose
Loads an inventory from the default database storage system

#### ⏰ When Called
When loadByID cannot find a custom loader and needs to use default storage

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The inventory ID to load from database |
| `noCache` | **boolean, optional** | If true, bypasses cache and forces reload from database |

#### ↩️ Returns
* Deferred promise that resolves to inventory instance

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load inventory from default storage
    lia.inventory.loadFromDefaultStorage(123):next(function(inv)
        print("Loaded from database:", inv.id)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load with cache bypass
    lia.inventory.loadFromDefaultStorage(123, true):next(function(inv)
        if inv then
            print("Fresh load from database:", inv.id)
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Load with comprehensive error handling and validation
    local function loadFromDatabase(id)
        return lia.inventory.loadFromDefaultStorage(id, true):next(function(inv)
            if not inv then
                lia.error("Failed to load inventory " .. id .. " from database")
                return deferred.reject("Inventory not found in database")
            end
            -- Validate inventory structure
            if not inv.data or not inv.items then
                lia.error("Invalid inventory structure for ID: " .. id)
                return deferred.reject("Corrupted inventory data")
            end
            -- Log successful load
            lia.log("Successfully loaded inventory " .. id .. " from database")
            return inv
        end):catch(function(err)
            lia.error("Database load error for inventory " .. id .. ": " .. tostring(err))
            return deferred.reject(err)
        end)
    end

```

---

### lia.inventory.instance

#### 📋 Purpose
Creates a new inventory instance and initializes it in storage

#### ⏰ When Called
When creating new inventories that need to be persisted to database

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `typeID` | **string** | The inventory type identifier |
| `initialData` | **table, optional** | Initial data to store with the inventory |

#### ↩️ Returns
* Deferred promise that resolves to the created inventory instance

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create a new inventory instance
    lia.inventory.instance("player"):next(function(inv)
        print("Created inventory:", inv.id)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create inventory with initial data
    local initialData = {owner = "player123", maxWeight = 50}
    lia.inventory.instance("storage", initialData):next(function(inv)
        print("Created storage inventory:", inv.id)
        print("Owner:", inv.data.owner)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Create inventory with validation and error handling
    local function createInventorySafely(typeID, data)
        if not lia.inventory.types[typeID] then
            return deferred.reject("Invalid inventory type: " .. typeID)
        end
        return lia.inventory.instance(typeID, data):next(function(inv)
            if not inv or not inv.id then
                return deferred.reject("Failed to create inventory instance")
            end
            -- Validate created inventory
            if not inv.data or not inv.items then
                return deferred.reject("Invalid inventory structure")
            end
            lia.log("Successfully created inventory " .. inv.id .. " of type " .. typeID)
            return inv
        end):catch(function(err)
            lia.error("Failed to create inventory: " .. tostring(err))
            return deferred.reject(err)
        end)
    end

```

---

### lia.inventory.loadAllFromCharID

#### 📋 Purpose
Loads all inventories associated with a specific character ID

#### ⏰ When Called
When a character logs in or when accessing all character inventories

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | The character ID to load inventories for |

#### ↩️ Returns
* Deferred promise that resolves to array of inventory instances

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load all inventories for a character
    lia.inventory.loadAllFromCharID(123):next(function(inventories)
        print("Loaded", #inventories, "inventories")
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load inventories with error handling
    lia.inventory.loadAllFromCharID(123):next(function(inventories)
        if inventories and #inventories > 0 then
            print("Successfully loaded", #inventories, "inventories")
            for _, inv in ipairs(inventories) do
                print("Inventory ID:", inv.id, "Type:", inv.data.invType)
            end
        end
    end):catch(function(err)
        print("Failed to load character inventories:", err)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Load inventories with validation and processing
    local function loadCharacterInventories(charID)
        return lia.inventory.loadAllFromCharID(charID):next(function(inventories)
            if not inventories then
                return deferred.reject("No inventories found for character " .. charID)
            end
            local validInventories = {}
            for _, inv in ipairs(inventories) do
                if inv and inv.id and inv.data then
                    -- Validate inventory structure
                    if inv.items and inv.config then
                        table.insert(validInventories, inv)
                    else
                        lia.warning("Invalid inventory structure for ID: " .. inv.id)
                    end
                end
            end
            lia.log("Loaded " .. #validInventories .. " valid inventories for character " .. charID)
            return validInventories
        end):catch(function(err)
            lia.error("Failed to load inventories for character " .. charID .. ": " .. tostring(err))
            return deferred.reject(err)
        end)
    end

```

---

### lia.inventory.deleteByID

#### 📋 Purpose
Permanently deletes an inventory and all its associated data from the database

#### ⏰ When Called
When removing inventories that are no longer needed or during cleanup operations

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The inventory ID to delete |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Delete an inventory by ID
    lia.inventory.deleteByID(123)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Delete inventory with validation
    local function deleteInventory(id)
        if not isnumber(id) or id <= 0 then
            lia.error("Invalid inventory ID for deletion: " .. tostring(id))
            return false
        end
        lia.inventory.deleteByID(id)
        lia.log("Deleted inventory ID: " .. id)
        return true
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Delete inventory with comprehensive cleanup
    local function deleteInventorySafely(id)
        if not isnumber(id) or id <= 0 then
            return deferred.reject("Invalid inventory ID: " .. tostring(id))
        end
        -- Check if inventory exists before deletion
        return lia.inventory.loadByID(id):next(function(inv)
            if not inv then
                lia.warning("Attempted to delete non-existent inventory: " .. id)
                return false
            end
            -- Clean up any items in the inventory
            if inv.items then
                for _, item in pairs(inv.items) do
                    if item and item.destroy then
                        item:destroy()
                    end
                end
            end
            -- Delete from database
            lia.inventory.deleteByID(id)
            lia.log("Successfully deleted inventory " .. id .. " and all associated data")
            return true
        end):catch(function(err)
            lia.error("Failed to delete inventory " .. id .. ": " .. tostring(err))
            return false
        end)
    end

```

---

### lia.inventory.cleanUpForCharacter

#### 📋 Purpose
Destroys all inventory instances associated with a character

#### ⏰ When Called
When a character is deleted or during character cleanup operations

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `character` | **table** | The character object containing inventory references |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Clean up character inventories
    lia.inventory.cleanUpForCharacter(character)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Clean up with validation
    local function cleanupCharacterInventories(character)
        if not character or not character.getInv then
            lia.error("Invalid character object for cleanup")
            return false
        end
        lia.inventory.cleanUpForCharacter(character)
        lia.log("Cleaned up inventories for character: " .. character:getName())
        return true
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Clean up with comprehensive logging and validation
    local function cleanupCharacterInventoriesSafely(character)
        if not character or not character.getInv then
            lia.error("Invalid character object for inventory cleanup")
            return false
        end
        local inventories = character:getInv(true)
        if not inventories or table.IsEmpty(inventories) then
            lia.log("No inventories to clean up for character: " .. character:getName())
            return true
        end
        local count = 0
        for _, inv in pairs(inventories) do
            if inv and inv.destroy then
                inv:destroy()
                count = count + 1
            end
        end
        lia.log("Cleaned up " .. count .. " inventories for character: " .. character:getName())
        return true
    end

```

---

### lia.inventory.checkOverflow

#### 📋 Purpose
Checks for and handles inventory overflow when inventory size changes

#### ⏰ When Called
When an inventory's dimensions are reduced and items may no longer fit

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inv` | **table** | The inventory instance to check for overflow |
| `character` | **table** | The character object to store overflow items with |
| `oldW` | **number** | The previous width of the inventory |
| `oldH` | **number** | The previous height of the inventory |

#### ↩️ Returns
* Boolean indicating whether overflow items were found and stored

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check for overflow after inventory resize
    local hadOverflow = lia.inventory.checkOverflow(inventory, character, 10, 8)
    if hadOverflow then
        lia.notify.add("Some items were moved to overflow storage", NOTIFY_GENERIC)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Comprehensive overflow handling with validation
    local function handleInventoryResize(inventory, character, oldWidth, oldHeight)
        if not inventory or not character then
            lia.error("Invalid parameters for inventory overflow check")
            return false
        end
        local overflowDetected = lia.inventory.checkOverflow(inventory, character, oldWidth, oldHeight)
        if overflowDetected then
            local overflowData = character:getData("overflowItems")
            lia.log("Overflow detected: " .. #overflowData.items .. " items stored for character " .. character:getName())
            -- Notify player about overflow
            lia.notify.add("Inventory resized - some items moved to overflow storage", NOTIFY_WARNING)
            return true
        end
        return false
    end

```

---

### lia.inventory.registerStorage

#### 📋 Purpose
Registers a storage container model with inventory configuration

#### ⏰ When Called
During module initialization to register storage containers like crates, lockers, etc.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | **string** | The model path of the storage container |
| `data` | **table** | Configuration data containing name, invType, and invData |

#### ↩️ Returns
* The registered storage data table

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic storage container
    lia.inventory.registerStorage("models/props_c17/lockers001a.mdl", {
        name    = "Locker",
        invType = "storage",
        invData = {w = 5, h = 3}
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register storage with custom configuration
    local storageData = {
        name    = "Medical Cabinet",
        invType = "medical",
        invData = {
            w            = 8,
            h            = 4,
            maxWeight    = 30,
            restrictions = {"medical", "drugs"}
        }
    }
    lia.inventory.registerStorage("models/props_c17/furnituremedicinecabinet001a.mdl", storageData)

```

#### ⚙️ High Complexity
```lua
    -- High: Register multiple storage types with validation
    local function registerStorageContainers()
        local storages = {
            {
                model = "models/props_c17/lockers001a.mdl",
                data  = {
                    name    = "Security Locker",
                    invType = "security",
                    invData = {w = 6, h = 4, maxWeight = 50, restricted = true}
                }
            },
            {
                model = "models/props_c17/furnituremedicinecabinet001a.mdl",
                data  = {
                    name    = "Medical Cabinet",
                    invType = "medical",
                    invData = {w = 8, h = 4, maxWeight = 30, medicalOnly = true}
                }
            }
        }
        for _, storage in ipairs(storages) do
            if storage.model and storage.data then
                lia.inventory.registerStorage(storage.model, storage.data)
                lia.log("Registered storage: " .. storage.data.name)
            end
        end
    end

```

---

### lia.inventory.getStorage

#### 📋 Purpose
Retrieves storage configuration data for a specific model

#### ⏰ When Called
When checking if a model has registered storage or accessing storage configuration

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | **string** | The model path to look up storage data for |

#### ↩️ Returns
* Storage data table if found, nil otherwise

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get storage data for a model
    local storageData = lia.inventory.getStorage("models/props_c17/lockers001a.mdl")
    if storageData then
        print("Storage name:", storageData.name)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get storage with validation
    local function getStorageInfo(model)
        if not model or not isstring(model) then
            return nil
        end
        local storageData = lia.inventory.getStorage(model)
        if storageData then
            return {
                name = storageData.name,
                type = storageData.invType,
                size = storageData.invData.w * storageData.invData.h
            }
        end
        return nil
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Get storage with comprehensive validation and processing
    local function getStorageConfiguration(model)
        if not model or not isstring(model) then
            lia.warning("Invalid model provided to getStorageConfiguration: " .. tostring(model))
            return nil
        end
        local storageData = lia.inventory.getStorage(model)
        if not storageData then
            lia.log("No storage configuration found for model: " .. model)
            return nil
        end
        -- Validate storage data structure
        if not storageData.name or not storageData.invType or not storageData.invData then
            lia.error("Invalid storage data structure for model: " .. model)
            return nil
        end
        -- Process and return validated data
        return {
            name         = storageData.name,
            type         = storageData.invType,
            width        = storageData.invData.w or 5,
            height       = storageData.invData.h or 3,
            maxWeight    = storageData.invData.maxWeight,
            restrictions = storageData.invData.restrictions,
            isTrunk      = storageData.isTrunk or false
        }
    end

```

---

### lia.inventory.registerTrunk

#### 📋 Purpose
Registers a vehicle class with trunk inventory configuration

#### ⏰ When Called
During module initialization to register vehicle trunks

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vehicleClass` | **string** | The vehicle class name |
| `data` | **table** | Configuration data containing name, invType, and invData |

#### ↩️ Returns
* The registered trunk data table

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic vehicle trunk
    lia.inventory.registerTrunk("prop_vehicle_jeep", {
        name    = "Jeep Trunk",
        invType = "trunk",
        invData = {w = 8, h = 3}
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register trunk with custom configuration
    local trunkData = {
        name    = "Police Car Trunk",
        invType = "police_trunk",
        invData = {
            w            = 10,
            h            = 4,
            maxWeight    = 100,
            restricted   = true,
            allowedItems = {"weapons", "evidence"}
        }
    }
    lia.inventory.registerTrunk("prop_vehicle_police", trunkData)

```

#### ⚙️ High Complexity
```lua
    -- High: Register multiple vehicle trunks with validation
    local function registerVehicleTrunks()
        local vehicles = {
            {
                class = "prop_vehicle_jeep",
                data  = {
                    name    = "Civilian Vehicle Trunk",
                    invType = "civilian_trunk",
                    invData = {w = 8, h = 3, maxWeight = 50}
                }
            },
            {
                class = "prop_vehicle_police",
                data  = {
                    name    = "Police Vehicle Trunk",
                    invType = "police_trunk",
                    invData = {w = 10, h = 4, maxWeight = 100, restricted = true}
                }
            },
            {
                class = "prop_vehicle_ambulance",
                data  = {
                    name    = "Ambulance Storage",
                    invType = "medical_trunk",
                    invData = {w = 12, h = 5, maxWeight = 75, medicalOnly = true}
                }
            }
        }
        for _, vehicle in ipairs(vehicles) do
            if vehicle.class and vehicle.data then
                lia.inventory.registerTrunk(vehicle.class, vehicle.data)
                lia.log("Registered trunk for vehicle: " .. vehicle.data.name)
            end
        end
    end

```

---

### lia.inventory.getTrunk

#### 📋 Purpose
Retrieves trunk configuration data for a specific vehicle class

#### ⏰ When Called
When checking if a vehicle has a trunk or accessing trunk configuration

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vehicleClass` | **string** | The vehicle class name to look up trunk data for |

#### ↩️ Returns
* Trunk data table if found, nil otherwise

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get trunk data for a vehicle
    local trunkData = lia.inventory.getTrunk("prop_vehicle_jeep")
    if trunkData then
        print("Trunk name:", trunkData.name)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get trunk with validation
    local function getVehicleTrunk(vehicleClass)
        if not vehicleClass or not isstring(vehicleClass) then
            return nil
        end
        local trunkData = lia.inventory.getTrunk(vehicleClass)
        if trunkData then
            return {
                name      = trunkData.name,
                type      = trunkData.invType,
                size      = trunkData.invData.w * trunkData.invData.h,
                maxWeight = trunkData.invData.maxWeight
            }
        end
        return nil
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Get trunk with comprehensive validation and processing
    local function getVehicleTrunkConfiguration(vehicleClass)
        if not vehicleClass or not isstring(vehicleClass) then
            lia.warning("Invalid vehicle class provided: " .. tostring(vehicleClass))
            return nil
        end
        local trunkData = lia.inventory.getTrunk(vehicleClass)
        if not trunkData then
            lia.log("No trunk configuration found for vehicle: " .. vehicleClass)
            return nil
        end
        -- Validate trunk data structure
        if not trunkData.name or not trunkData.invType or not trunkData.invData then
            lia.error("Invalid trunk data structure for vehicle: " .. vehicleClass)
            return nil
        end
        -- Process and return validated data
        return {
            name         = trunkData.name,
            type         = trunkData.invType,
            width        = trunkData.invData.w or 10,
            height       = trunkData.invData.h or 2,
            maxWeight    = trunkData.invData.maxWeight,
            restrictions = trunkData.invData.restrictions,
            isTrunk      = trunkData.isTrunk or true,
            trunkKey     = trunkData.trunkKey
        }
    end

```

---

### lia.inventory.getAllTrunks

#### 📋 Purpose
Retrieves all registered vehicle trunk configurations

#### ⏰ When Called
When needing to iterate through all available vehicle trunks

#### ↩️ Returns
* Table containing all trunk configurations indexed by vehicle class

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get all trunks
    local trunks = lia.inventory.getAllTrunks()
    for vehicleClass, trunkData in pairs(trunks) do
        print("Vehicle:", vehicleClass, "Trunk:", trunkData.name)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get trunks with processing
    local function getAllTrunkInfo()
        local trunks = lia.inventory.getAllTrunks()
        local trunkList = {}
        for vehicleClass, trunkData in pairs(trunks) do
            table.insert(trunkList, {
                vehicleClass = vehicleClass,
                name         = trunkData.name,
                size         = trunkData.invData.w * trunkData.invData.h
            })
        end
        return trunkList
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Get trunks with comprehensive validation and categorization
    local function getCategorizedTrunks()
        local trunks = lia.inventory.getAllTrunks()
        local categorized = {
            civilian  = {},
            emergency = {},
            military  = {},
            other     = {}
        }
        for vehicleClass, trunkData in pairs(trunks) do
            if not trunkData or not trunkData.name or not trunkData.invData then
                lia.warning("Invalid trunk data for vehicle: " .. vehicleClass)
                goto continue
            end
            local trunkInfo = {
                vehicleClass = vehicleClass,
                name         = trunkData.name,
                type         = trunkData.invType,
                width        = trunkData.invData.w,
                height       = trunkData.invData.h,
                maxWeight    = trunkData.invData.maxWeight,
                restricted   = trunkData.invData.restricted or false
            }
            -- Categorize based on vehicle class
            local lowerClass = vehicleClass:lower()
            if string.find(lowerClass, "police") or string.find(lowerClass, "ambulance") then
                table.insert(categorized.emergency, trunkInfo)
            elseif string.find(lowerClass, "military") or string.find(lowerClass, "tank") then
                table.insert(categorized.military, trunkInfo)
            elseif string.find(lowerClass, "civilian") or string.find(lowerClass, "jeep") then
                table.insert(categorized.civilian, trunkInfo)
            else
                table.insert(categorized.other, trunkInfo)
            end
            ::continue::
        end
        return categorized
    end

```

---

### lia.inventory.getAllStorage

#### 📋 Purpose
Retrieves all registered storage configurations with optional trunk filtering

#### ⏰ When Called
When needing to iterate through all available storage containers

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `includeTrunks` | **boolean, optional** | If false, excludes vehicle trunks from results |

#### ↩️ Returns
* Table containing all storage configurations indexed by model/class

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get all storage (including trunks)
    local allStorage = lia.inventory.getAllStorage()
    for key, data in pairs(allStorage) do
        print("Storage:", key, "Name:", data.name)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get storage excluding trunks
    local function getStorageContainers()
        local storageOnly = lia.inventory.getAllStorage(false)
        local containers = {}
        for model, data in pairs(storageOnly) do
            table.insert(containers, {
                model = model,
                name = data.name,
                type = data.invType,
                size = data.invData.w * data.invData.h
            })
        end
        return containers
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Get storage with comprehensive categorization and validation
    local function getCategorizedStorage(includeTrunks)
        local allStorage = lia.inventory.getAllStorage(includeTrunks)
        local categorized = {
            containers = {},
            trunks = {},
            invalid = {}
        }
        for key, data in pairs(allStorage) do
            if not data or not data.name or not data.invData then
                table.insert(categorized.invalid, {key = key, reason = "Invalid data structure"})
                goto continue
            end
            local storageInfo = {
                key = key,
                name = data.name,
                type = data.invType,
                width = data.invData.w,
                height = data.invData.h,
                maxWeight = data.invData.maxWeight,
                isTrunk = data.isTrunk or false
            }
            if data.isTrunk then
                table.insert(categorized.trunks, storageInfo)
            else
                table.insert(categorized.containers, storageInfo)
            end
            ::continue::
        end
        lia.log("Categorized " .. #categorized.containers .. " containers and " .. #categorized.trunks .. " trunks")
        if #categorized.invalid > 0 then
            lia.warning("Found " .. #categorized.invalid .. " invalid storage entries")
        end
        return categorized
    end

```

---

### lia.inventory.show

#### 📋 Purpose
Displays an inventory panel to the client

#### ⏰ When Called
When a player opens an inventory (player inventory, storage container, etc.)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventory` | **table** | The inventory instance to display |
| `parent` | **panel, optional** | Parent panel to attach the inventory panel to |

#### ↩️ Returns
* The created inventory panel

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Show inventory panel
    local panel = lia.inventory.show(inventory)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Show inventory with parent panel
    local function showInventoryInFrame(inventory)
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 300)
        frame:Center()
        frame:MakePopup()
        local invPanel = lia.inventory.show(inventory, frame)
        return invPanel
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Show inventory with comprehensive validation and error handling
    local function showInventorySafely(inventory, parent)
        if not inventory or not inventory.id then
            lia.notify("Invalid inventory provided", "error")
            return nil
        end
        -- Check if inventory is already open
        local globalName = "inv" .. inventory.id
        if IsValid(lia.gui[globalName]) then
            lia.gui[globalName]:Remove()
        end
        -- Validate parent panel
        if parent and not IsValid(parent) then
            lia.warning("Invalid parent panel provided to showInventorySafely")
            parent = nil
        end
        -- Create inventory panel
        local panel = lia.inventory.show(inventory, parent)
        if not panel or not IsValid(panel) then
            lia.error("Failed to create inventory panel for inventory " .. inventory.id)
            return nil
        end
        -- Add custom styling and behavior
        panel:SetPos(50, 50)
        panel:SetSize(600, 400)
        -- Add close button
        local closeBtn = panel:Add("DButton")
        closeBtn:SetText("Close")
        closeBtn:SetPos(panel:GetWide() - 80, 10)
        closeBtn:SetSize(70, 25)
        closeBtn.DoClick = function()
            panel:Remove()
        end
        lia.log("Successfully displayed inventory panel for inventory " .. inventory.id)
        return panel
    end

```

---

### lia.inventory.showDual

#### 📋 Purpose
Displays two inventory panels side-by-side with linked closing behavior

#### ⏰ When Called
When needing to show two inventories simultaneously (e.g., player inventory with storage, trading, etc.)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventory1` | **table** | The first inventory instance to display |
| `inventory2` | **table** | The second inventory instance to display |
| `parent` | **panel, optional** | Parent panel to attach the inventory panels to |

#### ↩️ Returns
* Table containing both created inventory panels {panel1, panel2}, or nil if dual inventory is already open

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua

```

#### 📊 Medium Complexity
```lua

```

#### ⚙️ High Complexity
```lua

```

---

