# Doors Library

Door management system for the Lilia framework providing preset configuration,

---

Overview

The doors library provides comprehensive door management functionality including
preset configuration, database schema verification, and data cleanup operations.
It handles door data persistence, loading door configurations from presets,
and maintaining database integrity. The library manages door ownership, access
permissions, faction and class restrictions, and provides utilities for door
data validation and corruption cleanup. It operates primarily on the server side
and integrates with the database system to persist door configurations across
server restarts. The library also handles door locking/unlocking mechanics and
provides hooks for custom door behavior integration.

---

### lia.doors.setCachedData

#### 📋 Purpose
Store door data overrides in memory and sync to clients, omitting defaults.

#### ⏰ When Called
After editing door settings (price, access, flags) server-side.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `door` | **Entity** | Door entity. |
| `data` | **table** | Door data overrides. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.doors.setCachedData(door, {
        name = "Police HQ",
        price = 0,
        factions = {FACTION_POLICE}
    })

```

---

### lia.doors.getCachedData

#### 📋 Purpose
Retrieve cached door data merged with defaults.

#### ⏰ When Called
Before saving/loading or when building UI state for a door.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `door` | **Entity** |  |

#### ↩️ Returns
* table
Complete door data with defaults filled.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local data = lia.doors.getCachedData(door)
    print("Door price:", data.price)

```

---

### lia.doors.syncDoorData

#### 📋 Purpose
Net-sync a single door's cached data to all clients.

#### ⏰ When Called
After updating a door's data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `door` | **Entity** |  |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.doors.syncDoorData(door)

```

---

### lia.doors.syncAllDoorsToClient

#### 📋 Purpose
Bulk-sync all cached doors to a single client.

#### ⏰ When Called
On player spawn/join or after admin refresh.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** |  |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    hook.Add("PlayerInitialSpawn", "SyncDoorsOnJoin", function(ply)
        lia.doors.syncAllDoorsToClient(ply)
    end)

```

---

### lia.doors.setData

#### 📋 Purpose
Set data for a door (alias to setCachedData).

#### ⏰ When Called
Convenience wrapper used by other systems.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `door` | **Entity** |  |
| `data` | **table** |  |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.doors.setData(door, {locked = true})

```

---

### lia.doors.addPreset

#### 📋 Purpose
Register a preset of door data for a specific map.

#### ⏰ When Called
During map setup to predefine door ownership/prices.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mapName` | **string** |  |
| `presetData` | **table** |  |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.doors.addPreset("rp_downtown", {
        [1234] = {name = "Bank", price = 0, factions = {FACTION_POLICE}},
        [5678] = {locked = true, hidden = true}
    })

```

---

### lia.doors.getPreset

#### 📋 Purpose
Retrieve a door preset table for a map.

#### ⏰ When Called
During map load or admin inspection of presets.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mapName` | **string** |  |

#### ↩️ Returns
* table|nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local preset = lia.doors.getPreset(game.GetMap())
    if preset then PrintTable(preset) end

```

---

### lia.doors.verifyDatabaseSchema

#### 📋 Purpose
Validate the doors database schema against expected columns.

#### ⏰ When Called
On startup or after migrations to detect missing/mismatched columns.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    hook.Add("DatabaseConnected", "VerifyDoorSchema", lia.doors.verifyDatabaseSchema)

```

---

### lia.doors.cleanupCorruptedData

#### 📋 Purpose
Detect and repair corrupted faction/class door data in the database.

#### ⏰ When Called
Maintenance task to clean malformed data entries.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    concommand.Add("lia_fix_doors", function(admin)
        if not IsValid(admin) or not admin:IsAdmin() then return end
        lia.doors.cleanupCorruptedData()
    end)

```

---

### lia.doors.getData

#### 📋 Purpose
Access cached door data (server/client wrapper).

#### ⏰ When Called
Anywhere door data is needed without hitting DB.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `door` | **Entity** |  |

#### ↩️ Returns
* table

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local data = lia.doors.getData(ent)
    if data.locked then
        -- show locked icon
    end

```

---

### lia.doors.getCachedData

#### 📋 Purpose
Client helper to build full door data from cached entries.

#### ⏰ When Called
For HUD/tooltips when interacting with doors.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `door` | **Entity** |  |

#### ↩️ Returns
* table

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local info = lia.doors.getCachedData(door)
    draw.SimpleText(info.name or "Door", "LiliaFont.18", x, y, color_white)

```

---

### lia.doors.updateCachedData

#### 📋 Purpose
Update the client-side cache for a door ID (or clear it).

#### ⏰ When Called
After receiving sync updates from the server.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `doorID` | **number** |  |
| `data` | **table|nil** | nil clears the cache entry. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.doors.updateCachedData(doorID, net.ReadTable())

```

---

