# Utility Library

Common operations and helper functions for the Lilia framework.

---

Overview

The utility library provides comprehensive functionality for common operations and helper functions used throughout the Lilia framework. It contains a wide range of utilities for player management, string processing, entity handling, UI operations, and general purpose calculations. The library is divided into server-side functions for game logic and data management, and client-side functions for user interface, visual effects, and player interaction. These utilities simplify complex operations, provide consistent behavior across the framework, and offer reusable components for modules and plugins. The library handles everything from player identification and spatial queries to advanced UI animations and text processing, ensuring robust and efficient operations across both server and client environments.

---

### lia.util.findPlayersInBox

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.getBySteamID

#### 📋 Purpose
Find a player by their Steam ID or Steam ID 64

#### ⏰ When Called
When you need to locate a specific player using their Steam identification for operations like bans, whitelists, or data retrieval

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `steamID` | **string** | The Steam ID (STEAM_0:0:123456) or Steam ID 64 to search for |

#### ↩️ Returns
* Player entity if found with a valid character, nil otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find player by Steam ID
    local player = lia.util.getBySteamID("STEAM_0:0:12345678")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check if player is online before performing action
    local targetPlayer = lia.util.getBySteamID(playerSteamID)
    if IsValid(targetPlayer) then
        targetPlayer:giveMoney(1000)
    else
        print("Player not found or offline")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Process multiple Steam IDs with validation
    local steamIDs = {"STEAM_0:0:123456", "STEAM_0:1:789012", "76561198012345678"}
    local foundPlayers = {}
    for _, steamID in ipairs(steamIDs) do
        local player = lia.util.getBySteamID(steamID)
        if IsValid(player) then
            foundPlayers[#foundPlayers + 1] = {
                steamID  = steamID,
                player   = player,
                charName = player:getChar():getName()
            }
        end
    end

```

---

### lia.util.findPlayersInSphere

#### 📋 Purpose
Find all players within a specified spherical radius from a center point

#### ⏰ When Called
When you need to find players in a circular area for proximity-based operations like damage, effects, or notifications

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `origin` | **Vector** | The center point of the sphere |
| `radius` | **number** | The radius of the sphere in units |

#### ↩️ Returns
* Table of player entities found within the spherical area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players within 500 units of a position
    local nearbyPlayers = lia.util.findPlayersInSphere(playerPos, 500)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Apply effect to players within radius
    local explosionPos = Vector(100, 200, 50)
    local affectedPlayers = lia.util.findPlayersInSphere(explosionPos, 300)
    for _, player in ipairs(affectedPlayers) do
        player:takeDamage(50)
        player:notify("Hit by explosion!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a zone system with multiple overlapping spheres
    local zones = {
        {center = Vector(0, 0, 0),      radius = 200, type = "safe"   },
        {center = Vector(500, 0, 0),    radius = 150, type = "danger" },
        {center = Vector(250, 250, 0),  radius = 100, type = "neutral"}
    }
    for _, player in player.GetAll() do
        local playerPos = player:GetPos()
        local inZone = {}
        for _, zone in ipairs(zones) do
            if playerPos:Distance(zone.center) <= zone.radius then
                inZone[zone.type] = true
            end
        end
        if inZone.danger and not inZone.safe then
            player:takeDamage(10)
        end
    end

```

---

### lia.util.findPlayer

#### 📋 Purpose
Find a player by various identifier types including Steam ID, Steam ID 64, name, or special selectors

#### ⏰ When Called
When you need to locate a specific player using flexible identification methods for commands, admin actions, or interactions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player requesting the search (for notifications and special selectors) |
| `identifier` | **string** | The identifier to search for (Steam ID, Steam ID 64, player name, "^" for self, "@" for looked-at player) |

#### ↩️ Returns
* Player entity if found, nil otherwise with appropriate error notifications

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find player by partial name
    local targetPlayer = lia.util.findPlayer(client, "John")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find player and perform action with error handling
    local targetPlayer = lia.util.findPlayer(client, targetSteamID)
    if targetPlayer then
        targetPlayer:giveMoney(100)
        client:notify("Gave money to " .. targetPlayer:Name())
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a player selection system with multiple methods
    local function selectPlayer(admin, identifier)
        -- Try Steam ID first
        local target = lia.util.findPlayer(admin, identifier)
        if not target then
            -- Try Steam ID 64
            if string.match(identifier, "^%d+$") and #identifier >= 17 then
                target = lia.util.findPlayer(admin, identifier)
            end
        end
        if not target then
            -- Try partial name match
            for _, ply in player.Iterator() do
                if string.find(ply:Name():lower(), identifier:lower()) then
                    target = ply
                    break
                end
            end
        end
        return target
    end

```

---

### lia.util.findPlayerItems

#### 📋 Purpose
Find all items created by a specific player in the world

#### ⏰ When Called
When you need to locate dropped items or spawned entities created by a particular player for cleanup, tracking, or management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose created items should be found |

#### ↩️ Returns
* Table of item entities created by the specified player

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find all items dropped by a player
    local playerItems = lia.util.findPlayerItems(somePlayer)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Clean up items after player disconnects
    local droppedItems = lia.util.findPlayerItems(disconnectingPlayer)
    for _, item in ipairs(droppedItems) do
        item:Remove()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create an item management system with ownership tracking
    local function managePlayerItems(player, action)
        local items = lia.util.findPlayerItems(player)
        for _, item in ipairs(items) do
            if action == "remove" then
                item:Remove()
            elseif action == "transfer" then
                item:SetCreator(newOwner)
            elseif action == "info" then
                print("Item: " .. item:getNetVar("id") .. " at " .. tostring(item:GetPos()))
            end
        end
    end

```

---

### lia.util.findPlayerItemsByClass

#### 📋 Purpose
Find all items of a specific class created by a particular player

#### ⏰ When Called
When you need to locate specific types of items created by a player for targeted operations like weapon cleanup or resource management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose created items should be found |
| `class` | **string** | The item class/type to filter by (e.g., "weapon_ar2", "item_healthkit") |

