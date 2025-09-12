# Database & Persistence Hooks

This page documents the hooks for database operations, data persistence, and entity management in the Lilia framework.

---

## Overview

The database and persistence system forms the foundation of Lilia's data management architecture, providing comprehensive hooks for managing data storage, entity persistence, character management, and inventory operations. These hooks enable developers to customize every aspect of data handling, from basic save/load operations to complex entity state management and character lifecycle events.

The database and persistence system in Lilia is built around a sophisticated architecture that supports multiple database backends, automatic data serialization, and extensive customization capabilities. The system handles everything from simple key-value storage to complex relational data structures, ensuring that all game state is properly maintained across server restarts and player sessions.

**Core Data Management Hooks** provide the fundamental building blocks for data persistence, including entity state tracking, data validation, and automatic serialization. These hooks allow developers to define custom data structures, implement data migration strategies, and ensure data integrity across all operations.

**Character Lifecycle Management** hooks handle the complete character experience from creation to deletion, including character data persistence, inventory management, and state restoration. These hooks enable complex character systems with custom attributes, persistent inventories, and sophisticated character progression mechanics.

**Entity Persistence System** hooks manage the persistence of game entities, allowing developers to save and restore entity states, positions, and custom properties. This system supports both automatic persistence for important entities and manual control for specific use cases.

**Inventory and Item Management** hooks provide comprehensive control over item storage, transfer, and persistence. These hooks enable complex inventory systems with custom item properties, transfer restrictions, and automatic data synchronization.

**Database Schema Management** hooks allow developers to customize database initialization, table creation, and data migration processes. These hooks ensure that custom data structures are properly integrated into the framework's database system.

**Data Validation and Security** hooks provide mechanisms for data validation, sanitization, and security checks. These hooks help prevent data corruption, ensure data integrity, and implement custom security measures for sensitive data.

**Performance and Optimization** hooks enable developers to optimize database operations, implement caching strategies, and manage data cleanup processes. These hooks help maintain optimal performance even with large amounts of persistent data.

**Cross-System Integration** hooks facilitate integration between the persistence system and other framework components, ensuring that data changes are properly propagated throughout the system and that all components remain synchronized.

**Error Handling and Recovery** hooks provide robust error handling for database operations, including automatic retry mechanisms, data recovery procedures, and comprehensive logging for debugging and monitoring.

**Custom Data Types** hooks allow developers to define custom data types and serialization methods, enabling the persistence of complex data structures that go beyond basic Lua types.

---

### OnEntityPersistUpdated

**Purpose**

Notifies that a persistent entity's stored data has been updated and saved.

**Parameters**

* `ent` (*Entity*): The persistent entity.
* `data` (*table*): The saved persistence payload for this entity.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to respond when persistent entity data is updated and saved.
-- Persistent entities maintain their state across server restarts.
-- This hook is useful for logging persistence updates and debugging entity state changes.

-- Log when vendor entities are saved to persistence
hook.Add("OnEntityPersistUpdated", "LogVendorSave", function(ent, data)
    -- Check if the entity is valid and is a vendor
    if IsValid(ent) and ent:GetClass() == "lia_vendor" then
        -- Print the vendor's name to server console
        print("Vendor persistence updated:", data.name or "Unknown")
    end
end)

-- Track all entity persistence updates for debugging
hook.Add("OnEntityPersistUpdated", "DebugPersistence", function(ent, data)
    if IsValid(ent) then
        print("Entity", ent:GetClass(), "persistence data updated")
        -- Log specific data fields if they exist
        if data.position then
            print("  Position:", data.position)
        end
        if data.angles then
            print("  Angles:", data.angles)
        end
    end
end)
```

---

### UpdateEntityPersistence

**Purpose**

Request that the gamemode re-save a persistent entity's data to disk.

**Parameters**

* `ent` (*Entity*): The persistent entity to update.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to request that persistent entity data be re-saved to disk.
-- This hook is useful for forcing immediate persistence updates after entity modifications.
-- It can be used to ensure data is saved when entities are modified programmatically.

-- After editing a vendor entity, persist changes immediately
local vendor = ents.FindByClass("lia_vendor")[1]
if IsValid(vendor) then
    -- Force the entity to save its current state
    hook.Run("UpdateEntityPersistence", vendor)
    print("Vendor persistence updated")
end

-- Update persistence after modifying entity properties
hook.Add("PlayerSay", "UpdateEntityOnCommand", function(ply, text)
    if text == "!saveentities" then
        -- Find all persistent entities and update them
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetPersistent() then
                hook.Run("UpdateEntityPersistence", ent)
            end
        end
        ply:ChatPrint("All persistent entities updated")
    end
end)
```

---

### SaveData

**Purpose**

Called when the server saves data to disk. Allows adding custom data to the save payload.

**Parameters**

* `data` (*table*): Save data table to populate.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to add custom data to the server save payload.
-- The save system persists server state across restarts.
-- This hook allows you to include custom data that should be preserved.

-- Add custom data to the save payload
hook.Add("SaveData", "SaveCustomData", function(data)
    -- Add server-specific data that should persist
    data.serverName = GetHostName()
    data.saveTime = os.time()
    data.customValue = "example"
    
    -- Add player count at time of save
    data.playerCount = #player.GetAll()
    
    print("Custom data added to save payload")
end)

-- Save module-specific data
hook.Add("SaveData", "SaveModuleData", function(data)
    -- Ensure data table exists
    if not data.modules then
        data.modules = {}
    end
    
    -- Save custom module state
    data.modules.customModule = {
        enabled = true,
        version = "1.0.0",
        settings = {
            debug = false,
            maxItems = 100
        }
    }
end)
```

---

### OnDataSet

**Purpose**

Fires when a key-value pair is stored in the server's data system.

**Parameters**

* `key` (*string*): Data key that was set.
* `value` (*any*): Value that was stored.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log all data changes for debugging
hook.Add("OnDataSet", "LogDataChanges", function(key, value)
    -- Convert value to string for logging
    local valueStr = tostring(value)
    if type(value) == "table" then
        valueStr = util.TableToJSON(value)
    end
    
    print("Data set:", key, "=", valueStr)
end)

-- Track specific data keys
hook.Add("OnDataSet", "TrackImportantData", function(key, value)
    -- Monitor important configuration changes
    if string.find(key, "config_") then
        print("Configuration updated:", key, "to", tostring(value))
        
        -- Notify administrators of config changes
        for _, ply in pairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("Config changed: " .. key)
            end
        end
    end
end)
```

