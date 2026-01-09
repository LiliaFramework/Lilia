# Faction Library

Comprehensive faction (team) management and registration system for the Lilia framework.

---

Overview

The faction library provides comprehensive functionality for managing factions (teams) in the Lilia framework. It handles registration, loading, and management of faction data including models, colors, descriptions, and team setup. The library operates on both server and client sides, with server handling faction registration and client handling whitelist checks. It includes functionality for loading factions from directories, managing faction models with bodygroup support, and providing utilities for faction categorization and player management. The library ensures proper team setup and model precaching for all registered factions, supporting both simple string models and complex model data with bodygroup configurations.

---

### lia.faction.register

#### 📋 Purpose
Registers a new faction with the specified unique ID and data table, setting up team configuration and model caching.

#### ⏰ When Called
Called during gamemode initialization to register factions programmatically, typically in shared files or during faction loading.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique identifier for the faction. |
| `data` | **table** | A table containing faction configuration data including name, description, color, models, etc. |

#### ↩️ Returns
* number, table
Returns the faction index and the faction data table.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local index, faction = lia.faction.register("citizen", {
        name = "Citizen",
        desc = "A regular citizen",
        color = Color(100, 150, 200),
        models = {"models/player/group01/male_01.mdl"}
    })

```

---

### lia.faction.cacheModels

#### 📋 Purpose
Precaches model files to ensure they load quickly when needed, handling both string model paths and table-based model data.

#### ⏰ When Called
Called automatically during faction registration to precache all models associated with a faction.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `models` | **table** | A table of model data, where each entry can be a string path or a table with model information. |

#### ↩️ Returns
* nil
This function does not return a value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local models = {"models/player/group01/male_01.mdl", "models/player/group01/female_01.mdl"}
    lia.faction.cacheModels(models)

```

---

### lia.faction.loadFromDir

#### 📋 Purpose
Loads faction definitions from Lua files in a specified directory, registering each faction found.

#### ⏰ When Called
Called during gamemode initialization to load faction definitions from organized directory structures.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `directory` | **string** | The path to the directory containing faction definition files. |

#### ↩️ Returns
* nil
This function does not return a value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.faction.loadFromDir("gamemode/factions")

```

---

### lia.faction.get

#### 📋 Purpose
Retrieves faction data by either its unique ID or index number.

#### ⏰ When Called
Called whenever faction information needs to be accessed by other systems or scripts.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `identifier` | **string|number** | The faction's unique ID string or numeric index. |

#### ↩️ Returns
* table
The faction data table, or nil if not found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local faction = lia.faction.get("citizen")
    -- or
    local faction = lia.faction.get(1)

```

---

### lia.faction.getIndex

#### 📋 Purpose
Retrieves the numeric team index for a faction given its unique ID.

#### ⏰ When Called
Called when the numeric team index is needed for GMod team functions or comparisons.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique identifier of the faction. |

#### ↩️ Returns
* number
The faction's team index, or nil if the faction doesn't exist.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local index = lia.faction.getIndex("citizen")
    if index then
        print("Citizen faction index: " .. index)
    end

```

---

### lia.faction.getClasses

#### 📋 Purpose
Retrieves all character classes that belong to a specific faction.

#### ⏰ When Called
Called when needing to display or work with all classes available to a faction.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `faction` | **string|number** | The faction identifier (unique ID or index). |

#### ↩️ Returns
* table
An array of class data tables that belong to the specified faction.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local classes = lia.faction.getClasses("citizen")
    for _, class in ipairs(classes) do
        print("Class: " .. class.name)
    end

```

---

### lia.faction.getPlayers

#### 📋 Purpose
Retrieves all players who are currently playing characters in the specified faction.

#### ⏰ When Called
Called when needing to iterate over or work with all players belonging to a specific faction.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `faction` | **string|number** | The faction identifier (unique ID or index). |

#### ↩️ Returns
* table
An array of player entities who belong to the specified faction.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local players = lia.faction.getPlayers("citizen")
    for _, player in ipairs(players) do
        player:ChatPrint("Hello citizens!")
    end

```

---

### lia.faction.getPlayerCount

#### 📋 Purpose
Counts the number of players currently playing characters in the specified faction.

#### ⏰ When Called
Called when needing to know how many players are in a faction for UI display, limits, or statistics.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `faction` | **string|number** | The faction identifier (unique ID or index). |

#### ↩️ Returns
* number
The number of players in the specified faction.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local count = lia.faction.getPlayerCount("citizen")
    print("There are " .. count .. " citizens online")

```