#### ↩️ Returns
* Table of item entities of the specified class created by the player

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find all weapons dropped by a player
    local droppedWeapons = lia.util.findPlayerItemsByClass(player, "weapon_ar2")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Remove specific item types after player death
    local healthKits = lia.util.findPlayerItemsByClass(deadPlayer, "item_healthkit")
    for _, kit in ipairs(healthKits) do
        kit:Remove()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create an inventory management system with class-based filtering
    local function cleanupPlayerItems(player, itemClasses)
        local removedCount = 0
        for _, class in ipairs(itemClasses) do
            local items = lia.util.findPlayerItemsByClass(player, class)
            for _, item in ipairs(items) do
                item:Remove()
                removedCount = removedCount + 1
            end
        end
        return removedCount
    end
    -- Usage
    local removed = cleanupPlayerItems(leavingPlayer, {"weapon_*", "item_*"})

```

---

### lia.util.findPlayerEntities

#### 📋 Purpose
Find all entities created by or associated with a specific player, optionally filtered by class

#### ⏰ When Called
When you need to locate entities spawned by a player for management, cleanup, or tracking purposes

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose entities should be found |
| `class` | **string** | Optional class name to filter entities (e.g., "prop_physics", "npc_zombie") |

#### ↩️ Returns
* Table of entities created by or associated with the specified player

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find all entities created by a player
    local playerEntities = lia.util.findPlayerEntities(somePlayer)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find specific entity types created by player
    local playerProps = lia.util.findPlayerEntities(player, "prop_physics")
    for _, prop in ipairs(playerProps) do
        prop:Remove()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create an entity management system with ownership tracking
    local function managePlayerEntities(player, action, classFilter)
        local entities = lia.util.findPlayerEntities(player, classFilter)
        local results = {removed = 0, modified = 0}
        for _, entity in ipairs(entities) do
            if action == "remove" then
                entity:Remove()
                results.removed = results.removed + 1
            elseif action == "freeze" then
                local phys = entity:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(false)
                    results.modified = results.modified + 1
                end
            end
        end
        return results
    end

```

---

### lia.util.stringMatches

#### 📋 Purpose
Check if two strings match using flexible comparison methods including case-insensitive and partial matching

#### ⏰ When Called
When you need to compare strings with flexible matching for search functionality, name validation, or text processing

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `a` | **string** | The first string to compare |
| `b` | **string** | The second string to compare (the search pattern) |

#### ↩️ Returns
* Boolean indicating if the strings match using any of the comparison methods

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check if strings are equal (case-insensitive)
    local matches = lia.util.stringMatches("Hello", "hello")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check if player name contains search term
    local function playerNameMatches(player, searchTerm)
        return lia.util.stringMatches(player:Name(), searchTerm)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a flexible search system with multiple criteria
    local function advancedStringSearch(text, searchTerms)
        local results = {}
        for _, term in ipairs(searchTerms) do
            if lia.util.stringMatches(text, term) then
                results[#results + 1] = {
                    text        = text,
                    matchedTerm = term,
                    matchType   = "partial"
                }
            end
        end
        return results
    end
    -- Usage
    local searchResults = advancedStringSearch("Player Name", {"player", "name", "test"})

```

---

### lia.util.getAdmins

#### 📋 Purpose
Get a list of all currently online administrators/staff members

#### ⏰ When Called
When you need to identify staff members for admin-only operations, notifications, or privilege checks

#### ↩️ Returns
* Table of player entities that are currently staff members

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get all online admins
    local admins = lia.util.getAdmins()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Send notification to all admins
    local admins = lia.util.getAdmins()
    for _, admin in ipairs(admins) do
        admin:notify("Server maintenance in 5 minutes!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create an admin monitoring system with activity tracking
    local function getActiveAdmins()
        local admins = lia.util.getAdmins()
        local activeAdmins = {}
        for _, admin in ipairs(admins) do
            if admin:isStaff() and admin:getChar() then
                activeAdmins[#activeAdmins + 1] = {
                    player   = admin,
                    steamID  = admin:SteamID(),
                    name     = admin:Name(),
                    lastSeen = CurTime()
                }
            end
        end
        return activeAdmins
    end
    -- Usage
    local activeStaff = getActiveAdmins()

```

---

### lia.util.findPlayerBySteamID64

#### 📋 Purpose
Find a player by their Steam ID 64, converting it to Steam ID format first

#### ⏰ When Called
When you need to locate a player using their Steam ID 64 for database operations or external integrations

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `SteamID64` | **string** | The Steam ID 64 to search for |

#### ↩️ Returns
* Player entity if found, nil otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find player by Steam ID 64
    local player = lia.util.findPlayerBySteamID64("76561198012345678")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check if Steam ID 64 is currently online
    local targetPlayer = lia.util.findPlayerBySteamID64(steamID64)
    if IsValid(targetPlayer) then
        print(targetPlayer:Name() .. " is currently online")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Process multiple Steam ID 64s for batch operations
    local steamID64s = {"76561198012345678", "76561198098765432", "76561198111111111"}
    local onlinePlayers = {}
    for _, steamID64 in ipairs(steamID64s) do
        local player = lia.util.findPlayerBySteamID64(steamID64)
        if IsValid(player) then
            onlinePlayers[#onlinePlayers + 1] = {
                steamID64 = steamID64,
                player    = player,
                character = player:getChar():getName()
            }
        end
    end