---

### PersistenceSave

**Purpose**

Called before an entity's persistence data is saved to disk.

**Parameters**

* `ent` (*Entity*): Entity being saved.
* `data` (*table*): Persistence data being saved.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Add timestamp to all saved entities
hook.Add("PersistenceSave", "AddTimestamp", function(ent, data)
    -- Add save timestamp for tracking
    data.lastSaved = os.time()
    data.saveDate = os.date("%Y-%m-%d %H:%M:%S")
    
    -- Add entity-specific metadata
    data.entityClass = ent:GetClass()
    data.mapName = game.GetMap()
end)

-- Add custom data for specific entity types
hook.Add("PersistenceSave", "AddCustomData", function(ent, data)
    -- Add custom data for vendor entities
    if ent:GetClass() == "lia_vendor" then
        data.vendorData = {
            lastRestocked = ent.lastRestocked or 0,
            totalSales = ent.totalSales or 0,
            isActive = ent:GetActive()
        }
    end
    
    -- Add health data for NPCs
    if ent:IsNPC() then
        data.health = ent:Health()
        data.maxHealth = ent:GetMaxHealth()
    end
end)
```

---

### CanPersistEntity

**Purpose**

Determines if an entity should be saved for persistence.

**Parameters**

* `ent` (*Entity*): Entity to check.

**Returns**

* `boolean` (*boolean*): False to prevent persistence.

**Realm**

**Server**

**Example Usage**

```lua
-- Prevent temporary entities from being saved
hook.Add("CanPersistEntity", "NoTempEntities", function(ent)
    -- Don't save temporary entities
    if ent:IsTemporary() then
        return false
    end
    
    -- Don't save entities that are being removed
    if ent:IsMarkedForDeletion() then
        return false
    end
end)

-- Only save specific entity types
hook.Add("CanPersistEntity", "OnlySpecificTypes", function(ent)
    local allowedTypes = {
        "lia_vendor",
        "lia_item",
        "lia_money",
        "prop_physics"
    }
    
    -- Check if entity class is in allowed list
    for _, class in pairs(allowedTypes) do
        if ent:GetClass() == class then
            return true
        end
    end
    
    -- Deny persistence for other entity types
    return false
end)
```

---

### GetEntitySaveData

**Purpose**

Allows modification of the data saved for an entity's persistence.

**Parameters**

* `ent` (*Entity*): Entity being saved.
* `data` (*table*): Current save data.

**Returns**

* `modifiedData` (*table*): Modified save data.

**Realm**

**Server**

**Example Usage**

```lua
-- Add metadata to all saved entities
hook.Add("GetEntitySaveData", "AddMetadata", function(ent, data)
    -- Add system metadata
    data.metadata = {
        savedBy = "system",
        saveVersion = "1.0",
        timestamp = os.time()
    }
    
    -- Add entity-specific data
    if ent:GetClass() == "lia_vendor" then
        data.vendorInfo = {
            owner = ent:GetOwner() and ent:GetOwner():Nick() or "Unknown",
            lastInteraction = ent.lastInteraction or 0
        }
    end
    
    return data
end)

-- Clean up sensitive data before saving
hook.Add("GetEntitySaveData", "CleanSensitiveData", function(ent, data)
    -- Remove sensitive information
    if data.password then
        data.password = nil
    end
    
    -- Sanitize player names
    if data.ownerName then
        data.ownerName = string.gsub(data.ownerName, "[^%w%s]", "")
    end
    
    return data
end)
```

---

### OnEntityPersisted

**Purpose**

Fires when an entity has been successfully saved to persistence.

**Parameters**

* `ent` (*Entity*): Entity that was saved.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log successful entity persistence
hook.Add("OnEntityPersisted", "LogPersistence", function(ent)
    -- Log the entity class and position
    local pos = ent:GetPos()
    print("Entity persisted:", ent:GetClass(), "at", pos)
    
    -- Track persistence statistics
    if not _G.persistenceStats then
        _G.persistenceStats = {}
    end
    
    local class = ent:GetClass()
    _G.persistenceStats[class] = (_G.persistenceStats[class] or 0) + 1
end)

-- Notify administrators of important entity saves
hook.Add("OnEntityPersisted", "NotifyAdmins", function(ent)
    -- Notify for vendor saves
    if ent:GetClass() == "lia_vendor" then
        for _, ply in pairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("Vendor entity saved: " .. (ent:GetName() or "Unnamed"))
            end
        end
    end
end)
```

---

### OnEntityLoaded

**Purpose**

Called when a persistent entity is loaded from disk.

**Parameters**

* `ent` (*Entity*): Entity that was loaded.
* `data` (*table*): Loaded persistence data.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Restore entity state from saved data
hook.Add("OnEntityLoaded", "RestoreState", function(ent, data)
    -- Restore health if it was saved
    if data.health then
        ent:SetHealth(data.health)
    end
    
    -- Restore position and angles
    if data.position then
        ent:SetPos(data.position)
    end
    if data.angles then
        ent:SetAngles(data.angles)
    end
    
    -- Restore custom properties
    if data.customProps then
        for key, value in pairs(data.customProps) do
            ent:SetKeyValue(key, tostring(value))
        end
    end
end)

