# Doors Library

This page documents the functions for working with door ownership, access control, and door-related permissions.

---

## Overview

The doors library (`lia.doors`) provides a comprehensive door management system for the Lilia framework. It handles door ownership, access control through factions and classes, door presets, database persistence, and door interaction mechanics. The system supports both regular doors and vehicles, with configurable permissions and ownership models.

---

### lia.doors.AddPreset

**Purpose**

Adds a door preset configuration for a specific map.

**Parameters**

* `mapName` (*string*): The name of the map to add the preset for.
* `presetData` (*table*): The preset data containing door configurations.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add a door preset for a specific map
local presetData = {
    [1] = {
        name = "Main Office Door",
        price = 1000,
        locked = false,
        factions = {"police", "mayor"},
        classes = {"chief", "officer"}
    },
    [2] = {
        name = "Storage Room",
        price = 500,
        locked = true,
        factions = {"police"},
        group = "police_doors"
    }
}

lia.doors.AddPreset("rp_downtown_v4c", presetData)

-- Add a simple preset with basic door data
local simplePreset = {
    [5] = {
        name = "Apartment Door",
        price = 200,
        disabled = false
    }
}

lia.doors.AddPreset("rp_evocity_v4b", simplePreset)
```

---

### lia.doors.GetPreset

**Purpose**

Retrieves a door preset configuration for a specific map.

**Parameters**

* `mapName` (*string*): The name of the map to get the preset for.

**Returns**

* `presetData` (*table|nil*): The preset data for the map, or nil if no preset exists.

**Realm**

Server.

**Example Usage**

```lua
-- Get a door preset for the current map
local mapName = game.GetMap()
local preset = lia.doors.GetPreset(mapName)

if preset then
    print("Found preset with " .. table.Count(preset) .. " doors")
    for doorID, doorData in pairs(preset) do
        print("Door " .. doorID .. ": " .. (doorData.name or "Unnamed"))
    end
else
    print("No preset found for map: " .. mapName)
end

-- Check if a specific door has preset data
local doorPreset = lia.doors.GetPreset("rp_downtown_v4c")
if doorPreset and doorPreset[1] then
    local doorData = doorPreset[1]
    print("Door 1 preset name: " .. (doorData.name or "Unnamed"))
    print("Door 1 price: " .. (doorData.price or 0))
end
```

---

### lia.doors.VerifyDatabaseSchema

**Purpose**

Verifies that the doors database table has the correct schema and column types.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Verify database schema on server startup
hook.Add("Initialize", "VerifyDoorSchema", function()
    timer.Simple(5, function()
        lia.doors.VerifyDatabaseSchema()
    end)
end)

-- Verify schema after database connection
lia.db.connect(function()
    lia.doors.VerifyDatabaseSchema()
end)

-- Manual schema verification
lia.doors.VerifyDatabaseSchema()
```

---

### lia.doors.CleanupCorruptedData

**Purpose**

Scans the doors database for corrupted data and attempts to fix it.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Clean up corrupted data on server startup
hook.Add("InitPostEntity", "CleanupDoorData", function()
    timer.Simple(10, function()
        lia.doors.CleanupCorruptedData()
    end)
end)

-- Manual cleanup of corrupted data
lia.doors.CleanupCorruptedData()

-- Cleanup after detecting data issues
hook.Add("PlayerSay", "DetectDataCorruption", function(ply, text)
    if text == "!cleanupdoors" and ply:IsSuperAdmin() then
        lia.doors.CleanupCorruptedData()
        ply:ChatPrint("Door data cleanup initiated.")
    end
end)
```

---

### lia.doors.AddDoorGroupColumn

**Purpose**

Adds the door_group column to the doors database table if it doesn't exist.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add door group column on server startup
hook.Add("InitPostEntity", "AddDoorGroupColumn", function()
    timer.Simple(15, function()
        lia.doors.AddDoorGroupColumn()
    end)
end)

-- Add column after database migration
lia.db.connect(function()
    lia.doors.AddDoorGroupColumn()
end)

-- Manual column addition
lia.doors.AddDoorGroupColumn()
```