```

---

### lia.util.findPlayerBySteamID

#### 📋 Purpose
Find a player by their Steam ID

#### ⏰ When Called
When you need to locate a player using their Steam ID for admin actions, bans, or data retrieval

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `SteamID` | **string** | The Steam ID to search for (STEAM_0:0:123456 format) |

#### ↩️ Returns
* Player entity if found, nil otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find player by Steam ID
    local player = lia.util.findPlayerBySteamID("STEAM_0:0:12345678")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Verify player identity before action
    local targetPlayer = lia.util.findPlayerBySteamID(steamID)
    if IsValid(targetPlayer) and targetPlayer:getChar() then
        targetPlayer:kick("Reason for kick")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a player tracking system with Steam ID validation
    local function trackPlayerActivity(steamID)
        local player = lia.util.findPlayerBySteamID(steamID)
        if IsValid(player) then
            return {
                steamID   = steamID,
                name      = player:Name(),
                character = player:getChar():getName(),
                position  = player:GetPos(),
                status    = "online"
            }
        else
            return {
                steamID = steamID,
                status  = "offline"
            }
        end
    end

```

---

### lia.util.canFit

#### 📋 Purpose
Check if an entity can fit at a specific position without colliding with solid objects

#### ⏰ When Called
When you need to validate if an entity can be placed at a location for spawning, teleportation, or collision detection

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pos` | **Vector** | The position to check for entity placement |
| `mins` | **Vector** | Optional minimum bounding box coordinates (defaults to Vector(16, 16, 0)) |
| `maxs` | **Vector** | Optional maximum bounding box coordinates (defaults to mins value) |
| `filter` | **Entity/Table** | Optional entity or table of entities to ignore in collision detection |

#### ↩️ Returns
* Boolean indicating if the position is clear (true) or obstructed (false)

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check if player can fit at position
    local canTeleport = lia.util.canFit(targetPosition)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Validate spawn position for entity
    local spawnPos = Vector(100, 200, 50)
    if lia.util.canFit(spawnPos, Vector(-16, -16, 0), Vector(16, 16, 72)) then
        local npc = ents.Create("npc_zombie")
        npc:SetPos(spawnPos)
        npc:Spawn()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a smart placement system with multiple validation checks
    local function findValidPlacement(centerPos, entitySize, attempts)
        local validPositions = {}
        for i = 1, attempts do
            local randomOffset = Vector(
                math.random(-100, 100),
                math.random(-100, 100),
                0
            )
            local testPos = centerPos + randomOffset
            if lia.util.canFit(testPos, entitySize.mins, entitySize.maxs) then
                validPositions[#validPositions + 1] = testPos
            end
        end
        return validPositions
    end
    -- Usage
    local positions = findValidPlacement(playerPos, {mins = Vector(-16, -16, 0), maxs = Vector(16, 16, 72)}, 50)

```

---

### lia.util.playerInRadius

#### 📋 Purpose
Find all players within a specified radius from a center position

#### ⏰ When Called
When you need to find players in a circular area for proximity-based operations like damage, effects, or area management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pos` | **Vector** | The center position to check from |
| `dist` | **number** | The radius distance to check within |

#### ↩️ Returns
* Table of player entities found within the specified radius

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players within 100 units
    local nearbyPlayers = lia.util.playerInRadius(playerPos, 100)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Apply area effect to players in radius
    local explosionCenter = Vector(500, 300, 100)
    local affectedPlayers = lia.util.playerInRadius(explosionCenter, 200)
    for _, player in ipairs(affectedPlayers) do
        player:takeDamage(75)
        player:notify("You were caught in the blast!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a zone management system with multiple areas
    local zones = {
        {center = Vector(0, 0, 0),     radius = 150, type = "safe"   },
        {center = Vector(400, 0, 0),  radius = 100, type = "combat" },
        {center = Vector(200, 200, 0), radius = 80,  type = "neutral"}
    }
    for _, player in player.GetAll() do
        local playerPos = player:GetPos()
        local zonesIn = {}
        for _, zone in ipairs(zones) do
            if playerPos:Distance(zone.center) <= zone.radius then
                zonesIn[zone.type] = true
            end
        end
        if zonesIn.combat and not zonesIn.safe then
            player:setNetVar("inCombat", true)
        else
            player:setNetVar("inCombat", false)
        end
    end

```

---

### lia.util.formatStringNamed

#### 📋 Purpose
Format a string using named placeholders with flexible argument handling

#### ⏰ When Called
When you need to format strings with named parameters for localization, templating, or dynamic text generation

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `format` | **string** | The format string containing {placeholder} patterns |

#### ↩️ Returns
* String with placeholders replaced by provided values

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Format string with individual arguments
    local message = lia.util.formatStringNamed("Hello {name}!", "John")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Format string with named parameters
    local data = {name = "Alice", score = 150}
    local message = lia.util.formatStringNamed("Player {name} scored {score} points!", data)

```

#### ⚙️ High Complexity
```lua
    -- High: Create a templating system with complex data structures
    local template = "Player {name} from {faction} has {health} HP and {money} credits"
    local playerData = {
        name    = "Bob",
        faction = "Security",
        health  = 85,
        money   = 2500
    }
    local function formatPlayerInfo(template, data)
        local formatted = template
        for key, value in pairs(data) do
            formatted = formatted:gsub("{" .. key .. "}", tostring(value))
        end
        return formatted
    end
    -- Usage with both methods
    local message1 = lia.util.formatStringNamed(template, playerData)
    local message2 = formatPlayerInfo(template, playerData)

```

---

### lia.util.getMaterial

#### 📋 Purpose
Get a cached material object from a file path, creating it if it doesn't exist

#### ⏰ When Called
When you need to load and cache materials for rendering, UI elements, or visual effects to improve performance

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `materialPath` | **string** | The file path to the material (e.g., "materials/effects/blur.vmt") |
| `materialParameters` | **string** | Optional parameters for material creation |

#### ↩️ Returns
* IMaterial object for the specified material path

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get a cached material
    local blurMaterial = lia.util.getMaterial("pp/blurscreen")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Use material for rendering effects
    local material = lia.util.getMaterial("effects/flashlight001")
    surface.SetMaterial(material)
    surface.SetDrawColor(255, 255, 255, 128)
    surface.DrawTexturedRect(x, y, w, h)

```