-- Initialize vendor-specific data
hook.Add("OnEntityLoaded", "InitializeVendor", function(ent, data)
    if ent:GetClass() == "lia_vendor" then
        -- Restore vendor inventory
        if data.vendorInventory then
            ent:SetInventory(data.vendorInventory)
        end
        
        -- Restore vendor settings
        if data.vendorSettings then
            ent:SetVendorSettings(data.vendorSettings)
        end
        
        print("Vendor loaded:", data.name or "Unnamed")
    end
end)
```

---

### LoadData

**Purpose**

Called when the server loads saved data from disk.

**Parameters**

* `data` (*table*): Loaded data table.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Load custom data from save file
hook.Add("LoadData", "LoadCustomData", function(data)
    -- Load custom values
    if data.customValue then
        print("Loaded custom value:", data.customValue)
        _G.customValue = data.customValue
    end
    
    -- Load server settings
    if data.serverSettings then
        for key, value in pairs(data.serverSettings) do
            _G.serverSettings = _G.serverSettings or {}
            _G.serverSettings[key] = value
        end
        print("Server settings loaded")
    end
    
    -- Load module data
    if data.modules then
        for moduleName, moduleData in pairs(data.modules) do
            print("Loading module data for:", moduleName)
            -- Process module-specific data
            if moduleName == "customModule" then
                _G.customModuleData = moduleData
            end
        end
    end
end)

-- Validate loaded data integrity
hook.Add("LoadData", "ValidateData", function(data)
    -- Check for required data
    if not data.version then
        print("Warning: No version data found in save file")
    end
    
    -- Validate data structure
    if data.characters and type(data.characters) ~= "table" then
        print("Error: Invalid characters data structure")
        data.characters = {}
    end
    
    print("Data validation completed")
end)
```

---

### PostLoadData

**Purpose**

Runs after all saved data has been loaded and processed.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Initialize systems after all data is loaded
hook.Add("PostLoadData", "InitializeAfterLoad", function()
    print("All data loaded successfully")
    
    -- Initialize custom systems
    if _G.customModuleData then
        -- Set up custom module with loaded data
        CustomModule:Initialize(_G.customModuleData)
    end
    
    -- Start background processes
    timer.Create("DataCleanup", 300, 0, function()
        -- Clean up old data every 5 minutes
        print("Performing data cleanup...")
    end)
    
    -- Notify all players that data is ready
    for _, ply in pairs(player.GetAll()) do
        ply:ChatPrint("Server data loaded and ready!")
    end
end)

-- Perform post-load validation
hook.Add("PostLoadData", "PostLoadValidation", function()
    -- Validate that all critical systems are working
    local success = true
    
    -- Check database connection
    if not lia.db then
        print("Error: Database not connected after load")
        success = false
    end
    
    -- Check essential modules
    if not lia.module then
        print("Error: Module system not initialized")
        success = false
    end
    
    if success then
        print("Post-load validation passed")
    else
        print("Post-load validation failed - some systems may not work properly")
    end
end)
```

---

### ShouldDataBeSaved

**Purpose**

Determines if a specific data key should be saved to disk.

**Parameters**

* `key` (*string*): Data key to check.

**Returns**

* `boolean` (*boolean*): False to skip saving this key.

**Realm**

**Server**

**Example Usage**

```lua
-- Skip temporary data from being saved
hook.Add("ShouldDataBeSaved", "SkipTempData", function(key)
    -- Don't save temporary data
    if string.find(key, "temp_") then
        return false
    end
    
    -- Don't save debug data
    if string.find(key, "debug_") then
        return false
    end
    
    -- Don't save session-specific data
    if string.find(key, "session_") then
        return false
    end
end)

-- Filter sensitive data
hook.Add("ShouldDataBeSaved", "FilterSensitiveData", function(key)
    -- List of sensitive keys that should not be saved
    local sensitiveKeys = {
        "password",
        "token",
        "secret",
        "private_key"
    }
    
    -- Check if key contains sensitive information
    for _, sensitive in pairs(sensitiveKeys) do
        if string.find(string.lower(key), sensitive) then
            print("Blocked saving sensitive data:", key)
            return false
        end
    end
    
    return true
end)
```

---

### DatabaseConnected

**Purpose**

Fires when the database connection is established.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Initialize systems when database connects
hook.Add("DatabaseConnected", "InitDatabase", function()
    print("Database connection established")
    
    -- Set up database tables
    lia.db.query([[
        CREATE TABLE IF NOT EXISTS custom_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT UNIQUE,
            value TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    -- Load initial data
    lia.db.query("SELECT * FROM custom_data", function(data)
        if data then
            print("Loaded", #data, "custom data entries")
        end
    end)
    
    -- Start database maintenance timer
    timer.Create("DatabaseMaintenance", 3600, 0, function()
        -- Run database maintenance every hour
        lia.db.query("VACUUM")
        print("Database maintenance completed")
    end)
end)

-- Notify administrators of database status
hook.Add("DatabaseConnected", "NotifyAdmins", function()
    for _, ply in pairs(player.GetAll()) do
        if ply:IsAdmin() then
            ply:ChatPrint("Database connection established successfully")
        end
    end
end)
```

---

### CanSaveData

**Purpose**

Checks if data can be saved at this time.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `boolean` (*boolean*): False to prevent saving.

**Realm**

**Server**

**Example Usage**

```lua
-- Prevent saving during special events
hook.Add("CanSaveData", "PreventSaveDuringEvent", function()
    -- Don't save during active events
    if game.GetGlobalState("event_active") then
        print("Saving blocked: Event in progress")
        return false
    end
    
    -- Don't save during map changes
    if game.GetGlobalState("map_changing") then
        print("Saving blocked: Map changing")
        return false
    end
    
    return true
end)

-- Check database availability before saving
hook.Add("CanSaveData", "CheckDatabaseStatus", function()
    -- Ensure database is connected
    if not lia.db or not lia.db.isConnected() then
        print("Saving blocked: Database not connected")
        return false
    end
    
    -- Check if database is busy
    if lia.db.isBusy() then
        print("Saving blocked: Database busy")
        return false
    end
    
    return true
end)
```

---

### SetupDatabase

**Purpose**

Called during database initialization to set up tables and schema.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("SetupDatabase", "CreateCustomTables", function()
    -- Custom table creation logic
end)
```

---

### OnDatabaseLoaded

**Purpose**

Fires after the database schema and initial data have been loaded.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnDatabaseLoaded", "PostDatabaseInit", function()
    print("Database fully loaded")
end)
```

