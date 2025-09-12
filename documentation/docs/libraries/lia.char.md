# Character Library

This page documents the functions for working with character data and management.

---

## Overview

The character library (`lia.char`) provides a comprehensive system for managing character data, loading, saving, and manipulating character information in the Lilia framework, serving as the core character management system that handles all aspects of player character lifecycle and data persistence. This library handles sophisticated character management with support for multiple character slots per player, complex character data structures, and dynamic character loading that enables rich character customization and persistent character progression. The system features advanced character creation with support for character validation, default data initialization, and seamless integration with the framework's class and faction systems that ensure consistent character setup and proper roleplay integration. It includes comprehensive character data management with support for persistent storage, real-time synchronization, and robust data validation that maintains character integrity across server restarts and client disconnections. The library provides robust character operations with support for character switching, character deletion, character restoration, and comprehensive cleanup procedures that ensure optimal server performance and data consistency. Additional features include integration with the framework's permission system for character access control, performance optimization for large character databases, and comprehensive character validation that ensures balanced and fair character progression, making it essential for creating engaging character systems that support complex roleplay scenarios and provide meaningful character development opportunities for players.

---

### getCharacter

**Purpose**

Retrieves a character by its ID, with optional callback support.

**Parameters**

* `charID` (*number*): The ID of the character to retrieve.
* `client` (*Player*): Optional client parameter (used internally).
* `callback` (*function*): Optional callback function to execute when character is loaded.

**Returns**

* `character` (*table*): The character object if found, nil otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Get a character by ID
local char = lia.char.getCharacter(123)
if char then
    print("Character name:", char:getName())
end

-- Get character with callback
lia.char.getCharacter(123, nil, function(char)
    if char then
        print("Character loaded:", char:getName())
    else
        print("Character not found!")
    end
end)

-- Use in a command
lia.command.add("getchar", {
    arguments = {
        {name = "id", type = "number"}
    },
    onRun = function(client, arguments)
        local char = lia.char.getCharacter(arguments[1])
        if char then
            client:notify("Character: " .. char:getName())
        else
            client:notify("Character not found!")
        end
    end
})
```

---

### isLoaded

**Purpose**

Checks if a character is currently loaded in memory.

**Parameters**

* `charID` (*number*): The ID of the character to check.

**Returns**

* `isLoaded` (*boolean*): True if the character is loaded, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if character is loaded
if lia.char.isLoaded(123) then
    print("Character 123 is loaded")
else
    print("Character 123 is not loaded")
end

-- Use in a function
local function isCharacterActive(charID)
    return lia.char.isLoaded(charID)
end

-- Check multiple characters
for i = 1, 10 do
    if lia.char.isLoaded(i) then
        print("Character " .. i .. " is active")
    end
end
```

---

### getAll

**Purpose**

Retrieves all currently loaded characters.

**Parameters**

*None*

**Returns**

* `characters` (*table*): Table of all loaded characters.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all loaded characters
local characters = lia.char.getAll()
print("Total loaded characters:", table.Count(characters))

-- Iterate through all characters
for client, char in pairs(lia.char.getAll()) do
    if IsValid(client) then
        print(client:Name() .. " has character: " .. char:getName())
    end
end

-- Count characters by faction
local factionCount = {}
for client, char in pairs(lia.char.getAll()) do
    local faction = char:getFaction()
    factionCount[faction] = (factionCount[faction] or 0) + 1
end
```

---

### addCharacter

**Purpose**

Adds a character to the loaded characters table.

**Parameters**

* `id` (*number*): The ID of the character.
* `character` (*table*): The character object to add.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a character to the loaded list
lia.char.addCharacter(123, characterObject)

-- This is typically used internally by the character system
-- when loading characters from the database
```

---

### removeCharacter

**Purpose**

Removes a character from the loaded characters table.

**Parameters**

* `id` (*number*): The ID of the character to remove.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Remove a character from memory
lia.char.removeCharacter(123)