---

### lia.faction.isFactionCategory

#### 📋 Purpose
Checks if a faction belongs to a specific category of factions.

#### ⏰ When Called
Called when determining if a faction is part of a group or category for organizational purposes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `faction` | **string|number** | The faction identifier to check. |
| `categoryFactions` | **table** | An array of faction identifiers that define the category. |

#### ↩️ Returns
* boolean
True if the faction is in the category, false otherwise.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local lawFactions = {"police", "sheriff"}
    if lia.faction.isFactionCategory("police", lawFactions) then
        print("This is a law enforcement faction")
    end

```

---

### lia.faction.jobGenerate

#### 📋 Purpose
Generates a basic faction configuration programmatically with minimal required parameters.

#### ⏰ When Called
Called for quick faction creation during development or for compatibility with other systems.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | **number** | The numeric team index for the faction. |
| `name` | **string** | The display name of the faction. |
| `color` | **Color** | The color associated with the faction. |
| `default` | **boolean** | Whether this is a default faction that doesn't require whitelisting. |
| `models` | **table** | Array of model paths for the faction (optional, uses defaults if not provided). |

#### ↩️ Returns
* table
The created faction data table.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local faction = lia.faction.jobGenerate(5, "Visitor", Color(200, 200, 200), true)

```

---

### lia.faction.formatModelData

#### 📋 Purpose
Formats and standardizes model data across all factions, converting bodygroup configurations to proper format.

#### ⏰ When Called
Called after faction loading to ensure all model data is properly formatted for use.

#### ↩️ Returns
* nil
This function does not return a value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Called automatically during faction initialization
    lia.faction.formatModelData()

```

---

### lia.faction.getCategories

#### 📋 Purpose
Retrieves all model categories defined for a faction (string keys in the models table).

#### ⏰ When Called
Called when needing to display or work with faction model categories in UI or selection systems.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `teamName` | **string** | The unique ID of the faction. |

#### ↩️ Returns
* table
An array of category names (strings) defined for the faction's models.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local categories = lia.faction.getCategories("citizen")
    for _, category in ipairs(categories) do
        print("Category: " .. category)
    end

```

---

### lia.faction.getModelsFromCategory

#### 📋 Purpose
Retrieves all models belonging to a specific category within a faction.

#### ⏰ When Called
Called when needing to display or select models from a particular category for character creation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `teamName` | **string** | The unique ID of the faction. |
| `category` | **string** | The name of the model category to retrieve. |

#### ↩️ Returns
* table
A table of models in the specified category, indexed by their position.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local models = lia.faction.getModelsFromCategory("citizen", "male")
    for index, model in pairs(models) do
        print("Model " .. index .. ": " .. (istable(model) and model[1] or model))
    end

```

---

### lia.faction.getDefaultClass

#### 📋 Purpose
Retrieves the default character class for a faction (marked with isDefault = true).

#### ⏰ When Called
Called when automatically assigning a class to new characters or when needing the primary class for a faction.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string|number** | The faction identifier (unique ID or index). |

#### ↩️ Returns
* table
The default class data table for the faction, or nil if no default class exists.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local defaultClass = lia.faction.getDefaultClass("citizen")
    if defaultClass then
        print("Default class: " .. defaultClass.name)
    end

```

---

### lia.faction.hasWhitelist

#### 📋 Purpose
Checks if the local player has whitelist access to the specified faction on the client side.

#### ⏰ When Called
Called on the client when determining if a faction should be available for character creation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `faction` | **string|number** | The faction identifier (unique ID or index). |

#### ↩️ Returns
* boolean
True if the player has access to the faction, false otherwise.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    if lia.faction.hasWhitelist("citizen") then
        -- Show citizen faction in character creation menu
    end

```

---

### lia.faction.hasWhitelist

#### 📋 Purpose
Checks whitelist access for a faction on the server side (currently simplified implementation).

#### ⏰ When Called
Called on the server for faction access validation, though the current implementation is restrictive.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `faction` | **string|number** | The faction identifier (unique ID or index). |

#### ↩️ Returns
* boolean
True only for default factions, false for all others including staff.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Server-side validation
    if lia.faction.hasWhitelist("citizen") then
        -- Allow character creation
    end

```

---