---

### OnWipeTables

**Purpose**

Called when database tables are being wiped/reset.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnWipeTables", "BackupBeforeWipe", function()
    -- Backup logic before wipe
end)
```

---

### LiliaTablesLoaded

**Purpose**

Fires when all Lilia database tables have been loaded and are ready.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("LiliaTablesLoaded", "InitializeModules", function()
    -- Initialize modules that depend on database tables
end)
```

---

### OnLoadTables

**Purpose**

Called during the table loading process.

**Parameters**

* `tableName` (*string*): Name of the table being loaded.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnLoadTables", "LogTableLoading", function(tableName)
    print("Loading table:", tableName)
end)
```

---

### OnItemRegistered

**Purpose**

Fires when an item is registered in the system.

**Parameters**

* `item` (*table*): Item data that was registered.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnItemRegistered", "LogItemRegistration", function(item)
    print("Item registered:", item.name)
end)
```

---

### OnCharVarChanged

**Purpose**

Called when a character variable changes.

**Parameters**

* `character` (*Character*): Character whose variable changed.
* `key` (*string*): Variable key that changed.
* `oldValue` (*any*): Previous value.
* `newValue` (*any*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnCharVarChanged", "LogCharChanges", function(character, key, old, new)
    print("Character var changed:", key, "from", old, "to", new)
end)
```

---

### OnCharLocalVarChanged

**Purpose**

Fires when a character's local variable changes.

**Parameters**

* `character` (*Character*): Character whose variable changed.
* `key` (*string*): Variable key that changed.
* `oldValue` (*any*): Previous value.
* `newValue` (*any*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("OnCharLocalVarChanged", "UpdateUI", function(character, key, old, new)
    -- Update UI elements based on local var changes
end)
```

---

### LocalVarChanged

**Purpose**

Called when any local variable changes.

**Parameters**