#### ⚙️ High Complexity
```lua
    -- High: Create a material management system with preloading
    local materialCache = {}
    local function preloadMaterials(materialList)
        for _, materialPath in ipairs(materialList) do
            materialCache[materialPath] = lia.util.getMaterial(materialPath)
        end
    end
    local function drawMaterialEffect(materialPath, x, y, w, h, alpha)
        local material = materialCache[materialPath] or lia.util.getMaterial(materialPath)
        if material then
            surface.SetMaterial(material)
            surface.SetDrawColor(255, 255, 255, alpha or 255)
            surface.DrawTexturedRect(x, y, w, h)
        end
    end
    -- Usage
    preloadMaterials({"effects/water_warp01", "effects/bubble", "pp/blurscreen"})
    drawMaterialEffect("effects/water_warp01", 100, 100, 200, 200, 150)

```

---

### lia.util.findFaction

#### 📋 Purpose
Find a faction by name or unique ID using flexible matching

#### ⏰ When Called
When you need to locate faction information for player assignment, permissions, or faction-based operations

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player requesting the faction (for error notifications) |
| `name` | **string** | The faction name or unique ID to search for |

#### ↩️ Returns
* Faction table if found, nil otherwise with error notification

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find faction by name
    local faction = lia.util.findFaction(player, "Security")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check faction before performing action
    local faction = lia.util.findFaction(client, factionName)
    if faction then
        player:setFaction(faction.index)
        client:notify("Player moved to " .. faction.name)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a faction management system with validation
    local function managePlayerFaction(admin, targetPlayer, factionName, action)
        local faction = lia.util.findFaction(admin, factionName)
        if not faction then
            return false, "Faction not found"
        end
        if action == "assign" then
            targetPlayer:setFaction(faction.index)
            return true, "Player assigned to " .. faction.name
        elseif action == "check" then
            return true, "Player is in faction: " .. (targetPlayer:getFaction() == faction.index and faction.name or "Different faction")
        elseif action == "info" then
            return true, string.format("Faction: %s, Color: %s, Models: %d",
                faction.name, tostring(faction.color), #faction.models)
        end
        return false, "Invalid action"
    end
    -- Usage
    local success, message = managePlayerFaction(admin, target, "Citizen", "assign")

```

---

### lia.util.generateRandomName

#### 📋 Purpose
Generate a random full name by combining first and last names from provided or default lists

#### ⏰ When Called
When you need to create random character names for NPCs, testing, or procedural content generation

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `firstNames` | **table** | Optional table of first names to choose from |
| `lastNames` | **table** | Optional table of last names to choose from |

#### ↩️ Returns
* String containing a randomly generated full name (FirstName LastName)

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Generate a random name using defaults
    local randomName = lia.util.generateRandomName()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Generate name with custom name lists
    local fantasyFirstNames = {"Aragorn", "Legolas", "Gimli", "Frodo"}
    local fantasyLastNames = {"Stormwind", "Ironfist", "Shadowalker", "Lightbringer"}
    local fantasyName = lia.util.generateRandomName(fantasyFirstNames, fantasyLastNames)

```

#### ⚙️ High Complexity
```lua
    -- High: Create a name generation system with cultural variations
    local nameCultures = {
        western = {
            first = {"John", "Jane", "Michael", "Sarah"},
            last  = {"Smith", "Johnson", "Williams", "Brown"}
        },
        eastern = {
            first = {"Hiroshi", "Yuki", "Kenji", "Sakura"},
            last  = {"Tanaka", "Suzuki", "Yamamoto", "Watanabe"}
        }
    }
    local function generateCulturalName(culture)
        local cultureData = nameCultures[culture]
        if cultureData then
            return lia.util.generateRandomName(cultureData.first, cultureData.last)
        end
        return lia.util.generateRandomName() -- fallback to defaults
    end
    -- Usage
    local westernName = generateCulturalName("western")
    local easternName = generateCulturalName("eastern")

```

---

### lia.util.sendTableUI

#### 📋 Purpose
Send a table-based user interface to a specific client for displaying data in a structured format

#### ⏰ When Called
When you need to display tabular data to a player, such as inventories, player lists, or administrative information

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player to send the table UI to |
| `title` | **string** | The title of the table window |
| `columns` | **table** | Array of column definitions with name, width, and other properties |
| `data` | **table** | Array of row data to display in the table |
| `options` | **table** | Optional configuration options for the table UI |
| `characterID` | **number** | Optional character ID for character-specific data |

#### ↩️ Returns
* Nothing (sends network message to client)

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Send basic player list
    local columns = {
        {name = "Name",    width = 150},
        {name = "Steam ID", width = 200}
    }
    local players = player.GetAll()
    local data = {}
    for _, ply in ipairs(players) do
        data[#data + 1] = {ply:Name(), ply:SteamID()}
    end
    lia.util.sendTableUI(client, "Player List", columns, data)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Send inventory with action options
    local columns = {
        {name = "Item",     width = 150},
        {name = "Quantity", width = 80 },
        {name = "Value",    width = 100}
    }
    local options = {
        {name = "Drop", net = "liaDropItem"},
        {name = "Use",  net = "liaUseItem" }
    }
    lia.util.sendTableUI(client, "Inventory", columns, inventoryData, options, characterID)

```

#### ⚙️ High Complexity
```lua
    -- High: Create a comprehensive admin panel with multiple data types
    local function sendAdminPanel(admin, targetPlayer)
        local columns = {
            {name = "Property", width = 150},
            {name = "Value",    width = 200},
            {name = "Actions",  width = 100}
        }
        local playerData = {
            {"Name",     targetPlayer:Name()},
            {"Steam ID", targetPlayer:SteamID()},
            {"Health",   targetPlayer:Health()},
            {"Armor",    targetPlayer:Armor()},
            {"Money",    targetPlayer:getMoney()},
            {"Faction",  targetPlayer:getFaction()}
        }
        local options = {
            {name = "Kick",     net = "liaKickPlayer"   },
            {name = "Ban",      net = "liaBanPlayer"    },
            {name = "Teleport", net = "liaTeleportPlayer"}
        }
        lia.util.sendTableUI(admin, "Player Info: " .. targetPlayer:Name(),
            columns, playerData, options, targetPlayer:getChar() and targetPlayer:getChar():getID())
    end

```

---

### lia.util.findEmptySpace

#### 📋 Purpose
Find empty spaces around an entity for spawning or placement purposes

#### ⏰ When Called
When you need to find valid locations to spawn entities, NPCs, or items around a central position

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The central entity to search around |
| `filter` | **Entity/Table** | Optional entity or table of entities to ignore in collision detection |
| `spacing` | **number** | Distance between each tested position (default: 32) |
| `size` | **number** | Grid size to search in (default: 3, meaning -3 to +3 in both x and y) |
| `height` | **number** | Height of the area to check for collisions (default: 36) |
| `tolerance` | **number** | Additional clearance above ground (default: 5) |

#### ↩️ Returns
* Table of valid Vector positions sorted by distance from the entity

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find nearby empty spaces
    local emptySpaces = lia.util.findEmptySpace(someEntity)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find spawn locations for NPCs around player
    local spawnPositions = lia.util.findEmptySpace(player, player, 64, 5, 72, 10)
    for _, pos in ipairs(spawnPositions) do
        if #spawnPositions >= 3 then break end -- Limit to 3 NPCs
        local npc = ents.Create("npc_zombie")
        npc:SetPos(pos)
        npc:Spawn()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a smart spawning system with validation
    local function spawnEntitiesInArea(centerEntity, entityType, count, spacing)
        local validPositions = lia.util.findEmptySpace(centerEntity, nil, spacing or 48, 4, 64, 8)
        for i = 1, math.min(count, #validPositions) do
            local pos = validPositions[i]
            if pos then
                local entity = ents.Create(entityType)
                entity:SetPos(pos)
                -- Add some randomization to position
                local randomOffset = Vector(
                    math.random(-16, 16),
                    math.random(-16, 16),
                    0
                )
                entity:SetPos(pos + randomOffset)
                entity:Spawn()
                -- Ensure entity is properly placed
                if not lia.util.canFit(entity:GetPos(), entity:GetModelBounds()) then
                    entity:Remove()
                end
            end
        end
        return #validPositions
    end

```

---

### lia.util.animateAppearance

#### 📋 Purpose
Animate a panel's appearance with scaling, positioning, and alpha transitions

#### ⏰ When Called
When you need to create smooth entrance animations for UI panels, menus, or dialog boxes

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | The DPanel to animate |
| `target_w` | **number** | Target width for the animation |
| `target_h` | **number** | Target height for the animation |
| `duration` | **number** | Duration of size/position animation in seconds (default: 0.18) |
| `alpha_dur` | **number** | Duration of alpha animation in seconds (default: same as duration) |
| `callback` | **function** | Optional callback function to execute when animation completes |
| `scale_factor` | **number** | Scale factor for initial size (default: 0.8) |

#### ↩️ Returns
* Nothing (modifies panel directly)

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Basic panel appearance animation
    local panel = vgui.Create("DPanel")
    panel:SetSize(200, 100)
    lia.util.animateAppearance(panel, 200, 100)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Animate panel with custom duration and callback
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:Center()
    lia.util.animateAppearance(frame, 400, 300, 0.3, 0.2, function(panel)
        print("Animation completed!")
        panel:MakePopup()
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Create a complex UI system with staggered animations
    local function createAnimatedMenu(title, options)
        local frame = vgui.Create("DFrame")
        frame:SetTitle(title)
        frame:SetSize(300, 200)
        frame:Center()
        -- Animate main frame
        lia.util.animateAppearance(frame, 300, 200, 0.25, 0.15)
        -- Create animated buttons with delays
        for i, option in ipairs(options) do
            local button = vgui.Create("DButton", frame)
            button:SetText(option.text)
            button:Dock(TOP)
            button:DockMargin(10, 5, 10, 5)
            -- Stagger animation timing
            timer.Simple(i * 0.05, function()
                if IsValid(button) then
                    button:SetAlpha(0)
                    lia.util.animateAppearance(button, button:GetWide(), button:GetTall(), 0.15, 0.1)
                end
            end)
        end
        return frame
    end

```

---

### lia.util.clampMenuPosition

#### 📋 Purpose
Clamp a panel's position to stay within screen boundaries while avoiding UI overlap

#### ⏰ When Called
When you need to ensure menus and panels stay visible and don't overlap with important UI elements like logos

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | The DPanel whose position should be clamped |

#### ↩️ Returns
* Nothing (modifies panel position directly)

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Keep panel within screen bounds
    local panel = vgui.Create("DPanel")
    panel:SetPos(ScrW() + 100, ScrH() + 50) -- Off-screen position
    lia.util.clampMenuPosition(panel) -- Will move panel back on screen

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create a draggable panel that stays within bounds
    local frame = vgui.Create("DFrame")
    frame:SetSize(200, 150)
    frame:SetDraggable(true)
    -- Clamp position when dragging ends
    frame.OnMouseReleased = function()
        lia.util.clampMenuPosition(frame)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a smart positioning system for multiple panels
    local function positionPanelsSmartly(panels)
        local screenW, screenH = ScrW(), ScrH()
        local margin = 10
        -- Sort panels by priority (main panels first)
        table.sort(panels, function(a, b) return a.priority < b.priority end)
        for i, panel in ipairs(panels) do
            local x, y = panel:GetPos()
            local w, h = panel:GetSize()
            -- Try current position first
            lia.util.clampMenuPosition(panel)
            -- If panel would overlap with higher priority panels, reposition
            local needsReposition = false
            for j = 1, i - 1 do
                local otherPanel = panels[j]
                local otherX, otherY = otherPanel:GetPos()
                local otherW, otherH = otherPanel:GetSize()
                if x < otherX + otherW + margin and x + w + margin > otherX and
                   y < otherY + otherH + margin and y + h + margin > otherY then
                    needsReposition = true
                    break
                end
            end
            if needsReposition then
                -- Find best available position
                local bestX, bestY = margin, margin
                local minDistance = math.huge
                for testY = margin, screenH - h - margin, 20 do
                    for testX = margin, screenW - w - margin, 20 do
                        local distance = 0
                        -- Calculate distance from other panels
                        for _, otherPanel in ipairs(panels) do
                            if otherPanel ~= panel then
                                local otherX, otherY = otherPanel:GetPos()
                                local dx = testX - otherX
                                local dy = testY - otherY
                                distance = distance + (dx * dx + dy * dy)
                            end
                        end
                        if distance < minDistance then
                            minDistance = distance
                            bestX, bestY = testX, testY
                        end
                    end
                end
                panel:SetPos(bestX, bestY)
            end
        end
    end

```

---

### lia.util.drawGradient

#### 📋 Purpose
Draw a gradient background using predefined gradient materials

#### ⏰ When Called
When you need to create gradient backgrounds for UI elements, panels, or visual effects

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `_x` | **number** | X position to draw the gradient |
| `_y` | **number** | Y position to draw the gradient |
| `_w` | **number** | Width of the gradient area |
| `_h` | **number** | Height of the gradient area |
| `direction` | **number** | Gradient direction (1=up, 2=down, 3=left, 4=right) |
| `color_shadow` | **Color** | Color for the gradient shadow effect |
| `radius` | **number** | Corner radius for rounded gradients (default: 0) |
| `flags` | **number** | Material flags for rendering |

#### ↩️ Returns
* Nothing (draws directly to screen)

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Draw a basic gradient background
    lia.util.drawGradient(100, 100, 200, 150, 2, Color(0, 0, 0, 150))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create a gradient panel background
    local panel = vgui.Create("DPanel")
    panel.Paint = function(self, w, h)
        lia.util.drawGradient(0, 0, w, h, 2, Color(50, 50, 50, 200), 8)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create animated gradient backgrounds
    local gradients = {
        {dir = 1, color = Color(255, 100, 100, 150)},
        {dir = 2, color = Color(100, 255, 100, 150)},
        {dir = 3, color = Color(100, 100, 255, 150)},
        {dir = 4, color = Color(255, 255, 100, 150)}
    }
    local currentGradient = 1
    local function drawAnimatedGradient(x, y, w, h)
        local gradient = gradients[currentGradient]
        lia.util.drawGradient(x, y, w, h, gradient.dir, gradient.color, 12)
        -- Cycle through gradients
        if math.sin(CurTime() * 2) > 0.9 then
            currentGradient = currentGradient % #gradients + 1
        end
    end
    -- Usage in panel
    local panel = vgui.Create("DPanel")
    panel.Paint = function(self, w, h)
        drawAnimatedGradient(0, 0, w, h)
    end

```

---

### lia.util.wrapText

#### 📋 Purpose
Wrap text to fit within a specified width, breaking it into multiple lines

#### ⏰ When Called
When you need to display text that might be too long for a UI element, ensuring it wraps properly

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | The text to wrap |
| `width` | **number** | Maximum width in pixels for the text |
| `font` | **string** | Font to use for text measurement (default: "LiliaFont.16") |

#### ↩️ Returns
* Table of wrapped text lines, Number: Maximum width of any line

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Wrap text to fit in a label
    local lines, maxWidth = lia.util.wrapText("This is a long text that needs wrapping", 200)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create a multi-line label with wrapped text
    local text = "This is a very long description that should wrap to multiple lines when displayed in the UI."
    local lines, maxWidth = lia.util.wrapText(text, 300, "liaSmallFont")
    local label = vgui.Create("DLabel")
    label:SetSize(maxWidth, #lines * 20)
    label:SetText("")
    for i, line in ipairs(lines) do
        local lineLabel = vgui.Create("DLabel", label)
        lineLabel:SetPos(0, (i-1) * 20)
        lineLabel:SetText(line)
        lineLabel:SizeToContents()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic text wrapping system with font scaling
    local function createResponsiveTextPanel(text, maxWidth, fontBase)
        local fontSizes = {16, 14, 12, 10}
        local lines = {}
        local finalFont = fontBase
        for _, size in ipairs(fontSizes) do
            local font = fontBase .. size
            surface.SetFont(font)
            local tempLines, tempWidth = lia.util.wrapText(text, maxWidth, font)
            if tempWidth <= maxWidth then
                lines = tempLines
                finalFont = font
                break
            end
        end
        local panel = vgui.Create("DPanel")
        panel:SetSize(maxWidth, #lines * (tonumber(finalFont:match("%d+")) or 16))
        panel.Paint = function(self, w, h)
            surface.SetFont(finalFont)
            for i, line in ipairs(lines) do
                surface.SetTextPos(0, (i-1) * (h / #lines))
                surface.DrawText(line)
            end
        end
        return panel
    end
    -- Usage
    local textPanel = createResponsiveTextPanel("Very long text that needs to fit in a small area", 250, "liaFont.")

```

---

### lia.util.drawBlur

#### 📋 Purpose
Draw a blur effect behind a panel using screen-space blurring

#### ⏰ When Called
When you need to create a blurred background effect for UI elements like menus or dialogs

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | The panel to draw blur behind |
| `amount` | **number** | Intensity of the blur effect (default: 5) |
| `_` | **any** | Unused parameter (legacy) |
| `alpha` | **number** | Alpha transparency of the blur effect (default: 255) |

#### ↩️ Returns
* Nothing (draws directly to screen)

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add basic blur behind a panel
    local panel = vgui.Create("DPanel")
    lia.util.drawBlur(panel, 5, nil, 200)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create a blurred dialog background
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Important Message")
    frame:SetSize(400, 200)
    frame:Center()
    frame.Paint = function(self, w, h)
        lia.util.drawBlur(self, 8, nil, 180)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 150))
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create an animated blur effect system
    local blurIntensity = 0
    local function drawDynamicBlur(panel)
        blurIntensity = math.sin(CurTime() * 2) * 5 + 6
        lia.util.drawBlur(panel, blurIntensity, nil, 220)
    end
    local function createBlurredMenu(title, options)
        local frame = vgui.Create("DFrame")
        frame:SetTitle(title)
        frame:SetSize(300, 400)
        frame:Center()
        frame.Paint = function(self, w, h)
            drawDynamicBlur(self)
            draw.RoundedBox(12, 0, 0, w, h, Color(20, 20, 20, 200))
        end
        for i, option in ipairs(options) do
            local button = vgui.Create("DButton", frame)
            button:SetText(option.text)
            button:Dock(TOP)
            button:DockMargin(20, 10, 20, 10)
            button.Paint = function(self, w, h)
                if self:IsHovered() then
                    lia.util.drawBlur(self, 3, nil, 150)
                end
                draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 60, 200))
            end
            button.DoClick = option.callback
        end
    return frame
    end

