# Data Library

Data persistence, serialization, and management system for the Lilia framework.

---

Overview

The data library provides comprehensive functionality for data persistence, serialization, and management within the Lilia framework. It handles encoding and decoding of complex data types including vectors, angles, colors, and nested tables for database storage. The library manages both general data storage with gamemode and map-specific scoping, as well as entity persistence for maintaining spawned entities across server restarts. It includes automatic serialization/deserialization, database integration, and caching mechanisms to ensure efficient data access and storage operations.

---

### lia.data.encodetable

#### 📋 Purpose
Converts complex data types (vectors, angles, colors, tables) into database-storable formats

#### ⏰ When Called
Automatically called during data serialization before database storage

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **any** | The value to encode (vector, angle, color table, or regular table) |

#### ↩️ Returns
* table or any - Encoded representation suitable for JSON serialization

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Encode a vector
    local encoded = lia.data.encodetable(Vector(100, 200, 300))
    -- Returns: {100, 200, 300}

```

#### 📊 Medium Complexity
```lua
    -- Medium: Encode a color with alpha
    local color = Color(255, 128, 64, 200)
    local encoded = lia.data.encodetable(color)
    -- Returns: {255, 128, 64, 200}

```

#### ⚙️ High Complexity
```lua
    -- High: Encode nested table with mixed data types
    local complexData = {
        position = Vector(0, 0, 0),
        rotation = Angle(0, 90, 0),
        color   = Color(255, 0, 0),
        settings = {enabled = true, count = 5}
    }
    local encoded = lia.data.encodetable(complexData)
    -- Returns: {position = {0, 0, 0}, rotation = {0, 90, 0}, color = {255, 0, 0, 255}, settings = {enabled = true, count = 5}}

```

---

### lia.data.decode

#### 📋 Purpose
Converts encoded data back to original complex data types (vectors, angles, colors)

#### ⏰ When Called
Automatically called during data deserialization after database retrieval

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **any** | The encoded value to decode (table, string, or raw data) |

#### ↩️ Returns
* any - Decoded value with proper data types restored

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Decode a vector from encoded format
    local decoded = lia.data.decode({100, 200, 300})
    -- Returns: Vector(100, 200, 300)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Decode an angle from encoded format
    local encodedAngle = {0, 90, 0}
    local decoded = lia.data.decode(encodedAngle)
    -- Returns: Angle(0, 90, 0)

```

#### ⚙️ High Complexity
```lua
    -- High: Decode complex nested data structure
    local encodedData = {
        position = {100, 200, 300},
        rotation = {0, 90, 0},
        color    = {255, 0, 0, 255},
        settings = {enabled = true, count = 5}
    }
    local decoded = lia.data.decode(encodedData)
    -- Returns: {position = Vector(100, 200, 300), rotation = Angle(0, 90, 0), color = Color(255, 0, 0, 255), settings = {enabled = true, count = 5}}

```

---

### lia.data.serialize

#### 📋 Purpose
Converts any data structure into a JSON string suitable for database storage

#### ⏰ When Called
Called before storing data in the database to ensure proper serialization

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **any** | The data to serialize (tables, vectors, angles, colors, etc.) |

#### ↩️ Returns
* string - JSON string representation of the encoded data

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Serialize a basic table
    local serialized = lia.data.serialize({name = "test", value = 42})
    -- Returns: '{"name":"test","value":42}'

```

#### 📊 Medium Complexity
```lua
    -- Medium: Serialize a vector
    local serialized = lia.data.serialize(Vector(100, 200, 300))
    -- Returns: '{"value":[100,200,300]}'

```

#### ⚙️ High Complexity
```lua
    -- High: Serialize complex nested data with mixed types
    local complexData = {
        position = Vector(0, 0, 0),
        rotation = Angle(0, 90, 0),
        color    = Color(255, 0, 0),
        settings = {enabled = true, count = 5}
    }
    local serialized = lia.data.serialize(complexData)
    -- Returns: JSON string with all data properly encoded

