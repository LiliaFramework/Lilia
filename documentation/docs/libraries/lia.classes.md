# Classes Library

Character class management and validation system for the Lilia framework.

---

Overview

The classes library provides comprehensive functionality for managing character classes in the Lilia framework. It handles registration, validation, and management of player classes within factions. The library operates on both server and client sides, allowing for dynamic class creation, whitelist management, and player class assignment validation. It includes functionality for loading classes from directories, checking class availability, retrieving class information, and managing class limits. The library ensures proper faction validation and provides hooks for custom class behavior and restrictions.

---

### register

**Purpose**

Registers a new character class with the specified unique ID and data

**When Called**

During gamemode initialization or when dynamically creating classes

**Parameters**

* `uniqueID` (*string*): Unique identifier for the class
* `data` (*table*): Table containing class properties (name, desc, limit, faction, etc.)

**Returns**

* The registered class table

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
lia.class.register("citizen", {
name = "Citizen",
desc = "A regular citizen",
faction = FACTION_CITIZEN,
limit = 0
})

```

**Medium Complexity:**
```lua
lia.class.register("police_officer", {
name = "Police Officer",
desc = "A law enforcement officer",
faction = FACTION_POLICE,
limit = 5,
OnCanBe = function(self, client)
return client:getChar():getAttrib("strength", 0) >= 10
end
})

```

**High Complexity:**
```lua
local classData = {
name = "Elite Soldier",
desc = "A highly trained military operative",
faction = FACTION_MILITARY,
limit = 2,
isWhitelisted = true,
OnCanBe = function(self, client)
local char = client:getChar()
return char:getAttrib("strength", 0) >= 15 and
char:getAttrib("endurance", 0) >= 12 and
client:IsAdmin()
end,
OnSpawn = function(self, client)
client:Give("weapon_ar2")
client:SetHealth(150)
end
}
lia.class.register("elite_soldier", classData)

```

---

### loadFromDir

**Purpose**

Loads character classes from a directory containing class definition files

**When Called**

During gamemode initialization to load classes from files

**Parameters**

* `directory` (*string*): Path to directory containing class files

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
lia.class.loadFromDir("gamemodes/lilia/classes")

```

**Medium Complexity:**
```lua
local classDir = "gamemodes/lilia/modules/custom_classes/classes"
if file.Exists(classDir, "LUA") then
    lia.class.loadFromDir(classDir)
end

```

**High Complexity:**
```lua
local classDirectories = {
"gamemodes/lilia/classes",
"gamemodes/lilia/modules/factions/classes",
"gamemodes/lilia/modules/custom_classes/classes"
}
for _, dir in ipairs(classDirectories) do
    if file.Exists(dir, "LUA") then
        print("Loading classes from: " .. dir)
        lia.class.loadFromDir(dir)
    end
end

```

---

### canBe

**Purpose**

Checks if a client can join a specific character class

**When Called**

When a player attempts to join a class or when checking class availability

**Parameters**

* `client` (*Player*): The player attempting to join the class
* `class` (*number*): The class index to check

**Returns**

* boolean, string - Whether the player can join and reason if they cannot

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local canJoin, reason = lia.class.canBe(client, 1)
if canJoin then
    print("Player can join class")
    else
        print("Cannot join: " .. reason)
    end

```

**Medium Complexity:**
```lua
local function checkClassAvailability(client, className)
    local classIndex = lia.class.retrieveClass(className)
    if not classIndex then
        return false, "Class not found"
    end
    local canJoin, reason = lia.class.canBe(client, classIndex)
    return canJoin, reason
end

```

**High Complexity:**
```lua
local function validateClassSwitch(client, newClass)
    local currentChar = client:getChar()
    if not currentChar then
        return false, "No character"
    end
    local currentClass = currentChar:getClass()
    if currentClass == newClass then
        return false, "Already in this class"
    end
    local canJoin, reason = lia.class.canBe(client, newClass)
    if not canJoin then
        return false, reason
    end
    -- Additional custom validation
    if hook.Run("CustomClassValidation", client, newClass) == false then
        return false, "Custom validation failed"
    end
    return true, "Valid"