```

---

### lia.util.drawBlackBlur

#### 📋 Purpose
Draw a black blur effect with enhanced darkness behind a panel

#### ⏰ When Called
When you need to create a darker, more opaque blurred background effect for UI elements

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | The panel to draw blur behind |
| `amount` | **number** | Intensity of the blur effect (default: 6) |
| `passes` | **number** | Number of blur passes for quality (default: 5, minimum: 1) |
| `alpha` | **number** | Alpha transparency of the blur effect (default: 255) |
| `darkAlpha` | **number** | Alpha transparency of the dark overlay (default: 220) |

#### ↩️ Returns
* Nothing (draws directly to screen)

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add dark blur behind a panel
    local panel = vgui.Create("DPanel")
    lia.util.drawBlackBlur(panel, 6, 5, 255, 220)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create a cinematic menu with dark blur
    local menu = vgui.Create("DFrame")
    menu:SetTitle("Game Menu")
    menu:SetSize(500, 300)
    menu:Center()
    menu.Paint = function(self, w, h)
    lia.util.drawBlackBlur(self, 8, 7, 255, 240)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create an adaptive blur system based on context
    local function drawContextualBlur(panel, context)
        local settings = {
            menu    = {amount = 6,   passes = 5, alpha = 255, darkAlpha = 220},
            dialog  = {amount = 8,   passes = 7, alpha = 255, darkAlpha = 240},
            overlay = {amount = 4,   passes = 3, alpha = 200, darkAlpha = 180}
        }
        local config = settings[context] or settings.menu
        lia.util.drawBlackBlur(panel, config.amount, config.passes, config.alpha, config.darkAlpha)
    end
    local function createContextualUI(context, title)
        local frame = vgui.Create("DFrame")
        frame:SetTitle(title)
        frame:SetSize(400, 250)
        frame:Center()
        frame.Paint = function(self, w, h)
            drawContextualBlur(self, context)
            draw.RoundedBox(8, 0, 0, w, h, Color(10, 10, 10, 200))
        end
    return frame
    end
    -- Usage for different contexts
    local menuUI = createContextualUI("menu", "Main Menu")
    local dialogUI = createContextualUI("dialog", "Important Dialog")
    local overlayUI = createContextualUI("overlay", "HUD Overlay")

```

