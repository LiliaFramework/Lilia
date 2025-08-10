# Factions Library

This page covers the faction system helpers.

---

## Overview

The factions library loads faction definitions and stores them for later lookup. Factions are kept in two tables:

* `lia.faction.teams` — indexed by unique identifier.

* `lia.faction.indices` — indexed by team number.

By default a staff faction is registered and exposed as the global constant `FACTION_STAFF`.

The helpers below let you find factions and iterate over their data. See [Faction Fields](../definitions/faction.md) for the keys stored in each `FACTION` table.

---

### lia.faction.register

**Purpose**

Registers a new faction, localises its fields, precaches its models and assigns it a team.

**Parameters**

* `uniqueID` (*string*): Unique identifier for the faction.
* `data` (*table*): Faction properties. Missing fields default to:
  * `name` → `"unknown"`
  * `desc` → `"noDesc"`
  * `isDefault` → `true`
  * `color` → `Color(150, 150, 150)`
  * `models` → citizen model set
  * `index` → next free index if omitted

**Realm**

`Shared`

**Returns**

* `number`: Index assigned to the faction.
* `table`: The registered faction table.

**Notes**

* Uses `data.index` or an existing `FACTION_<UNIQUEID>` constant if provided; otherwise the next free index is used.
* Registers the faction in `lia.faction.indices` and `lia.faction.teams`.
* Defines global constant `FACTION_<UNIQUEID>` with the faction's index.
* Name, description and model lists are localized via `L()` and may be overridden by the hooks `OverrideFactionName`, `OverrideFactionDesc` and `OverrideFactionModels`.

**Example Usage**

```lua
local index, faction = lia.faction.register("citizen", {
    name = "Citizen",
    desc = "Common populace",
    isDefault = true,
    color = Color(100, 150, 200),
    models = {"models/player/group01/male_01.mdl"}
})
```

---

### lia.faction.loadFromDir

**Purpose**

Loads all Lua faction files from a directory, includes them **shared**, and registers the resulting `FACTION` tables.
Each file should define a global `FACTION` table describing the faction.
The filename (minus any leading `sh_`) becomes the faction's unique ID unless `FACTION.uniqueID` is set.
Missing `name`, `desc`, or `color` fields are replaced with defaults and an error is logged.
`isDefault` defaults to `true` and a new index is assigned if not provided.
Models default to the citizen set and are precached. Names, descriptions and models are localized via `L()` and can be overridden via the hooks `OverrideFactionName`, `OverrideFactionDesc` and `OverrideFactionModels`.
Factions are stored in both lookup tables and `team.SetUp` is called for each.

**Parameters**

