# Character Library

Comprehensive character creation, management, and persistence system for the Lilia framework.

---

Overview

The character library provides comprehensive functionality for managing player characters in the Lilia framework. It handles character creation, loading, saving, and management across both server and client sides. The library operates character data persistence, networking synchronization, and provides hooks for character variable changes. It includes functions for character validation, database operations, inventory management, and character lifecycle management. The library ensures proper character data integrity and provides a robust system for character-based gameplay mechanics including factions, attributes, money, and custom character variables.

---

### lia.char.getCharacter

#### 📋 Purpose
Retrieve a character by ID from cache or request a load if missing.

#### ⏰ When Called
Anytime code needs a character object by ID (selection, networking, admin tools).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | Character database ID to fetch. |
| `client` | **Player|nil** | Owning player; only used server-side when loading. |
| `callback` | **function|nil** | Invoked with the character once available (server cached immediately, otherwise after load/network). |

#### ↩️ Returns
* table|nil
The character object if already cached; otherwise nil while loading.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.char.getCharacter(targetID, ply, function(char)
        if char then
            char:sync(ply)
        end
    end)

```

---

### lia.char.getAll

#### 📋 Purpose
Return a table of all players currently holding loaded characters.

#### ⏰ When Called
For admin panels, diagnostics, or mass operations over active characters.

#### ↩️ Returns
* table
Keyed by Player with values of their active character objects.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    for ply, char in pairs(lia.char.getAll()) do
        print(ply:Name(), char:getName())
    end

```

---

### lia.char.isLoaded

#### 📋 Purpose
Check if a character ID currently exists in the local cache.

#### ⏰ When Called
Before loading or accessing a character to avoid duplicate work.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | Character database ID to test. |

#### ↩️ Returns
* boolean
True if the character is cached, otherwise false.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if not lia.char.isLoaded(id) then
        lia.char.getCharacter(id)
    end

```

---

### lia.char.addCharacter

#### 📋 Purpose
Insert a character into the cache and resolve any pending requests.

#### ⏰ When Called
After successfully loading or creating a character object.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | Character database ID. |
| `character` | **table** | Character object to store. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.char.addCharacter(char:getID(), char)

```

---

### lia.char.removeCharacter

#### 📋 Purpose
Remove a character from the local cache.

#### ⏰ When Called
After a character is deleted, unloaded, or no longer needed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | Character database ID to remove. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.char.removeCharacter(charID)

```

---

### lia.char.new

#### 📋 Purpose
Construct a character object and populate its variables with provided data or defaults.

#### ⏰ When Called
During character creation or when rebuilding a character from stored data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | **table** | Raw character data keyed by variable name. |
| `id` | **number|nil** | Database ID; defaults to 0 when nil. |
| `client` | **Player|nil** | Owning player entity, if available. |
| `steamID` | **string|nil** | SteamID string used when no player entity is provided. |

#### ↩️ Returns
* table
New character object.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local char = lia.char.new(row, row.id, ply)

```

---

### lia.char.hookVar

#### 📋 Purpose
Register a hook function that runs when a specific character variable changes.

#### ⏰ When Called
When modules need to react to updates of a given character variable.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `varName` | **string** | Character variable name. |
| `hookName` | **string** | Unique identifier for the hook. |
| `func` | **function** | Callback invoked with (character, oldValue, newValue). |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.char.hookVar("money", "OnMoneyChanged", function(char, old, new)
        hook.Run("OnCharMoneyChanged", char, old, new)
    end)

```

---

### lia.char.registerVar

#### 📋 Purpose
Register a character variable and generate accessor/mutator helpers with optional networking.

#### ⏰ When Called
During schema load to declare character fields such as name, money, or custom data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Variable identifier. |
| `data` | **table** | Configuration table defining defaults, validation, networking, and callbacks. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.char.registerVar("title", {
        field = "title",
        fieldType = "string",
        default = "",
    })

```

---

### lia.char.getCharData

#### 📋 Purpose
Read character data key/value pairs stored in the chardata table.

#### ⏰ When Called
When modules need arbitrary persisted data for a character, optionally scoped to a single key.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | Character database ID to query. |
| `key` | **string|nil** | Optional specific data key to return. |

#### ↩️ Returns
* table|any|nil
Table of all key/value pairs, a single value when key is provided, or nil if not found/invalid.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local prestige = lia.char.getCharData(charID, "prestige")

```

---

### lia.char.getCharDataRaw

#### 📋 Purpose
Retrieve raw character data from chardata without touching the cache.

#### ⏰ When Called
When a direct database read is needed, bypassing any loaded character state.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | Character database ID to query. |
| `key` | **string|nil** | Optional key for a single value; omit to fetch all. |

#### ↩️ Returns
* any|table|false|nil
Decoded value for the key, a table of all key/value pairs, false if a keyed lookup is missing, or nil on invalid input.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local allData = lia.char.getCharDataRaw(charID)

```