---

### lia.util.drawBlurAt

#### 📋 Purpose
Draw a blur effect at specific screen coordinates

#### ⏰ When Called
When you need to apply blur effects to specific screen areas for HUD elements or overlays

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | X position to draw the blur |
| `y` | **number** | Y position to draw the blur |
| `w` | **number** | Width of the blur area |
| `h` | **number** | Height of the blur area |
| `amount` | **number** | Intensity of the blur effect (default: 5) |
| `passes` | **number** | Number of blur passes (default: 0.2) |
| `alpha` | **number** | Alpha transparency of the blur effect (default: 255) |

#### ↩️ Returns
* Nothing (draws directly to screen)

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Blur a specific screen area
    lia.util.drawBlurAt(100, 100, 200, 150, 5, 0.2, 255)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create a blurred HUD overlay for damage effects
    local function drawDamageOverlay(damage)
        local alpha = math.Clamp(damage * 2, 0, 200)
        lia.util.drawBlurAt(0, 0, ScrW(), ScrH(), 3, 0.3, alpha)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic minimap with blur effects
    local function drawMinimapWithEffects(playerPos, mapSize)
        local mapX, mapY = 50, ScrH() - mapSize - 50
        local mapW, mapH = mapSize, mapSize
        -- Draw blurred background for minimap
        lia.util.drawBlurAt(mapX - 10, mapY - 10, mapW + 20, mapH + 20, 2, 0.1, 150)
        -- Draw minimap content
        surface.SetDrawColor(100, 100, 100, 200)
        surface.DrawRect(mapX, mapY, mapW, mapH)
        -- Draw player position with pulsing effect
        local pulseAlpha = (math.sin(CurTime() * 4) + 1) * 100 + 50
        surface.SetDrawColor(255, 255, 0, pulseAlpha)
        surface.DrawRect(mapX + mapW/2 - 2, mapY + mapH/2 - 2, 4, 4)
    end

