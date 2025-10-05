# Classes Library

This page documents the functions for working with character classes and job management.

---

## Overview

The classes library (`lia.class`) provides a comprehensive system for managing character classes, jobs, and roles in the Lilia framework, serving as the core job and role management system that enables diverse character specializations and structured roleplay scenarios. This library handles sophisticated class management with support for multiple class types, complex class hierarchies, and dynamic class assignment that enables rich character customization and specialized gameplay experiences. The system features advanced class registration with support for custom class creation, class validation, and seamless integration with the framework's faction and permission systems that ensure balanced and consistent roleplay opportunities. It includes comprehensive class validation with support for whitelist management, class requirements, and dynamic class availability that adapts to server configuration and player progression. The library provides robust class operations with support for class switching, class-specific abilities, and comprehensive class data management that maintains character progression and roleplay consistency. Additional features include integration with the framework's economy system for class-specific rewards, performance optimization for large class databases, and comprehensive administrative tools that enable effective class management and balanced gameplay experiences, making it essential for creating engaging roleplay scenarios that provide meaningful character progression and diverse gameplay opportunities for players.

---

### register

**Purpose**

Registers a new character class with the system.

**Parameters**

* `uniqueID` (*string*): The unique identifier for the class.
* `data` (*table*): The class configuration data.

**Returns**

* `class` (*table*): The registered class object.

**Realm**

Shared.

**Example Usage**

```lua
-- Register a basic class
lia.class.register("citizen", {
    name = "Citizen",
    desc = "A regular citizen",
    faction = "Citizen",
    limit = 0,
    isDefault = true,
    OnCanBe = function(client)
        return true
    end
})

-- Register a limited class
lia.class.register("police", {
    name = "Police Officer",
    desc = "A law enforcement officer",
    faction = "Police",
    limit = 5,
    isDefault = false,
    isWhitelisted = true,
    OnCanBe = function(client)
        local char = client:getChar()
        return char and char:hasFlags("p")
    end
})

-- Register a VIP class
lia.class.register("vip", {
    name = "VIP Member",
    desc = "A special VIP member",
    faction = "VIP",
    limit = 10,
    isDefault = false,
    isWhitelisted = true,
    OnCanBe = function(client)
        return client:hasPrivilege("vipClass")
    end
})

-- Register a class with custom properties
lia.class.register("medic", {
    name = "Medic",
    desc = "A medical professional",
    faction = "Medical",
    limit = 3,
    isDefault = false,
    weapons = {"weapon_medkit"},
    OnCanBe = function(client)
        local char = client:getChar()
        return char and char:hasFlags("m")
    end,
    OnSet = function(client, character)
        -- Custom logic when class is set
        client:Give("weapon_medkit")
    end
})
```

---

### loadFromDir

**Purpose**

Loads class definitions from a directory containing class files.

**Parameters**

* `directory` (*string*): The directory path to load class files from.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Load classes from a directory
lia.class.loadFromDir("gamemode/classes")

-- Load from a custom classes folder
lia.class.loadFromDir("addons/myaddon/classes")

-- Load from schema classes
lia.class.loadFromDir("schema/classes")

-- Load from multiple directories
lia.class.loadFromDir("gamemode/classes")
lia.class.loadFromDir("addons/customclasses/classes")
```

---

### canBe

**Purpose**

Checks if a client can join a specific class.

**Parameters**

* `client` (*Player*): The client to check.
* `class` (*number*): The class index to check.

**Returns**

* `canBe` (*boolean*): True if the client can join the class.
* `reason` (*string*): The reason if the client cannot join.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if client can be a specific class
local canBe, reason = lia.class.canBe(client, 1)
if canBe then
    print("Client can join class 1")
else
    print("Cannot join class 1:", reason)
end

-- Check multiple classes
for i = 1, #lia.class.list do
    local canBe, reason = lia.class.canBe(client, i)
    if canBe then
        print("Client can join class " .. i)
    end
end

-- Use in a command
lia.command.add("checkclass", {
    arguments = {
        {name = "class", type = "number"}
    },
    onRun = function(client, arguments)
        local canBe, reason = lia.class.canBe(client, arguments[1])
        if canBe then
            client:notify("You can join this class")
        else
            client:notify("Cannot join: " .. reason)
        end
    end
})
```

