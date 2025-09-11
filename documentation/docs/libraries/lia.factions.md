# Factions Library

This page documents the functions for working with factions and player groups.

---

## Overview

The factions library (`lia.faction`) provides a comprehensive system for managing player factions, classes, and group hierarchies in the Lilia framework, serving as the foundation for roleplay server social structures and organizational systems. This library handles complex faction management with support for hierarchical organizations, internal ranking systems, and dynamic faction relationships including alliances, rivalries, and neutral standings. The system features advanced class management with role-based permissions, skill trees, progression systems, and specialized abilities that define each player's capabilities within their faction. It includes sophisticated whitelist handling with application systems, approval workflows, and automated recruitment processes for maintaining faction quality and roleplay standards. The library provides comprehensive player grouping functionality with team formation, shared resources, collective objectives, and collaborative gameplay mechanics. Additional features include faction-based economy systems, territory control mechanics, diplomatic tools for inter-faction relations, and integration with other framework systems for creating immersive and engaging roleplay experiences that encourage long-term player investment and community building.

---

### lia.faction.register

**Purpose**

Registers a new faction with the faction system.

**Parameters**

* `factionData` (*table*): The faction data table containing name, color, etc.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register a basic faction
lia.faction.register({
    name = "Citizen",
    color = Color(255, 255, 255),
    description = "Regular citizens of the city"
})

-- Register a faction with more options
lia.faction.register({
    name = "Police",
    color = Color(0, 0, 255),
    description = "Law enforcement officers",
    models = {"models/player/barney.mdl", "models/player/alyx.mdl"},
    weapons = {"weapon_pistol", "weapon_stunstick"},
    max = 5
})

-- Register a faction with whitelist
lia.faction.register({
    name = "Mayor",
    color = Color(255, 215, 0),
    description = "City mayor",
    whitelist = true,
    max = 1
})

-- Use in a function
local function createFaction(name, color, description)
    lia.faction.register({
        name = name,
        color = color,
        description = description
    })
    print("Faction created: " .. name)
end
```

---

### lia.faction.cacheModels

**Purpose**

Caches faction models for faster access.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Cache faction models
local function cacheModels()
    lia.faction.cacheModels()
    print("Faction models cached")
end

-- Use in a function
local function reloadFactions()
    lia.faction.cacheModels()
    print("Factions reloaded and models cached")
end

-- Use in a hook
hook.Add("Initialize", "CacheFactionModels", function()
    lia.faction.cacheModels()
end)
```

---

### lia.faction.loadFromDir

**Purpose**

Loads factions from a directory.

**Parameters**

* `directory` (*string*): The directory path to load from.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load factions from directory
local function loadFactions()
    lia.faction.loadFromDir("gamemode/factions/")
    print("Factions loaded from directory")
end

-- Use in a function
local function reloadAllFactions()
    lia.faction.loadFromDir("gamemode/factions/")
    lia.faction.cacheModels()
    print("All factions reloaded")
end

-- Use in a hook
hook.Add("Initialize", "LoadFactions", function()
    lia.faction.loadFromDir("gamemode/factions/")
end)
```

---

### lia.faction.get

**Purpose**

Gets a faction by name.

**Parameters**

* `name` (*string*): The faction name.

**Returns**

* `faction` (*table*): The faction data table or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get a faction
local function getFaction(name)
    return lia.faction.get(name)
end

-- Use in a function
local function checkFactionExists(name)
    local faction = lia.faction.get(name)
    if faction then
        print("Faction exists: " .. name)
        return true
    else
        print("Faction not found: " .. name)
        return false
    end
end

-- Use in a command
lia.command.add("factioninfo", {
    arguments = {
        {name = "faction", type = "string"}
    },
    onRun = function(client, arguments)
        local faction = lia.faction.get(arguments[1])
        if faction then
            client:notify("Faction: " .. faction.name .. " - " .. faction.description)
        else
            client:notify("Faction not found")
        end
    end
})
```

---

### lia.faction.getIndex

**Purpose**

Gets the index of a faction.

**Parameters**

* `name` (*string*): The faction name.

**Returns**

* `index` (*number*): The faction index or 0.

**Realm**

Shared.

**Example Usage**

```lua
-- Get faction index
local function getFactionIndex(name)
    return lia.faction.getIndex(name)
end

-- Use in a function
local function getFactionByIndex(index)
    local factions = lia.faction.getAll()
    return factions[index]
end

-- Use in a function
local function sortFactions()
    local factions = lia.faction.getAll()
    table.sort(factions, function(a, b)
        return lia.faction.getIndex(a.name) < lia.faction.getIndex(b.name)
    end)
    return factions
end
```

---

### lia.faction.getClasses

**Purpose**

Gets all classes for a faction.

**Parameters**

* `factionName` (*string*): The faction name.

**Returns**

* `classes` (*table*): Table of faction classes.

**Realm**

Shared.

**Example Usage**

