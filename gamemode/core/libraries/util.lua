--[[
    Utility Library

    Common operations and helper functions for the Lilia framework.
]]
--[[
    Overview:
        The utility library provides comprehensive functionality for common operations and helper functions used throughout the Lilia framework. It contains a wide range of utilities for player management, string processing, entity handling, UI operations, and general purpose calculations. The library is divided into server-side functions for game logic and data management, and client-side functions for user interface, visual effects, and player interaction. These utilities simplify complex operations, provide consistent behavior across the framework, and offer reusable components for modules and plugins. The library handles everything from player identification and spatial queries to advanced UI animations and text processing, ensuring robust and efficient operations across both server and client environments.
]]
--[[
    Purpose:
        Find all players within a specified 3D box area

    When Called:
        When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

    Parameters:
        mins (Vector)
            The minimum corner coordinates of the box
        maxs (Vector)
            The maximum corner coordinates of the box

    Returns:
        Table of player entities found within the box area

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find players in a small area around a position
        local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))
        ```

    Medium Complexity:
        ```lua
        -- Medium: Find players in a zone and notify them
        local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
        for _, player in ipairs(zonePlayers) do
            player:notify("You are in the danger zone!")
        end
        ```

    High Complexity:
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
]]
function lia.util.findPlayersInBox(mins, maxs)
    local entsList = ents.FindInBox(mins, maxs)
    local plyList = {}
    for _, v in pairs(entsList) do
        if IsValid(v) and v:IsPlayer() then plyList[#plyList + 1] = v end
    end
    return plyList
end

--[[
    Purpose:
        Find a player by their Steam ID or Steam ID 64

    When Called:
        When you need to locate a specific player using their Steam identification for operations like bans, whitelists, or data retrieval

    Parameters:
        steamID (string)
            The Steam ID (STEAM_0:0:123456) or Steam ID 64 to search for

    Returns:
        Player entity if found with a valid character, nil otherwise

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find player by Steam ID
        local player = lia.util.getBySteamID("STEAM_0:0:12345678")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check if player is online before performing action
        local targetPlayer = lia.util.getBySteamID(playerSteamID)
        if IsValid(targetPlayer) then
            targetPlayer:giveMoney(1000)
        else
            print("Player not found or offline")
        end
        ```

    High Complexity:
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
]]
function lia.util.getBySteamID(steamID)
    if not isstring(steamID) or steamID == "" then return end
    local sid = steamID
    if steamID:match("^%d+$") and #steamID >= 17 then sid = util.SteamIDFrom64(steamID) end
    for _, client in player.Iterator() do
        if client:SteamID() == sid and client:getChar() then return client end
    end
end

--[[
    Purpose:
        Find all players within a specified spherical radius from a center point

    When Called:
        When you need to find players in a circular area for proximity-based operations like damage, effects, or notifications

    Parameters:
        origin (Vector)
            The center point of the sphere
        radius (number)
            The radius of the sphere in units

    Returns:
        Table of player entities found within the spherical area

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find players within 500 units of a position
        local nearbyPlayers = lia.util.findPlayersInSphere(playerPos, 500)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Apply effect to players within radius
        local explosionPos = Vector(100, 200, 50)
        local affectedPlayers = lia.util.findPlayersInSphere(explosionPos, 300)

        for _, player in ipairs(affectedPlayers) do
            player:takeDamage(50)
            player:notify("Hit by explosion!")
        end
        ```

    High Complexity:
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
]]
function lia.util.findPlayersInSphere(origin, radius)
    local plys = {}
    local r2 = radius ^ 2
    for _, client in player.Iterator() do
        if client:GetPos():DistToSqr(origin) <= r2 then plys[#plys + 1] = client end
    end
    return plys
end

--[[
    Purpose:
        Find a player by various identifier types including Steam ID, Steam ID 64, name, or special selectors

    When Called:
        When you need to locate a specific player using flexible identification methods for commands, admin actions, or interactions

    Parameters:
        client (Player)
            The player requesting the search (for notifications and special selectors)
        identifier (string)
            The identifier to search for (Steam ID, Steam ID 64, player name, "^" for self, "@" for looked-at player)

    Returns:
        Player entity if found, nil otherwise with appropriate error notifications

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find player by partial name
        local targetPlayer = lia.util.findPlayer(client, "John")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Find player and perform action with error handling
        local targetPlayer = lia.util.findPlayer(client, targetSteamID)
        if targetPlayer then
            targetPlayer:giveMoney(100)
            client:notify("Gave money to " .. targetPlayer:Name())
        end
        ```

    High Complexity:
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
]]
function lia.util.findPlayer(client, identifier)
    local isValidClient = IsValid(client)
    if not isstring(identifier) or identifier == "" then
        if isValidClient then client:notifyErrorLocalized("mustProvideString") end
        return nil
    end

    if string.match(identifier, "^STEAM_%d+:%d+:%d+$") then
        local ply = lia.util.getBySteamID(identifier)
        if IsValid(ply) then return ply end
        if isValidClient then client:notifyErrorLocalized("plyNoExist") end
        return nil
    end

    if string.match(identifier, "^%d+$") and #identifier >= 17 then
        local sid = util.SteamIDFrom64(identifier)
        if sid then
            local ply = lia.util.getBySteamID(sid)
            if IsValid(ply) then return ply end
        end

        if isValidClient then client:notifyErrorLocalized("plyNoExist") end
        return nil
    end

    if isValidClient and identifier == "^" then return client end
    if isValidClient and identifier == "@" then
        local trace = client:getTracedEntity()
        if IsValid(trace) and trace:IsPlayer() then return trace end
        client:notifyErrorLocalized("lookToUseAt")
        return nil
    end

    local safe = string.PatternSafe(identifier)
    for _, ply in player.Iterator() do
        if lia.util.stringMatches(ply:Name(), safe) then return ply end
    end

    if isValidClient then client:notifyErrorLocalized("plyNoExist") end
    return nil
end

--[[
    Purpose:
        Find all items created by a specific player in the world

    When Called:
        When you need to locate dropped items or spawned entities created by a particular player for cleanup, tracking, or management

    Parameters:
        client (Player)
            The player whose created items should be found

    Returns:
        Table of item entities created by the specified player

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find all items dropped by a player
        local playerItems = lia.util.findPlayerItems(somePlayer)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up items after player disconnects
        local droppedItems = lia.util.findPlayerItems(disconnectingPlayer)
        for _, item in ipairs(droppedItems) do
            item:Remove()
        end
        ```

    High Complexity:
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
]]
function lia.util.findPlayerItems(client)
    local items = {}
    for _, item in ents.Iterator() do
        if IsValid(item) and item:isItem() and item:GetCreator() == client then table.insert(items, item) end
    end
    return items
end

--[[
    Purpose:
        Find all items of a specific class created by a particular player

    When Called:
        When you need to locate specific types of items created by a player for targeted operations like weapon cleanup or resource management

    Parameters:
        client (Player)
            The player whose created items should be found
        class (string)
            The item class/type to filter by (e.g., "weapon_ar2", "item_healthkit")

    Returns:
        Table of item entities of the specified class created by the player

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find all weapons dropped by a player
        local droppedWeapons = lia.util.findPlayerItemsByClass(player, "weapon_ar2")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Remove specific item types after player death
        local healthKits = lia.util.findPlayerItemsByClass(deadPlayer, "item_healthkit")
        for _, kit in ipairs(healthKits) do
            kit:Remove()
        end
        ```

    High Complexity:
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
]]
function lia.util.findPlayerItemsByClass(client, class)
    local items = {}
    for _, item in ents.Iterator() do
        if IsValid(item) and item:isItem() and item:GetCreator() == client and item:getNetVar("id") == class then table.insert(items, item) end
    end
    return items