---

### get

**Purpose**

Retrieves a class by its identifier (index or uniqueID).

**Parameters**

* `identifier` (*number|string*): The class index or uniqueID.

**Returns**

* `class` (*table*): The class object if found, nil otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Get class by index
local class = lia.class.get(1)
if class then
    print("Class name:", class.name)
end

-- Get class by uniqueID
local class = lia.class.get("police")
if class then
    print("Police class found:", class.name)
end

-- Use in a function
local function getClassInfo(identifier)
    local class = lia.class.get(identifier)
    if class then
        return {
            name = class.name,
            desc = class.desc,
            limit = class.limit
        }
    end
    return nil
end
```

---

### getPlayers

**Purpose**

Gets all players currently in a specific class.

**Parameters**

* `class` (*number*): The class index to get players for.

**Returns**

* `players` (*table*): Table of players in the class.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all players in class 1
local players = lia.class.getPlayers(1)
print("Players in class 1:", #players)

-- Get all police officers
local policeClass = lia.class.get("police")
if policeClass then
    local police = lia.class.getPlayers(policeClass.index)
    print("Police officers online:", #police)
end

-- Use in a command
lia.command.add("listclass", {
    arguments = {
        {name = "class", type = "number"}
    },
    onRun = function(client, arguments)
        local players = lia.class.getPlayers(arguments[1])
        client:notify("Players in class: " .. #players)
    end
})
```

---

### getPlayerCount

**Purpose**

Gets the number of players currently in a specific class.

**Parameters**

* `class` (*number*): The class index to count players for.

**Returns**

* `count` (*number*): The number of players in the class.

**Realm**

Shared.

**Example Usage**

```lua
-- Get player count for class 1
local count = lia.class.getPlayerCount(1)
print("Players in class 1:", count)

-- Check if class is full
local class = lia.class.get("police")
if class then
    local count = lia.class.getPlayerCount(class.index)
    if count >= class.limit then
        print("Police class is full!")
    end
end

-- Use in a function
local function isClassFull(classIndex)
    local class = lia.class.get(classIndex)
    if class and class.limit > 0 then
        return lia.class.getPlayerCount(classIndex) >= class.limit
    end
    return false
end
```

---

### retrieveClass

**Purpose**

Retrieves a class by searching for a matching name or uniqueID.

**Parameters**

* `class` (*string*): The class name or uniqueID to search for.

**Returns**

* `classIndex` (*number*): The class index if found, nil otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Find class by name
local classIndex = lia.class.retrieveClass("Police Officer")
if classIndex then
    print("Found class at index:", classIndex)
end

-- Find class by uniqueID
local classIndex = lia.class.retrieveClass("police")
if classIndex then
    print("Found police class at index:", classIndex)
end

-- Use in a command
lia.command.add("findclass", {
    arguments = {
        {name = "name", type = "string"}
    },
    onRun = function(client, arguments)
        local classIndex = lia.class.retrieveClass(arguments[1])
        if classIndex then
            client:notify("Found class at index: " .. classIndex)
        else
            client:notify("Class not found")
        end
    end
})
```

---

### hasWhitelist

**Purpose**

Checks if a class requires whitelist access.

**Parameters**

* `class` (*number*): The class index to check.

**Returns**

* `hasWhitelist` (*boolean*): True if the class requires whitelist, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if class requires whitelist
local class = lia.class.get("police")
if class then
    local hasWhitelist = lia.class.hasWhitelist(class.index)
    if hasWhitelist then
        print("Police class requires whitelist")
    end
end

-- Check multiple classes
for i = 1, #lia.class.list do
    if lia.class.hasWhitelist(i) then
        print("Class " .. i .. " requires whitelist")
    end
end

-- Use in a function
local function isWhitelistedClass(classIndex)
    return lia.class.hasWhitelist(classIndex)
end
```

