# Data Library

Data persistence, serialization, and management system for the Lilia framework.

---

Overview

The data library provides comprehensive functionality for data persistence, serialization, and management within the Lilia framework. It handles encoding and decoding of complex data types including vectors, angles, colors, and nested tables for database storage. The library manages both general data storage with gamemode and map-specific scoping, as well as entity persistence for maintaining spawned entities across server restarts. It includes automatic serialization/deserialization, database integration, and caching mechanisms to ensure efficient data access and storage operations.

---

### lia.data.encodetable

#### 📋 Purpose
Encode vectors/angles/colors/tables into JSON-safe structures.

#### ⏰ When Called
Before persisting data to DB or file storage.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **any** |  |

#### ↩️ Returns
* any
Encoded representation.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local payload = lia.data.encodetable({
        pos = Vector(0, 0, 64),
        ang = Angle(0, 90, 0),
        tint = Color(255, 0, 0)
    })

```

---

### lia.data.decode

#### 📋 Purpose
Decode nested structures into native types (Vector/Angle/Color).

#### ⏰ When Called
After reading serialized data from DB/file.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **any** |  |

#### ↩️ Returns
* any
Decoded value with deep conversion.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local decoded = lia.data.decode(storedJsonTable)
    local pos = decoded.spawnPos

```

---

### lia.data.serialize

#### 📋 Purpose
Serialize a value into JSON, pre-encoding special types.

#### ⏰ When Called
Before writing data blobs into DB columns.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | **any** |  |

#### ↩️ Returns
* string
JSON string.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local json = lia.data.serialize({pos = Vector(1,2,3)})
    lia.db.updateSomewhere(json)

```

---

### lia.data.deserialize

#### 📋 Purpose
Deserialize JSON/pon or raw tables back into native types.

#### ⏰ When Called
After fetching data rows from DB.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `raw` | **string|table|any** |  |

#### ↩️ Returns
* any

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local row = lia.db.select(...):get()
    local data = lia.data.deserialize(row.data)

```

---

### lia.data.decodeVector

#### 📋 Purpose
Decode a vector from various string/table encodings.

#### ⏰ When Called
While rebuilding persistent entities or map data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `raw` | **any** |  |

#### ↩️ Returns
* Vector|any

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local pos = lia.data.decodeVector(row.pos)
    if isvector(pos) then ent:SetPos(pos) end

```

---

### lia.data.decodeAngle

#### 📋 Purpose
Decode an angle from string/table encodings.

#### ⏰ When Called
During persistence loading or data deserialization.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `raw` | **any** |  |

#### ↩️ Returns
* Angle|any

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local ang = lia.data.decodeAngle(row.angles)
    if isangle(ang) then ent:SetAngles(ang) end

```

---

### lia.data.set

#### 📋 Purpose
Persist a key/value pair scoped to gamemode/map (or global).

#### ⏰ When Called
To save configuration/state data into the DB.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** |  |
| `value` | **any** |  |
| `global` | **boolean|nil** |  |
| `ignoreMap` | **boolean|nil** |  |

#### ↩️ Returns
* string
Path prefix used for file save fallback.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.data.set("event.active", true, false, false)

```

---

### lia.data.delete

#### 📋 Purpose
Delete a stored key (and row if empty) from DB cache.

#### ⏰ When Called
To remove saved state/config entries.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** |  |
| `global` | **boolean|nil** |  |
| `ignoreMap` | **boolean|nil** |  |

#### ↩️ Returns
* boolean

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.data.delete("event.active")

```

---

### lia.data.loadTables

#### 📋 Purpose
Load stored data rows for global, gamemode, and map scopes.

#### ⏰ When Called
On database ready to hydrate lia.data.stored cache.

#### ↩️ Returns
* nil (async via promises)

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    hook.Add("DatabaseConnected", "LoadLiliaData", lia.data.loadTables)

```

---

### lia.data.loadPersistence

#### 📋 Purpose
Ensure persistence table has required columns; add if missing.

#### ⏰ When Called
Before saving/loading persistent entities.

#### ↩️ Returns
* promise

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.data.loadPersistence():next(function() print("Persistence columns ready") end)

```

---

### lia.data.savePersistence

#### 📋 Purpose
Save persistent entities to the database (with dynamic columns).

#### ⏰ When Called
On PersistenceSave hook/timer with collected entities.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entities` | **table** | Array of entity data tables. |

#### ↩️ Returns
* promise|nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    hook.Run("PersistenceSave", collectedEntities)

```

---

### lia.data.loadPersistenceData

#### 📋 Purpose
Load persistent entities from DB, decode fields, and cache them.

#### ⏰ When Called
On server start or when manually reloading persistence.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `callback` | **function|nil** | Invoked with entities table once loaded. |

#### ↩️ Returns
* promise

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.data.loadPersistenceData(function(entities)
        for _, entData in ipairs(entities) do
            -- spawn logic here
        end
    end)

```

---

### lia.data.get

#### 📋 Purpose
Fetch a stored key from cache, deserializing strings on demand.

#### ⏰ When Called
Anywhere stored data is read after loadTables.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** |  |
| `default` | **any** |  |

#### ↩️ Returns
* any

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local eventData = lia.data.get("event.settings", {})

```

---

### lia.data.getPersistence

#### 📋 Purpose
Return the cached list of persistent entities (last loaded/saved).

#### ⏰ When Called
For admin tools or debug displays.

#### ↩️ Returns
* table

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    PrintTable(lia.data.getPersistence())

```

---

### lia.data.addEquivalencyMap

#### 📋 Purpose
Register an equivalency between two map names (bidirectional).

#### ⏰ When Called
To share data/persistence across multiple map aliases.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `map1` | **string** |  |
| `map2` | **string** |  |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.data.addEquivalencyMap("rp_downtown_v1", "rp_downtown_v2")

```

---

### lia.data.getEquivalencyMap

#### 📋 Purpose
Resolve a map name to its equivalency (if registered).

#### ⏰ When Called
Before saving/loading data keyed by map name.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `map` | **string** |  |

#### ↩️ Returns
* string

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local canonical = lia.data.getEquivalencyMap(game.GetMap())

```

---

