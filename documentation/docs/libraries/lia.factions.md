# Factions Library

This page documents the functions for working with factions and player groups.

---

## Overview

The factions library (`lia.faction`) provides a comprehensive system for managing player factions, classes, and group hierarchies in the Lilia framework, serving as the foundation for roleplay server social structures and organizational systems. This library handles complex faction management with support for hierarchical organizations, internal ranking systems, and dynamic faction relationships including alliances, rivalries, and neutral standings. The system features advanced class management with role-based permissions, skill trees, progression systems, and specialized abilities that define each player's capabilities within their faction. It includes sophisticated whitelist handling with application systems, approval workflows, and automated recruitment processes for maintaining faction quality and roleplay standards. The library provides comprehensive player grouping functionality with team formation, shared resources, collective objectives, and collaborative gameplay mechanics. Additional features include faction-based economy systems, territory control mechanics, diplomatic tools for inter-faction relations, and integration with other framework systems for creating immersive and engaging roleplay experiences that encourage long-term player investment and community building.

---

### register

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

### cacheModels

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

### loadFromDir

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

### get

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

### getIndex

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

### getClasses

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

### getPlayers

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

### getPlayerCount

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

### isFactionCategory

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

### jobGenerate

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

### formatModelData

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

### getCategories

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

### getModelsFromCategory

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

### getDefaultClass

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

### registerGroup

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

### getGroup

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

### getFactionsInGroup

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

### hasWhitelist

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

---

## Definitions

# Faction Fields

This document describes all the configurable `FACTION` fields available in the codebase, with their descriptions and example usages.

Unspecified fields will use sensible defaults.

---

## Overview

Each faction in the game is defined by a set of fields on the global `FACTION` table. These fields control everything from display name and lore, to starting weapons and player statistics. All fields are optional; unspecified fields will fall back to sensible defaults.

---

### FACTION.name

**Type:**

`string`

**Description:**

Display name shown for members of this faction.

**Example Usage:**

```lua
FACTION.name = "Minecrafters"
```

---

### FACTION.desc

**Type:**

`string`

**Description:**

Lore or descriptive text about the faction.

**Example Usage:**

```lua
FACTION.desc = "Surviving and crafting in the blocky world."
```

---

### FACTION.isDefault

**Type:**

`boolean`

**Description:**

Set to `true` if players may select this faction without a whitelist.

**Example Usage:**

```lua
FACTION.isDefault = false
```

---

### FACTION.uniqueID

**Type:**

`string`

**Description:**

Internal string identifier for referencing the faction.

**Example Usage:**

```lua
FACTION.uniqueID = "staff"
```

### FACTION.prefix

**Type:**

`string` or `function`

**Description:**

Optional prefix automatically prepended to new character names. If a function is

provided, it is called with the player creating the character and should return

the desired text. The result is inserted before the base name with a space and

trimmed; returning `nil` or an empty string results in no prefix being applied.

**Example Usage:**

```lua
FACTION.prefix = "[CIT]"
-- or
FACTION.prefix = function(client)
    return client:isVIP() and "[VIP]" or ""
end
```

---

### FACTION.index

**Type:**

`number`

**Description:**

Numeric identifier assigned during faction registration.

**Example Usage:**

```lua
FACTION_STAFF = FACTION.index
```

---

### FACTION.color

**Type:**

`Color`

**Description:**

Color used in UI elements to represent the faction. Defaults to `Color(150, 150, 150)` if not specified.

**Example Usage:**

```lua
FACTION.color = Color(255, 56, 252)
```

---

### FACTION.models

**Type:**

`table`

**Description:**

Table of player model paths available to faction members.

**Example Usage:**

```lua
FACTION.models = {
    "models/Humans/Group02/male_07.mdl",
    "models/Humans/Group02/female_02.mdl"
}
```

---

### FACTION.logo

**Type:**

`string`

**Description:**

Material path for the faction logo displayed in the scoreboard header.

**Example Usage:**

```lua
FACTION.logo = "materials/factions/citizen_logo.png"
```

---

### FACTION.weapons

**Type:**

`table`

**Description:**

Weapons automatically granted on spawn.

**Example Usage:**

```lua
FACTION.weapons = {"weapon_physgun", "gmod_tool"}
```

---

### FACTION.items

**Type:**

`table`

**Description:**

Item uniqueIDs automatically granted on character creation.

**Example Usage:**

```lua
FACTION.items = {"radio", "handcuffs"}
```

---

### FACTION.pay

**Type:**

`number`

**Description:**

Payment amount for members each interval.

**Example Usage:**

```lua
FACTION.pay = 50
```

---

### FACTION.payLimit

