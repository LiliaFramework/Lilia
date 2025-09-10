# Data Library

This page documents the functions for working with data serialization and persistence.

---

## Overview

The data library (`lia.data`) provides a comprehensive system for data serialization, deserialization, and persistence in the Lilia framework. It includes table encoding/decoding, data storage, and persistence management functionality.

---

### lia.data.encodetable

**Purpose**

Encodes a table into a string format for storage or transmission.

**Parameters**

* `data` (*table*): The table to encode.

**Returns**

* `encodedString` (*string*): The encoded table string.

**Realm**

Shared.

**Example Usage**

```lua
-- Encode a table
local function encodeTable(data)
    return lia.data.encodetable(data)
end

-- Use in a function
local function savePlayerData(client)
    local data = {
        name = client:Name(),
        steamid = client:SteamID(),
        level = 10,
        items = {"weapon_ak47", "item_health"}
    }
    local encoded = lia.data.encodetable(data)
    print("Encoded data:", encoded)
end

-- Use in a command
lia.command.add("encodedata", {
    onRun = function(client, arguments)
        local data = {
            player = client:Name(),
            time = os.time(),
            position = client:GetPos()
        }
        local encoded = lia.data.encodetable(data)
        client:notify("Encoded data: " .. encoded)
    end
})

-- Use in a function
local function createSaveData(character)
    local data = {
        charID = character:getID(),
        name = character:getName(),
        money = character:getMoney(),
        inventory = character:getInv():getItems()
    }
    return lia.data.encodetable(data)
end
```

---

### lia.data.decode

**Purpose**

Decodes a string back into a table.

**Parameters**

* `encodedString` (*string*): The encoded string to decode.

**Returns**

* `decodedTable` (*table*): The decoded table.

**Realm**

Shared.

**Example Usage**

```lua
-- Decode a string
local function decodeString(encoded)
    return lia.data.decode(encoded)
end

-- Use in a function
local function loadPlayerData(encodedData)
    local data = lia.data.decode(encodedData)
    if data then
        print("Loaded player data:", data.name, data.level)
        return data
    else
        print("Failed to decode data")
        return nil
    end
end

-- Use in a command
lia.command.add("decodedata", {
    arguments = {
        {name = "data", type = "string"}
    },
    onRun = function(client, arguments)
        local data = lia.data.decode(arguments[1])
        if data then
            client:notify("Decoded data: " .. util.TableToJSON(data))
        else
            client:notify("Failed to decode data")
        end
    end
})

-- Use in a function
local function restoreCharacterData(encodedData)
    local data = lia.data.decode(encodedData)
    if data then
        local character = lia.char.getCharacter(data.charID)
        if character then
            character:setMoney(data.money)
            -- Restore other data
        end
    end
end
```

---

### lia.data.serialize

**Purpose**

Serializes data into a format suitable for storage.

**Parameters**

* `data` (*any*): The data to serialize.

**Returns**

* `serializedData` (*string*): The serialized data string.

**Realm**

Shared.

**Example Usage**

```lua
-- Serialize data
local function serializeData(data)
    return lia.data.serialize(data)
end

-- Use in a function
local function saveGameState()
    local state = {
        players = {},
        entities = {},
        time = os.time()
    }
    
    for _, client in ipairs(player.GetAll()) do
        table.insert(state.players, {
            name = client:Name(),
            pos = client:GetPos(),
            char = client:getChar()
        })
    end
    
    local serialized = lia.data.serialize(state)
    file.Write("gamestate.txt", serialized)
end

-- Use in a command
lia.command.add("serialize", {
    onRun = function(client, arguments)
        local data = {
            player = client:Name(),
            position = client:GetPos(),
            health = client:Health()
        }
        local serialized = lia.data.serialize(data)
        client:notify("Serialized data: " .. serialized)
    end
})

-- Use in a function
local function createBackup()
    local backup = {
        characters = {},
        items = {},
        config = lia.config.getOptions()
    }
    
    for _, character in ipairs(lia.char.getAll()) do
        table.insert(backup.characters, character)
    end
    
    return lia.data.serialize(backup)
end
```

---

### lia.data.deserialize

**Purpose**

Deserializes data from a stored format.

**Parameters**

* `serializedData` (*string*): The serialized data string.

**Returns**

* `deserializedData` (*any*): The deserialized data.

**Realm**

Shared.

**Example Usage**