end

--[[
    Purpose:
        Find all entities created by or associated with a specific player, optionally filtered by class

    When Called:
        When you need to locate entities spawned by a player for management, cleanup, or tracking purposes

    Parameters:
        client (Player)
            The player whose entities should be found
        class (string)
            Optional class name to filter entities (e.g., "prop_physics", "npc_zombie")

    Returns:
        Table of entities created by or associated with the specified player

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find all entities created by a player
        local playerEntities = lia.util.findPlayerEntities(somePlayer)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Find specific entity types created by player
        local playerProps = lia.util.findPlayerEntities(player, "prop_physics")
        for _, prop in ipairs(playerProps) do
            prop:Remove()
        end
        ```

    High Complexity:
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
]]
function lia.util.findPlayerEntities(client, class)
    local entities = {}
    for _, entity in ents.Iterator() do
        if IsValid(entity) and (not class or entity:GetClass() == class) and (entity:GetCreator() == client or entity.client and entity.client == client) then table.insert(entities, entity) end
    end
    return entities
end

--[[
    Purpose:
        Check if two strings match using flexible comparison methods including case-insensitive and partial matching

    When Called:
        When you need to compare strings with flexible matching for search functionality, name validation, or text processing

    Parameters:
        a (string)
            The first string to compare
        b (string)
            The second string to compare (the search pattern)

    Returns:
        Boolean indicating if the strings match using any of the comparison methods

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Check if strings are equal (case-insensitive)
        local matches = lia.util.stringMatches("Hello", "hello")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check if player name contains search term
        local function playerNameMatches(player, searchTerm)
            return lia.util.stringMatches(player:Name(), searchTerm)
        end
        ```

    High Complexity:
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
]]
function lia.util.stringMatches(a, b)
    if a and b then
        local a2, b2 = a:lower(), b:lower()
        if a == b then return true end
        if a2 == b2 then return true end
        if a:find(b) then return true end
        if a2:find(b2) then return true end
    end
    return false
end

--[[
    Purpose:
        Get a list of all currently online administrators/staff members

    When Called:
        When you need to identify staff members for admin-only operations, notifications, or privilege checks

    Parameters:
        None

    Returns:
        Table of player entities that are currently staff members

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get all online admins
        local admins = lia.util.getAdmins()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Send notification to all admins
        local admins = lia.util.getAdmins()
        for _, admin in ipairs(admins) do
            admin:notify("Server maintenance in 5 minutes!")
        end
        ```

    High Complexity:
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
]]
function lia.util.getAdmins()
    local staff = {}
    for _, client in player.Iterator() do
        local hasPermission = client:isStaff()
        if hasPermission then staff[#staff + 1] = client end
    end
    return staff
end

--[[
    Purpose:
        Find a player by their Steam ID 64, converting it to Steam ID format first

    When Called:
        When you need to locate a player using their Steam ID 64 for database operations or external integrations

    Parameters:
        SteamID64 (string)
            The Steam ID 64 to search for

    Returns:
        Player entity if found, nil otherwise

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find player by Steam ID 64
        local player = lia.util.findPlayerBySteamID64("76561198012345678")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check if Steam ID 64 is currently online
        local targetPlayer = lia.util.findPlayerBySteamID64(steamID64)
        if IsValid(targetPlayer) then
            print(targetPlayer:Name() .. " is currently online")
        end
        ```

    High Complexity:
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
]]
function lia.util.findPlayerBySteamID64(SteamID64)
    local SteamID = util.SteamIDFrom64(SteamID64)
    if not SteamID then return nil end
    return lia.util.findPlayerBySteamID(SteamID)
end

--[[
    Purpose:
        Find a player by their Steam ID

    When Called:
        When you need to locate a player using their Steam ID for admin actions, bans, or data retrieval

    Parameters:
        SteamID (string)
            The Steam ID to search for (STEAM_0:0:123456 format)

    Returns:
        Player entity if found, nil otherwise

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find player by Steam ID
        local player = lia.util.findPlayerBySteamID("STEAM_0:0:12345678")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Verify player identity before action
        local targetPlayer = lia.util.findPlayerBySteamID(steamID)
        if IsValid(targetPlayer) and targetPlayer:getChar() then
            targetPlayer:kick("Reason for kick")
        end
        ```

    High Complexity:
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
]]
function lia.util.findPlayerBySteamID(SteamID)
    for _, client in player.Iterator() do
        if client:SteamID() == SteamID then return client end
    end
    return nil
end

--[[
    Purpose:
        Check if an entity can fit at a specific position without colliding with solid objects

    When Called:
        When you need to validate if an entity can be placed at a location for spawning, teleportation, or collision detection

    Parameters:
        pos (Vector)
            The position to check for entity placement
        mins (Vector)
            Optional minimum bounding box coordinates (defaults to Vector(16, 16, 0))
        maxs (Vector)
            Optional maximum bounding box coordinates (defaults to mins value)
        filter (Entity/Table)
            Optional entity or table of entities to ignore in collision detection

    Returns:
        Boolean indicating if the position is clear (true) or obstructed (false)

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Check if player can fit at position
        local canTeleport = lia.util.canFit(targetPosition)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Validate spawn position for entity
        local spawnPos = Vector(100, 200, 50)
        if lia.util.canFit(spawnPos, Vector(-16, -16, 0), Vector(16, 16, 72)) then
            local npc = ents.Create("npc_zombie")
            npc:SetPos(spawnPos)
            npc:Spawn()
        end
        ```

    High Complexity:
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
]]
function lia.util.canFit(pos, mins, maxs, filter)
    mins = mins ~= nil and mins or Vector(16, 16, 0)
    local tr = util.TraceHull({
        start = pos + Vector(0, 0, 1),
        mask = MASK_PLAYERSOLID,
        filter = filter,
        endpos = pos,
        mins = mins.x > 0 and mins * -1 or mins,
        maxs = maxs ~= nil and maxs or mins
    })
    return not tr.Hit
end

--[[
    Purpose:
        Find all players within a specified radius from a center position

    When Called:
        When you need to find players in a circular area for proximity-based operations like damage, effects, or area management

    Parameters:
        pos (Vector)
            The center position to check from
        dist (number)
            The radius distance to check within

    Returns:
        Table of player entities found within the specified radius

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find players within 100 units
        local nearbyPlayers = lia.util.playerInRadius(playerPos, 100)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Apply area effect to players in radius
        local explosionCenter = Vector(500, 300, 100)
        local affectedPlayers = lia.util.playerInRadius(explosionCenter, 200)

        for _, player in ipairs(affectedPlayers) do
            player:takeDamage(75)
            player:notify("You were caught in the blast!")
        end
        ```

    High Complexity:
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
]]
function lia.util.playerInRadius(pos, dist)
    dist = dist * dist
    local t = {}
    for _, client in player.Iterator() do
        if IsValid(client) and client:GetPos():DistToSqr(pos) < dist then t[#t + 1] = client end
    end
    return t
end

--[[
    Purpose:
        Format a string using named placeholders with flexible argument handling

    When Called:
        When you need to format strings with named parameters for localization, templating, or dynamic text generation

    Parameters:
        format (string)
            The format string containing {placeholder} patterns
        ... (mixed)
            Either a table with named keys or individual arguments to replace placeholders

    Returns:
        String with placeholders replaced by provided values

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Format string with individual arguments
        local message = lia.util.formatStringNamed("Hello {name}!", "John")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Format string with named parameters
        local data = {name = "Alice", score = 150}
        local message = lia.util.formatStringNamed("Player {name} scored {score} points!", data)
        ```

    High Complexity:
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
]]
function lia.util.formatStringNamed(format, ...)
    local arguments = {...}
    local bArray = false
    local input
    if istable(arguments[1]) then
        input = arguments[1]
    else
        input = arguments
        bArray = true
    end

    local i = 0
    local result = format:gsub("{(%w-)}", function(word)
        i = i + 1
        return tostring(bArray and input[i] or input[word] or word)
    end)
    return result