---

### lia.char.getOwnerByID

#### 📋 Purpose
Find the player entity that owns a given character ID.

#### ⏰ When Called
When needing to target or notify the current owner of a loaded character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ID` | **number** | Character database ID. |

#### ↩️ Returns
* Player|nil
Player who currently has the character loaded, or nil if none.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local owner = lia.char.getOwnerByID(charID)

```

---

### lia.char.getBySteamID

#### 📋 Purpose
Get the active character of an online player by SteamID/SteamID64.

#### ⏰ When Called
For lookups across connected players when only a Steam identifier is known.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `steamID` | **string** | SteamID or SteamID64 string. |

#### ↩️ Returns
* table|nil
Character object if the player is online and has one loaded, else nil.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local char = lia.char.getBySteamID(targetSteamID)

```

---

### lia.char.getTeamColor

#### 📋 Purpose
Return the team/class color for a player, falling back to team color.

#### ⏰ When Called
Whenever UI or drawing code needs a consistent color for the player's current class.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose color is requested. |

#### ↩️ Returns
* table
Color table sourced from class definition or team color.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local color = lia.char.getTeamColor(ply)

```

---

### lia.char.create

#### 📋 Purpose
Create a new character row, build its object, and initialize inventories.

#### ⏰ When Called
During character creation after validation to persist and ready the new character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | **table** | Prepared character data including steamID, faction, and name. |
| `callback` | **function|nil** | Invoked with the new character ID once creation finishes. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.char.create(payload, function(charID) print("created", charID) end)

```

---

### lia.char.restore

#### 📋 Purpose
Load all characters for a player (or a specific ID) into memory and inventory.

#### ⏰ When Called
On player connect or when an admin requests to restore a specific character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose characters should be loaded. |
| `callback` | **function|nil** | Invoked with a list of loaded character IDs once complete. |
| `id` | **number|nil** | Optional single character ID to restrict the load. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.char.restore(ply, function(chars) print("loaded", #chars) end)

```

---

### lia.char.cleanUpForPlayer

#### 📋 Purpose
Unload and save all characters cached for a player.

#### ⏰ When Called
When a player disconnects or is cleaned up to free memory and inventories.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose cached characters should be unloaded. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.char.cleanUpForPlayer(ply)

```

---

### lia.char.delete

#### 📋 Purpose
Delete a character, its data, and inventories, and notify affected players.

#### ⏰ When Called
By admin or player actions that permanently remove a character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | Character database ID to delete. |
| `client` | **Player|nil** | Player requesting deletion, if any. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.char.delete(charID, ply)

```

---

### lia.char.getCharBanned

#### 📋 Purpose
Check the ban state of a character in the database.

#### ⏰ When Called
Before allowing a character to load or when displaying ban info.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | Character database ID. |

#### ↩️ Returns
* number|nil
Ban flag/value (0 if not banned), or nil on invalid input.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    if lia.char.getCharBanned(id) ~= 0 then return end

```

---

### lia.char.setCharDatabase

#### 📋 Purpose
Write a character variable to the database and update any loaded instance.

#### ⏰ When Called
Whenever persistent character fields or custom data need to be changed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | Character database ID. |
| `field` | **string** | Character var or custom data key. |
| `value` | **any** | Value to store; nil removes custom data entries. |

#### ↩️ Returns
* boolean
True on success, false on immediate failure.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.char.setCharDatabase(charID, "money", newAmount)

```

---

### lia.char.unloadCharacter

#### 📋 Purpose
Save and unload a character from memory, clearing associated data vars.

#### ⏰ When Called
When a character is no longer active or needs to be freed from cache.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | Character database ID to unload. |

#### ↩️ Returns
* boolean
True if a character was unloaded, false if none was loaded.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.char.unloadCharacter(charID)

```

---

### lia.char.unloadUnusedCharacters

#### 📋 Purpose
Unload all cached characters for a player except the currently active one.

#### ⏰ When Called
After character switches to reduce memory and inventory usage.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose cached characters should be reduced. |
| `activeCharID` | **number** | Character ID to keep loaded. |

#### ↩️ Returns
* number
Count of characters that were unloaded.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.char.unloadUnusedCharacters(ply, newCharID)

```

---

### lia.char.loadSingleCharacter

#### 📋 Purpose
Load a single character from the database, building inventories and caching it.

#### ⏰ When Called
When a specific character is selected, restored, or fetched server-side.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | Character database ID to load. |
| `client` | **Player|nil** | Owning player, used for permission checks and inventory linking. |
| `callback` | **function|nil** | Invoked with the loaded character or nil on failure. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.char.loadSingleCharacter(id, ply, function(char) if char then char:sync(ply) end end)

```

---

