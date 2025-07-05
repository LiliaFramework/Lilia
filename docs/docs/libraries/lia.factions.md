# Factions Library

This page covers the faction system helpers.

---

## Overview

The factions library loads faction definitions and stores them for later lookup. Factions are kept in two tables:

`lia.faction.teams` indexed by unique identifier and

`lia.faction.indices` indexed by team number. The library offers helpers to find

factions and iterate over their data.

See [Faction Fields](../definitions/faction.md) for details on the data stored in

each `FACTION` table.

---

### lia.faction.loadFromDir

**Description:**

Loads all Lua faction files (`*.lua`) from the specified directory,

includes them as shared files and registers the factions. Each file must

define a `FACTION` table with properties such as name, description, color

and models. The function calls `team.SetUp` for every faction, caches all

models to improve load times and stores the result in both

`lia.faction.teams` and `lia.faction.indices`.

**Parameters:**

* `directory` (`string`) – The path to the directory containing faction files.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.faction.loadFromDir
    lia.faction.loadFromDir("path/to/factions")
```

---

### lia.faction.get

**Description:**

Retrieves a faction by its index or unique identifier.

**Parameters:**

* `identifier` (`number or string`) – The faction's index or unique identifier.


**Realm:**

* Shared


**Returns:**

* table|nil – The faction table if found; nil otherwise.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.faction.get
    local faction = lia.faction.get("citizen")
```

---

### lia.faction.getIndex

**Description:**

Retrieves the index of a faction by its unique identifier.

**Parameters:**

* `uniqueID` (`string`) – The unique identifier of the faction.


**Realm:**

* Shared


**Returns:**

* number|nil – The faction index if found; nil otherwise.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.faction.getIndex
    local index = lia.faction.getIndex("citizen")
```

---

### lia.faction.getClasses

**Description:**

Retrieves a list of classes associated with the specified faction.

**Parameters:**

* `faction` (`number`) – The faction index.


**Realm:**

* Shared


**Returns:**

* table – A table containing class tables that belong to the faction.


**Example Usage:**

```lua
    -- Retrieve class definitions that belong to the Citizen faction
    local classes = lia.faction.getClasses(FACTION_CITIZEN)
```

---

### lia.faction.getPlayers

**Description:**

Retrieves all player entities whose characters belong to the specified faction.

**Parameters:**

* `faction` (`number`) – The faction index.


**Realm:**

* Shared


**Returns:**

* table – A table of player entities in the faction.


**Example Usage:**

```lua
    -- Get all players currently in the Citizen faction
    local players = lia.faction.getPlayers(FACTION_CITIZEN)
```

---

### lia.faction.getPlayerCount

**Description:**

Counts the number of players whose characters belong to the specified faction.

**Parameters:**

* `faction` (`number`) – The faction index.


**Realm:**

* Shared


**Returns:**

* number – The number of players in the faction.


**Example Usage:**

```lua
    -- Count how many players are citizens
    local count = lia.faction.getPlayerCount(FACTION_CITIZEN)
```

---

### lia.faction.isFactionCategory

**Description:**

Checks if the specified faction is a member of a given category.

**Parameters:**

* `faction` (`string`) – The faction unique identifier.


* `categoryFactions` (`table`) – A table containing faction identifiers that define the category.


**Realm:**

* Shared


**Returns:**

* boolean – True if the faction is in the category; false otherwise.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.faction.isFactionCategory
    local isMember = lia.faction.isFactionCategory("citizen", {"citizen", "veteran"})
```

---

### lia.faction.jobGenerate

**Description:**

Generates a new faction (job) based on provided parameters.

Creates a faction table with index, name, description, color, models, and registers it with the team system.

Pre-caches the faction models.

**Parameters:**

* `index` (`number`) – The team index for the faction.


* `name` (`string`) – The faction name.


* `color` (`Color`) – The faction color.


* `default` (`boolean`) – Whether the faction is default.


* `models` (`table`) – A table of model paths or model data for the faction.


**Realm:**

* Shared


**Returns:**

* table – The newly generated faction table.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.faction.jobGenerate
    local faction = lia.faction.jobGenerate(2, "Police", Color(0, 0, 255), false, {"models/player/police.mdl"})
```

---

### lia.faction.formatModelData

**Description:**

Processes and formats model data for all registered factions.

Iterates through each faction's model data and applies formatting to ensure proper grouping.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.faction.formatModelData
    lia.faction.formatModelData()
```

---

### lia.faction.getCategories

**Description:**

Retrieves a list of model categories for a given faction.

Categories are determined by keys in the faction's models table that are strings.

**Parameters:**

* `teamName` (`string`) – The unique identifier of the faction.


**Realm:**

* Shared


**Returns:**

* table – A list of category names.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.faction.getCategories
    local categories = lia.faction.getCategories("citizen")
```

---

### lia.faction.getModelsFromCategory

**Description:**

Retrieves models from a specified category for a given faction.

**Parameters:**

* `teamName` (`string`) – The unique identifier of the faction.


* `category` (`string`) – The model category to retrieve.


**Realm:**

* Shared


**Returns:**

* table – A table of models in the specified category.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.faction.getModelsFromCategory
    local models = lia.faction.getModelsFromCategory("citizen", "special")
```

---

### lia.faction.getDefaultClass

**Description:**

Retrieves the default class for a specified faction.

Searches through the class list for the first class that is marked as default for the faction.

**Parameters:**

* `id` (`string`) – The unique identifier of the faction.


**Realm:**

* Shared


**Returns:**

* table|nil – The default class table if found; nil otherwise.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.faction.getDefaultClass
    local defaultClass = lia.faction.getDefaultClass("citizen")
```

---

### lia.faction.hasWhitelist

**Description:**

Determines if the local player has whitelist access for a given faction.

Checks the local whitelist data against the faction's uniqueID.

**Parameters:**

* `faction` (`number`) – The faction index.


**Realm:**

* Client


**Returns:**

* boolean – True if the player is whitelisted; false otherwise.


**Example Usage:**

```lua
    -- Check whether the local player is whitelisted for the Citizen faction
    local whitelisted = lia.faction.hasWhitelist(FACTION_CITIZEN)
```
