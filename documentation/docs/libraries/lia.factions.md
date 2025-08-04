# Factions Library

This page covers the faction system helpers.

---

## Overview

The factions library loads faction definitions and stores them for later lookup. Factions are kept in two tables:

* `lia.faction.teams` — indexed by unique identifier.

* `lia.faction.indices` — indexed by team number.

The helpers below let you find factions and iterate over their data. See [Faction Fields](../definitions/faction.md) for the keys stored in each `FACTION` table.

---

### lia.faction.loadFromDir

**Purpose**

Loads all Lua faction files from a directory, includes them **shared**, and registers the resulting `FACTION` tables. Models are precached and factions are stored in both lookup tables.

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

* `faction` (*number*): Faction index.

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

Retrieves all player entities whose characters are in the given faction.

**Parameters**

* `faction` (*number*): Faction index.

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

Counts how many players belong to the specified faction.

**Parameters**

* `faction` (*number*): Faction index.

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

* `faction` (*string*): Faction unique ID.

* `categoryFactions` (*table*): Array of faction IDs in the category.

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

Dynamically creates and registers a new faction (job) with the team system, precaching its models.

**Parameters**

* `index` (*number*): Team index.

* `name` (*string*): Faction name.

* `color` (*Color*): Team colour.

* `default` (*boolean*): Whether this faction is default.

* `models` (*table*): Array of model paths or model data.

**Realm**

`Shared`

**Returns**

* *table*: The generated faction table.

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

Normalises model tables for every registered faction, ensuring grouped categories are consistent.

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

* *table*: Array of category names.

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

* *table*: Array of model paths.

**Example Usage**

```lua
local models = lia.faction.getModelsFromCategory("citizen", "special")
```

---

### lia.faction.getDefaultClass

**Purpose**

Finds the first class marked as default for the given faction.

**Parameters**

* `id` (*number*): Faction index.

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

Client-side check whether the local player is whitelisted for a faction.

**Parameters**

* `faction` (*number*): Faction index.

**Realm**

`Client`

**Returns**

* *boolean*: `true` if the player is whitelisted.

**Example Usage**

```lua
local whitelisted = lia.faction.hasWhitelist(FACTION_CITIZEN)
```

---
