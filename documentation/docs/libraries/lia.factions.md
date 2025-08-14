# Factions Library

This page documents the functions for working with faction management and team systems.

---

## Overview

The factions library provides a system for managing player factions, teams, and group affiliations within the Lilia framework. It handles faction registration, team setup, model management, and provides utilities for working with faction data. The library supports faction-specific colors, models, and metadata, and integrates with Garry's Mod's team system.

### lia.faction.register

**Purpose**

Registers a new faction with the given unique ID and data table. Handles localization, color, models, and sets up the team. Also precaches all faction models and stores the faction in the global indices and teams tables.

**Parameters**

* `uniqueID` (*string*) - The unique identifier for the faction.
* `data` (*table*) - The data table containing faction properties (name, desc, color, models, etc).

**Returns**

* `index` (*number*) - The index assigned to the faction.
* `faction` (*table*) - The faction table that was registered.

**Realm**

Shared.

**Example Usage**

```lua
-- Register a new faction called "citizen"
local index, faction = lia.faction.register("citizen", {
    name = "Citizen",
    desc = "The common people of the city.",
    color = Color(100, 150, 200),
    isDefault = true,
    models = {"models/player/group01/male_01.mdl", "models/player/group01/female_01.mdl"}
})
```

### lia.faction.cacheModels

**Purpose**

Precaches all models for a faction to ensure they are loaded and ready for use. This function is automatically called during faction registration to optimize model loading performance and prevent model-related errors.

**Parameters**

* `models` (*table*) - A table containing model data. Each entry can be either a string (model path) or a table where the first element is the model path.

**Returns**

* *nil*

**Realm**

Shared.

**Example Usage**

```lua
-- Cache models for a faction
local factionModels = {
    "models/player/group01/male_01.mdl",
    "models/player/group01/female_01.mdl",
    {"models/player/group01/male_02.mdl", bodygroups = {...}},
    {"models/player/group01/female_02.mdl", bodygroups = {...}}
}
lia.faction.cacheModels(factionModels)

-- Or use it directly with faction data
lia.faction.cacheModels(faction.models)
```

**Notes**

* This function automatically handles both string and table model formats
* For table format models, only the first element (model path) is precached
* Called automatically during `lia.faction.register()` and `lia.faction.loadFromDir()`
* Helps prevent model loading delays and errors during gameplay

### lia.faction.loadFromDir

**Purpose**

Loads all faction definition files from the specified directory, registering them into `lia.faction.teams` and `lia.faction.indices`. Each faction file should define a `FACTION` table. This function ensures the faction's name, description, and color are set and localized, and precaches all models.

**Parameters**

* `directory` (*string*) - The directory path to search for faction files (should be relative to the gamemode).

**Returns**

* *nil*

**Realm**

Shared.

**Example Usage**

```lua
-- Load all factions from the "factions" directory
lia.faction.loadFromDir("gamemode/schema/factions")
```

### lia.faction.get

**Purpose**

Retrieves a faction table by its index or unique ID.

**Parameters**

* `identifier` (*number|string*) - The faction index or unique ID.

**Returns**

* `faction` (*table|nil*) - The faction table if found, or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the faction table for the "staff" faction
local staffFaction = lia.faction.get("staff")
-- Get the faction table by index
local factionByIndex = lia.faction.get(1)
```

### lia.faction.getIndex

**Purpose**

Retrieves the index of a faction by its unique ID.

**Parameters**

* `uniqueID` (*string*) - The unique ID of the faction.

**Returns**

* `index` (*number|nil*) - The index of the faction, or nil if not found.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the index of the "staff" faction
local staffIndex = lia.faction.getIndex("staff")
```

### lia.faction.getClasses

**Purpose**

Retrieves all classes associated with a given faction.

**Parameters**

* `faction` (*number|string*) - The faction index or unique ID.

**Returns**