* `key` (*string*): Variable key that changed.
* `oldValue` (*any*): Previous value.
* `newValue` (*any*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("LocalVarChanged", "TrackChanges", function(key, old, new)
    print("Local var changed:", key)
end)
```

---

### NetVarChanged

**Purpose**

Fires when a network variable changes.

**Parameters**

* `entity` (*Entity*): Entity whose netvar changed.
* `key` (*string*): Variable key that changed.
* `oldValue` (*any*): Previous value.
* `newValue` (*any*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("NetVarChanged", "MonitorNetVars", function(ent, key, old, new)
    print("NetVar changed on", ent, ":", key)
end)
```

---

### ItemDataChanged

**Purpose**

Called when an item's data changes.

**Parameters**

* `item` (*Item*): Item whose data changed.
* `key` (*string*): Data key that changed.
* `oldValue` (*any*): Previous value.
* `newValue` (*any*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("ItemDataChanged", "LogItemData", function(item, key, old, new)
    print("Item data changed:", item:getName(), key)
end)
```

---

### ItemQuantityChanged

**Purpose**

Fires when an item's quantity changes.

**Parameters**

* `item` (*Item*): Item whose quantity changed.
* `oldQuantity` (*number*): Previous quantity.
* `newQuantity` (*number*): New quantity.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Track quantity changes for items
hook.Add("ItemQuantityChanged", "TrackQuantity", function(item, old, new)
    local itemName = item:getName()
    print("Quantity changed for", itemName, "from", old, "to", new)
    
    -- Log significant quantity changes
    local change = new - old
    if math.abs(change) > 10 then
        print("Large quantity change detected:", itemName, "by", change)
    end
end)

-- Update item statistics
hook.Add("ItemQuantityChanged", "UpdateItemStats", function(item, old, new)
    -- Track total quantity changes
    local totalChanges = item:getData("quantityChanges", 0)
    item:setData("quantityChanges", totalChanges + 1)
    
    -- Track net quantity change
    local netChange = item:getData("netQuantityChange", 0)
    item:setData("netQuantityChange", netChange + (new - old))
    
    -- Update last modified timestamp
    item:setData("lastModified", os.time())
end)
```

---

### InventoryDataChanged

**Purpose**

Called when inventory data changes.

**Parameters**

* `inventory` (*Inventory*): Inventory whose data changed.
* `key` (*string*): Data key that changed.
* `oldValue` (*any*): Previous value.
* `newValue` (*any*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InventoryDataChanged", "LogInventoryData", function(inv, key, old, new)
    print("Inventory data changed:", key)
end)
```

---

### InventoryInitialized

**Purpose**

Fires when an inventory is initialized.

**Parameters**

* `inventory` (*Inventory*): Inventory that was initialized.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InventoryInitialized", "SetupInventory", function(inv)
    print("Inventory initialized with ID:", inv:getID())
end)
```

---

### InventoryItemAdded

**Purpose**

Called when an item is added to an inventory.

**Parameters**

* `inventory` (*Inventory*): Inventory that received the item.
* `item` (*Item*): Item that was added.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log item additions to inventory
hook.Add("InventoryItemAdded", "LogItemAddition", function(inv, item)
    local itemName = item:getName()
    local invID = inv:getID()
    
    print("Item added to inventory:", itemName, "inventory ID:", invID)
    
    -- Log to file for tracking
    file.Append("logs/inventory_changes.txt", 
        os.date("%Y-%m-%d %H:%M:%S") .. " - Added " .. itemName .. " to inventory " .. invID .. "\n"
    )
end)

-- Update inventory statistics
hook.Add("InventoryItemAdded", "UpdateStats", function(inv, item)
    -- Update item count
    local currentCount = inv:getData("itemCount", 0)
    inv:setData("itemCount", currentCount + 1)
    
    -- Update total value
    local itemValue = item:getData("value", 0)
    local totalValue = inv:getData("totalValue", 0)
    inv:setData("totalValue", totalValue + itemValue)
    
    -- Check if inventory is full
    local maxItems = inv:getData("maxItems", 100)
    if currentCount + 1 >= maxItems then
        print("Inventory is full:", inv:getID())
    end
end)
```

---

### InventoryItemRemoved

**Purpose**

Fires when an item is removed from an inventory.

**Parameters**

* `inventory` (*Inventory*): Inventory that lost the item.
* `item` (*Item*): Item that was removed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log item removals from inventory
hook.Add("InventoryItemRemoved", "LogItemRemoval", function(inv, item)
    local itemName = item:getName()
    local invID = inv:getID()
    
    print("Item removed from inventory:", itemName, "inventory ID:", invID)
    
    -- Log to file for tracking
    file.Append("logs/inventory_changes.txt", 
        os.date("%Y-%m-%d %H:%M:%S") .. " - Removed " .. itemName .. " from inventory " .. invID .. "\n"
    )
end)

-- Update inventory statistics after removal
hook.Add("InventoryItemRemoved", "UpdateStats", function(inv, item)
    -- Update item count
    local currentCount = inv:getData("itemCount", 0)
    inv:setData("itemCount", math.max(0, currentCount - 1))
    
    -- Update total value
    local itemValue = item:getData("value", 0)
    local totalValue = inv:getData("totalValue", 0)
    inv:setData("totalValue", math.max(0, totalValue - itemValue))
    
    -- Check if inventory is now empty
    local newCount = inv:getData("itemCount", 0)
    if newCount == 0 then
        print("Inventory is now empty:", inv:getID())
    end
end)
```

---

### InventoryDeleted

**Purpose**

Called when an inventory is deleted.

**Parameters**

* `inventory` (*Inventory*): Inventory that was deleted.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InventoryDeleted", "CleanupInventory", function(inv)
    print("Inventory deleted:", inv:getID())
end)
```

---

### ItemDeleted

**Purpose**

Fires when an item is deleted.

**Parameters**

* `item` (*Item*): Item that was deleted.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("ItemDeleted", "LogItemDeletion", function(item)
    print("Item deleted:", item:getName())
end)
```

---

### ItemInitialized

**Purpose**

Called when an item is initialized.

**Parameters**

* `item` (*Item*): Item that was initialized.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("ItemInitialized", "SetupItem", function(item)
    print("Item initialized:", item:getName())
end)
```

---

### OnCharDisconnect

**Purpose**

Fires when a character disconnects.

**Parameters**

* `character` (*Character*): Character that disconnected.
* `client` (*Player*): Player who owned the character.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log character disconnections
hook.Add("OnCharDisconnect", "LogDisconnect", function(character, client)
    local charName = character:getName()
    local playerName = client:Nick()
    
    print("Character disconnected:", charName, "owned by", playerName)
    
    -- Log to file for admin review
    file.Append("logs/character_disconnects.txt", 
        os.date("%Y-%m-%d %H:%M:%S") .. " - " .. charName .. " (" .. playerName .. ")\n"
    )
end)

-- Save character data before disconnect
hook.Add("OnCharDisconnect", "SaveBeforeDisconnect", function(character, client)
    -- Save character's current state
    character:save()
    
    -- Save inventory data
    if character:getInv() then
        character:getInv():save()
    end
    
    -- Save any custom data
    if character.customData then
        lia.db.update("characters", {
            custom_data = util.TableToJSON(character.customData)
        }, "id = " .. character:getID())
    end
    
    print("Character data saved before disconnect")
end)
```

---

### CharPreSave

**Purpose**

Called before a character is saved.

**Parameters**

* `character` (*Character*): Character being saved.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Prepare character data before saving
hook.Add("CharPreSave", "PrepareSave", function(character)
    -- Update last seen timestamp
    character:setData("lastSeen", os.time())
    
    -- Save current position
    local pos = character:getPos()
    if pos then
        character:setData("lastPosition", pos)
    end
    
    -- Save current health
    character:setData("lastHealth", character:getHealth())
    
    -- Clean up temporary data
    character:setData("tempData", nil)
    
    print("Character prepared for save:", character:getName())
end)

-- Validate character data before saving
hook.Add("CharPreSave", "ValidateData", function(character)
    -- Ensure character has required data
    if not character:getName() or character:getName() == "" then
        print("Warning: Character has no name, using fallback")
        character:setName("Unknown_" .. character:getID())
    end
    
    -- Validate character level
    local level = character:getData("level", 1)
    if level < 1 then
        character:setData("level", 1)
    end
    
    -- Ensure character has valid faction
    if not character:getFaction() then
        character:setFaction("citizen")
    end
end)
```

---

### CharPostSave

**Purpose**

Fires after a character is saved.

**Parameters**

* `character` (*Character*): Character that was saved.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Perform actions after character save
hook.Add("CharPostSave", "PostSaveActions", function(character)
    local charName = character:getName()
    print("Character saved:", charName)
    
    -- Log save event
    file.Append("logs/character_saves.txt", 
        os.date("%Y-%m-%d %H:%M:%S") .. " - " .. charName .. "\n"
    )
    
    -- Update save statistics
    if not _G.saveStats then
        _G.saveStats = {}
    end
    _G.saveStats.totalSaves = (_G.saveStats.totalSaves or 0) + 1
    _G.saveStats.lastSave = os.time()
end)

-- Clean up after save
hook.Add("CharPostSave", "CleanupAfterSave", function(character)
    -- Clear any temporary data
    character:setData("saveInProgress", nil)
    
    -- Update character cache
    if character.cache then
        character.cache.lastSave = os.time()
    end
    
    -- Notify character owner if online
    local client = character:getPlayer()
    if IsValid(client) then
        client:ChatPrint("Character data saved successfully")
    end
end)
```

---

### CharLoaded

**Purpose**

Called when a character is loaded.

**Parameters**

* `character` (*Character*): Character that was loaded.
* `client` (*Player*): Player who loaded the character.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Welcome message when character loads
hook.Add("CharLoaded", "WelcomeMessage", function(character, client)
    local charName = character:getName()
    client:ChatPrint("Welcome back, " .. charName)
    
    -- Show last login time
    local lastSeen = character:getData("lastSeen", 0)
    if lastSeen > 0 then
        local timeAgo = os.time() - lastSeen
        local hours = math.floor(timeAgo / 3600)
        client:ChatPrint("Last seen " .. hours .. " hours ago")
    end
end)

-- Initialize character after loading
hook.Add("CharLoaded", "InitializeCharacter", function(character, client)
    -- Set up character-specific data
    if not character:getData("level") then
        character:setData("level", 1)
    end
    
    -- Restore health if it was saved
    local savedHealth = character:getData("lastHealth")
    if savedHealth then
        character:setHealth(savedHealth)
    end
    
    -- Restore position if it was saved
    local savedPos = character:getData("lastPosition")
    if savedPos then
        character:setPos(savedPos)
    end
    
    -- Update last seen timestamp
    character:setData("lastSeen", os.time())
    
    print("Character initialized:", character:getName())
end)
```

---

### PreCharDelete

**Purpose**

Fires before a character is deleted.

**Parameters**

* `character` (*Character*): Character being deleted.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Create backup before character deletion
hook.Add("PreCharDelete", "BackupCharacter", function(character)
    local charName = character:getName()
    local charID = character:getID()
    
    -- Create backup data
    local backupData = {
        name = charName,
        id = charID,
        faction = character:getFaction(),
        level = character:getData("level", 1),
        health = character:getHealth(),
        position = character:getPos(),
        deletedAt = os.time(),
        deletedBy = "system"
    }
    
    -- Save backup to file
    local backupFile = "backups/characters/" .. charID .. "_" .. os.time() .. ".json"
    file.Write(backupFile, util.TableToJSON(backupData, true))
    
    print("Character backup created:", charName, "->", backupFile)
end)

-- Log character deletion
hook.Add("PreCharDelete", "LogDeletion", function(character)
    local charName = character:getName()
    local charID = character:getID()
    
    -- Log to admin file
    file.Append("logs/character_deletions.txt", 
        os.date("%Y-%m-%d %H:%M:%S") .. " - " .. charName .. " (ID: " .. charID .. ")\n"
    )
    
    -- Notify administrators
    for _, ply in pairs(player.GetAll()) do
        if ply:IsAdmin() then
            ply:ChatPrint("Character being deleted: " .. charName)
        end
    end
end)
```

---

### OnCharDelete

**Purpose**

Called when a character is deleted.

**Parameters**

* `character` (*Character*): Character that was deleted.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log character deletion completion
hook.Add("OnCharDelete", "LogDeletion", function(character)
    local charName = character:getName()
    print("Character deleted:", charName)
    
    -- Update deletion statistics
    if not _G.deletionStats then
        _G.deletionStats = {}
    end
    _G.deletionStats.totalDeletions = (_G.deletionStats.totalDeletions or 0) + 1
    _G.deletionStats.lastDeletion = os.time()
    
    -- Clean up related data
    local charID = character:getID()
    if charID then
        -- Remove from any caches
        if _G.characterCache then
            _G.characterCache[charID] = nil
        end
        
        -- Clean up inventory data
        lia.db.query("DELETE FROM lia_inventories WHERE character_id = " .. charID)
        
        -- Clean up item data
        lia.db.query("DELETE FROM lia_items WHERE character_id = " .. charID)
    end
end)

-- Notify administrators of deletion
hook.Add("OnCharDelete", "NotifyAdmins", function(character)
    local charName = character:getName()
    
    -- Notify all administrators
    for _, ply in pairs(player.GetAll()) do
        if ply:IsAdmin() then
            ply:ChatPrint("Character deletion completed: " .. charName)
        end
    end
    
    -- Send to admin chat if available
    if lia.chat then
        lia.chat.send(nil, "admin", "Character deleted: " .. charName)
    end
end)
```

---

### OnCharCreated

**Purpose**

Fires when a character is created.

**Parameters**

* `character` (*Character*): Character that was created.
* `client` (*Player*): Player who created the character.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCharCreated", "WelcomeNew", function(character, client)
    client:ChatPrint("Welcome to the server, " .. character:getName())
end)
```

---

### OnTransferred

**Purpose**

Called when something is transferred.

**Parameters**

* `old` (*any*): Previous state/location.
* `new` (*any*): New state/location.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnTransferred", "LogTransfer", function(old, new)
    print("Transfer occurred from", old, "to", new)
end)
```

---

### CharListLoaded

**Purpose**

Fires when the character list is loaded.

**Parameters**

* `characters` (*table*): List of characters.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("CharListLoaded", "ProcessCharacters", function(characters)
    print("Character list loaded with", #characters, "characters")
end)
```