**Type:**

`number`

**Description:**

Maximum pay a member can accumulate.

**Example Usage:**

```lua
FACTION.payLimit = 1000
```

---

### FACTION.limit

**Type:**

`number`

**Description:**

Maximum number of players allowed in this faction.

**Example Usage:**

```lua
FACTION.limit = 20
```

---

### FACTION.oneCharOnly

**Type:**

`boolean`

**Description:**

If `true`, players may only create one character in this faction.

**Example Usage:**

```lua
FACTION.oneCharOnly = true
```

---

### FACTION.health

**Type:**

`number`

**Description:**

Starting health for faction members.

**Example Usage:**

```lua
FACTION.health = 150
```

---

### FACTION.armor

**Type:**

`number`

**Description:**

Starting armor for faction members.

**Example Usage:**

```lua
FACTION.armor = 25
```

---

### FACTION.scale

**Type:**

`number`

**Description:**

Player model scale multiplier.

**Example Usage:**

```lua
FACTION.scale = 1.1
```

---

### FACTION.runSpeed

**Type:**

`number`

**Description:**

Base running speed.

**Example Usage:**

```lua
FACTION.runSpeed = 250
```

---

### FACTION.runSpeedMultiplier

**Type:**

`boolean`

**Description:**

If `true`, multiplies the base speed rather than replacing it.

**Example Usage:**

```lua
FACTION.runSpeedMultiplier = false
```

---

### FACTION.walkSpeed

**Type:**

`number`

**Description:**

Base walking speed.

**Example Usage:**

```lua
FACTION.walkSpeed = 200
```

---

### FACTION.walkSpeedMultiplier

**Type:**

`boolean`

**Description:**

If `true`, multiplies the base walk speed rather than replacing it.

**Example Usage:**

```lua
FACTION.walkSpeedMultiplier = true
```

---

### FACTION.jumpPower

**Type:**

`number`

**Description:**

Base jump power.

**Example Usage:**

```lua
FACTION.jumpPower = 200
```

---

### FACTION.jumpPowerMultiplier

**Type:**

`boolean`

**Description:**

If `true`, multiplies the base jump power rather than replacing it.

**Example Usage:**

```lua
FACTION.jumpPowerMultiplier = true
```

---

### FACTION.MemberToMemberAutoRecognition

**Type:**

`boolean`

**Description:**

Whether faction members automatically recognize each other on sight.

**Example Usage:**

```lua
FACTION.MemberToMemberAutoRecognition = true
```

---

### FACTION.RecognizesGlobally

**Type:**

`boolean`

**Description:**

If `true`, members recognize all players globally, regardless of faction.

**Example Usage:**

```lua
FACTION.RecognizesGlobally = false
```

### FACTION.isGloballyRecognized

**Type:**

`boolean`

**Description:**

If set to `true`, all players will automatically recognize members of this faction.

**Example Usage:**

```lua
FACTION.isGloballyRecognized = true
```

---

### FACTION.NPCRelations

**Type:**

`table`

**Description:**

Mapping of NPC class names to disposition constants (`D_HT`, `D_LI`, etc.). NPCs are updated on spawn/creation.

**Example Usage:**

```lua
FACTION.NPCRelations = {
    ["npc_combine_s"] = D_HT,
    ["npc_citizen"]     = D_LI
}
```

---

### FACTION.bloodcolor

**Type:**

`number`

**Description:**

Blood color enumeration constant for faction members.

**Example Usage:**

```lua
FACTION.bloodcolor = BLOOD_COLOR_RED
```

---

### FACTION.scoreboardHidden

**Type:**

`boolean`

**Description:**

If `true`, members of this faction are hidden from the scoreboard.

**Example Usage:**

```lua
FACTION.scoreboardHidden = false
```

---

### FACTION.commands

**Type:**

`table`

**Description:**

Table of command names that members of this faction may always use,

even if they normally lack the required privilege.

**Example Usage:**

```lua
FACTION.commands = {
    plytransfer = true,
}
```

---

### FACTION.group

**Type:**

`string`

**Description:**

Faction group identifier used for door access control and other systems.

**Example Usage:**

```lua
FACTION.group = "law_enforcement"
```

---

### FACTION.spawns

**Type:**

`table`

**Description:**

Faction-specific spawn points. Each spawn point can have position, angle, and map properties.

**Example Usage:**

```lua
FACTION.spawns = {
    {
        pos = Vector(100, 200, 50),
        ang = Angle(0, 90, 0),
        map = "rp_downtown_v4c_v2"
    }
}
```

---

### FACTION.mainMenuPosition

**Type:**

`Vector` or `table`

**Description:**