end

```

---

### get

**Purpose**

Retrieves a character class by its identifier (index or uniqueID)

**When Called**

When needing to access class information or properties

**Parameters**

* `identifier` (*number/string*): Class index or uniqueID to retrieve

**Returns**

* table - The class data table or nil if not found

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local class = lia.class.get(1)
if class then
    print("Class name: " .. class.name)
end

```

**Medium Complexity:**
```lua
local function getClassInfo(identifier)
    local class = lia.class.get(identifier)
    if not class then
        return nil, "Class not found"
    end
    return {
    name = class.name,
    description = class.desc,
    limit = class.limit,
    faction = class.faction
    }
end

```

**High Complexity:**
```lua
local function getClassDetails(identifier)
    local class = lia.class.get(identifier)
    if not class then
        return nil, "Class not found"
    end
    local players = lia.class.getPlayers(identifier)
    local playerCount = #players
    return {
    info = class,
    currentPlayers = players,
    playerCount = playerCount,
    isAvailable = class.limit == 0 or playerCount < class.limit,
    isWhitelisted = class.isWhitelisted or false,
    canJoin = function(client)
    return lia.class.canBe(client, identifier)
end
}
end

```

---

### getPlayers

**Purpose**

Gets all players currently using a specific character class

**When Called**

When needing to find players in a particular class or check class population

**Parameters**

* `class` (*number*): The class index to get players for

**Returns**