---

### retrieveJoinable

**Purpose**

Retrieves all classes that a client can join.

**Parameters**

* `client` (*Player*): The client to check joinable classes for.

**Returns**

* `classes` (*table*): Table of joinable classes.

**Realm**

Shared.

**Example Usage**

```lua
-- Get joinable classes for a client
local classes = lia.class.retrieveJoinable(client)
print("Client can join " .. #classes .. " classes")

-- Display joinable classes
for _, class in ipairs(classes) do
    print("Can join:", class.name)
end

-- Use in a command
lia.command.add("listjoinable", {
    onRun = function(client, arguments)
        local classes = lia.class.retrieveJoinable(client)
        client:notify("You can join " .. #classes .. " classes")
    end
})

-- Use in a menu
local function buildClassMenu(client)
    local classes = lia.class.retrieveJoinable(client)
    for _, class in ipairs(classes) do
        -- Add class to menu
        print("Adding class to menu:", class.name)
    end
end

---

## Definitions

# Class Fields

This document describes all configurable `CLASS` fields in the codebase. Each field controls a specific aspect of how a class behaves, appears, or is granted to players. Unspecified fields will use sensible defaults.

---

## Overview

The global `CLASS` table defines per-class settings such as display name, lore, starting equipment, pay parameters, movement speeds, and visual appearance. Use these fields to fully customize each class's behavior and presentation.

---

### CLASS.name

**Type:**

`string`

**Description:**

The displayed name of the class.

**Example Usage:**

```lua
CLASS.name = "Engineer"
```

---

### CLASS.desc

**Type:**

`string`

**Description:**

The description or lore of the class.

**Example Usage:**

```lua
CLASS.desc = "Technicians who maintain equipment."
```

---

### CLASS.uniqueID

**Type:**

`string`

**Description:**

Internal identifier used when referencing the class. If omitted, it defaults to the file name this class was loaded from.

**Example Usage:**

```lua
CLASS.uniqueID = "engineer"
```

---

### CLASS.index

**Type:**

`number`

**Description:**

Unique numeric identifier (team index) for the class.

**Example Usage:**

```lua
CLASS.index = CLASS_ENGINEER
```

---

### CLASS.isDefault

**Type:**

`boolean`

**Description:**

Determines if the class is available to all players by default.

**Example Usage:**

```lua
CLASS.isDefault = true
```

---

### CLASS.isWhitelisted

**Type:**

`boolean`

**Description:**

Indicates if the class requires a whitelist entry to be accessible.

**Example Usage:**

```lua
CLASS.isWhitelisted = false
```

---

### CLASS.faction

**Type:**

`number`

**Description:**

Links this class to a specific faction index. This field is required; registration fails if the faction is missing or invalid.

**Example Usage:**

```lua
CLASS.faction = FACTION_CITIZEN
```

---

### CLASS.color

**Type:**

`Color`

**Description:**

UI color representing the class. When omitted, the faction's color is used.

**Example Usage:**

```lua
CLASS.color = Color(255, 0, 0)
```

---

### CLASS.weapons

**Type:**

`string` or `table`

**Description:**

Weapons granted to members of this class on spawn. Supply a single weapon class or a table of weapon class strings.

**Example Usage:**

```lua
-- give two weapons
CLASS.weapons = {"weapon_pistol", "weapon_crowbar"}
-- or grant one weapon
CLASS.weapons = "weapon_pistol"
```

### CLASS.pay

**Type:**

`number`

**Description:**

Payment amount issued per pay interval.

**Example Usage:**

```lua
CLASS.pay = 50
```

---

### CLASS.payLimit

**Type:**

`number`

**Description:**

Maximum accumulated pay a player can hold.

**Example Usage:**

```lua
CLASS.payLimit = 1000
```

---

---

### CLASS.limit

**Type:**

`number`

**Description:**

Maximum number of players allowed in this class simultaneously.

**Example Usage:**

```lua
CLASS.limit = 10
```

---

### CLASS.health

**Type:**

`number`

**Description:**

Overrides the player's starting health when they spawn as this class. If omitted, health is unchanged.

**Example Usage:**

```lua
CLASS.health = 150
```

---

### CLASS.armor

**Type:**

`number`

**Description:**

Overrides the player's starting armor. If omitted, armor remains unchanged.

**Example Usage:**

```lua
CLASS.armor = 50
```

---

### CLASS.scale

**Type:**

`number`

**Description:**

Multiplier for player model size.

**Example Usage:**

```lua
CLASS.scale = 1.2
```

---

### CLASS.runSpeed

**Type:**

`number`

**Description:**

Overrides or multiplies the player's running speed. Set a number to replace the speed or a multiplier when used with `runSpeedMultiplier`. If unset, the run speed is unchanged.

**Example Usage:**

```lua
-- explicit speed value
CLASS.runSpeed = 250
OR
-- 25% faster than the base run speed
CLASS.runSpeed = 1.25
CLASS.runSpeedMultiplier = true
```

---

### CLASS.runSpeedMultiplier

**Type:**

`boolean`

**Description:**

Multiply base run speed instead of replacing it.

**Example Usage:**

```lua
CLASS.runSpeedMultiplier = true
```

---

### CLASS.walkSpeed

**Type:**

`number`

**Description:**

Overrides or multiplies the player's walking speed. If unset, the walk speed is unchanged.

**Example Usage:**

```lua
CLASS.walkSpeed = 200
```

---

### CLASS.walkSpeedMultiplier

**Type:**

`boolean`

**Description:**

Multiply base walk speed instead of replacing it.

**Example Usage:**

```lua
CLASS.walkSpeedMultiplier = false
```

---

### CLASS.jumpPower

**Type:**

`number`

**Description:**

Overrides or multiplies the player's jump power. If unset, the jump power is unchanged.

**Example Usage:**

```lua
CLASS.jumpPower = 200
```

---

### CLASS.jumpPowerMultiplier

**Type:**

`boolean`

**Description:**

Multiply base jump power instead of replacing it.

**Example Usage:**

```lua
CLASS.jumpPowerMultiplier = true
```

---

### CLASS.bloodcolor

**Type:**

`number`

**Description:**

Blood color enumeration constant for this class.

**Example Usage:**

```lua
CLASS.bloodcolor = BLOOD_COLOR_RED
```

---

### CLASS.logo

**Type:**

`string`

**Description:**

Path to the material used as this class's logo. When `nil`, no logo is displayed in the scoreboard or F1 menu.

**Example Usage:**

```lua
CLASS.logo = "materials/example/eng_logo.png"
```

---

### CLASS.scoreboardHidden

**Type:**

`boolean`

**Description:**

If `true`, this class will not display a header or logo on the scoreboard.

**Example Usage:**

```lua
CLASS.scoreboardHidden = true
```

---

### CLASS.skin

**Type:**

`number`

**Description:**

Model skin index to apply to members of this class.

**Example Usage:**

```lua
CLASS.skin = 2
```

---

### CLASS.subMaterials

**Type:**

`table`

**Description:**

List of material paths that replace the model's sub-materials. The first entry applies to sub-material `0`, the second to `1`, and so on. Leave `nil` for no overrides.

**Example Usage:**

```lua
CLASS.subMaterials = {
    "models/example/custom_cloth", -- sub-material 0
    "models/example/custom_armor" -- sub-material 1
}
```

---

### CLASS.model

**Type:**

`string` or `table`

**Description:**

Model path (or list of paths) assigned to this class. When omitted, the character's existing model is used.

**Example Usage:**

```lua
CLASS.model = "models/player/alyx.mdl"
```

---

### CLASS.requirements

**Type:**

`string` or `table`

**Description:**

Text displayed to the player describing what is needed to join this class. Accepts a string or list of strings. This field does not restrict access on its own.

**Example Usage:**

```lua
-- single requirement string
CLASS.requirements = "Flag V"
-- or list multiple requirements
CLASS.requirements = {"Flag V", "Engineering 25+"}
```

---

### CLASS.commands

**Type:**

`table`

**Description:**

Table of command names that members of this class may always use,

overriding standard command permissions. If omitted, no extra commands are granted.

**Example Usage:**

```lua
CLASS.commands = {
    plytransfer = true,
}
```

### CLASS.canInviteToFaction

**Type:**

`boolean`

**Description:**

Whether members of this class can invite players to join their faction.

**Example Usage:**

```lua
CLASS.canInviteToFaction = true
```

---

### CLASS.canInviteToClass

**Type:**

`boolean`

**Description:**

Whether members of this class can invite players to join this class.

**Example Usage:**

```lua
CLASS.canInviteToClass = true
```

---

### CLASS.OnCanBe(client)

**Type:**

`function`

**Description:**

Optional callback executed when a player attempts to join the class. `self` is the class table. Return `false` to block the player from joining.

**Example Usage:**

```lua
function CLASS:OnCanBe(client)
    return client:IsAdmin()