```lua
-- Get faction classes
local function getFactionClasses(factionName)
    return lia.faction.getClasses(factionName)
end

-- Use in a function
local function showFactionClasses(factionName)
    local classes = lia.faction.getClasses(factionName)
    if classes then
        print("Classes for " .. factionName .. ":")
        for _, class in ipairs(classes) do
            print("- " .. class.name)
        end
    end
end

-- Use in a function
local function getClassCount(factionName)
    local classes = lia.faction.getClasses(factionName)
    return classes and #classes or 0
end
```

---

### lia.faction.getPlayers

**Purpose**

Gets all players in a faction.

**Parameters**

* `factionName` (*string*): The faction name.

**Returns**

* `players` (*table*): Table of players in the faction.

**Realm**

Server.

**Example Usage**

```lua
-- Get faction players
local function getFactionPlayers(factionName)
    return lia.faction.getPlayers(factionName)
end

-- Use in a function
local function showFactionPlayers(factionName)
    local players = lia.faction.getPlayers(factionName)
    if players then
        print("Players in " .. factionName .. ":")
        for _, player in ipairs(players) do
            print("- " .. player:Name())
        end
    end
end

-- Use in a function
local function getFactionPlayerCount(factionName)
    local players = lia.faction.getPlayers(factionName)
    return players and #players or 0
end
```

---

### lia.faction.getPlayerCount

**Purpose**

Gets the number of players in a faction.

**Parameters**

* `factionName` (*string*): The faction name.

**Returns**

* `count` (*number*): The number of players in the faction.

**Realm**

Server.

**Example Usage**

```lua
-- Get faction player count
local function getFactionPlayerCount(factionName)
    return lia.faction.getPlayerCount(factionName)
end

-- Use in a function
local function checkFactionCapacity(factionName)
    local count = lia.faction.getPlayerCount(factionName)
    local faction = lia.faction.get(factionName)
    if faction and faction.max then
        if count >= faction.max then
            print("Faction " .. factionName .. " is full")
            return false
        end
    end
    return true
end

-- Use in a function
local function showFactionStats()
    local factions = lia.faction.getAll()
    for _, faction in ipairs(factions) do
        local count = lia.faction.getPlayerCount(faction.name)
        print(faction.name .. ": " .. count .. " players")
    end
end
```

---

### lia.faction.isFactionCategory

**Purpose**

Checks if a faction is a category.

**Parameters**

* `factionName` (*string*): The faction name.

**Returns**

* `isCategory` (*boolean*): True if the faction is a category.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if faction is category
local function isFactionCategory(factionName)
    return lia.faction.isFactionCategory(factionName)
end

-- Use in a function
local function getCategories()
    local factions = lia.faction.getAll()
    local categories = {}
    for _, faction in ipairs(factions) do
        if lia.faction.isFactionCategory(faction.name) then
            table.insert(categories, faction)
        end
    end
    return categories
end

-- Use in a function
local function showCategories()
    local categories = getCategories()
    print("Faction categories:")
    for _, category in ipairs(categories) do
        print("- " .. category.name)
    end
end
```

---

### lia.faction.jobGenerate

**Purpose**

Generates job data for a faction.

**Parameters**

* `factionData` (*table*): The faction data.

**Returns**

* `jobData` (*table*): The generated job data.

**Realm**

Shared.

**Example Usage**

```lua
-- Generate job data
local function generateJobData(factionData)
    return lia.faction.jobGenerate(factionData)
end

-- Use in a function
local function createJobFromFaction(factionName)
    local faction = lia.faction.get(factionName)
    if faction then
        local jobData = lia.faction.jobGenerate(faction)
        print("Job data generated for " .. factionName)
        return jobData
    end
    return nil
end

-- Use in a function
local function generateAllJobs()
    local factions = lia.faction.getAll()
    for _, faction in ipairs(factions) do
        local jobData = lia.faction.jobGenerate(faction)
        print("Generated job for " .. faction.name)
    end
end
```

---

### lia.faction.formatModelData

**Purpose**

Formats model data for a faction.

**Parameters**

* `models` (*table*): The model data table.

**Returns**

* `formattedModels` (*table*): The formatted model data.

**Realm**

Shared.

**Example Usage**

```lua
-- Format model data
local function formatModelData(models)
    return lia.faction.formatModelData(models)
end

-- Use in a function
local function setupFactionModels(factionName)
    local faction = lia.faction.get(factionName)
    if faction and faction.models then
        local formattedModels = lia.faction.formatModelData(faction.models)
        print("Models formatted for " .. factionName)
        return formattedModels
    end
    return nil
end

-- Use in a function
local function formatAllFactionModels()
    local factions = lia.faction.getAll()
    for _, faction in ipairs(factions) do
        if faction.models then
            local formatted = lia.faction.formatModelData(faction.models)
            print("Models formatted for " .. faction.name)
        end
    end
end
```

---

### lia.faction.getCategories

**Purpose**

Gets all faction categories.

**Parameters**

*None*

**Returns**

* `categories` (*table*): Table of faction categories.

**Realm**

Shared.

**Example Usage**

```lua
-- Get faction categories
local function getCategories()
    return lia.faction.getCategories()
end

