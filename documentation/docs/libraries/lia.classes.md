# Classes Library

This page documents the functions for working with character classes and job management.

---

## Overview

The classes library (`lia.class`) provides a comprehensive system for managing character classes, jobs, and roles in the Lilia framework, serving as the core job and role management system that enables diverse character specializations and structured roleplay scenarios. This library handles sophisticated class management with support for multiple class types, complex class hierarchies, and dynamic class assignment that enables rich character customization and specialized gameplay experiences. The system features advanced class registration with support for custom class creation, class validation, and seamless integration with the framework's faction and permission systems that ensure balanced and consistent roleplay opportunities. It includes comprehensive class validation with support for whitelist management, class requirements, and dynamic class availability that adapts to server configuration and player progression. The library provides robust class operations with support for class switching, class-specific abilities, and comprehensive class data management that maintains character progression and roleplay consistency. Additional features include integration with the framework's economy system for class-specific rewards, performance optimization for large class databases, and comprehensive administrative tools that enable effective class management and balanced gameplay experiences, making it essential for creating engaging roleplay scenarios that provide meaningful character progression and diverse gameplay opportunities for players.

---

### lia.class.register

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

### lia.class.loadFromDir

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

### lia.class.canBe

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

### lia.class.get

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

### lia.class.getPlayers

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

### lia.class.getPlayerCount

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

### lia.class.retrieveClass

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

### lia.class.hasWhitelist

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

### lia.class.retrieveJoinable

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
```