Controls the position and rotation of the character model in the main menu. Supports map-based positioning for different positions on different maps. If set as a `Vector`, only the position is changed. If set as a table, both position and angles can be specified for complete control over the character's appearance in the main menu.

**Example Usage:**

```lua
-- Simple position change only (works on all maps)
FACTION.mainMenuPosition = Vector(100, 0, 0)

-- Full control with position and rotation (works on all maps)
FACTION.mainMenuPosition = {
    position = Vector(0, 0, 0),
    angles = Angle(0, 180, 0)
}

-- Map-specific positions
FACTION.mainMenuPosition = {
    ["rp_nycity_day"] = {
        position = Vector(-9598.93, -3528.32, 0.03),
        angles = Angle(-3.23, 90.56, 0)
    },
    ["rp_downtown_v4c"] = {
        position = Vector(100, 200, 50),
        angles = Angle(0, 180, 0)
    }
}
```

---

### FACTION:OnSpawn

**Type:**

`function`

**Description:**

Called when a player spawns with faction attributes applied. Receives the client as the first parameter.

**Example Usage:**

```lua
function FACTION:OnSpawn(client)
    -- Custom spawn logic
    client:SetModelScale(1.2)
    client:SetHealth(150)
end
```

---

### FACTION:OnTransferred

**Type:**

`function`

**Description:**

Called when a character is transferred to this faction. Receives the target player and the old faction index.

**Example Usage:**

```lua
function FACTION:OnTransferred(targetPlayer, oldFaction)
    -- Custom transfer logic
    targetPlayer:notify("Welcome to our faction!")
end
```

---

### FACTION:NameTemplate

**Purpose**

Generates a custom character name before defaults are applied.

**Parameters**

* `client` (*Player*): The player creating the character.

**Returns**

* `string`, `boolean` (*string*, *boolean*): Generated name and whether to bypass default naming.

**Realm**

Shared.

**Example Usage**

```lua
function FACTION:NameTemplate(client)
    -- Prefix a random callsign with the faction name.
    local id = math.random(100, 999)
    return string.format("%s-%03d", self.name, id), true
end
```

---

### FACTION:GetDefaultName

**Purpose**

Retrieves the default character name for this faction.

**Parameters**

* `client` (*Player*): The client requesting the name.

**Returns**

* `string` (*string*): The generated name.

**Realm**

Shared.

**Example Usage**

```lua
function FACTION:GetDefaultName(client)
    -- Base the callsign on the player's account ID for consistency.
    return "Recruit-" .. client:AccountID()
end
```

---

### FACTION:GetDefaultDesc

**Purpose**

Provides the default description for a newly created character.

**Parameters**

* `client` (*Player*): The client for whom the description is generated.

**Returns**

* `string`, `boolean` (*string*, *boolean*): The description text and whether to override the user input.

**Realm**

Shared.

**Example Usage**

```lua
function FACTION:GetDefaultDesc(client)
    -- Use the name as part of a simple biography.
    local callsign = self:GetDefaultName(client)
    -- Returning true overrides any description entered by the player.
    return string.format("%s recently enlisted and is eager for duty.", callsign), true
end
```

---

### FACTION:OnCheckLimitReached

**Purpose**

Determines if the faction has reached its player limit.

**Parameters**

* `character` (*Character*): The character attempting to join.
* `client` (*Player*): The owner of that character.

**Returns**

* `boolean` (*boolean*): Whether the limit is reached.

**Realm**

Shared.

**Example Usage**

```lua
function FACTION:OnCheckLimitReached(character, client)
    -- Allow admins to bypass the limit.
    if client:IsAdmin() then
        return false
    end

    local maxMembers = self.limit or 10
    return lia.faction.getPlayerCount(self.index) >= maxMembers
end
```

---

## Example

The snippet below shows a minimal faction script using many of the fields described above.

```lua
FACTION.name = "Citizens"
FACTION.desc = "Everyday city dwellers."
FACTION.color = Color(75, 150, 50)
FACTION.isDefault = true
FACTION.models = {
    "models/Humans/Group01/male_01.mdl",
    "models/Humans/Group01/female_01.mdl"
}
FACTION.logo = "materials/factions/citizen_logo.png"
FACTION.prefix = "[CIT]"
FACTION.weapons = {"radio"}
FACTION.items = {"water"}
FACTION.pay = 20
FACTION.health = 100
FACTION.armor = 0
FACTION.runSpeed = 200
FACTION.walkSpeed = 100
FACTION.jumpPower = 160
FACTION.NPCRelations = {
    ["npc_metropolice"] = D_HT
}

FACTION_CITIZEN = FACTION.index
```
```