-- This is typically used when a character is deleted
-- or when cleaning up unused characters
```

---

### new

**Purpose**

Creates a new character object with the specified data.

**Parameters**

* `data` (*table*): The character data table.
* `id` (*number*): Optional character ID.
* `client` (*Player*): Optional client player.
* `steamID` (*string*): Optional SteamID.

**Returns**

* `character` (*table*): The new character object.

**Realm**

Shared.

**Example Usage**

```lua
-- Create a new character
local charData = {
    name = "John Doe",
    desc = "A test character",
    model = "models/player/group01/male_01.mdl",
    faction = "Citizen"
}
local character = lia.char.new(charData, 123, client, "STEAM_0:1:123456")

-- Create character with minimal data
local character = lia.char.new({
    name = "Test Character"
}, 124)

-- Create character for a specific client
local character = lia.char.new(charData, 125, client)
```

---

### hookVar

**Purpose**

Adds a hook to a character variable for custom behavior.

**Parameters**

* `varName` (*string*): The name of the variable to hook.
* `hookName` (*string*): The name of the hook.
* `func` (*function*): The function to execute when the hook is triggered.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Hook into name changes
lia.char.hookVar("name", "OnNameChange", function(char, oldName, newName)
    print("Character name changed from " .. oldName .. " to " .. newName)
end)

-- Hook into faction changes
lia.char.hookVar("faction", "OnFactionChange", function(char, oldFaction, newFaction)
    print("Character faction changed from " .. oldFaction .. " to " .. newFaction)
end)

-- Hook into model changes
lia.char.hookVar("model", "OnModelChange", function(char, oldModel, newModel)
    print("Character model changed from " .. oldModel .. " to " .. newModel)
end)
```

---

### registerVar

**Purpose**

Registers a new character variable with the system.

**Parameters**

* `key` (*string*): The variable key/name.
* `data` (*table*): The variable configuration data.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register a simple string variable
lia.char.registerVar("nickname", {
    field = "nickname",
    fieldType = "string",
    default = "",
    index = 5
})

-- Register a number variable
lia.char.registerVar("level", {
    field = "level",
    fieldType = "integer",
    default = 1,
    index = 6
})

-- Register a complex variable with validation
lia.char.registerVar("customData", {
    field = "customdata",
    fieldType = "text",
    default = {},
    index = 7,
    onValidate = function(value, data, client)
        if istable(value) then
            return true
        end
        return false, "Custom data must be a table"
    end
})
```

---

### getCharData

**Purpose**

Retrieves character data from the database by character ID.

**Parameters**

* `charID` (*number*): The character ID to retrieve data for.
* `key` (*string*): Optional specific key to retrieve.

**Returns**

* `data` (*table*): The character data or specific key value.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all character data
lia.char.getCharData(123):next(function(data)
    if data then
        print("Character data loaded")
        for k, v in pairs(data) do
            print(k .. ":", v)
        end
    end
end)

-- Get specific character data
lia.char.getCharData(123, "customData"):next(function(value)
    if value then
        print("Custom data:", value)
    end
end)

-- Use in a command
lia.command.add("chardata", {
    arguments = {
        {name = "id", type = "number"}
    },
    onRun = function(client, arguments)
        lia.char.getCharData(arguments[1]):next(function(data)
            if data then
                client:notify("Character data retrieved")
            else
                client:notify("Character not found")
            end
        end)
    end
})
```

---

### getCharDataRaw

**Purpose**

Retrieves raw character data from the database without processing.

**Parameters**

* `charID` (*number*): The character ID to retrieve data for.
* `key` (*string*): Optional specific key to retrieve.

**Returns**

* `data` (*table*): The raw character data or specific key value.

**Realm**

Shared.

**Example Usage**

```lua
-- Get raw character data
lia.char.getCharDataRaw(123):next(function(data)
    if data then
        print("Raw character data loaded")
    end
end)

-- Get specific raw data
lia.char.getCharDataRaw(123, "inventory"):next(function(value)
    if value then
        print("Raw inventory data:", value)
    end
end)
```

---

### getOwnerByID

**Purpose**

Finds the client who owns a character by character ID.

**Parameters**

* `ID` (*number*): The character ID to search for.