```lua
-- Deserialize data
local function deserializeData(serialized)
    return lia.data.deserialize(serialized)
end

-- Use in a function
local function loadGameState()
    local serialized = file.Read("gamestate.txt", "DATA")
    if serialized then
        local state = lia.data.deserialize(serialized)
        if state then
            print("Loaded game state from", state.time)
            return state
        end
    end
    return nil
end

-- Use in a command
lia.command.add("deserialize", {
    arguments = {
        {name = "data", type = "string"}
    },
    onRun = function(client, arguments)
        local data = lia.data.deserialize(arguments[1])
        if data then
            client:notify("Deserialized data: " .. util.TableToJSON(data))
        else
            client:notify("Failed to deserialize data")
        end
    end
})

-- Use in a function
local function restoreBackup(backupData)
    local backup = lia.data.deserialize(backupData)
    if backup then
        print("Restoring backup with", #backup.characters, "characters")
        -- Restore data
    end
end
```

---

### lia.data.decodeVector

**Purpose**

Decodes a vector from a string format.

**Parameters**

* `vectorString` (*string*): The vector string to decode.

**Returns**

* `vector` (*Vector*): The decoded vector.

**Realm**

Shared.

**Example Usage**

```lua
-- Decode a vector
local function decodeVector(vectorString)
    return lia.data.decodeVector(vectorString)
end

-- Use in a function
local function loadPlayerPosition(encodedPos)
    local pos = lia.data.decodeVector(encodedPos)
    if pos then
        print("Loaded position:", pos)
        return pos
    else
        print("Failed to decode position")
        return Vector(0, 0, 0)
    end
end

-- Use in a command
lia.command.add("decodevector", {
    arguments = {
        {name = "vector", type = "string"}
    },
    onRun = function(client, arguments)
        local vector = lia.data.decodeVector(arguments[1])
        if vector then
            client:notify("Decoded vector: " .. tostring(vector))
        else
            client:notify("Failed to decode vector")
        end
    end
})

-- Use in a function
local function restoreEntityPosition(entity, encodedPos)
    local pos = lia.data.decodeVector(encodedPos)
    if pos then
        entity:SetPos(pos)
    end
end
```

---

### lia.data.decodeAngle

**Purpose**

Decodes an angle from a string format.

**Parameters**

* `angleString` (*string*): The angle string to decode.

**Returns**

* `angle` (*Angle*): The decoded angle.

**Realm**

Shared.

**Example Usage**

```lua
-- Decode an angle
local function decodeAngle(angleString)
    return lia.data.decodeAngle(angleString)
end

-- Use in a function
local function loadPlayerRotation(encodedRot)
    local rot = lia.data.decodeAngle(encodedRot)
    if rot then
        print("Loaded rotation:", rot)
        return rot
    else
        print("Failed to decode rotation")
        return Angle(0, 0, 0)
    end
end

-- Use in a command
lia.command.add("decodeangle", {
    arguments = {
        {name = "angle", type = "string"}
    },
    onRun = function(client, arguments)
        local angle = lia.data.decodeAngle(arguments[1])
        if angle then
            client:notify("Decoded angle: " .. tostring(angle))
        else
            client:notify("Failed to decode angle")
        end
    end
})

-- Use in a function
local function restoreEntityRotation(entity, encodedRot)
    local rot = lia.data.decodeAngle(encodedRot)
    if rot then
        entity:SetAngles(rot)
    end
end
```

---

### lia.data.set

**Purpose**

Sets a data value for a key.

**Parameters**

* `key` (*string*): The data key.
* `value` (*any*): The value to set.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set a data value
local function setData(key, value)
    lia.data.set(key, value)
end

-- Use in a function
local function savePlayerStats(client)
    local stats = {
        kills = 10,
        deaths = 5,
        level = 15
    }
    lia.data.set("player_" .. client:SteamID(), stats)
end

-- Use in a command
lia.command.add("setdata", {
    arguments = {
        {name = "key", type = "string"},
        {name = "value", type = "string"}
    },
    onRun = function(client, arguments)
        lia.data.set(arguments[1], arguments[2])
        client:notify("Data set: " .. arguments[1] .. " = " .. arguments[2])
    end
})

-- Use in a function
local function createDataEntry(key, data)
    lia.data.set(key, data)
    print("Created data entry:", key)
end
```

---

### lia.data.delete

**Purpose**

Deletes a data value by key.

**Parameters**

* `key` (*string*): The data key to delete.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Delete a data value
local function deleteData(key)
    lia.data.delete(key)
end

-- Use in a function
local function clearPlayerData(client)
    lia.data.delete("player_" .. client:SteamID())
    print("Cleared data for", client:Name())
end

-- Use in a command
lia.command.add("deletedata", {
    arguments = {
        {name = "key", type = "string"}
    },
    onRun = function(client, arguments)
        lia.data.delete(arguments[1])
        client:notify("Deleted data: " .. arguments[1])
    end
})

-- Use in a function
local function cleanupOldData()
    local keys = {"old_data_1", "old_data_2", "old_data_3"}
    for _, key in ipairs(keys) do
        lia.data.delete(key)
    end
end
```