end

--[[
    Purpose:
        Get a cached material object from a file path, creating it if it doesn't exist

    When Called:
        When you need to load and cache materials for rendering, UI elements, or visual effects to improve performance

    Parameters:
        materialPath (string)
            The file path to the material (e.g., "materials/effects/blur.vmt")
        materialParameters (string)
            Optional parameters for material creation

    Returns:
        IMaterial object for the specified material path

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get a cached material
        local blurMaterial = lia.util.getMaterial("pp/blurscreen")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Use material for rendering effects
        local material = lia.util.getMaterial("effects/flashlight001")
        surface.SetMaterial(material)
        surface.SetDrawColor(255, 255, 255, 128)
        surface.DrawTexturedRect(x, y, w, h)
        ```

    High Complexity:
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
]]
function lia.util.getMaterial(materialPath, materialParameters)
    lia.util.cachedMaterials = lia.util.cachedMaterials or {}
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath, materialParameters)
    return lia.util.cachedMaterials[materialPath]
end

--[[
    Purpose:
        Find a faction by name or unique ID using flexible matching

    When Called:
        When you need to locate faction information for player assignment, permissions, or faction-based operations

    Parameters:
        client (Player)
            The player requesting the faction (for error notifications)
        name (string)
            The faction name or unique ID to search for

    Returns:
        Faction table if found, nil otherwise with error notification

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find faction by name
        local faction = lia.util.findFaction(player, "Security")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check faction before performing action
        local faction = lia.util.findFaction(client, factionName)
        if faction then
            player:setFaction(faction.index)
            client:notify("Player moved to " .. faction.name)
        end
        ```

    High Complexity:
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
]]
function lia.util.findFaction(client, name)
    if lia.faction.teams[name] then return lia.faction.teams[name] end
    for _, v in ipairs(lia.faction.indices) do
        if lia.util.stringMatches(v.name, name) or lia.util.stringMatches(v.uniqueID, name) then return v end
    end

    client:notifyErrorLocalized("invalidFaction")
    return nil
end

if system.IsLinux() then
    local cache = {}
    local function GetSoundPath(path, gamedir)
        if not gamedir then
            path = "sound/" .. path
            gamedir = "GAME"
        end
        return path, gamedir
    end

    local function f_IsWAV(f)
        f:Seek(8)
        return f:Read(4) == "WAVE"
    end

    local function f_SampleDepth(f)
        f:Seek(34)
        local bytes = {}
        for i = 1, 2 do
            bytes[i] = f:ReadByte(1)
        end

        local num = bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)
        return num
    end

    local function f_SampleRate(f)
        f:Seek(24)
        local bytes = {}
        for i = 1, 4 do
            bytes[i] = f:ReadByte(1)
        end

        local num = bit.lshift(bytes[4], 24) + bit.lshift(bytes[3], 16) + bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)
        return num
    end

    local function f_Channels(f)
        f:Seek(22)
        local bytes = {}
        for i = 1, 2 do
            bytes[i] = f:ReadByte(1)
        end

        local num = bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)
        return num
    end

    local function f_Duration(f)
        return (f:Size() - 44) / (f_SampleDepth(f) / 8 * f_SampleRate(f) * f_Channels(f))
    end

    liaSoundDuration = liaSoundDuration or SoundDuration
    function SoundDuration(str)
        local path, gamedir = GetSoundPath(str)
        local f = file.Open(path, "rb", gamedir)
        if not f then return 0 end
        local ret
        if cache[str] then
            ret = cache[str]
        elseif f_IsWAV(f) then
            ret = f_Duration(f)
        else
            ret = liaSoundDuration(str)
        end

        f:Close()
        return ret
    end
end