```

---

### lia.util.createTableUI

#### 📋 Purpose
Create a complete table-based UI window for displaying data with interactive features

#### ⏰ When Called
When you need to display tabular data with sorting, actions, and interactive options

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string** | Title for the table window |
| `columns` | **table** | Array of column definitions |
| `data` | **table** | Array of row data to display |
| `options` | **table** | Optional action buttons and configurations |
| `charID` | **number** | Character ID for character-specific data |

#### ↩️ Returns
* Frame, ListView: The created frame and list view objects

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create basic table UI
    local frame, listView = lia.util.createTableUI("Player List", columns, playerData)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create table with action options
    local options = {
        {name = "Teleport", net = "liaTeleportTo"},
        {name = "Kick",     net = "liaKickPlayer"}
    }
    local frame, listView = lia.util.createTableUI("Admin Panel", columns, data, options, charID)

```

#### ⚙️ High Complexity
```lua
    -- High: Create comprehensive data management interface
    local function createDataManager(dataType)
        local columns = {
            {name = "ID",     field = "id",     width = 80 },
            {name = "Name",   field = "name",   width = 200},
            {name = "Status", field = "status", width = 120}
        }
        local options = {
            {name = "Edit",        net = "liaEdit" .. dataType  },
            {name = "Delete",      net = "liaDelete" .. dataType},
            {name = "View Details", net = "liaView" .. dataType }
        }
        return lia.util.createTableUI(dataType .. " Management", columns, getData(dataType), options)
    end

```