---

### CharListUpdated

**Purpose**

Called when the character list is updated.

**Parameters**

* `characters` (*table*): Updated character list.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("CharListUpdated", "RefreshUI", function(characters)
    -- Refresh character selection UI
end)
```

---

### CharListExtraDetails

**Purpose**

Allows adding extra details to character list entries.

**Parameters**

* `character` (*Character*): Character to add details for.

**Returns**

* `details` (*table*): Extra details to display.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("CharListExtraDetails", "AddLevel", function(character)
    return {level = character:getData("level", 1)}
end)
```

---

### KickedFromChar

**Purpose**

Fires when a player is kicked from a character.

**Parameters**

* `character` (*Character*): Character the player was kicked from.
* `reason` (*string*): Reason for the kick.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("KickedFromChar", "LogKick", function(character, reason)
    print("Player kicked from character:", reason)
end)
```


---

### CharRestored

**Purpose**

Fires when a character is restored.

**Parameters**

* `character` (*Character*): Character that was restored.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("CharRestored", "LogRestore", function(character)
    print("Character restored:", character:getName())
end)
```

---

### CreateDefaultInventory

**Purpose**

Called to create a default inventory.

**Parameters**

* `client` (*Player*): Player to create inventory for.

**Returns**

* `inventory` (*Inventory*): Created inventory.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CreateDefaultInventory", "SetupDefaultInv", function(client)
    -- Create and return default inventory
end)
```

---

### CreateInventoryPanel

**Purpose**

Fires when an inventory panel is created.

**Parameters**

* `inventory` (*Inventory*): Inventory the panel is for.

**Returns**

* `panel` (*Panel*): Created inventory panel.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("CreateInventoryPanel", "CustomPanel", function(inventory)
    -- Create and return custom inventory panel
end)
```