```

---

### lia.data.deserialize

#### 📋 Purpose
Converts serialized data (JSON strings or tables) back to original data structures

#### ⏰ When Called
Called after retrieving data from database to restore original data types

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `raw` | **string|table** | Serialized data from database (JSON string or table) |

#### ↩️ Returns
* any - Deserialized data with proper types restored, or nil if invalid

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Deserialize a JSON string
    local deserialized = lia.data.deserialize('{"name":"test","value":42}')
    -- Returns: {name = "test", value = 42}

```

#### 📊 Medium Complexity
```lua
    -- Medium: Deserialize encoded vector data
    local jsonData = '{"value":[100,200,300]}'
    local deserialized = lia.data.deserialize(jsonData)
    -- Returns: Vector(100, 200, 300)

```

#### ⚙️ High Complexity
```lua
    -- High: Deserialize complex data with fallback handling
    local complexJson = '{"position":[0,0,0],"rotation":[0,90,0],"color":[255,0,0,255],"settings":{"enabled":true,"count":5}}'
    local deserialized = lia.data.deserialize(complexJson)
    -- Returns: {position = Vector(0, 0, 0), rotation = Angle(0, 90, 0), color = Color(255, 0, 0, 255), settings = {enabled = true, count = 5}}

```

---

### lia.data.decodeVector

#### 📋 Purpose
Specifically decodes vector data from various formats (JSON, strings, tables)

#### ⏰ When Called
Called when specifically needing to decode vector data from database or serialized format

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `raw` | **any** | Raw data that should contain vector information |

#### ↩️ Returns
* Vector or any - Decoded Vector object, or original data if not vector format

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Decode vector from array format
    local vector = lia.data.decodeVector({100, 200, 300})
    -- Returns: Vector(100, 200, 300)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Decode vector from JSON string
    local jsonString = '[100,200,300]'
    local vector = lia.data.decodeVector(jsonString)
    -- Returns: Vector(100, 200, 300)

```

#### ⚙️ High Complexity
```lua
    -- High: Decode vector with multiple format fallbacks
    local vectorData = "Vector(100, 200, 300)"
    local vector = lia.data.decodeVector(vectorData)
    -- Returns: Vector(100, 200, 300) - handles string parsing

```

---

### lia.data.decodeAngle

#### 📋 Purpose
Specifically decodes angle data from various formats (JSON, strings, tables)

#### ⏰ When Called
Called when specifically needing to decode angle data from database or serialized format

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `raw` | **any** | Raw data that should contain angle information |

#### ↩️ Returns
* Angle or any - Decoded Angle object, or original data if not angle format

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Decode angle from array format
    local angle = lia.data.decodeAngle({0, 90, 0})
    -- Returns: Angle(0, 90, 0)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Decode angle from JSON string
    local jsonString = '[0,90,0]'
    local angle = lia.data.decodeAngle(jsonString)
    -- Returns: Angle(0, 90, 0)

```

#### ⚙️ High Complexity
```lua
    -- High: Decode angle with multiple format fallbacks
    local angleData = "Angle(0, 90, 0)"
    local angle = lia.data.decodeAngle(angleData)
    -- Returns: Angle(0, 90, 0) - handles string parsing

```

---

### lia.data.set

#### 📋 Purpose
Stores data in the database with gamemode and map-specific scoping

#### ⏰ When Called
Called when storing persistent data that should survive server restarts

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Unique identifier for the data |
| `value` | **any** | Data to store |
| `global` | **boolean, optional** | Store globally across all gamemodes/maps |
| `ignoreMap` | **boolean, optional** | Store for all maps in current gamemode |

#### ↩️ Returns
* string - Database path where data was stored

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Store basic data for current gamemode and map
    lia.data.set("playerCount", 25)
    -- Stores data scoped to current gamemode and map