-- Use in a function
local function showCategories()
    local categories = lia.faction.getCategories()
    print("Faction categories:")
    for _, category in ipairs(categories) do
        print("- " .. category.name)
    end
end

-- Use in a function
local function getCategoryCount()
    local categories = lia.faction.getCategories()
    return #categories
end
```

---

### lia.faction.getModelsFromCategory

**Purpose**

Gets models from a faction category.

**Parameters**

* `categoryName` (*string*): The category name.

**Returns**

* `models` (*table*): Table of models in the category.

**Realm**

Shared.

**Example Usage**

```lua
-- Get models from category
local function getModelsFromCategory(categoryName)
    return lia.faction.getModelsFromCategory(categoryName)
end

-- Use in a function
local function showCategoryModels(categoryName)
    local models = lia.faction.getModelsFromCategory(categoryName)
    if models then
        print("Models in " .. categoryName .. ":")
        for _, model in ipairs(models) do
            print("- " .. model)
        end
    end
end

-- Use in a function
local function getModelCount(categoryName)
    local models = lia.faction.getModelsFromCategory(categoryName)
    return models and #models or 0
end
```

---

### lia.faction.getDefaultClass

**Purpose**

Gets the default class for a faction.

**Parameters**

* `factionName` (*string*): The faction name.

**Returns**

* `defaultClass` (*table*): The default class data or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get default class
local function getDefaultClass(factionName)
    return lia.faction.getDefaultClass(factionName)
end

-- Use in a function
local function showDefaultClass(factionName)
    local defaultClass = lia.faction.getDefaultClass(factionName)
    if defaultClass then
        print("Default class for " .. factionName .. ": " .. defaultClass.name)
    else
        print("No default class for " .. factionName)
    end
end

-- Use in a function
local function setPlayerDefaultClass(client, factionName)
    local defaultClass = lia.faction.getDefaultClass(factionName)
    if defaultClass then
        client:setChar():setClass(defaultClass)
        print("Set default class for " .. client:Name())
    end
end
```

---

### lia.faction.registerGroup

**Purpose**

Registers a faction group.

**Parameters**

* `groupData` (*table*): The group data table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register faction group
local function registerGroup(groupData)
    lia.faction.registerGroup(groupData)
end

-- Use in a function
local function createFactionGroup(name, factions)
    lia.faction.registerGroup({
        name = name,
        factions = factions
    })
    print("Faction group created: " .. name)
end

-- Use in a function
local function createLawEnforcementGroup()
    lia.faction.registerGroup({
        name = "Law Enforcement",
        factions = {"Police", "SWAT", "FBI"}
    })
end
```

---

### lia.faction.getGroup

**Purpose**

Gets a faction group by name.

**Parameters**

* `groupName` (*string*): The group name.

**Returns**

* `group` (*table*): The group data table or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get faction group
local function getGroup(groupName)
    return lia.faction.getGroup(groupName)
end

-- Use in a function
local function checkGroupExists(groupName)
    local group = lia.faction.getGroup(groupName)
    if group then
        print("Group exists: " .. groupName)
        return true
    else
        print("Group not found: " .. groupName)
        return false
    end
end

-- Use in a function
local function showGroupFactions(groupName)
    local group = lia.faction.getGroup(groupName)
    if group then
        print("Factions in " .. groupName .. ":")
        for _, faction in ipairs(group.factions) do
            print("- " .. faction)
        end
    end
end
```

---

### lia.faction.getFactionsInGroup

**Purpose**

Gets all factions in a group.

**Parameters**

* `groupName` (*string*): The group name.

**Returns**

* `factions` (*table*): Table of factions in the group.

**Realm**

Shared.

**Example Usage**

```lua
-- Get factions in group
local function getFactionsInGroup(groupName)
    return lia.faction.getFactionsInGroup(groupName)
end

-- Use in a function
local function showGroupFactions(groupName)
    local factions = lia.faction.getFactionsInGroup(groupName)
    if factions then
        print("Factions in " .. groupName .. ":")
        for _, faction in ipairs(factions) do
            print("- " .. faction)
        end
    end
end

-- Use in a function
local function getGroupFactionCount(groupName)
    local factions = lia.faction.getFactionsInGroup(groupName)
    return factions and #factions or 0
end
```

---

### lia.faction.hasWhitelist

**Purpose**

Checks if a faction has a whitelist.

**Parameters**

* `factionName` (*string*): The faction name.

**Returns**

* `hasWhitelist` (*boolean*): True if the faction has a whitelist.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if faction has whitelist
local function hasWhitelist(factionName)
    return lia.faction.hasWhitelist(factionName)
end

-- Use in a function
local function checkFactionAccess(client, factionName)
    if lia.faction.hasWhitelist(factionName) then
        if not client:isWhitelisted(factionName) then
            client:notify("You are not whitelisted for this faction")
            return false
        end
    end
    return true
end

-- Use in a function
local function showWhitelistedFactions()
    local factions = lia.faction.getAll()
    print("Whitelisted factions:")
    for _, faction in ipairs(factions) do
        if lia.faction.hasWhitelist(faction.name) then
            print("- " .. faction.name)
        end
    end
end
```