---

### lia.data.loadTables

**Purpose**

Loads data tables from the database.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load data tables
local function loadData()
    lia.data.loadTables()
    print("Data tables loaded")
end

-- Use in a hook
hook.Add("Initialize", "LoadData", function()
    lia.data.loadTables()
end)

-- Use in a function
local function reloadData()
    lia.data.loadTables()
    print("Data reloaded")
end
```

---

### lia.data.loadPersistence

**Purpose**

Loads persistence data from the database.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load persistence data
local function loadPersistence()
    lia.data.loadPersistence()
    print("Persistence data loaded")
end

-- Use in a hook
hook.Add("Initialize", "LoadPersistence", function()
    lia.data.loadPersistence()
end)

-- Use in a function
local function reloadPersistence()
    lia.data.loadPersistence()
    print("Persistence reloaded")
end
```

---

### lia.data.savePersistence

**Purpose**

Saves persistence data to the database.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Save persistence data
local function savePersistence()
    lia.data.savePersistence()
    print("Persistence data saved")
end

-- Use in a timer
timer.Create("SavePersistence", 300, 0, function()
    lia.data.savePersistence()
end)

-- Use in a function
local function forceSave()
    lia.data.savePersistence()
    print("Persistence force saved")
end
```

---

### lia.data.loadPersistenceData

**Purpose**

Loads persistence data for a specific key.

**Parameters**

* `key` (*string*): The persistence key to load.

**Returns**

* `data` (*any*): The loaded persistence data.

**Realm**

Server.

**Example Usage**

```lua
-- Load persistence data for a key
local function loadPersistenceData(key)
    return lia.data.loadPersistenceData(key)
end

-- Use in a function
local function loadPlayerPersistence(client)
    local data = lia.data.loadPersistenceData("player_" .. client:SteamID())
    if data then
        print("Loaded persistence for", client:Name())
        return data
    end
    return nil
end

-- Use in a command
lia.command.add("loadpersistence", {
    arguments = {
        {name = "key", type = "string"}
    },
    onRun = function(client, arguments)
        local data = lia.data.loadPersistenceData(arguments[1])
        if data then
            client:notify("Loaded persistence: " .. util.TableToJSON(data))
        else
            client:notify("No persistence data found")
        end
    end
})

-- Use in a function
local function restorePlayerData(client)
    local data = lia.data.loadPersistenceData("player_" .. client:SteamID())
    if data then
        -- Restore player data
        client:SetPos(data.position)
        client:SetHealth(data.health)
    end
end
```

---

### lia.data.get

**Purpose**

Gets a data value by key.

**Parameters**

* `key` (*string*): The data key.

**Returns**

* `value` (*any*): The data value.

**Realm**

Shared.

**Example Usage**

```lua
-- Get a data value
local function getData(key)
    return lia.data.get(key)
end

-- Use in a function
local function getPlayerStats(client)
    local stats = lia.data.get("player_" .. client:SteamID())
    if stats then
        print("Player stats:", stats.kills, stats.deaths)
        return stats
    end
    return nil
end

-- Use in a command
lia.command.add("getdata", {
    arguments = {
        {name = "key", type = "string"}
    },
    onRun = function(client, arguments)
        local data = lia.data.get(arguments[1])
        if data then
            client:notify("Data: " .. util.TableToJSON(data))
        else
            client:notify("No data found")
        end
    end
})

-- Use in a function
local function checkDataExists(key)
    local data = lia.data.get(key)
    return data ~= nil
end
```

---

### lia.data.getPersistence

**Purpose**

Gets persistence data for a specific key.

**Parameters**

* `key` (*string*): The persistence key.

**Returns**

* `data` (*any*): The persistence data.

**Realm**

Shared.

**Example Usage**

```lua
-- Get persistence data
local function getPersistenceData(key)
    return lia.data.getPersistence(key)
end

-- Use in a function
local function getPlayerPersistence(client)
    local data = lia.data.getPersistence("player_" .. client:SteamID())
    if data then
        print("Player persistence:", data)
        return data
    end
    return nil
end

-- Use in a command
lia.command.add("getpersistence", {
    arguments = {
        {name = "key", type = "string"}
    },
    onRun = function(client, arguments)
        local data = lia.data.getPersistence(arguments[1])
        if data then
            client:notify("Persistence: " .. util.TableToJSON(data))
        else
            client:notify("No persistence data found")
        end
    end
})

-- Use in a function
local function checkPersistenceExists(key)
    local data = lia.data.getPersistence(key)
    return data ~= nil
end
```