```

#### 📊 Medium Complexity
```lua
    -- Medium: Store data globally across all gamemodes and maps
    lia.data.set("serverVersion", "1.0.0", true)
    -- Stores data globally, accessible from any gamemode/map

```

#### ⚙️ High Complexity
```lua
    -- High: Store complex data with custom scoping
    local playerData = {
        position  = Vector(100, 200, 300),
        inventory = {weapon = "pistol", ammo = 50},
        settings  = {volume = 0.8, graphics = "high"}
    }
    lia.data.set("player_" .. player:SteamID64(), playerData, false, true)
    -- Stores player data for current gamemode but all maps

```

---

### lia.data.delete

#### 📋 Purpose
Removes data from the database with gamemode and map-specific scoping

#### ⏰ When Called
Called when removing persistent data that should no longer be stored

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Unique identifier for the data to delete |
| `global` | **boolean, optional** | Delete from global scope |
| `ignoreMap` | **boolean, optional** | Delete from all maps in current gamemode |

#### ↩️ Returns
* boolean - Always returns true

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Delete data for current gamemode and map
    lia.data.delete("playerCount")
    -- Removes data scoped to current gamemode and map

```

#### 📊 Medium Complexity
```lua
    -- Medium: Delete data globally across all gamemodes and maps
    lia.data.delete("serverVersion", true)
    -- Removes data from global scope

```

#### ⚙️ High Complexity
```lua
    -- High: Delete player data with custom scoping
    local playerID = "player_" .. player:SteamID64()
    lia.data.delete(playerID, false, true)
    -- Removes player data for current gamemode but all maps

```

---

### lia.data.loadTables

#### 📋 Purpose
Loads all stored data from database into memory with hierarchical scoping

#### ⏰ When Called
Called during server startup to restore all persistent data

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load all data tables
    lia.data.loadTables()
    -- Loads global, gamemode, and map-specific data

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load data with custom initialization
    lia.data.loadTables()
    -- After loading, access specific data
    local playerCount = lia.data.get("playerCount", 0)

```

#### ⚙️ High Complexity
```lua
    -- High: Load data with validation and error handling
    lia.data.loadTables()
    -- Data is loaded hierarchically: global -> gamemode -> map-specific
    -- Later data overrides earlier data (map overrides gamemode overrides global)

```

---

### lia.data.loadPersistence

#### 📋 Purpose
Ensures persistence table has required columns for entity storage

#### ⏰ When Called
Called during server startup to prepare database schema for entity persistence

#### ↩️ Returns
* Promise - Database operation promise

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load persistence schema
    lia.data.loadPersistence()
    -- Ensures all required columns exist in persistence table

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load persistence with error handling
    lia.data.loadPersistence():next(function()
        print("Persistence schema loaded successfully")
    end):catch(function(err)
        print("Failed to load persistence schema: " .. err)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Load persistence as part of initialization sequence
    lia.data.loadPersistence():next(function()
        return lia.data.loadPersistenceData(function(entities)
            -- Process loaded entities
            for _, ent in ipairs(entities) do
                -- Spawn entities or process data
            end
        end)
    end)

```

---

### lia.data.savePersistence

#### 📋 Purpose
Saves entity data to database for persistence across server restarts

#### ⏰ When Called
Called during server shutdown or periodic saves to persist entity states

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entities` | **table** | Array of entity data tables to save |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Save basic entity data
    local entities = {
        {class = "prop_physics", pos = Vector(0, 0, 0), angles = Angle(0, 0, 0), model = "models/props_c17/FurnitureTable001a.mdl"}
    }
    lia.data.savePersistence(entities)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Save entities with custom properties
    local entities = {
        {
            class   = "lia_vendor",
            pos     = Vector(100, 200, 0),
            angles  = Angle(0, 90, 0),
            model   = "models/player.mdl",
            name    = "Weapon Vendor",
            items   = {"weapon_pistol", "weapon_shotgun"}
        }
    }
    lia.data.savePersistence(entities)

```