end
```

---

## Example

```lua
-- schema/classes/engineer.lua
CLASS.name = "Engineer"
CLASS.desc = "Technicians who maintain complex machinery."
CLASS.faction = FACTION_CITIZEN
CLASS.isDefault = true
CLASS.color = Color(150, 150, 255)
CLASS.weapons = {"weapon_pistol", "weapon_crowbar"}
CLASS.pay = 25
CLASS.payLimit = 250
CLASS.limit = 5
CLASS.health = 120
CLASS.armor = 25
CLASS.scale = 1
CLASS.runSpeed = 1.1
CLASS.runSpeedMultiplier = true
CLASS.walkSpeed = 1
CLASS.walkSpeedMultiplier = true
CLASS.jumpPower = 200
CLASS.jumpPowerMultiplier = false
CLASS.logo = "materials/example/eng_logo.png"
CLASS.scoreboardHidden = true
CLASS.skin = 0
CLASS.subMaterials = {
    "models/example/custom_cloth", -- sub-material 0
    "models/example/custom_armor" -- sub-material 1
}
CLASS.model = {
    "models/player/Group03/male_07.mdl",
    "models/player/Group03/female_02.mdl"
}
CLASS.requirements = "Flag V"
CLASS.isWhitelisted = false
CLASS.uniqueID = "engineer"
CLASS.index = CLASS_ENGINEER
CLASS.bloodcolor = BLOOD_COLOR_RED
CLASS.commands = {
    plytransfer = true
}
CLASS.canInviteToFaction = true
CLASS.canInviteToClass = true
```

---

### CLASS:OnCanBe

**Purpose**

Determines whether a player is allowed to switch to this class.

**Parameters**

* `client` (*Player*): The player attempting to switch.

**Returns**

* `boolean?` (*boolean*): Return `false` to deny the change.

**Realm**

Server.

**Example Usage**

```lua
function CLASS:OnCanBe(client)
    -- Only allow admins or players that own the "V" flag.
    if client:IsAdmin() then
        return true
    end

    local char = client:getChar()
    if char and char:hasFlags("V") then
        return true
    end

    -- Returning false prevents the switch.
    return false