* table - Array of player entities in the specified class

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local players = lia.class.getPlayers(1)
print("Players in class 1: " .. #players)

```

**Medium Complexity:**
```lua
local function getClassMembers(className)
    local classIndex = lia.class.retrieveClass(className)
    if not classIndex then
        return {}
    end
    local players = lia.class.getPlayers(classIndex)
    local memberNames = {}
    for _, player in ipairs(players) do
        table.insert(memberNames, player:Name())
    end
    return memberNames
end

```

**High Complexity:**
```lua
local function getClassStatistics(classIndex)
    local players = lia.class.getPlayers(classIndex)
    local stats = {
    count = #players,
    players = {},
    onlineTime = 0,
    averageLevel = 0
    }
    for _, player in ipairs(players) do
        local char = player:getChar()
        if char then
            table.insert(stats.players, {
            name = player:Name(),
            level = char:getLevel(),
            playtime = char:getPlayTime()
            })
            stats.onlineTime = stats.onlineTime + char:getPlayTime()
        end
    end
    if stats.count > 0 then
        stats.averageLevel = stats.onlineTime / stats.count
    end
    return stats
end

```

---

### getPlayerCount

**Purpose**

Gets the count of players currently using a specific character class

**When Called**

When needing to check class population without retrieving player objects

**Parameters**

* `class` (*number*): The class index to count players for

**Returns**

* number - Number of players in the specified class

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local count = lia.class.getPlayerCount(1)
print("Players in class: " .. count)

```

**Medium Complexity:**
```lua
local function checkClassAvailability(classIndex)
    local class = lia.class.get(classIndex)
    if not class then
        return false, "Class not found"
    end
    local currentCount = lia.class.getPlayerCount(classIndex)
    local isFull = class.limit > 0 and currentCount >= class.limit
    return not isFull, isFull and "Class is full" or "Available"
end

```

**High Complexity:**
```lua
local function getClassPopulationReport()
    local report = {}
    for i, class in ipairs(lia.class.list) do
        local count = lia.class.getPlayerCount(i)
        local percentage = 0
        if class.limit > 0 then
            percentage = (count / class.limit) * 100
        end
        table.insert(report, {
        name = class.name,
        currentCount = count,
        limit = class.limit,
        percentage = percentage,
        isFull = class.limit > 0 and count >= class.limit,
        faction = class.faction
        })
    end
    return report
end

```

---

### retrieveClass

**Purpose**

Finds a class by matching its uniqueID or name with a search string

**When Called**

When needing to find a class by name or partial identifier

**Parameters**

* `class` (*string*): String to match against class uniqueID or name

**Returns**

* number - The class index if found, nil otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local classIndex = lia.class.retrieveClass("citizen")
if classIndex then
    print("Found class at index: " .. classIndex)
end

```

**Medium Complexity:**
```lua
local function findClassByName(searchTerm)
    local classIndex = lia.class.retrieveClass(searchTerm)
    if not classIndex then
        return nil, "Class '" .. searchTerm .. "' not found"
    end
    local class = lia.class.get(classIndex)
    return classIndex, class
end

```

**High Complexity:**
```lua
local function searchClasses(searchTerm)
    local results = {}
    local term = string.lower(searchTerm)
    for i, class in ipairs(lia.class.list) do
        local uniqueID = string.lower(class.uniqueID or "")
        local name = string.lower(class.name or "")
        if string.find(uniqueID, term) or string.find(name, term) then
            table.insert(results, {
            index = i,
            class = class,
            matchType = string.find(uniqueID, term) and "uniqueID" or "name"
            })
        end
    end
    return results
end

```

---

### hasWhitelist

**Purpose**

Checks if a character class has whitelist restrictions

**When Called**

When checking if a class requires special permissions or whitelist access

**Parameters**

* `class` (*number*): The class index to check for whitelist

**Returns**

* boolean - True if the class has whitelist restrictions, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local hasWhitelist = lia.class.hasWhitelist(1)
if hasWhitelist then
    print("This class requires whitelist")
end

```

**Medium Complexity:**
```lua
local function checkClassAccess(client, classIndex)
    local class = lia.class.get(classIndex)
    if not class then
        return false, "Class not found"
    end
    if lia.class.hasWhitelist(classIndex) then
        -- Check if player has whitelist access
        local hasAccess = client:IsAdmin() or client:IsSuperAdmin()
        return hasAccess, hasAccess and "Access granted" or "Whitelist required"
    end
    return true, "No whitelist required"
end

```

**High Complexity:**
```lua
local function getWhitelistClasses()
    local whitelistClasses = {}
    local regularClasses = {}
    for i, class in ipairs(lia.class.list) do
        if lia.class.hasWhitelist(i) then
            table.insert(whitelistClasses, {
            index = i,
            class = class,
            requiredPermissions = class.requiredPermissions or {}
            })
            else
                table.insert(regularClasses, {
                index = i,
                class = class
                })
            end
        end
        return {
        whitelist = whitelistClasses,
        regular = regularClasses,
        totalWhitelist = #whitelistClasses,
        totalRegular = #regularClasses
        }
    end

```

---

### retrieveJoinable

**Purpose**

Retrieves all classes that a specific client can join

**When Called**

When displaying available classes to a player or checking joinable options

**Parameters**

* `client` (*Player*): The player to check joinable classes for (optional, defaults to LocalPlayer on client)

**Returns**

* table - Array of class tables that the client can join

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
local joinableClasses = lia.class.retrieveJoinable(client)
print("Player can join " .. #joinableClasses .. " classes")

```

**Medium Complexity:**
```lua
local function getJoinableClassNames(client)
    local joinableClasses = lia.class.retrieveJoinable(client)
    local classNames = {}
    for _, class in ipairs(joinableClasses) do
        table.insert(classNames, class.name)
    end
    return classNames
end

```

**High Complexity:**
```lua
local function getDetailedJoinableClasses(client)
    local joinableClasses = lia.class.retrieveJoinable(client)
    local detailedClasses = {}
    for _, class in ipairs(joinableClasses) do
        local playerCount = lia.class.getPlayerCount(class.index)
        local isFull = class.limit > 0 and playerCount >= class.limit
        table.insert(detailedClasses, {
        class = class,
        playerCount = playerCount,
        limit = class.limit,
        isFull = isFull,
        availability = isFull and "Full" or "Available",
        requiresWhitelist = lia.class.hasWhitelist(class.index)
        })
    end
    -- Sort by availability and name
    table.sort(detailedClasses, function(a, b)
    if a.isFull ~= b.isFull then
        return not a.isFull -- Available classes first
    end
    return a.class.name < b.class.name
end)
return detailedClasses
end

```

---

