# Character Library

This page covers utilities for manipulating character data.

---

## Overview

The character library handles creation and persistence of player characters. It manages character variables, interacts with the database, and offers helpers for retrieving characters by ID or SteamID. Because these functions directly modify stored data, use them carefully or you may corrupt character information.

---

### lia.char.getCharacter

**Purpose**

Retrieves a character object by ID. If the character is not loaded, it is loaded and the callback is invoked.

**Parameters**

* `charID` (*number*): Character identifier.
* `client` (*Player*): Owning player (server only, optional).
* `callback` (*function*): Function executed once the character is available (optional).

**Realm**

`Shared`

**Returns**

* *table | nil*: The loaded character or `nil` if not currently loaded.

**Example Usage**

```lua
lia.char.getCharacter(1, client, function(char)
    print("Loaded", char:getName())
end)
```

---

### lia.char.isLoaded

**Purpose**

Checks whether a character with the given ID is currently loaded.

**Parameters**

* `charID` (*number*): Character identifier.

**Realm**

`Shared`

**Returns**

* *boolean*: `true` if loaded, otherwise `false`.

**Example Usage**

```lua
if lia.char.isLoaded(1) then
    print("Character 1 is loaded")
end
```

---

### lia.char.addCharacter

**Purpose**

Registers a character object as loaded and resolves pending callbacks for that ID.

**Parameters**

* `id` (*number*): Character ID.
* `character` (*table*): Character object.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.char.addCharacter(char:getID(), char)
```

---

### lia.char.removeCharacter

**Purpose**

Removes a character from the loaded cache.

**Parameters**

* `id` (*number*): Character ID.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.char.removeCharacter(1)
```

---

### lia.char.new

**Purpose**

Creates a new character instance with default variables and metatable.

**Parameters**

* `data` (*table*): Table of character variables.

* `id` (*number*): Character ID.

* `client` (*Player*): Player entity.

* `steamID` (*string*): SteamID64 string if the client is not valid.

**Realm**

`Shared`

**Returns**

* *table*: New character object.

**Example Usage**

```lua
-- Create a simple character for a player
local char = lia.char.new({ name = "John" }, 1, client)
```

---

### lia.char.hookVar

**Purpose**

Registers a hook function that runs whenever a specific character variable changes.

**Parameters**

* `varName` (*string*): Variable name to hook.

* `hookName` (*string*): Unique hook identifier.

* `func` (*function*): Function called on variable change.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Print the new name whenever a character's name changes
lia.char.hookVar("name", "PrintName", function(char, old, new)
    print(char, old, new)
end)
```

---

### lia.char.registerVar

**Purpose**

Registers a character variable with metadata and auto-generates accessor methods.

**Parameters**

* `key` (*string*): Variable key.

* `data` (*table*): Variable metadata (default value, validation, networking, etc.).

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Register an "age" field that only accepts numbers
lia.char.registerVar("age", {
    field = "age",
    default = 20,
    onValidate = isnumber
})
```

---

### lia.char.getCharData

**Purpose**

Retrieves a character’s JSON data from the database as a Lua table (or a single key).

**Parameters**

* `charID` (*number | string*): Character ID.

* `key` (*string*): Specific data key to return (optional).

**Realm**

`Shared`

**Returns**

* *table | any | nil*: Full data table or a single value. Returns `nil` if the ID is invalid.

**Example Usage**

```lua
local age = lia.char.getCharData(1, "age")
```

---

### lia.char.getCharDataRaw

**Purpose**

Returns character data from `lia_chardata` as a table or a single value.

**Parameters**

* `charID` (*number | string*): Character ID.

* `key` (*string*): Specific data key to return (optional).

**Realm**

`Shared`

**Returns**

* *table | any | false | nil*: Full data table or single value. Returns `false` if the key does not exist, `nil` if the ID is invalid.

**Example Usage**

```lua
local row = lia.char.getCharDataRaw(1)
```

---

### lia.char.getOwnerByID

**Purpose**

Finds the player entity that owns the character with the given ID.

**Parameters**

* `ID` (*number | string*): Character ID.

**Realm**

`Shared`

**Returns**

* *Player | nil*: Player entity or `nil` if not found.

**Example Usage**

```lua
local ply = lia.char.getOwnerByID(1)
```

---

### lia.char.getBySteamID

**Purpose**

Retrieves a character object by SteamID or SteamID64 from currently connected players.

**Parameters**

* `steamID` (*string*): SteamID or SteamID64.

**Realm**

`Shared`

**Returns**

* *table | nil*: Character object or `nil`.

**Example Usage**

```lua
local char = lia.char.getBySteamID("STEAM_0:0:11101")
```

---

### lia.char.getAll

**Purpose**

Returns a table mapping all players to their loaded characters.

**Parameters**

* *None*

**Realm**

`Shared`

**Returns**

* *table*: Map of `Player → Character`.

**Example Usage**

```lua
for ply, char in pairs(lia.char.getAll()) do
    print(ply, char:getName())
end
```

---

### lia.char.GetTeamColor

**Purpose**

Determines the team colour for a client based on their character class or default team.

**Parameters**