---

### DoModuleIncludes

**Purpose**

Called during module inclusion process.

**Parameters**

* `moduleName` (*string*): Name of the module being included.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("DoModuleIncludes", "LogIncludes", function(moduleName)
    print("Including module:", moduleName)
end)
```

---

### InitializedConfig

**Purpose**

Fires when configuration is initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedConfig", "PostConfigInit", function()
    print("Configuration initialized")
end)
```

---

### InitializedItems

**Purpose**

Called when items are initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedItems", "PostItemInit", function()
    print("Items initialized")
end)
```

---

### InitializedModules

**Purpose**

Fires when modules are initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedModules", "PostModuleInit", function()
    print("Modules initialized")
end)
```

---

### InitializedOptions

**Purpose**

Called when options are initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedOptions", "PostOptionInit", function()
    print("Options initialized")
end)
```

---

### InitializedSchema

**Purpose**

Fires when schema is initialized.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("InitializedSchema", "PostSchemaInit", function()
    print("Schema initialized")
end)
```

---

### OnPlayerPurchaseDoor

**Purpose**

Called when a player purchases a door.

**Parameters**

* `client` (*Player*): Player who purchased the door.
* `door` (*Entity*): Door that was purchased.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnPlayerPurchaseDoor", "LogPurchase", function(client, door)
    print(client:Nick(), "purchased door")
end)
```

---

### OnServerLog

**Purpose**

Fires when a server log entry is created.

**Parameters**

* `message` (*string*): Log message.
* `category` (*string*): Log category.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnServerLog", "CustomLogging", function(message, category)
    -- Custom log processing
end)
```

---

### PlayerMessageSend

**Purpose**

Called when a player sends a message.

**Parameters**

* `client` (*Player*): Player who sent the message.
* `chatType` (*string*): Type of chat message.
* `message` (*string*): Message content.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerMessageSend", "LogMessages", function(client, chatType, message)
    print(client:Nick(), "sent", chatType, ":", message)
end)
```

---

### ChatParsed

**Purpose**

Fires when a chat message is parsed.

**Parameters**

* `speaker` (*Player*): Player who sent the message.
* `text` (*string*): Original message text.
* `chatType` (*string*): Type of chat.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("ChatParsed", "ProcessChat", function(speaker, text, chatType)
    -- Process parsed chat message
end)
```

---

### OnConfigUpdated

**Purpose**

Called when configuration is updated.

**Parameters**

* `key` (*string*): Configuration key that was updated.
* `oldValue` (*any*): Previous value.
* `newValue` (*any*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnConfigUpdated", "LogConfigChange", function(key, old, new)
    print("Config updated:", key, "from", old, "to", new)
end)
```

---

### OnOOCMessageSent

**Purpose**

Fires when an out-of-character message is sent.

**Parameters**

* `client` (*Player*): Player who sent the message.
* `text` (*string*): Message content.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnOOCMessageSent", "ProcessOOC", function(client, text)
    -- Process OOC message
end)
```

---

### OnSalaryGive

**Purpose**

Called when salary is given to a player.

**Parameters**

* `client` (*Player*): Player receiving salary.
* `amount` (*number*): Salary amount.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnSalaryGive", "LogSalary", function(client, amount)
    print(client:Nick(), "received salary:", amount)
end)
```

---

### OnTicketClaimed

**Purpose**

Fires when a ticket is claimed.

**Parameters**

* `ticket` (*table*): Ticket that was claimed.
* `claimer` (*Player*): Player who claimed the ticket.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnTicketClaimed", "ProcessClaim", function(ticket, claimer)
    -- Process ticket claim
end)
```

---

### OnTicketClosed

**Purpose**

Called when a ticket is closed.

**Parameters**

* `ticket` (*table*): Ticket that was closed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnTicketClosed", "ProcessClosure", function(ticket)
    -- Process ticket closure
end)
```

---

### OnTicketCreated

**Purpose**

Fires when a ticket is created.

**Parameters**

* `ticket` (*table*): Ticket that was created.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnTicketCreated", "ProcessCreation", function(ticket)
    -- Process ticket creation
end)
```

---

### OnVendorEdited

**Purpose**

Called when a vendor is edited.

**Parameters**

* `vendor` (*Entity*): Vendor that was edited.
* `client` (*Player*): Player who edited the vendor.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnVendorEdited", "LogEdit", function(vendor, client)
    print("Vendor edited by", client:Nick())
end)
```

---

### CanPlayerEquipItem

**Purpose**

Queries if a player can equip an item. Returning false stops the equip action.

**Parameters**

* `client` (*Player*): Player equipping.
* `item` (*table*): Item to equip.

**Returns**

* `boolean` (*boolean*): False to block equipping.

**Realm**

**Server**

**Example Usage**

```lua
-- Check level requirement for equipping items
hook.Add("CanPlayerEquipItem", "CheckLevel", function(ply, item)
    local character = ply:getChar()
    if not character then return false end
    
    -- Check if item has level requirement
    if item.minLevel then
        local playerLevel = character:getAttrib("level", 0)
        if playerLevel < item.minLevel then
            ply:ChatPrint("You need level " .. item.minLevel .. " to equip this item!")
            return false
        end
    end
    
    -- Check faction requirement
    if item.requiredFaction then
        local playerFaction = character:getFaction()
        if playerFaction ~= item.requiredFaction then
            ply:ChatPrint("Your faction cannot equip this item!")
            return false
        end
    end
    
    return true
end)