**Returns**

* `client` (*Player*): The client who owns the character, nil if not found.

**Realm**

Shared.

**Example Usage**

```lua
-- Find character owner
local owner = lia.char.getOwnerByID(123)
if IsValid(owner) then
    print("Character 123 is owned by:", owner:Name())
else
    print("Character 123 is not currently online")
end

-- Use in a function
local function getCharacterOwner(charID)
    return lia.char.getOwnerByID(charID)
end

-- Check if character is online
if lia.char.getOwnerByID(123) then
    print("Character 123 is online")
end
```

---

### getBySteamID

**Purpose**

Finds a character by the owner's SteamID.

**Parameters**

* `steamID` (*string*): The SteamID to search for.

**Returns**

* `character` (*table*): The character object if found, nil otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Find character by SteamID
local char = lia.char.getBySteamID("STEAM_0:1:123456")
if char then
    print("Found character:", char:getName())
else
    print("No character found for this SteamID")
end

-- Use in a command
lia.command.add("findchar", {
    arguments = {
        {name = "steamid", type = "string"}
    },
    onRun = function(client, arguments)
        local char = lia.char.getBySteamID(arguments[1])
        if char then
            client:notify("Found character: " .. char:getName())
        else
            client:notify("No character found")
        end
    end
})
```

---

### GetTeamColor

**Purpose**

Gets the team color for a client based on their character's class.

**Parameters**

* `client` (*Player*): The client to get team color for.

**Returns**

* `color` (*Color*): The team color for the client.

**Realm**

Shared.

**Example Usage**

```lua
-- Get team color for a client
local color = lia.char.GetTeamColor(client)
print("Team color:", color.r, color.g, color.b)

-- Use in drawing functions
hook.Add("HUDPaint", "DrawPlayerInfo", function()
    for _, ply in player.Iterator() do
        local color = lia.char.GetTeamColor(ply)
        local pos = ply:GetPos():ToScreen()
        draw.SimpleText(ply:Name(), "liaMediumFont", pos.x, pos.y, color)
    end
end)

-- Use in scoreboard
local function getPlayerColor(ply)
    return lia.char.GetTeamColor(ply)
end
```

---

### create

**Purpose**

Creates a new character in the database.

**Parameters**

* `data` (*table*): The character data table.
* `callback` (*function*): Optional callback function to execute after creation.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Create a new character
local charData = {
    name = "John Doe",
    desc = "A new character",
    model = "models/player/group01/male_01.mdl",
    faction = "Citizen",
    steamID = "STEAM_0:1:123456"
}

lia.char.create(charData, function(charID)
    print("Character created with ID:", charID)
end)

-- Create character with callback
lia.char.create(charData, function(charID)
    if charID then
        print("Character created successfully!")
        -- Do something with the new character
    else
        print("Failed to create character")
    end
end)
```

---

### restore

**Purpose**

Restores a character from the database for a client.

**Parameters**

