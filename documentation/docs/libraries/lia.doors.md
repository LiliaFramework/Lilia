# Doors Library Server

Server-side door management and configuration system for the Lilia framework.

---

Overview

The doors library server component provides comprehensive door management functionality including
preset configuration, database schema verification, and data cleanup operations. It handles
door data persistence, loading door configurations from presets, and maintaining database
integrity. The library manages door ownership, access permissions, faction and class restrictions,
and provides utilities for door data validation and corruption cleanup. It operates primarily
on the server side and integrates with the database system to persist door configurations
across server restarts. The library also handles door locking/unlocking mechanics and
provides hooks for custom door behavior integration.

---

### lia.doors.addPreset

#### 📋 Purpose
Adds a door preset configuration for a specific map

#### ⏰ When Called
When setting up predefined door configurations for maps

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mapName` | **string** | The name of the map to apply the preset to |
| `presetData` | **table** | Table containing door configuration data with the following structure: |
| `name` | **string, optional** | Custom name for the door |
| `price` | **number, optional** | Price to purchase the door |
| `locked` | **boolean, optional** | Whether the door starts locked |
| `disabled` | **boolean, optional** | Whether the door is disabled |
| `hidden` | **boolean, optional** | Whether the door info is hidden |
| `noSell` | **boolean, optional** | Whether the door cannot be sold |
| `factions` | **table, optional** | Array of faction uniqueIDs that can access the door |
| `classes` | **table, optional** | Array of class uniqueIDs that can access the door |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add basic door preset for a map
    lia.doors.addPreset("rp_downtown_v4c_v2", {
    [123] = {
    name = "Police Station Door",
    price = 1000,
    locked = true
    }
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add preset with faction restrictions
    lia.doors.addPreset("rp_downtown_v4c_v2", {
    [123] = {
    name = "Police Station",
    price = 5000,
    locked = false,
    factions = {"police", "mayor"}
    },
    [124] = {
    name = "Evidence Room",
    price = 0,
    locked = true,
    factions = {"police"}
    }
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Complex preset with multiple doors and restrictions
    local policeDoors = {
    [123] = {
    name = "Police Station Main",
    price = 10000,
    locked = false,
    factions = {"police", "mayor", "chief"}
    },
    [124] = {
    name = "Evidence Room",
    price = 0,
    locked = true,
    factions = {"police"},
    classes = {"detective", "chief"}
    },
    [125] = {
    name = "Interrogation Room",
    price = 0,
    locked = true,
    factions = {"police"},
    classes = {"detective", "chief", "officer"}
    }
    }
    lia.doors.addPreset("rp_downtown_v4c_v2", policeDoors)

```

---

### lia.doors.getPreset

#### 📋 Purpose
Retrieves a door preset configuration for a specific map

#### ⏰ When Called
When loading door data or checking for existing presets

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mapName` | **string** | The name of the map to get the preset for |

#### ↩️ Returns
* Table or nil - The preset data table if found, nil otherwise

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get preset for current map
    local preset = lia.doors.getPreset(game.GetMap())
    if preset then
        print("Found preset for map")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check and use preset data
    local mapName = game.GetMap()
    local preset = lia.doors.getPreset(mapName)
    if preset then
        for doorID, doorData in pairs(preset) do
            print("Door " .. doorID .. " has preset: " .. (doorData.name or "Unnamed"))
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic preset loading with validation
    local function loadMapPresets(mapName)
        local preset = lia.doors.getPreset(mapName)
        if not preset then
            lia.warning("No door preset found for map: " .. mapName)
            return false
        end
        local validDoors = 0
        for doorID, doorData in pairs(preset) do
            local ent = ents.GetMapCreatedEntity(doorID)
            if IsValid(ent) and ent:isDoor() then
                validDoors = validDoors + 1
                -- Apply preset data to door
                ent:setNetVar("doorData", doorData)
            end
        end
        lia.information("Loaded " .. validDoors .. " doors from preset for " .. mapName)
        return true
    end

```

---

### lia.customSchemaCheck

#### 📋 Purpose
Verifies the database schema for the doors table matches expected structure