end
```

---

### CLASS:OnLeave

**Purpose**

Runs on the previous class after a player successfully changes classes.

**Parameters**

* `client` (*Player*): The player who has left the class.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

Server.

**Example Usage**

```lua
function CLASS:OnLeave(client)
    -- Strip any class-specific weapons.
    client:StripWeapon("weapon_pistol")

    -- Restore the player's previous model before the class change.
    local char = client:getChar()
    if char and self.model then
        char:setModel(char:getData("model", char:getModel()))
    end

    -- Reset movement speeds back to the config defaults.
    client:SetWalkSpeed(lia.config.get("WalkSpeed"))
    client:SetRunSpeed(lia.config.get("RunSpeed"))
end
```

---

### CLASS:OnSet

**Purpose**

Executes immediately after a player joins this class.

**Parameters**

* `client` (*Player*): The player who has joined the class.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

Server.

**Example Usage**

```lua
function CLASS:OnSet(client)
    local char = client:getChar()

    -- Apply the class model and give a starter pistol.
    if char and self.model then
        char:setModel(self.model)
    end
    client:Give("weapon_pistol")

    -- Initialize base stats from the class definition.
    if self.health then
        client:SetHealth(self.health)
        client:SetMaxHealth(self.health)
    end
    if self.armor then
        client:SetArmor(self.armor)
    end