* `classes` (*table*) - A table of class tables belonging to the faction.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all classes for the "staff" faction
local staffClasses = lia.faction.getClasses("staff")
```

### lia.faction.getPlayers

**Purpose**

Retrieves all players currently in the specified faction.

**Parameters**

* `faction` (*number|string*) - The faction index or unique ID.

**Returns**

* `players` (*table*) - A table of player objects in the faction.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all players in the "staff" faction
local staffPlayers = lia.faction.getPlayers("staff")
```

### lia.faction.getPlayerCount

**Purpose**

Counts the number of players currently in the specified faction.

**Parameters**

* `faction` (*number|string*) - The faction index or unique ID.

**Returns**

* `count` (*number*) - The number of players in the faction.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the number of players in the "staff" faction
local staffCount = lia.faction.getPlayerCount("staff")
```

### lia.faction.isFactionCategory

**Purpose**

Checks if a given faction is part of a specified category (list of factions).

**Parameters**

* `faction` (*number|string*) - The faction index or unique ID.
* `categoryFactions` (*table*) - Table of faction indices or unique IDs representing the category.

**Returns**

* `isCategory` (*boolean*) - True if the faction is in the category, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if "staff" is in the admin category
local isAdmin = lia.faction.isFactionCategory("staff", {"staff", "admin", "superadmin"})
```

### lia.faction.jobGenerate

**Purpose**

Generates and registers a simple faction/job with the specified properties.

**Parameters**

* `index` (*number*) - The index to assign to the faction.
* `name` (*string*) - The name of the faction.
* `color` (*Color*) - The color of the faction.
* `default` (*boolean*) - Whether the faction is default.
* `models` (*table|nil*) - Table of model paths for the faction (optional).

**Returns**

* `FACTION` (*table*) - The created faction table.

**Realm**

Shared.

**Example Usage**

```lua
-- Generate a new job/faction called "Guard"
local guardFaction = lia.faction.jobGenerate(2, "Guard", Color(0, 100, 255), false, {"models/player/police.mdl"})
```

### lia.faction.formatModelData

**Purpose**

Processes and formats the model data for all factions, ensuring bodygroup data is properly set up for each model. This is useful for advanced model customization and bodygroup support.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Format all faction model data after loading factions
lia.faction.formatModelData()
```

### lia.faction.getCategories

**Purpose**

Retrieves all model categories for a given faction/team name.

**Parameters**

* `teamName` (*string*) - The unique ID of the faction/team.

**Returns**

* `categories` (*table*) - A table of category names (strings).

**Realm**

Shared.

**Example Usage**

```lua
-- Get all model categories for the "staff" faction
local categories = lia.faction.getCategories("staff")
```

### lia.faction.getModelsFromCategory

**Purpose**

Retrieves all models from a specific category for a given faction/team.

**Parameters**

* `teamName` (*string*) - The unique ID of the faction/team.
* `category` (*string*) - The category name.

**Returns**

* `models` (*table*) - A table of models in the specified category.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all "male" models for the "citizen" faction
local maleModels = lia.faction.getModelsFromCategory("citizen", "male")
```

### lia.faction.getDefaultClass

**Purpose**

Retrieves the default class for a given faction.

**Parameters**

* `id` (*number|string*) - The faction index or unique ID.

**Returns**

* `defaultClass` (*table|nil*) - The default class table, or nil if not found.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the default class for the "staff" faction
local defaultClass = lia.faction.getDefaultClass("staff")
```

### lia.faction.hasWhitelist

**Purpose**

Checks if the local player has a whitelist for the specified faction.

**Parameters**

* `faction` (*number|string*) - The faction index or unique ID.

**Returns**

* `hasWhitelist` (*boolean*) - True if the player has a whitelist or the faction is default, false otherwise.

**Realm**

Client.

**Example Usage**

```lua
-- Check if the local player has access to the "staff" faction
if lia.faction.hasWhitelist("staff") then
    print("You are whitelisted for staff!")
end
```