#### ⏰ When Called
During server initialization or when checking database integrity

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Verify schema on server start
    lia.doors.verifyDatabaseSchema()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Verify schema with custom handling
    hook.Add("InitPostEntity", "VerifyDoorSchema", function()
    timer.Simple(5, function()
    lia.doors.verifyDatabaseSchema()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom schema verification with migration
    function customSchemaCheck()
        lia.doors.verifyDatabaseSchema()
        -- Check for missing columns and add them
        local missingColumns = {
        door_group = "text"
        }
        for column, type in pairs(missingColumns) do
            lia.db.query("ALTER TABLE lia_doors ADD COLUMN " .. column .. " " .. type)
        end
    end

```

---

### lia.doors.verifyDatabaseSchema

#### 📋 Purpose
Verifies the database schema for the doors table matches expected structure

#### ⏰ When Called
During server initialization or when checking database integrity

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Verify schema on server start
    lia.doors.verifyDatabaseSchema()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Verify schema with custom handling
    hook.Add("InitPostEntity", "VerifyDoorSchema", function()
    timer.Simple(5, function()
    lia.doors.verifyDatabaseSchema()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom schema verification with migration
    function customSchemaCheck()
        lia.doors.verifyDatabaseSchema()
        -- Check for missing columns and add them
        local missingColumns = {
        door_group = "text"
        }
        for column, type in pairs(missingColumns) do
            lia.db.query("ALTER TABLE lia_doors ADD COLUMN " .. column .. " " .. type)
        end
    end

```

---

### lia.advancedDoorCleanup

#### 📋 Purpose
Cleans up corrupted door data in the database by removing invalid faction/class data

#### ⏰ When Called
During server initialization or when data corruption is detected

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Run cleanup on server start
    lia.doors.cleanupCorruptedData()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Schedule cleanup with delay
    hook.Add("InitPostEntity", "CleanupDoorData", function()
    timer.Simple(2, function()
    lia.doors.cleanupCorruptedData()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom cleanup with logging and validation
    function advancedDoorCleanup()
        lia.information("Starting door data cleanup...")
        lia.doors.cleanupCorruptedData()
        -- Additional validation
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
        lia.db.query("SELECT COUNT(*) as count FROM lia_doors WHERE " .. condition):next(function(res)
        local count = res.results[1].count
        lia.information("Door cleanup completed. Total doors in database: " .. count)
    end)
    end

```

---

### lia.doors.cleanupCorruptedData

#### 📋 Purpose
Cleans up corrupted door data in the database by removing invalid faction/class data

#### ⏰ When Called
During server initialization or when data corruption is detected

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Run cleanup on server start
    lia.doors.cleanupCorruptedData()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Schedule cleanup with delay
    hook.Add("InitPostEntity", "CleanupDoorData", function()
    timer.Simple(2, function()
    lia.doors.cleanupCorruptedData()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom cleanup with logging and validation
    function advancedDoorCleanup()
        lia.information("Starting door data cleanup...")
        lia.doors.cleanupCorruptedData()
        -- Additional validation
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
        lia.db.query("SELECT COUNT(*) as count FROM lia_doors WHERE " .. condition):next(function(res)
        local count = res.results[1].count
        lia.information("Door cleanup completed. Total doors in database: " .. count)
    end)
    end

```

---

### lia.MODULE:PlayerUse

#### 📋 Purpose
Cleans up corrupted door data in the database by removing invalid faction/class data

#### ⏰ When Called
During server initialization or when data corruption is detected

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Run cleanup on server start
    lia.doors.cleanupCorruptedData()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Schedule cleanup with delay
    hook.Add("InitPostEntity", "CleanupDoorData", function()
    timer.Simple(2, function()
    lia.doors.cleanupCorruptedData()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom cleanup with logging and validation
    function advancedDoorCleanup()
        lia.information("Starting door data cleanup...")
        lia.doors.cleanupCorruptedData()
        -- Additional validation
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
        lia.db.query("SELECT COUNT(*) as count FROM lia_doors WHERE " .. condition):next(function(res)
        local count = res.results[1].count
        lia.information("Door cleanup completed. Total doors in database: " .. count)
    end)
    end

```

---

### lia.MODULE:CanPlayerUseDoor

#### 📋 Purpose
Cleans up corrupted door data in the database by removing invalid faction/class data

#### ⏰ When Called
During server initialization or when data corruption is detected

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Run cleanup on server start
    lia.doors.cleanupCorruptedData()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Schedule cleanup with delay
    hook.Add("InitPostEntity", "CleanupDoorData", function()
    timer.Simple(2, function()
    lia.doors.cleanupCorruptedData()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom cleanup with logging and validation
    function advancedDoorCleanup()
        lia.information("Starting door data cleanup...")
        lia.doors.cleanupCorruptedData()
        -- Additional validation
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
        lia.db.query("SELECT COUNT(*) as count FROM lia_doors WHERE " .. condition):next(function(res)
        local count = res.results[1].count
        lia.information("Door cleanup completed. Total doors in database: " .. count)
    end)
    end

```

---

### lia.MODULE:CanPlayerAccessDoor

#### 📋 Purpose
Cleans up corrupted door data in the database by removing invalid faction/class data

#### ⏰ When Called
During server initialization or when data corruption is detected

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Run cleanup on server start
    lia.doors.cleanupCorruptedData()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Schedule cleanup with delay
    hook.Add("InitPostEntity", "CleanupDoorData", function()
    timer.Simple(2, function()
    lia.doors.cleanupCorruptedData()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom cleanup with logging and validation
    function advancedDoorCleanup()
        lia.information("Starting door data cleanup...")
        lia.doors.cleanupCorruptedData()
        -- Additional validation
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
        lia.db.query("SELECT COUNT(*) as count FROM lia_doors WHERE " .. condition):next(function(res)
        local count = res.results[1].count
        lia.information("Door cleanup completed. Total doors in database: " .. count)
    end)
    end

```

---

### lia.MODULE:ShowTeam

#### 📋 Purpose
Cleans up corrupted door data in the database by removing invalid faction/class data

#### ⏰ When Called
During server initialization or when data corruption is detected

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Run cleanup on server start
    lia.doors.cleanupCorruptedData()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Schedule cleanup with delay
    hook.Add("InitPostEntity", "CleanupDoorData", function()
    timer.Simple(2, function()
    lia.doors.cleanupCorruptedData()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom cleanup with logging and validation
    function advancedDoorCleanup()
        lia.information("Starting door data cleanup...")
        lia.doors.cleanupCorruptedData()
        -- Additional validation
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
        lia.db.query("SELECT COUNT(*) as count FROM lia_doors WHERE " .. condition):next(function(res)
        local count = res.results[1].count
        lia.information("Door cleanup completed. Total doors in database: " .. count)
    end)
    end

```

---

### lia.MODULE:KeyLock

#### 📋 Purpose
Cleans up corrupted door data in the database by removing invalid faction/class data

#### ⏰ When Called
During server initialization or when data corruption is detected

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Run cleanup on server start
    lia.doors.cleanupCorruptedData()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Schedule cleanup with delay
    hook.Add("InitPostEntity", "CleanupDoorData", function()
    timer.Simple(2, function()
    lia.doors.cleanupCorruptedData()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom cleanup with logging and validation
    function advancedDoorCleanup()
        lia.information("Starting door data cleanup...")
        lia.doors.cleanupCorruptedData()
        -- Additional validation
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
        lia.db.query("SELECT COUNT(*) as count FROM lia_doors WHERE " .. condition):next(function(res)
        local count = res.results[1].count
        lia.information("Door cleanup completed. Total doors in database: " .. count)
    end)
    end

```

---

### lia.MODULE:KeyUnlock

#### 📋 Purpose
Cleans up corrupted door data in the database by removing invalid faction/class data

#### ⏰ When Called
During server initialization or when data corruption is detected

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Run cleanup on server start
    lia.doors.cleanupCorruptedData()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Schedule cleanup with delay
    hook.Add("InitPostEntity", "CleanupDoorData", function()
    timer.Simple(2, function()
    lia.doors.cleanupCorruptedData()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom cleanup with logging and validation
    function advancedDoorCleanup()
        lia.information("Starting door data cleanup...")
        lia.doors.cleanupCorruptedData()
        -- Additional validation
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
        lia.db.query("SELECT COUNT(*) as count FROM lia_doors WHERE " .. condition):next(function(res)
        local count = res.results[1].count
        lia.information("Door cleanup completed. Total doors in database: " .. count)
    end)
    end

```

---

### lia.MODULE:ToggleLock

#### 📋 Purpose
Cleans up corrupted door data in the database by removing invalid faction/class data

#### ⏰ When Called
During server initialization or when data corruption is detected

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Run cleanup on server start
    lia.doors.cleanupCorruptedData()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Schedule cleanup with delay
    hook.Add("InitPostEntity", "CleanupDoorData", function()
    timer.Simple(2, function()
    lia.doors.cleanupCorruptedData()
    end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Custom cleanup with logging and validation
    function advancedDoorCleanup()
        lia.information("Starting door data cleanup...")
        lia.doors.cleanupCorruptedData()
        -- Additional validation
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local map = game.GetMap()
        local condition = "gamemode = " .. lia.db.convertDataType(gamemode) .. " AND map = " .. lia.db.convertDataType(map)
        lia.db.query("SELECT COUNT(*) as count FROM lia_doors WHERE " .. condition):next(function(res)
        local count = res.results[1].count
        lia.information("Door cleanup completed. Total doors in database: " .. count)
    end)
    end

```

---