end
```

---

### CLASS:OnSpawn

**Purpose**

Runs each time a member of this class respawns.

**Parameters**

* `client` (*Player*): The player who has just spawned.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

Server.

**Example Usage**

```lua
function CLASS:OnSpawn(client)
    -- Apply the class load-out and stats every respawn.
    client:SetMaxHealth(self.health or 150)
    client:SetHealth(client:GetMaxHealth())
    client:SetArmor(self.armor or 50)

    for _, wep in ipairs(self.weapons or {}) do
        client:Give(wep)
    end

    if self.runSpeed then
        client:SetRunSpeed(self.runSpeed)
    end
    if self.walkSpeed then
        client:SetWalkSpeed(self.walkSpeed)
    end
end
```

---

### CLASS:OnTransferred

**Purpose**

Fires when a player is moved into this class from another.

**Parameters**

* `client` (*Player*): The player who was transferred.
* `oldClass` (*number*): Index of the previous class.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

Server.

**Example Usage**

```lua
function CLASS:OnTransferred(client, oldClass)
    local char = client:getChar()
    if char and self.model then
        -- Swap the model to match the new class.
        char:setModel(self.model)
    end

    -- Record the previous class so we can switch back later if needed.
    char:setData("previousClass", oldClass)
end
```

---

## Example

```lua
-- schema/classes/engineer.lua
CLASS.name = "Engineer"
CLASS.desc = "Technicians who maintain complex machinery."
CLASS.faction = FACTION_CITIZEN
CLASS.isDefault = true
CLASS.color = Color(150, 150, 255)
CLASS.weapons = {"weapon_pistol", "weapon_crowbar"}
CLASS.pay = 25
CLASS.payLimit = 250
CLASS.limit = 5
CLASS.health = 120
CLASS.armor = 25
CLASS.scale = 1
CLASS.runSpeed = 1.1
CLASS.runSpeedMultiplier = true
CLASS.walkSpeed = 1
CLASS.walkSpeedMultiplier = true
CLASS.jumpPower = 200
CLASS.jumpPowerMultiplier = false
CLASS.logo = "materials/example/eng_logo.png"
CLASS.scoreboardHidden = true
CLASS.skin = 0
CLASS.subMaterials = {
    "models/example/custom_cloth", -- sub-material 0
    "models/example/custom_armor" -- sub-material 1
}
CLASS.model = {
    "models/player/Group03/male_07.mdl",
    "models/player/Group03/female_02.mdl"
}
CLASS.requirements = "Flag V"
CLASS.isWhitelisted = false
CLASS.uniqueID = "engineer"
CLASS.index = CLASS_ENGINEER
CLASS.bloodcolor = BLOOD_COLOR_RED
CLASS.commands = {
    plytransfer = true
}
CLASS.canInviteToFaction = true
CLASS.canInviteToClass = true
```
```