-- Check if player has required attributes
hook.Add("CanPlayerEquipItem", "CheckAttributes", function(ply, item)
    local character = ply:getChar()
    if not character then return false end
    
    -- Check strength requirement
    if item.requiredStrength then
        local strength = character:getAttrib("str", 0)
        if strength < item.requiredStrength then
            ply:ChatPrint("You need " .. item.requiredStrength .. " strength to equip this item!")
            return false
        end
    end
    
    -- Check if item is cursed
    if item.cursed then
        ply:ChatPrint("This item is cursed and cannot be equipped!")
        return false
    end
    
    return true
end)
```

---

### CanPlayerUnequipItem

**Purpose**

Called before an item is unequipped. Return false to keep the item equipped.

**Parameters**

* `client` (*Player*): Player unequipping.
* `item` (*table*): Item being unequipped.

**Returns**

* `boolean` (*boolean*): False to prevent unequipping.

**Realm**

**Server**

**Example Usage**

```lua
-- Prevent unequipping cursed gear
hook.Add("CanPlayerUnequipItem", "Cursed", function(ply, item)
    -- Check if item is cursed
    if item.cursed then
        ply:ChatPrint("This item is cursed and cannot be unequipped!")
        return false
    end
    
    -- Check if item is bound to player
    if item.boundToPlayer and item.boundToPlayer ~= ply:SteamID() then
        ply:ChatPrint("This item is bound to another player!")
        return false
    end
    
    return true
end)

-- Check if player is in combat
hook.Add("CanPlayerUnequipItem", "CombatCheck", function(ply, item)
    -- Prevent unequipping during combat
    if ply:getChar() and ply:getChar():getData("inCombat", false) then
        ply:ChatPrint("You cannot unequip items while in combat!")
        return false
    end
    
    -- Check if item is essential
    if item.essential then
        ply:ChatPrint("This item is essential and cannot be unequipped!")
        return false
    end
    
    return true
end)
```

---

### CanPlayerRotateItem

**Purpose**

Called when a player attempts to rotate an inventory item. Return false to block rotating.

**Parameters**

* `client` (*Player*): Player rotating.
* `item` (*table*): Item being rotated.

**Returns**

* `boolean` (*boolean*): False to block rotating.

**Realm**

**Server**

**Example Usage**

```lua
-- Prevent rotating certain special items
hook.Add("CanPlayerRotateItem", "NoRotatingArtifacts", function(ply, item)
    -- Prevent rotating artifacts
    if item.isArtifact then
        ply:ChatPrint("Artifacts cannot be rotated!")
        return false
    end
    
    -- Prevent rotating fragile items
    if item.fragile then
        ply:ChatPrint("This item is too fragile to rotate!")
        return false
    end
    
    return true
end)

-- Check if player has permission to rotate
hook.Add("CanPlayerRotateItem", "CheckPermission", function(ply, item)
    -- Check if player is admin or has special permission
    if not ply:IsAdmin() and not ply:getChar():getData("canRotateItems", false) then
        ply:ChatPrint("You don't have permission to rotate items!")
        return false
    end
    
    -- Check if item is locked
    if item.locked then
        ply:ChatPrint("This item is locked and cannot be rotated!")
        return false
    end
    
    return true
end)
```

---

### PostPlayerSay

**Purpose**

Runs after chat messages are processed. Allows reacting to player chat.

**Parameters**

* `client` (*Player*): Speaking player.
* `message` (*string*): Chat text.
* `chatType` (*string*): Chat channel.
* `anonymous` (*boolean*): Whether the message was anonymous.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log all OOC chat
hook.Add("PostPlayerSay", "LogOOC", function(ply, msg, chatType)
    -- Log OOC messages to file
    if chatType == "ooc" then
        print("[OOC]", ply:Nick(), msg)
        
        -- Log to file for admin review
        file.Append("logs/ooc_chat.txt", 
            os.date("%Y-%m-%d %H:%M:%S") .. " [OOC] " .. ply:Nick() .. ": " .. msg .. "\n"
        )
    end
    
    -- Log admin chat
    if chatType == "admin" then
        print("[ADMIN]", ply:Nick(), msg)
        
        -- Log to admin file
        file.Append("logs/admin_chat.txt", 
            os.date("%Y-%m-%d %H:%M:%S") .. " [ADMIN] " .. ply:Nick() .. ": " .. msg .. "\n"
        )
    end
end)

-- Track chat statistics
hook.Add("PostPlayerSay", "TrackChatStats", function(ply, msg, chatType)
    -- Initialize stats if not exists
    if not _G.chatStats then
        _G.chatStats = {}
    end
    
    -- Track message count by type
    _G.chatStats[chatType] = (_G.chatStats[chatType] or 0) + 1
    
    -- Track player message count
    local steamID = ply:SteamID()
    if not _G.chatStats.players then
        _G.chatStats.players = {}
    end
    _G.chatStats.players[steamID] = (_G.chatStats.players[steamID] or 0) + 1
    
    -- Track message length
    local msgLength = string.len(msg)
    if not _G.chatStats.avgLength then
        _G.chatStats.avgLength = 0
        _G.chatStats.totalLength = 0
        _G.chatStats.messageCount = 0
    end
    
    _G.chatStats.totalLength = _G.chatStats.totalLength + msgLength
    _G.chatStats.messageCount = _G.chatStats.messageCount + 1
    _G.chatStats.avgLength = _G.chatStats.totalLength / _G.chatStats.messageCount
end)
```

---

### ShouldSpawnClientRagdoll

**Purpose**

Decides if a corpse ragdoll should spawn for a player. Return false to skip ragdoll creation.

**Parameters**

* `client` (*Player*): Player that died.

**Returns**

* `boolean` (*boolean*): False to skip ragdoll.

**Realm**

**Server**

**Example Usage**

```lua
-- Disable ragdolls for bots
hook.Add("ShouldSpawnClientRagdoll", "NoBotRagdoll", function(ply)
    -- Don't create ragdolls for bots
    if ply:IsBot() then
        return false
    end
    
    -- Don't create ragdolls for players with no character
    if not ply:getChar() then
        return false
    end
    
    return true
end)

-- Check if player has ragdoll permission
hook.Add("ShouldSpawnClientRagdoll", "CheckPermission", function(ply)
    -- Check if player has ragdoll enabled
    if ply:getChar() and not ply:getChar():getData("ragdollEnabled", true) then
        return false
    end
    
    -- Don't create ragdolls in certain areas
    local pos = ply:GetPos()
    local mapName = game.GetMap()
    
    -- Check for no-ragdoll zones
    if mapName == "gm_flatgrass" then
        return false
    end
    
    return true
end)
```