--[[
    Purpose:
        Generate a random full name by combining first and last names from provided or default lists

    When Called:
        When you need to create random character names for NPCs, testing, or procedural content generation

    Parameters:
        firstNames (table)
            Optional table of first names to choose from
        lastNames (table)
            Optional table of last names to choose from

    Returns:
        String containing a randomly generated full name (FirstName LastName)

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Generate a random name using defaults
        local randomName = lia.util.generateRandomName()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Generate name with custom name lists
        local fantasyFirstNames = {"Aragorn", "Legolas", "Gimli", "Frodo"}
        local fantasyLastNames = {"Stormwind", "Ironfist", "Shadowalker", "Lightbringer"}
        local fantasyName = lia.util.generateRandomName(fantasyFirstNames, fantasyLastNames)
        ```

    High Complexity:
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
]]
function lia.util.generateRandomName(firstNames, lastNames)
    local defaultFirstNames = {"John", "Jane", "Michael", "Sarah", "David", "Emily", "Robert", "Amanda", "James", "Jennifer", "William", "Elizabeth", "Richard", "Michelle", "Thomas", "Lisa", "Daniel", "Stephanie", "Matthew", "Nicole", "Anthony", "Samantha", "Charles", "Mary", "Joseph", "Patricia", "Christopher", "Linda", "Andrew", "Barbara", "Joshua", "Susan", "Ryan", "Jessica", "Brandon", "Helen", "Tyler", "Nancy", "Kevin", "Betty", "Jason", "Sandra", "Jacob", "Donna", "Kyle", "Carol", "Nathan", "Ruth", "Jeffrey", "Sharon", "Frank", "Michelle", "Scott", "Laura", "Steven", "Sarah", "Nicholas", "Kimberly", "Gregory", "Deborah", "Eric", "Dorothy", "Stephen", "Amy", "Timothy", "Angela", "Larry", "Melissa", "Jonathan", "Brenda", "Raymond", "Emma", "Patrick", "Anna", "Benjamin", "Rebecca", "Bryan", "Virginia", "Samuel", "Kathleen", "Alexander", "Pamela", "Jack", "Martha", "Dennis", "Debra", "Jerry", "Amanda", "Tyler", "Stephanie", "Aaron", "Christine", "Henry", "Marie", "Douglas", "Janet", "Peter", "Catherine", "Jose", "Frances", "Adam", "Ann", "Zachary", "Joyce", "Walter", "Diane", "Kenneth", "Alice", "Ryan", "Julie", "Gregory", "Heather", "Austin", "Teresa", "Keith", "Doris", "Samuel", "Gloria", "Gary", "Evelyn", "Jesse", "Jean", "Joe", "Cheryl", "Billy", "Mildred", "Bruce", "Katherine", "Gabriel", "Joan", "Roy", "Ashley", "Albert", "Judith", "Willie", "Rose", "Logan", "Janice", "Randy", "Kelly", "Louis", "Nicole", "Russell", "Judy", "Ralph", "Christina", "Sean", "Kathy", "Eugene", "Theresa", "Vincent", "Beverly", "Bobby", "Denise", "Johnny", "Tammy", "Bradley", "Irene", "Philip", "Jane", "Todd", "Lori", "Jesse", "Rachel", "Craig", "Marilyn", "Alan", "Andrea", "Shawn", "Kathryn", "Clarence", "Louise", "Sean", "Sara", "Victor", "Anne", "Jimmy", "Jacqueline", "Chad", "Wanda", "Phillip", "Bonnie", "Travis", "Julia", "Carlos", "Ruby", "Shane", "Lois", "Ronald", "Tina", "Brandon", "Phyllis", "Angel", "Norma", "Russell", "Paula", "Harold", "Diana", "Dustin", "Annie", "Pedro", "Lillian", "Shawn", "Emily", "Colin", "Robin", "Brian", "Rita"}
    local defaultLastNames = {"Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts", "Gomez", "Phillips", "Evans", "Turner", "Diaz", "Parker", "Cruz", "Edwards", "Collins", "Reyes", "Stewart", "Morris", "Morales", "Murphy", "Cook", "Rogers", "Gutierrez", "Ortiz", "Morgan", "Cooper", "Peterson", "Bailey", "Reed", "Kelly", "Howard", "Ramos", "Kim", "Cox", "Ward", "Richardson", "Watson", "Brooks", "Chavez", "Wood", "James", "Bennett", "Gray", "Mendoza", "Ruiz", "Hughes", "Price", "Alvarez", "Castillo", "Sanders", "Patel", "Myers", "Long", "Ross", "Foster", "Jimenez", "Powell", "Jenkins", "Perry", "Russell", "Sullivan", "Bell", "Coleman", "Butler", "Henderson", "Barnes", "Gonzales", "Fisher", "Vasquez", "Simmons", "Romero", "Jordan", "Patterson", "Alexander", "Hamilton", "Graham", "Reynolds", "Griffin", "Wallace", "Moreno", "West", "Cole", "Hayes", "Bryant", "Herrera", "Gibson", "Ellis", "Tran", "Medina", "Aguilar", "Stevens", "Murray", "Ford", "Castro", "Marshall", "Owens", "Harrison", "Fernandez", "McDonald", "Woods", "Washington", "Kennedy", "Wells", "Vargas", "Henry", "Chen", "Freeman", "Webb", "Tucker", "Guzman", "Burns", "Crawford", "Olson", "Simpson", "Porter", "Hunter", "Gordon", "Mendez", "Silva", "Shaw", "Snyder", "Mason", "Dixon", "Munoz", "Hunt", "Hicks", "Holmes", "Palmer", "Wagner", "Black", "Robertson", "Boyd", "Rose", "Stone", "Salazar", "Fox", "Warren", "Mills", "Meyer", "Rice", "Schmidt", "Garza", "Daniels", "Ferguson", "Nichols", "Stephens", "Soto", "Weaver", "Ryan", "Gardner", "Payne", "Grant", "Dunn", "Kelley", "Spencer", "Hawkins", "Arnold", "Pierce", "Vazquez", "Hansen", "Peters", "Santos", "Hart", "Bradley", "Knight", "Elliott", "Cunningham", "Duncan", "Armstrong", "Hudson", "Carroll", "Lane", "Riley", "Andrews", "Alvarado", "Ray", "Delgado", "Berry", "Perkins", "Hoffman", "Johnston", "Matthews", "Pena", "Richards", "Contreras", "Willis", "Carpenter", "Lawrence", "Sandoval"}
    local firstNameList = firstNames or defaultFirstNames
    local lastNameList = lastNames or defaultLastNames
    if not istable(firstNameList) or #firstNameList == 0 then firstNameList = defaultFirstNames end
    if not istable(lastNameList) or #lastNameList == 0 then lastNameList = defaultLastNames end
    local firstIndex = math.random(1, #firstNameList)
    local lastIndex = math.random(1, #lastNameList)
    return firstNameList[firstIndex] .. " " .. lastNameList[lastIndex]
end

if SERVER then
    --[[
    Purpose:
        Send a table-based user interface to a specific client for displaying data in a structured format

    When Called:
        When you need to display tabular data to a player, such as inventories, player lists, or administrative information

    Parameters:
        client (Player)
            The player to send the table UI to
        title (string)
            The title of the table window
        columns (table)
            Array of column definitions with name, width, and other properties
        data (table)
            Array of row data to display in the table
        options (table)
            Optional configuration options for the table UI
        characterID (number)
            Optional character ID for character-specific data

    Returns:
        Nothing (sends network message to client)

    Realm:
        Server

    Example Usage:

    Low Complexity:
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

    Medium Complexity:
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

    High Complexity:
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
]]
    function lia.util.sendTableUI(client, title, columns, data, options, characterID)
        if not IsValid(client) or not client:IsPlayer() then return end
        local localizedColumns = {}
        for i, colInfo in ipairs(columns or {}) do
            local localizedColInfo = table.Copy(colInfo)
            if localizedColInfo.name then localizedColInfo.name = L(localizedColInfo.name) end
            localizedColumns[i] = localizedColInfo
        end

        local tableUIData = {
            title = title and L(title) or L("tableListTitle"),
            columns = localizedColumns,
            data = data,
            options = options or {},
            characterID = characterID
        }

        lia.net.writeBigTable(client, "liaSendTableUI", tableUIData)
    end

    --[[
    Purpose:
        Find empty spaces around an entity for spawning or placement purposes

    When Called:
        When you need to find valid locations to spawn entities, NPCs, or items around a central position

    Parameters:
        entity (Entity)
            The central entity to search around
        filter (Entity/Table)
            Optional entity or table of entities to ignore in collision detection
        spacing (number)
            Distance between each tested position (default: 32)
        size (number)
            Grid size to search in (default: 3, meaning -3 to +3 in both x and y)
        height (number)
            Height of the area to check for collisions (default: 36)
        tolerance (number)
            Additional clearance above ground (default: 5)

    Returns:
        Table of valid Vector positions sorted by distance from the entity

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find nearby empty spaces
        local emptySpaces = lia.util.findEmptySpace(someEntity)
        ```

    Medium Complexity:
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

    High Complexity:
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
]]
    function lia.util.findEmptySpace(entity, filter, spacing, size, height, tolerance)
        spacing = spacing or 32
        size = size or 3
        height = height or 36
        tolerance = tolerance or 5
        local position = entity:GetPos()
        local mins = Vector(-spacing * 0.5, -spacing * 0.5, 0)
        local maxs = Vector(spacing * 0.5, spacing * 0.5, height)
        local output = {}
        for x = -size, size do
            for y = -size, size do
                local origin = position + Vector(x * spacing, y * spacing, 0)
                local data = {}
                data.start = origin + mins + Vector(0, 0, tolerance)
                data.endpos = origin + maxs
                data.filter = filter or entity
                local trace = util.TraceLine(data)
                data.start = origin + Vector(-maxs.x, -maxs.y, tolerance)
                data.endpos = origin + Vector(mins.x, mins.y, height)
                local trace2 = util.TraceLine(data)
                if trace.StartSolid or trace.Hit or trace2.StartSolid or trace2.Hit or not util.IsInWorld(origin) then continue end
                output[#output + 1] = origin
            end
        end

        table.sort(output, function(a, b) return a:Distance(position) < b:Distance(position) end)
        return output
    end
else
    lia.util.ShadowText = lia.derma.shadowText
    lia.util.DrawTextOutlined = lia.derma.drawTextOutlined
    lia.util.DrawTip = lia.derma.drawTip
    lia.util.drawText = lia.derma.drawText
    lia.util.drawTexture = lia.derma.drawSurfaceTexture
    lia.util.skinFunc = lia.derma.skinFunc
    lia.util.approachExp = lia.derma.approachExp
    lia.util.easeOutCubic = lia.derma.easeOutCubic
    lia.util.easeInOutCubic = lia.derma.easeInOutCubic
    --[[
    Purpose:
        Animate a panel's appearance with scaling, positioning, and alpha transitions

    When Called:
        When you need to create smooth entrance animations for UI panels, menus, or dialog boxes

    Parameters:
        panel (Panel)
            The DPanel to animate
        target_w (number)
            Target width for the animation
        target_h (number)
            Target height for the animation
        duration (number)
            Duration of size/position animation in seconds (default: 0.18)
        alpha_dur (number)
            Duration of alpha animation in seconds (default: same as duration)
        callback (function)
            Optional callback function to execute when animation completes
        scale_factor (number)
            Scale factor for initial size (default: 0.8)

    Returns:
        Nothing (modifies panel directly)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Basic panel appearance animation
        local panel = vgui.Create("DPanel")
        panel:SetSize(200, 100)
        lia.util.animateAppearance(panel, 200, 100)
        ```

    Medium Complexity:
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

    High Complexity:
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
]]
    function lia.util.animateAppearance(panel, target_w, target_h, duration, alpha_dur, callback, scale_factor)
        local scaleFactor = 0.8
        if not IsValid(panel) then return end
        duration = (duration and duration > 0) and duration or 0.18
        alpha_dur = (alpha_dur and alpha_dur > 0) and alpha_dur or duration
        local targetX, targetY = panel:GetPos()
        local initialW = target_w * (scale_factor and scale_factor or scaleFactor)
        local initialH = target_h * (scale_factor and scale_factor or scaleFactor)
        local initialX = targetX + (target_w - initialW) / 2
        local initialY = targetY + (target_h - initialH) / 2
        panel:SetSize(initialW, initialH)
        panel:SetPos(initialX, initialY)
        panel:SetAlpha(0)
        local curW, curH = initialW, initialH
        local curX, curY = initialX, initialY
        local curA = 0
        local eps = 0.5
        local alpha_eps = 1
        local speedSize = 3 / math.max(0.0001, duration)
        local speedAlpha = 3 / math.max(0.0001, alpha_dur)
        panel.Think = function()
            if not IsValid(panel) then return end
            local dt = FrameTime()
            curW = lia.util.approachExp(curW, target_w, speedSize, dt)
            curH = lia.util.approachExp(curH, target_h, speedSize, dt)
            curX = lia.util.approachExp(curX, targetX, speedSize, dt)
            curY = lia.util.approachExp(curY, targetY, speedSize, dt)
            curA = lia.util.approachExp(curA, 255, speedAlpha, dt)
            panel:SetSize(curW, curH)
            panel:SetPos(curX, curY)
            panel:SetAlpha(math.floor(curA + 0.5))
            local doneSize = math.abs(curW - target_w) <= eps and math.abs(curH - target_h) <= eps
            local donePos = math.abs(curX - targetX) <= eps and math.abs(curY - targetY) <= eps
            local doneAlpha = math.abs(curA - 255) <= alpha_eps
            if doneSize and donePos and doneAlpha then
                panel:SetSize(target_w, target_h)
                panel:SetPos(targetX, targetY)
                panel:SetAlpha(255)
                panel.Think = nil
                if callback then callback(panel) end
            end
        end
    end

    --[[
    Purpose:
        Clamp a panel's position to stay within screen boundaries while avoiding UI overlap

    When Called:
        When you need to ensure menus and panels stay visible and don't overlap with important UI elements like logos

    Parameters:
        panel (Panel)
            The DPanel whose position should be clamped

    Returns:
        Nothing (modifies panel position directly)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Keep panel within screen bounds
        local panel = vgui.Create("DPanel")
        panel:SetPos(ScrW() + 100, ScrH() + 50) -- Off-screen position
        lia.util.clampMenuPosition(panel) -- Will move panel back on screen
        ```

    Medium Complexity:
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

    High Complexity:
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
]]
    function lia.util.clampMenuPosition(panel)
        if not IsValid(panel) then return end
        local x, y = panel:GetPos()
        local w, h = panel:GetSize()
        local sw, sh = ScrW(), ScrH()
        local logoMargin = 0
        if IsValid(lia.gui.character) and IsValid(lia.gui.character.logo) then
            local logoX, logoY = lia.gui.character.logo:GetPos()
            local logoW, logoH = lia.gui.character.logo:GetSize()
            local logoRight = logoX + logoW
            local logoBottom = logoY + logoH
            if x < logoRight and x + w > logoX and y < logoBottom and y + h > logoY then logoMargin = logoH + (ScrH() * 0.01) end
        end

        if x < 5 then
            x = 5
        elseif x + w > sw - 5 then
            x = sw - 5 - w
        end

        if y < 5 then
            y = 5
        elseif y + h > sh - 5 then
            y = sh - 5 - h
        end

        if logoMargin > 0 and y < logoMargin then y = logoMargin end
        panel:SetPos(x, y)
    end

    --[[
    Purpose:
        Draw a gradient background using predefined gradient materials

    When Called:
        When you need to create gradient backgrounds for UI elements, panels, or visual effects

    Parameters:
        _x (number)
            X position to draw the gradient
        _y (number)
            Y position to draw the gradient
        _w (number)
            Width of the gradient area
        _h (number)
            Height of the gradient area
        direction (number)
            Gradient direction (1=up, 2=down, 3=left, 4=right)
        color_shadow (Color)
            Color for the gradient shadow effect
        radius (number)
            Corner radius for rounded gradients (default: 0)
        flags (number)
            Material flags for rendering

    Returns:
        Nothing (draws directly to screen)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Draw a basic gradient background
        lia.util.drawGradient(100, 100, 200, 150, 2, Color(0, 0, 0, 150))
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create a gradient panel background
        local panel = vgui.Create("DPanel")
        panel.Paint = function(self, w, h)
            lia.util.drawGradient(0, 0, w, h, 2, Color(50, 50, 50, 200), 8)
        end
        ```

    High Complexity:
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
]]
    function lia.util.drawGradient(_x, _y, _w, _h, direction, color_shadow, radius, flags)
        local listGradients = {Material("vgui/gradient_up"), Material("vgui/gradient_down"), Material("vgui/gradient-l"), Material("vgui/gradient-r")}
        radius = radius and radius or 0
        lia.derma.drawMaterial(radius, _x, _y, _w, _h, color_shadow, listGradients[direction], flags)
    end

    --[[
    Purpose:
        Wrap text to fit within a specified width, breaking it into multiple lines

    When Called:
        When you need to display text that might be too long for a UI element, ensuring it wraps properly

    Parameters:
        text (string)
            The text to wrap
        width (number)
            Maximum width in pixels for the text
        font (string)
            Font to use for text measurement (default: "LiliaFont.16")

    Returns:
        Table of wrapped text lines, Number: Maximum width of any line

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Wrap text to fit in a label
        local lines, maxWidth = lia.util.wrapText("This is a long text that needs wrapping", 200)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create a multi-line label with wrapped text
        local text = "This is a very long description that should wrap to multiple lines when displayed in the UI."
        local lines, maxWidth = lia.util.wrapText(text, 300, "LiliaFont.17")

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

    High Complexity:
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
]]
    function lia.util.wrapText(text, width, font)
        font = font or "LiliaFont.16"
        surface.SetFont(font)
        local exploded = string.Explode("%s", text, true)
        local line = ""
        local lines = {}
        local w = surface.GetTextSize(text)
        local maxW = 0
        if w <= width then
            text, _ = text:gsub("%s", " ")
            return {text}, w
        end

        for i = 1, #exploded do
            local word = exploded[i]
            line = line .. " " .. word
            w = surface.GetTextSize(line)
            if w > width then
                lines[#lines + 1] = line
                line = ""
                if w > maxW then maxW = w end
            end
        end

        if line ~= "" then lines[#lines + 1] = line end
        return lines, maxW
    end

    --[[
    Purpose:
        Draw a blur effect behind a panel using screen-space blurring

    When Called:
        When you need to create a blurred background effect for UI elements like menus or dialogs

    Parameters:
        panel (Panel)
            The panel to draw blur behind
        amount (number)
            Intensity of the blur effect (default: 5)
        _ (any)
            Unused parameter (legacy)
        alpha (number)
            Alpha transparency of the blur effect (default: 255)

    Returns:
        Nothing (draws directly to screen)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add basic blur behind a panel
        local panel = vgui.Create("DPanel")
        lia.util.drawBlur(panel, 5, nil, 200)
        ```

    Medium Complexity:
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

    High Complexity:
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
]]
    function lia.util.drawBlur(panel, amount, _, alpha)
        amount = amount or 5
        alpha = alpha or 255
        local maxPasses = 3
        surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
        surface.SetDrawColor(255, 255, 255, alpha)
        local x, y = panel:LocalToScreen(0, 0)
        local blurMat = lia.util.getMaterial("pp/blurscreen")
        for i = 0, maxPasses do
            local blurValue = (i / maxPasses) * amount
            blurMat:SetFloat("$blur", blurValue)
            blurMat:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
        end
    end

    --[[
    Purpose:
        Draw a black blur effect with enhanced darkness behind a panel

    When Called:
        When you need to create a darker, more opaque blurred background effect for UI elements

    Parameters:
        panel (Panel)
            The panel to draw blur behind
        amount (number)
            Intensity of the blur effect (default: 6)
        passes (number)
            Number of blur passes for quality (default: 5, minimum: 1)
        alpha (number)
            Alpha transparency of the blur effect (default: 255)
        darkAlpha (number)
            Alpha transparency of the dark overlay (default: 220)

    Returns:
        Nothing (draws directly to screen)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add dark blur behind a panel
        local panel = vgui.Create("DPanel")
        lia.util.drawBlackBlur(panel, 6, 5, 255, 220)
        ```

    Medium Complexity:
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

    High Complexity:
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
]]
    function lia.util.drawBlackBlur(panel, amount, passes, alpha, darkAlpha)
        if not IsValid(panel) then return end
        amount = amount or 6
        passes = math.max(1, passes or 5)
        alpha = alpha or 255
        darkAlpha = darkAlpha or 220
        local mat = lia.util.getMaterial("pp/blurscreen")
        local x, y = panel:LocalToScreen(0, 0)
        x = math.floor(x)
        y = math.floor(y)
        local sw, sh = ScrW(), ScrH()
        local expand = 4
        render.UpdateScreenEffectTexture()
        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, alpha)
        for i = 1, passes do
            mat:SetFloat("$blur", i / passes * amount)
            mat:Recompute()
            surface.DrawTexturedRectUV(-x - expand, -y - expand, sw + expand * 2, sh + expand * 2, 0, 0, 1, 1)
        end

        surface.SetDrawColor(0, 0, 0, darkAlpha)
        surface.DrawRect(x, y, panel:GetWide(), panel:GetTall())
    end

    --[[
    Purpose:
        Draw a blur effect at specific screen coordinates

    When Called:
        When you need to apply blur effects to specific screen areas for HUD elements or overlays

    Parameters:
        x (number)
            X position to draw the blur
        y (number)
            Y position to draw the blur
        w (number)
            Width of the blur area
        h (number)
            Height of the blur area
        amount (number)
            Intensity of the blur effect (default: 5)
        passes (number)
            Number of blur passes (default: 0.2)
        alpha (number)
            Alpha transparency of the blur effect (default: 255)

    Returns:
        Nothing (draws directly to screen)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Blur a specific screen area
        lia.util.drawBlurAt(100, 100, 200, 150, 5, 0.2, 255)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create a blurred HUD overlay for damage effects
        local function drawDamageOverlay(damage)
            local alpha = math.Clamp(damage * 2, 0, 200)
            lia.util.drawBlurAt(0, 0, ScrW(), ScrH(), 3, 0.3, alpha)
        end
        ```

    High Complexity:
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
]]
    function lia.util.drawBlurAt(x, y, w, h, amount, passes, alpha)
        amount = amount or 5
        alpha = alpha or 255
        surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
        surface.SetDrawColor(255, 255, 255, alpha)
        local x2, y2 = x / ScrW(), y / ScrH()
        local w2, h2 = (x + w) / ScrW(), (y + h) / ScrH()
        for i = -(passes or 0.2), 1, 0.2 do
            lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
            lia.util.getMaterial("pp/blurscreen"):Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
        end
    end

    lia.util.requestArguments = lia.derma.requestArguments
    --[[
    Purpose:
        Request entity information from the user using a dialog, and optionally remove the entity if cancelled

    When Called:
        When you need to get information from a user about an entity, and want to remove the entity if they cancel

    Parameters:
        entity (Entity)
            The entity to potentially remove if the user cancels
        argTypes (table)
            Table of argument types in the format {"name" = "string"} or {"name" = {"string", options}}
        callback (function)
            Function to call with the information when the user submits. Receives the information table as parameter.

    Returns:
        Nothing (opens a dialog)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Request name for an entity
        lia.util.requestEntityInformation(entity, {name = "string"}, function(information)
            print("Name entered: " .. information.name)
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Request multiple fields
        lia.util.requestEntityInformation(entity, {
            ["name"] = "string",
            ["description"] = "string",
            ["type"] = {"table", {"option1", "option2", "option3"}}
        }, function(information)
            -- Process the information
            entity:SetNWString("Name", information.name)
        end)
        ```
    ]]
    function lia.util.requestEntityInformation(entity, argTypes, callback)
        if not IsValid(entity) then
            ErrorNoHalt("[lia.util.requestEntityInformation] Invalid entity provided\n")
            return
        end

        lia.derma.requestArguments("Entity Information", argTypes, function(success, information)
            if not success then
                if IsValid(entity) then entity:Remove() end
            else
                if isfunction(callback) then callback(information) end
            end
        end)
    end

    --[[
    Purpose:
        Create a complete table-based UI window for displaying data with interactive features

    When Called:
        When you need to display tabular data with sorting, actions, and interactive options

    Parameters:
        title (string)
            Title for the table window
        columns (table)
            Array of column definitions
        data (table)
            Array of row data to display
        options (table)
            Optional action buttons and configurations
        charID (number)
            Character ID for character-specific data

    Returns:
        Frame, ListView: The created frame and list view objects

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Create basic table UI
        local frame, listView = lia.util.createTableUI("Player List", columns, playerData)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create table with action options
        local options = {
            {name = "Teleport", net = "liaTeleportTo"},
            {name = "Kick",     net = "liaKickPlayer"}
        }
        local frame, listView = lia.util.createTableUI("Admin Panel", columns, data, options, charID)
        ```

    High Complexity:
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
]]
    function lia.util.createTableUI(title, columns, data, options, charID)
        local frameWidth, frameHeight = ScrW() * 0.8, ScrH() * 0.8
        local frame = vgui.Create("liaFrame")
        frame:SetTitle(title and L(title) or L("tableListTitle"))
        frame:SetSize(frameWidth, frameHeight)
        frame:Center()
        frame:MakePopup()
        frame:ShowCloseButton(true)
        frame.Paint = function(self, w, h)
            lia.util.drawBlur(self, 4)
            draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
        end

        local listView = frame:Add("liaTable")
        listView:Dock(FILL)
        for _, colInfo in ipairs(columns or {}) do
            local localizedName = colInfo.name and L(colInfo.name) or L("na")
            listView:AddColumn(localizedName, colInfo.width, colInfo.align, colInfo.sortable)
        end

        for _, row in ipairs(data) do
            local lineData = {}
            for _, colInfo in ipairs(columns) do
                table.insert(lineData, row[colInfo.field] or L("na"))
            end

            local line = listView:AddLine(unpack(lineData))
            line.rowData = row
        end

        listView:AddMenuOption(L("copyRow"), function(rowData)
            local rowString = ""
            for key, value in pairs(rowData) do
                value = tostring(value or L("na"))
                key = tostring(key)
                rowString = rowString .. key:gsub("^%l", string.upper) .. " " .. value .. " | "
            end

            rowString = rowString:sub(1, -4)
            SetClipboardText(rowString)
        end)

        for _, option in ipairs(istable(options) and options or {}) do
            listView:AddMenuOption(option.name and L(option.name) or option.name, function()
                if not option.net then return end
                if option.ExtraFields then
                    local inputPanel = vgui.Create("liaFrame")
                    inputPanel:SetTitle(L("optionsTitle", option.name))
                    inputPanel:SetSize(300, 300 + #table.GetKeys(option.ExtraFields) * 35)
                    inputPanel:Center()
                    inputPanel:MakePopup()
                    local form = vgui.Create("DForm", inputPanel)
                    form:Dock(FILL)
                    form:SetLabel("")
                    form.Paint = function() end
                    local inputs = {}
                    for fName, fType in pairs(option.ExtraFields) do
                        local label = vgui.Create("DLabel", form)
                        label:SetText(fName)
                        label:Dock(TOP)
                        label:DockMargin(5, 10, 5, 0)
                        form:AddItem(label)
                        if isstring(fType) and fType == "text" then
                            local entry = vgui.Create("DTextEntry", form)
                            entry:Dock(TOP)
                            entry:DockMargin(5, 5, 5, 0)
                            entry:SetPlaceholderText(L("typeFieldPrompt", fName))
                            form:AddItem(entry)
                            inputs[fName] = {
                                panel = entry,
                                ftype = "text"
                            }
                        elseif isstring(fType) and fType == "combo" then
                            local combo = vgui.Create("liaComboBox", form)
                            combo:Dock(TOP)
                            combo:DockMargin(5, 5, 5, 0)
                            combo:PostInit()
                            combo:SetValue(L("selectPrompt", fName))
                            form:AddItem(combo)
                            inputs[fName] = {
                                panel = combo,
                                ftype = "combo"
                            }
                        elseif istable(fType) then
                            local combo = vgui.Create("liaComboBox", form)
                            combo:Dock(TOP)
                            combo:DockMargin(5, 5, 5, 0)
                            combo:PostInit()
                            combo:SetValue(L("selectPrompt", fName))
                            for _, choice in ipairs(fType) do
                                combo:AddChoice(choice)
                            end

                            combo:FinishAddingOptions()
                            form:AddItem(combo)
                            inputs[fName] = {
                                panel = combo,
                                ftype = "combo"
                            }
                        end
                    end

                    local submitButton = vgui.Create("DButton", form)
                    submitButton:SetText(L("submit"))
                    submitButton:Dock(TOP)
                    submitButton:DockMargin(5, 10, 5, 0)
                    form:AddItem(submitButton)
                    submitButton.DoClick = function()
                        local values = {}
                        for fName, info in pairs(inputs) do
                            if not IsValid(info.panel) then continue end
                            if info.ftype == "text" then
                                values[fName] = info.panel:GetValue() or ""
                            elseif info.ftype == "combo" then
                                values[fName] = info.panel:GetSelected() or ""
                            end
                        end

                        net.Start(option.net)
                        net.WriteInt(charID, 32)
                        net.WriteTable(listView.rows[rowIndex])
                        for _, fVal in pairs(values) do
                            if isnumber(fVal) then
                                net.WriteInt(fVal, 32)
                            else
                                net.WriteString(fVal)
                            end
                        end

                        net.SendToServer()
                        inputPanel:Close()
                        frame:Remove()
                    end
                else
                    net.Start(option.net)
                    net.WriteInt(charID, 32)
                    net.WriteTable(listView.rows[rowIndex])
                    net.SendToServer()
                    frame:Remove()
                end
            end)
        end

        timer.Simple(0.1, function()
            if IsValid(frame) and IsValid(listView) then
                frame:InvalidateLayout(true)
                listView:InvalidateLayout(true)
                frame:SizeToChildren(false, true)
            end
        end)
        return frame, listView
    end

    --[[
    Purpose:
        Create and display an options menu with interactive buttons

    When Called:
        When you need to present a list of options or actions to the user in a popup menu

    Parameters:
        title (string)
            Title for the options menu
        options (table)
            Array of option objects or key-value pairs with name and callback properties

    Returns:
        Frame: The created options menu frame

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Create basic options menu
        local frame = lia.util.openOptionsMenu("Choose Action", {
        {name = "Option 1", callback = function() print("Option 1 selected") end},
        {name = "Option 2", callback = function() print("Option 2 selected") end}
        })
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create contextual options menu
        local options = {
            ["Heal Player"] = function() healTargetPlayer(target) end,
            ["Teleport"]    = function() teleportToTarget(target) end,
            ["Give Item"]   = function() openGiveItemMenu(target) end
        }
        lia.util.openOptionsMenu("Player Actions", options)
        ```

    High Complexity:
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
]]
    function lia.util.openOptionsMenu(title, options)
        if not istable(options) then return end
        local entries = {}
        if options[1] then
            for _, opt in ipairs(options) do
                if isstring(opt.name) and isfunction(opt.callback) then entries[#entries + 1] = opt end
            end
        else
            for name, callback in pairs(options) do
                if isfunction(callback) then
                    entries[#entries + 1] = {
                        name = name,
                        callback = callback
                    }
                end
            end
        end

        if #entries == 0 then return end
        local frameW, entryH = 300, 30
        local frameH = entryH * #entries + 50
        local frame = vgui.Create("liaFrame")
        frame:SetSize(frameW, frameH)
        frame:Center()
        frame:MakePopup()
        frame:SetTitle("")
        frame:ShowCloseButton(true)
        frame.Paint = function(self, w, h)
            lia.util.drawBlur(self, 4)
            draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
        end

        local titleLabel = frame:Add("DLabel")
        titleLabel:SetPos(0, 8)
        titleLabel:SetSize(frameW, 20)
        titleLabel:SetText(L(title or "options"))
        titleLabel:SetFont("LiliaFont.17")
        titleLabel:SetColor(color_white)
        titleLabel:SetContentAlignment(5)
        local layout = frame:Add("DListLayout")
        layout:Dock(FILL)
        layout:DockMargin(10, 32, 10, 10)
        for _, opt in ipairs(entries) do
            local btn = layout:Add("DButton")
            btn:SetTall(entryH)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 5)
            btn:SetText(L(opt.name))
            btn:SetFont("LiliaFont.17")
            btn:SetTextColor(color_white)
            btn:SetContentAlignment(5)
            btn.Paint = function(self, w, h)
                if self:IsHovered() then
                    draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 160))
                else
                    draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 100))
                end
            end

            btn.DoClick = function()
                frame:Close()
                opt.callback()
            end
        end
        return frame
    end

    local vectorMeta = FindMetaTable("Vector")
    local toScreen = vectorMeta and vectorMeta.ToScreen or function()
        return {
            x = 0,
            y = 0,
            visible = false
        }
    end

    local defaultTheme = {
        background_alpha = Color(34, 34, 34, 210),
        header = Color(34, 34, 34, 210),
        accent = Color(255, 255, 255, 180),
        text = Color(255, 255, 255)
    }

    local function scaleColorAlpha(col, scale)
        col = col or defaultTheme.background_alpha
        local a = col.a or 255
        return Color(col.r, col.g, col.b, math.Clamp(a * scale, 0, 255))
    end

    local function EntText(text, x, y, fade)
        surface.SetFont("LiliaFont.24")
        local tw, th = surface.GetTextSize(text)
        local bx, by = math.Round(x - tw * 0.5 - 8), math.Round(y - 8)
        local bw, bh = tw + 16, th + 16
        local theme = lia.color.theme or defaultTheme
        local fadeAlpha = math.Clamp(fade, 0, 1)
        local headerColor = scaleColorAlpha(theme.background_panelpopup or theme.header or defaultTheme.header, fadeAlpha)
        local accentColor = scaleColorAlpha(theme.theme or theme.text or defaultTheme.accent, fadeAlpha)
        local textColor = scaleColorAlpha(theme.text or defaultTheme.text, fadeAlpha)
        lia.util.drawBlurAt(bx, by, bw, bh - 6, 6, 0.2, math.floor(fadeAlpha * 255))
        lia.derma.rect(bx, by, bw, bh - 6):Radii(8, 8, 0, 0):Color(headerColor):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(bx, by + bh - 6, bw, 6):Radii(0, 0, 8, 8):Color(accentColor):Draw()
        draw.SimpleText(text, "LiliaFont.24", math.Round(x), math.Round(y - 2), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        return bh
    end

    lia.util.entsScales = lia.util.entsScales or {}
    --[[
    Purpose:
        Draw floating text above an entity with distance-based fade effects

    When Called:
        When you need to display information or labels above entities in the 3D world

    Parameters:
        ent (Entity)
            The entity to draw text above
        text (string)
            The text to display
        posY (number)
            Vertical offset for text positioning (default: 0)
        alphaOverride (number)
            Optional alpha override for manual control

    Returns:
        Nothing (draws directly to screen)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Draw text above an entity
        lia.util.drawEntText(someEntity, "Important Item")
        ```

    Medium Complexity:
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

    High Complexity:
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
]]
    function lia.util.drawEntText(ent, text, posY, alphaOverride)
        if not (IsValid(ent) and text and text ~= "") then return end
        posY = posY or 0
        local distSqr = EyePos():DistToSqr(ent:GetPos())
        local maxDist = 380
        if distSqr > maxDist * maxDist then return end
        local dist = math.sqrt(distSqr)
        local minDist = 20
        local idx = ent:EntIndex()
        local prev = lia.util.entsScales[idx] or 0
        local normalized = math.Clamp((maxDist - dist) / math.max(1, maxDist - minDist), 0, 1)
        local appearThreshold = 0.8
        local disappearThreshold = 0.01
        local target
        if normalized <= disappearThreshold then
            target = 0
        elseif normalized >= appearThreshold then
            target = 1
        else
            target = (normalized - disappearThreshold) / (appearThreshold - disappearThreshold)
        end

        local dt = FrameTime() or 0.016
        local appearSpeed = 18
        local disappearSpeed = 12
        local speed = (target > prev) and appearSpeed or disappearSpeed
        local cur = lia.util.approachExp(prev, target, speed, dt)
        if math.abs(cur - target) < 0.0005 then cur = target end
        if cur == 0 and target == 0 then
            lia.util.entsScales[idx] = nil
            return
        end

        lia.util.entsScales[idx] = cur
        local eased = lia.util.easeInOutCubic(cur)
        if eased <= 0 then return end
        local fade = eased
        if alphaOverride then
            if alphaOverride > 1 then
                fade = fade * math.Clamp(alphaOverride / 255, 0, 1)
            else
                fade = fade * math.Clamp(alphaOverride, 0, 1)
            end
        end

        if fade <= 0 then return end
        local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
        local _, rotatedMax = ent:GetRotatedAABB(mins, maxs)
        local bob = math.sin(CurTime() + idx) / 3 + 0.5
        local center = ent:LocalToWorld(ent:OBBCenter()) + Vector(0, 0, math.abs(rotatedMax.z / 2) + 12 + bob)
        local screenPos = toScreen(center)
        if screenPos.visible == false then return end
        EntText(text, screenPos.x, screenPos.y + posY, fade)
    end

    --[[
    Purpose:
        Draw floating text at the player's look position with distance-based fade effects

    When Called:
        When you need to display contextual information at the location the player is looking at

    Parameters:
        text (string)
            The text to display
        posY (number)
            Vertical offset for text positioning (default: 0)
        alphaOverride (number)
            Optional alpha override for manual control
        maxDist (number)
            Maximum distance to display text (default: 380)

    Returns:
        Nothing (draws directly to screen)

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Draw text where player is looking
        lia.util.drawLookText("Target Location")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Show distance-based information
        local trace = LocalPlayer():GetEyeTrace()
        if trace.Hit then
            local distance = math.Round(trace.HitPos:Distance(LocalPlayer():GetPos()))
            lia.util.drawLookText("Distance: " .. distance .. " units", 20)
        end
        ```

    High Complexity:
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
]]
    function lia.util.drawLookText(text, posY, alphaOverride, maxDist)
        if not (text and text ~= "") then return end
        posY = posY or 0
        maxDist = maxDist or 380
        local trace = util.TraceLine({
            start = EyePos(),
            endpos = EyePos() + EyeAngles():Forward() * maxDist,
            filter = LocalPlayer()
        })

        if not trace.Hit then return end
        local distSqr = EyePos():DistToSqr(trace.HitPos)
        if distSqr > maxDist * maxDist then return end
        local dist = math.sqrt(distSqr)
        local minDist = 20
        local normalized = math.Clamp((maxDist - dist) / math.max(1, maxDist - minDist), 0, 1)
        local appearThreshold = 0.8
        local disappearThreshold = 0.01
        local target
        if normalized <= disappearThreshold then
            target = 0
        elseif normalized >= appearThreshold then
            target = 1
        else
            target = (normalized - disappearThreshold) / (appearThreshold - disappearThreshold)
        end

        local dt = FrameTime() or 0.016
        local appearSpeed = 18
        local disappearSpeed = 12
        local cur = lia.util.approachExp(0, target, (target > 0) and appearSpeed or disappearSpeed, dt)
        if cur <= 0 then return end
        local fade = lia.util.easeInOutCubic(cur)
        if alphaOverride then
            if alphaOverride > 1 then
                fade = fade * math.Clamp(alphaOverride / 255, 0, 1)
            else
                fade = fade * math.Clamp(alphaOverride, 0, 1)
            end
        end

        if fade <= 0 then return end
        local screenPos = toScreen(trace.HitPos)
        if screenPos.visible == false then return end
        EntText(text, screenPos.x, screenPos.y + posY, fade)
    end
end