* `directory` (*string*): Path to the folder containing faction files.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.faction.loadFromDir("path/to/factions")
```

---

### lia.faction.get

**Purpose**

Retrieves a faction table by its index or unique identifier.

**Parameters**

* `identifier` (*number | string*): Faction index or unique ID.

**Realm**

`Shared`

**Returns**

* *table | nil*: The faction table, or `nil` if not found.

**Example Usage**

```lua
local faction = lia.faction.get("citizen")
```

---

### lia.faction.getIndex

**Purpose**

Returns the numeric index of a faction given its unique identifier.

**Parameters**

* `uniqueID` (*string*): Faction unique ID.

**Realm**

`Shared`

**Returns**

* *number | nil*: Index if found, otherwise `nil`.

**Example Usage**

```lua
local index = lia.faction.getIndex("citizen")
```

---

### lia.faction.getClasses

**Purpose**

Returns a list of class tables that belong to the specified faction.

**Parameters**

* `faction` (*number | string*): Faction index or unique ID.

**Realm**

`Shared`

**Returns**

* *table*: Array of class tables.

**Example Usage**

```lua
local classes = lia.faction.getClasses(FACTION_CITIZEN)
```

---

### lia.faction.getPlayers

**Purpose**

Retrieves all player entities whose characters are in the given faction. Players without a character are ignored.

**Parameters**

* `faction` (*number | string*): Faction index or unique ID.

**Realm**

`Shared`

**Returns**

* *table*: Array of `Player` entities.

**Example Usage**

```lua
local players = lia.faction.getPlayers(FACTION_CITIZEN)
```

---

### lia.faction.getPlayerCount

**Purpose**

Counts how many players belong to the specified faction. Players without a character are not counted.

**Parameters**

* `faction` (*number | string*): Faction index or unique ID.

**Realm**

`Shared`

**Returns**

* *number*: Player count.

**Example Usage**

```lua
local count = lia.faction.getPlayerCount(FACTION_CITIZEN)
```

---

### lia.faction.isFactionCategory

**Purpose**

Checks whether a faction belongs to a category defined by a list of faction IDs.

**Parameters**

* `faction` (*number | string*): Faction index or unique ID.
* `categoryFactions` (*table*): Array of faction indices or unique IDs in the category.

**Realm**

`Shared`

**Returns**

* *boolean*: `true` if the faction is in the category.

**Example Usage**

```lua
local isMember = lia.faction.isFactionCategory("citizen", { "citizen", "veteran" })
```

---

### lia.faction.jobGenerate

**Purpose**

Dynamically creates and registers a new faction (job) with the team system, precaching its models and storing it in the lookup tables.

**Parameters**

* `index` (*number*): Team index.

* `name` (*string*): Faction name.

* `color` (*Color*): Team colour.

* `default` (*boolean*): Whether this faction is default.

* `models` (*table | nil*): Optional array of model paths or model data. Defaults to the citizen model set.

**Realm**

`Shared`

**Returns**

* *table*: The generated faction table. The `desc` field is empty and `uniqueID` defaults to `name`.

**Example Usage**

```lua
local police = lia.faction.jobGenerate(
    2,
    "Police",
    Color(0, 0, 255),
    false,
    { "models/player/police.mdl" }
)
```

---

### lia.faction.formatModelData

**Purpose**

Processes all faction model entries and expands any bodygroup data so each model has numeric group indices. Useful for bodygroup customisation.

**Parameters**

*None*

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.faction.formatModelData()
```

---

### lia.faction.getCategories

**Purpose**

Returns a list of model category names for the given faction.

**Parameters**

* `teamName` (*string*): Faction unique ID.

**Realm**

`Shared`

**Returns**

* *table*: Array of category names (empty if none or the faction doesn't exist).

**Example Usage**

```lua
local categories = lia.faction.getCategories("citizen")
```

---

### lia.faction.getModelsFromCategory

**Purpose**

Returns the models that belong to a specific category for a faction.

**Parameters**

* `teamName` (*string*): Faction unique ID.

* `category` (*string*): Category name.

**Realm**

`Shared`

**Returns**

* *table*: Table of model entries (strings or `{path, skin, bodygroups}`) — empty if the faction or category is missing.

**Example Usage**

```lua
local models = lia.faction.getModelsFromCategory("citizen", "special")
```

---

### lia.faction.getDefaultClass

**Purpose**

Finds the first class marked as default for the given faction.

**Parameters**

* `id` (*number | string*): Faction index or unique ID.

**Realm**

`Shared`

**Returns**

* *table | nil*: Default class table, or `nil` if none.

**Example Usage**

```lua
local defaultClass = lia.faction.getDefaultClass(FACTION_CITIZEN)
```

---

### lia.faction.hasWhitelist

**Purpose**

Client-side check whether the local player is whitelisted for a faction. Default factions always return `true`. For the `FACTION_STAFF` faction the `createStaffCharacter` privilege is required and the player is notified if the privilege is missing. Other factions check `lia.localData.whitelists`.

**Parameters**

* `faction` (*number | string*): Faction index or unique ID.

**Realm**

`Client`

**Returns**

* *boolean*: `true` if the faction is default or the player has a whitelist.

**Example Usage**

```lua
local whitelisted = lia.faction.hasWhitelist(FACTION_CITIZEN)
```