* `client` (*Player*): The client to restore the character for.
* `callback` (*function*): Optional callback function to execute after restoration.
* `id` (*number*): Optional specific character ID to restore.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Restore all characters for a client
lia.char.restore(client, function(characters)
    print("Restored " .. #characters .. " characters")
end)

-- Restore specific character
lia.char.restore(client, function(characters)
    print("Restored character:", characters[1])
end, 123)

-- Use in player spawn
hook.Add("PlayerSpawn", "RestoreCharacters", function(ply)
    lia.char.restore(ply, function(characters)
        if #characters > 0 then
            print("Restored " .. #characters .. " characters for " .. ply:Name())
        end
    end)
end)
```

---

### cleanUpForPlayer

**Purpose**

Cleans up all characters for a specific player.

**Parameters**

* `client` (*Player*): The client to clean up characters for.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Clean up characters when player disconnects
hook.Add("PlayerDisconnected", "CleanupCharacters", function(ply)
    lia.char.cleanUpForPlayer(ply)
end)

-- Clean up characters manually
lia.char.cleanUpForPlayer(client)

-- Use in admin command
lia.command.add("cleanupchar", {
    arguments = {
        {name = "target", type = "player"}
    },
    onRun = function(client, arguments)
        lia.char.cleanUpForPlayer(arguments[1])
        client:notify("Cleaned up characters for " .. arguments[1]:Name())
    end
})
```

---

### delete

**Purpose**

Deletes a character from the database and memory.

**Parameters**

* `id` (*number*): The character ID to delete.
* `client` (*Player*): Optional client parameter.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Delete a character
lia.char.delete(123)

-- Delete character for specific client
lia.char.delete(123, client)

-- Use in a command
lia.command.add("deletechar", {
    arguments = {
        {name = "id", type = "number"}
    },
    onRun = function(client, arguments)
        lia.char.delete(arguments[1], client)
        client:notify("Character deleted")
    end
})
```

---

### getCharBanned

**Purpose**

Checks if a character is banned.

**Parameters**

* `charID` (*number*): The character ID to check.

**Returns**

* `banned` (*number*): The ban status (0 = not banned, >0 = banned).

**Realm**

Server.

**Example Usage**

```lua
-- Check if character is banned
lia.char.getCharBanned(123):next(function(banned)
    if banned > 0 then
        print("Character is banned")
    else
        print("Character is not banned")
    end
end)

-- Use in character validation
local function isCharacterBanned(charID)
    lia.char.getCharBanned(charID):next(function(banned)
        if banned > 0 then
            print("Cannot use banned character")
        end
    end)
end
```

---

### setCharDatabase

**Purpose**

Sets character data in the database.

**Parameters**

* `charID` (*number*): The character ID to update.
* `field` (*string*): The field name to update.
* `value` (*any*): The value to set.

**Returns**

* `success` (*boolean*): True if successful, false otherwise.

**Realm**

Server.

**Example Usage**

```lua
-- Set character name
lia.char.setCharDatabase(123, "name", "New Name")

-- Set character description
lia.char.setCharDatabase(123, "desc", "Updated description")

-- Set character money
lia.char.setCharDatabase(123, "money", 1000)

-- Set custom data
lia.char.setCharDatabase(123, "customData", {level = 5, xp = 1000})
```

---

### unloadCharacter

**Purpose**

Unloads a character from memory and saves it to the database.

**Parameters**

* `charID` (*number*): The character ID to unload.

**Returns**

* `success` (*boolean*): True if successful, false otherwise.

**Realm**

Server.

**Example Usage**

```lua
-- Unload a character
local success = lia.char.unloadCharacter(123)
if success then
    print("Character unloaded successfully")
end

-- Unload character when player disconnects
hook.Add("PlayerDisconnected", "UnloadCharacter", function(ply)
    local char = ply:getChar()
    if char then
        lia.char.unloadCharacter(char:getID())
    end
end)
```

---

### unloadUnusedCharacters

**Purpose**

Unloads unused characters for a client, keeping only the active one.

**Parameters**

* `client` (*Player*): The client to unload unused characters for.
* `activeCharID` (*number*): The ID of the character to keep active.

**Returns**

* `unloadedCount` (*number*): The number of characters unloaded.

**Realm**

Server.

**Example Usage**

```lua
-- Unload unused characters
local count = lia.char.unloadUnusedCharacters(client, 123)
print("Unloaded " .. count .. " unused characters")

-- Use when switching characters
local function switchCharacter(client, newCharID)
    local oldChar = client:getChar()
    if oldChar then
        local unloaded = lia.char.unloadUnusedCharacters(client, newCharID)
        print("Unloaded " .. unloaded .. " characters")
    end
end
```

---

### loadSingleCharacter

**Purpose**

Loads a single character by ID for a client.

**Parameters**

* `charID` (*number*): The character ID to load.
* `client` (*Player*): The client to load the character for.
* `callback` (*function*): Optional callback function to execute after loading.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load a single character
lia.char.loadSingleCharacter(123, client, function(char)
    if char then
        print("Character loaded:", char:getName())
    else
        print("Failed to load character")
    end
end)

-- Load character without callback
lia.char.loadSingleCharacter(123, client)
```