* `client` (*Player*): Player entity.

**Realm**

`Shared`

**Returns**

* *Color*: Team or class colour.

**Example Usage**

```lua
local color = lia.char.GetTeamColor(client)
```

---

### lia.char.create

**Purpose**

Inserts a new character into the database, creates a default inventory, and fires hooks.

**Parameters**

* `data` (*table*): Character creation data. Requires `name`, `model`, and `steamID`. `money` defaults to `lia.config.get("DefaultMoney")`, and `faction` defaults to `L("unknown")` when omitted.

* `callback` (*function*): Optional function receiving the new character ID.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.char.create({
    name = "John",
    steamID = client:SteamID64(),
    faction = "Citizen"
}, function(id)
    print("Created", id)
end)
```

---

### lia.char.restore

**Purpose**

Loads characters for a client from the database, optionally filtering by ID, and fires hooks.

**Parameters**

* `client` (*Player*): Player entity.

* `callback` (*function*): Callback receiving a list of character IDs.

* `id` (*number*): Specific character ID to restore (optional).

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.char.restore(client, function(ids)
    PrintTable(ids)
end)
```

---

### lia.char.cleanUpForPlayer

**Purpose**

Cleans up loaded characters and inventories for a player on disconnect.

**Parameters**

* `client` (*Player*): Player entity.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.char.cleanUpForPlayer(client)
```

---

### lia.char.delete

**Purpose**

Deletes a character by ID, cleans up, and notifies players via hooks. If no `client` is provided, any player using the character is removed from it.

**Parameters**

* `id` (*number*): Character ID to delete.

* `client` (*Player*): Player entity to remove from the character (optional).

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.char.delete(1, client)
```

---

### lia.char.setCharData

**Purpose**

Updates a character’s JSON data field in the database and the loaded object. Triggers `OnCharVarChanged` if loaded.

**Parameters**

* `charID` (*number | string*): Character ID.

* `key` (*string*): Data key.

* `val` (*any*): New value.

**Realm**

`Server`

**Returns**

* *boolean | nil*: `true` on success. Returns `nil` if the ID or key is invalid.

**Example Usage**

```lua
lia.char.setCharData(1, "age", 25)
```

---

### lia.char.setCharName

**Purpose**

Changes a character’s name in the database and the loaded object, firing appropriate hooks.

**Parameters**

* `charID` (*number | string*): Character ID.

* `name` (*string*): New character name.

**Realm**

`Server`

**Returns**

* *boolean | nil*: `true` on success, `false` if the database update fails, `nil` if inputs are invalid.

**Example Usage**

```lua
lia.char.setCharName(1, "NewName")
```

---

### lia.char.setCharModel

**Purpose**

Updates the character’s model and bodygroups in the database and in-game, firing hooks.

**Parameters**

* `charID` (*number | string*): Character ID.

* `model` (*string*): Model path.

* `bg` (*table*): Bodygroup list.

**Realm**

`Server`

**Returns**

* *boolean | nil*: `true` on success, `false` if the database update fails, `nil` if inputs are invalid.

**Example Usage**

```lua
lia.char.setCharModel(1, "models/player.mdl", {})
```

---

### lia.char.getCharBanned

**Purpose**

Fetches a character's banned status from the database.

**Parameters**

* `charID` (*number | string*): Character ID.

**Realm**

`Server`

**Returns**

* *number | nil*: Ban value. Returns `0` if not banned or `nil` if the ID is invalid.

**Example Usage**

```lua
local banned = lia.char.getCharBanned(1)
``` 

---

### lia.char.setCharBanned

**Purpose**

Sets or clears a character's banned status.

**Parameters**

* `charID` (*number | string*): Character ID.
* `value` (*number | string*): Ban value (`0` to unban).

**Realm**

`Server`

**Returns**

* *boolean | nil*: `true` on success, `false` if the database update fails, `nil` if the ID is invalid.

**Example Usage**

```lua
lia.char.setCharBanned(1, 1)
```

---

### lia.char.unloadCharacter

**Purpose**

Saves and removes a character from memory, cleaning up associated data.

**Parameters**

* `charID` (*number*): Character ID.

**Realm**

`Server`

**Returns**

* *boolean*: `true` if unloaded, `false` if the character was not loaded.

**Example Usage**

```lua
lia.char.unloadCharacter(1)
```

---

### lia.char.unloadUnusedCharacters

**Purpose**

Unloads all characters for a player except the active one.

**Parameters**

* `client` (*Player*): Player entity.
* `activeCharID` (*number*): Character ID to keep loaded.

**Realm**

`Server`

**Returns**

* *number*: Count of characters unloaded.

**Example Usage**

```lua
local count = lia.char.unloadUnusedCharacters(client, activeID)
```

---

### lia.char.loadSingleCharacter

**Purpose**

Loads a single character by ID for a client if it is not already loaded.

**Parameters**

* `charID` (*number*): Character ID.
* `client` (*Player*): Owning player.
* `callback` (*function*): Function executed once loading completes.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.char.loadSingleCharacter(1, client, function(char)
    if char then
        print("Loaded", char:getName())
    end
end)
```

---