#### ⚙️ High Complexity
```lua
    -- High: Save complex entities with dynamic properties
    local entities = {}
    for _, ent in ipairs(ents.GetAll()) do
        if ent:GetClass() == "lia_item" then
            table.insert(entities, {
                class   = ent:GetClass(),
                pos     = ent:GetPos(),
                angles  = ent:GetAngles(),
                model   = ent:GetModel(),
                itemID  = ent:GetItemID(),
                amount  = ent:GetAmount(),
                data    = ent:GetData()
            })
        end
    end
    lia.data.savePersistence(entities)

```

---

### lia.data.loadPersistenceData

#### 📋 Purpose
Loads persisted entity data from database and optionally executes callback

#### ⏰ When Called
Called during server startup to restore persisted entities

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `callback` | **function, optional** | Function to call with loaded entity data |

#### ↩️ Returns
* Promise - Database operation promise

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load persistence data
    lia.data.loadPersistenceData()
    -- Loads entity data into cache

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load persistence data with callback
    lia.data.loadPersistenceData(function(entities)
        print("Loaded " .. #entities .. " entities")
        for _, ent in ipairs(entities) do
            print("Entity: " .. ent.class .. " at " .. tostring(ent.pos))
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Load persistence data with entity spawning
    lia.data.loadPersistenceData(function(entities)
        for _, entData in ipairs(entities) do
            local ent = ents.Create(entData.class)
            if IsValid(ent) then
                ent:SetPos(entData.pos)
                ent:SetAngles(entData.angles)
                ent:SetModel(entData.model)
                ent:Spawn()
                -- Restore custom properties
                for k, v in pairs(entData) do
                    if not defaultCols[k] then
                        ent:SetNWVar(k, v)
                    end
                end
            end
        end
    end)

```

---

### lia.data.get

#### 📋 Purpose
Retrieves stored data from memory cache with automatic deserialization

#### ⏰ When Called
Called when accessing stored persistent data

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Unique identifier for the data |
| `default` | **any, optional** | Default value if key not found |

#### ↩️ Returns
* any - Stored data or default value if not found

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get basic data
    local playerCount = lia.data.get("playerCount", 0)
    -- Returns stored player count or 0 if not found

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get data with default fallback
    local serverSettings = lia.data.get("serverSettings", {
        maxPlayers  = 32,
        mapRotation = {"gm_flatgrass", "gm_construct"}
    })
    -- Returns stored settings or default configuration

```

#### ⚙️ High Complexity
```lua
    -- High: Get complex data with validation
    local playerData = lia.data.get("player_" .. player:SteamID64(), {})
    if playerData.position then
        player:SetPos(playerData.position)
    end
    if playerData.inventory then
        player:GetInventory():LoadFromData(playerData.inventory)
    end
    -- Retrieves and processes complex player data

```

---

### lia.data.getPersistence

#### 📋 Purpose
Retrieves cached entity persistence data from memory

#### ⏰ When Called
Called when accessing loaded entity persistence data

#### ↩️ Returns
* table - Array of entity data tables or empty table if none loaded

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get persistence data
    local entities = lia.data.getPersistence()
    print("Loaded " .. #entities .. " entities")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get persistence data with filtering
    local entities = lia.data.getPersistence()
    local vendors = {}
    for _, ent in ipairs(entities) do
        if ent.class == "lia_vendor" then
            table.insert(vendors, ent)
        end
    end
    print("Found " .. #vendors .. " vendors")

```

#### ⚙️ High Complexity
```lua
    -- High: Get persistence data with processing
    local entities = lia.data.getPersistence()
    local entityStats = {}
    for _, ent in ipairs(entities) do
        if not entityStats[ent.class] then
            entityStats[ent.class] = 0
        end
        entityStats[ent.class] = entityStats[ent.class] + 1
    end
    for class, count in pairs(entityStats) do
        print(class .. ": " .. count .. " entities")
    end

```

---