---

### lia.util.openOptionsMenu

#### 📋 Purpose
Create and display an options menu with interactive buttons

#### ⏰ When Called
When you need to present a list of options or actions to the user in a popup menu

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string** | Title for the options menu |
| `options` | **table** | Array of option objects or key-value pairs with name and callback properties |

#### ↩️ Returns
* Frame: The created options menu frame

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create basic options menu
    local frame = lia.util.openOptionsMenu("Choose Action", {
    {name = "Option 1", callback = function() print("Option 1 selected") end},
    {name = "Option 2", callback = function() print("Option 2 selected") end}
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create contextual options menu
    local options = {
        ["Heal Player"] = function() healTargetPlayer(target) end,
        ["Teleport"]    = function() teleportToTarget(target) end,
        ["Give Item"]   = function() openGiveItemMenu(target) end
    }
    lia.util.openOptionsMenu("Player Actions", options)

```

#### ⚙️ High Complexity
```lua
    -- High: Create dynamic options system with categories
    local function createCategorizedOptions(categories)
        local allOptions = {}
        for categoryName, categoryOptions in pairs(categories) do
            -- Add category header (disabled button)
            allOptions[#allOptions + 1] = {
                name     = categoryName,
                callback = function() end, -- No action for headers
                disabled = true
            }
            -- Add category options
            for _, option in ipairs(categoryOptions) do
                allOptions[#allOptions + 1] = option
            end
            -- Add spacer
            allOptions[#allOptions + 1] = {
                name      = "",
                callback  = function() end,
                separator = true
            }
        end
        return lia.util.openOptionsMenu("Categorized Options", allOptions)
    end

```

---

### lia.util.drawEntText

#### 📋 Purpose
Draw floating text above an entity with distance-based fade effects

#### ⏰ When Called
When you need to display information or labels above entities in the 3D world

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **Entity** | The entity to draw text above |
| `text` | **string** | The text to display |
| `posY` | **number** | Vertical offset for text positioning (default: 0) |
| `alphaOverride` | **number** | Optional alpha override for manual control |

#### ↩️ Returns
* Nothing (draws directly to screen)

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Draw text above an entity
    lia.util.drawEntText(someEntity, "Important Item")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Draw contextual entity information
    local function drawEntityInfo(ent)
        if ent:isItem() then
            local itemName = ent:getNetVar("id", "Unknown Item")
            lia.util.drawEntText(ent, itemName, 20)
        elseif ent:IsPlayer() then
            lia.util.drawEntText(ent, ent:Name(), 30)
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a comprehensive entity labeling system
    local function drawSmartEntityLabels()
        local entities = ents.FindInSphere(LocalPlayer():GetPos(), 500)
        for _, ent in ipairs(entities) do
            if not IsValid(ent) then continue end
            local text = ""
            local offset = 0
            local alpha = nil
            if ent:IsPlayer() then
                text = ent:Name()
                offset = 40
            elseif ent:isItem() then
                text = ent:getNetVar("id", "Item")
                offset = 25
                alpha = 200 -- Slightly transparent for items
            elseif ent:GetClass() == "prop_physics" then
                text = "Interactive Object"
                offset = 30
            end
            if text ~= "" then
                lia.util.drawEntText(ent, text, offset, alpha)
            end
        end
        -- Call in HUDPaint or Think hook
        hook.Add("HUDPaint", "DrawEntityLabels", drawSmartEntityLabels)

```

---

### lia.util.drawLookText

#### 📋 Purpose
Draw floating text at the player's look position with distance-based fade effects

#### ⏰ When Called
When you need to display contextual information at the location the player is looking at

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | The text to display |
| `posY` | **number** | Vertical offset for text positioning (default: 0) |
| `alphaOverride` | **number** | Optional alpha override for manual control |
| `maxDist` | **number** | Maximum distance to display text (default: 380) |

#### ↩️ Returns
* Nothing (draws directly to screen)

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Draw text where player is looking
    lia.util.drawLookText("Target Location")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Show distance-based information
    local trace = LocalPlayer():GetEyeTrace()
    if trace.Hit then
        local distance = math.Round(trace.HitPos:Distance(LocalPlayer():GetPos()))
        lia.util.drawLookText("Distance: " .. distance .. " units", 20)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create an interactive world information system
    local function drawContextualWorldInfo()
        local trace = util.TraceLine({
            start   = EyePos(),
            endpos  = EyePos() + EyeAngles():Forward() * 200,
            filter  = LocalPlayer()
        })
        if trace.Hit and trace.HitPos:Distance(EyePos()) <= 200 then
            local hitPos = trace.HitPos
            local hitEntity = trace.Entity
            if IsValid(hitEntity) then
                if hitEntity:IsPlayer() then
                    lia.util.drawLookText("Player: " .. hitEntity:Name(), 30)
                elseif hitEntity:isItem() then
                    local itemName = hitEntity:getNetVar("id", "Unknown Item")
                    lia.util.drawLookText("Item: " .. itemName, 25)
                else
                    lia.util.drawLookText("Entity: " .. hitEntity:GetClass(), 20)
                end
            else
                -- Show world position information
                local posText = string.format("X: %d, Y: %d, Z: %d",
                    math.Round(hitPos.x), math.Round(hitPos.y), math.Round(hitPos.z))
                lia.util.drawLookText("Position: " .. posText, 15)
            end
        end
    end
    -- Call in HUDPaint hook
    hook.Add("HUDPaint", "DrawWorldInfo", drawContextualWorldInfo)

```

---

