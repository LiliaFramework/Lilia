--[[
    Folder: Libraries
    File: util.md
]]
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
        Finds all players within an axis-aligned bounding box.

    When Called:
        Use when you need the players contained inside specific world bounds (e.g. triggers or zones).

    Parameters:
        mins (Vector)
            Minimum corner of the search box.
        maxs (Vector)
            Maximum corner of the search box.

    Returns:
        table
            List of player entities inside the box.

    Realm:
        Shared

    Example Usage:
        ```lua
            local players = lia.util.findPlayersInBox(Vector(-128, -128, 0), Vector(128, 128, 128))
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
        Locates a connected player by SteamID or SteamID64 and requires an active character.

    When Called:
        Use when commands or systems need to resolve a Steam identifier to a live player with a character loaded.

    Parameters:
        steamID (string)
            SteamID (e.g. "STEAM_0:1:12345") or SteamID64; empty/invalid strings are ignored.

    Returns:
        Player|nil
            The matching player with a loaded character, or nil if not found/invalid input.

    Realm:
        Shared

    Example Usage:
        ```lua
            local ply = lia.util.getBySteamID("76561198000000000")
            if ply then print("Found", ply:Name()) end
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
        Returns all players inside a spherical radius from a point.

    When Called:
        Use to gather players near a position for proximity-based effects or checks.

    Parameters:
        origin (Vector)
            Center of the search sphere.
        radius (number)
            Radius of the search sphere.

    Returns:
        table
            Players whose positions are within the given radius.

    Realm:
        Shared

    Example Usage:
        ```lua
            for _, ply in ipairs(lia.util.findPlayersInSphere(pos, 256)) do
                ply:ChatPrint("You feel a nearby pulse.")
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
        Resolves a player from various identifiers and optionally informs the caller on failure.

    When Called:
        Use in admin/command handlers that accept flexible player identifiers (SteamID, SteamID64, name, "^", "@").

    Parameters:
        client (Player|nil)
            The player requesting the lookup; used for localized error notifications.
        identifier (string)
            Identifier to match: SteamID, SteamID64, "^" (self), "@" (trace target), or partial name.

    Returns:
        Player|nil
            Matched player or nil when no match is found/identifier is invalid.

    Realm:
        Shared

    Example Usage:
        ```lua
            local target = lia.util.findPlayer(caller, args[1])
            if not target then return end
            target:kick("Example")
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
        Collects all spawned item entities created by a specific player.

    When Called:
        Use when cleaning up or inspecting items a player has spawned into the world.

    Parameters:
        client (Player)
            Player whose created item entities should be found.

    Returns:
        table
            List of item entities created by the player.

    Realm:
        Shared

    Example Usage:
        ```lua
            for _, ent in ipairs(lia.util.findPlayerItems(ply)) do
                ent:Remove()
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
        Collects spawned item entities from a player filtered by item class.

    When Called:
        Use when you need only specific item classes (by netvar "id") created by a player.

    Parameters:
        client (Player)
            Player whose item entities are being inspected.
        class (string)
            Item class/netvar id to match.

    Returns:
        table
            Item entities created by the player that match the class.

    Realm:
        Shared

    Example Usage:
        ```lua
            local ammo = lia.util.findPlayerItemsByClass(ply, "ammo_9mm")
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
        Finds entities created by or associated with a player, optionally by class.

    When Called:
        Use to track props or scripted entities a player spawned or owns.

    Parameters:
        client (Player)
            Player whose entities should be matched.
        class (string|nil)
            Optional entity class filter; nil includes all classes.

    Returns:
        table
            Entities created by or linked via entity.client to the player that match the class filter.

    Realm:
        Shared

    Example Usage:
        ```lua
            local ragdolls = lia.util.findPlayerEntities(ply, "prop_ragdoll")
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
        Performs case-insensitive equality and substring comparison between two strings.

    When Called:
        Use for loose name matching where exact case is not important.

    Parameters:
        a (string)
            First string to compare.
        b (string)
            Second string to compare.

    Returns:
        boolean
            True if the strings are equal (case-insensitive) or one contains the other; otherwise false.

    Realm:
        Shared

    Example Usage:
        ```lua
            if lia.util.stringMatches(ply:Name(), "john") then print("Matched player") end
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
        Returns all connected staff members.

    When Called:
        Use when broadcasting staff notifications or iterating over staff-only recipients.

    Parameters:
        (none)

    Returns:
        table
            Players that pass `isStaff()`.

    Realm:
        Shared

    Example Usage:
        ```lua
            for _, admin in ipairs(lia.util.getAdmins()) do
                admin:notify("Server restart in 5 minutes.")
            end
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
        Resolves a player from a SteamID64 wrapper around `findPlayerBySteamID`.

    When Called:
        Use when you have a 64-bit SteamID and need the corresponding player entity.

    Parameters:
        SteamID64 (string)
            SteamID64 to resolve.

    Returns:
        Player|nil
            Matching player or nil when none is found/SteamID64 is invalid.

    Realm:
        Shared

    Example Usage:
        ```lua
            local ply = lia.util.findPlayerBySteamID64(steamID64)
        ```
]]
function lia.util.findPlayerBySteamID64(SteamID64)
    local SteamID = util.SteamIDFrom64(SteamID64)
    if not SteamID then return nil end
    return lia.util.findPlayerBySteamID(SteamID)
end

--[[
    Purpose:
        Searches connected players for a matching SteamID.

    When Called:
        Use when you need to map a SteamID string to the in-game player.

    Parameters:
        SteamID (string)
            SteamID in legacy format (e.g. "STEAM_0:1:12345").

    Returns:
        Player|nil
            Player whose SteamID matches, or nil if none.

    Realm:
        Shared

    Example Usage:
        ```lua
            local ply = lia.util.findPlayerBySteamID("STEAM_0:1:12345")
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
        Checks whether a bounding hull can fit at a position without collisions.

    When Called:
        Use before spawning or teleporting entities to ensure the space is clear.

    Parameters:
        pos (Vector)
            Position to test.
        mins (Vector)
            Hull minimums; defaults to Vector(16, 16, 0) mirrored if positive.
        maxs (Vector|nil)
            Hull maximums; defaults to mins when nil.
        filter (Entity|table|nil)
            Entity or filter list to ignore in the trace.

    Returns:
        boolean
            True if the hull does not hit anything solid, false otherwise.

    Realm:
        Shared

    Example Usage:
        ```lua
            if lia.util.canFit(pos, Vector(16, 16, 0)) then
                ent:SetPos(pos)
            end
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
        Finds all players within a given radius.

    When Called:
        Use for proximity-based logic such as AoE effects or notifications.

    Parameters:
        pos (Vector)
            Center position for the search.
        dist (number)
            Radius to search, in units.

    Returns:
        table
            Players whose distance squared to pos is less than dist^2.

    Realm:
        Shared

    Example Usage:
        ```lua
            for _, ply in ipairs(lia.util.playerInRadius(pos, 512)) do
                ply:notify("You are near the beacon.")
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
        Formats a string using named placeholders or positional arguments.

    When Called:
        Use to substitute tokens in a template string with table keys or ordered arguments.

    Parameters:
        format (string)
            Template containing placeholders like "{name}".
        ... (table|any)
            Either a table of replacements or positional values when no table is provided.

    Returns:
        string
            The formatted string with placeholders replaced.

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.util.formatStringNamed("Hello {who}", {who = "world"})
            lia.util.formatStringNamed("{1} + {2}", 1, 2)
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
        Retrieves and caches a material by path and parameters.

    When Called:
        Use whenever drawing materials repeatedly to avoid recreating them.

    Parameters:
        materialPath (string)
            Path to the material.
        materialParameters (string|nil)
            Optional material creation parameters.

    Returns:
        IMaterial
            Cached or newly created material instance.

    Realm:
        Shared

    Example Usage:
        ```lua
            local blurMat = lia.util.getMaterial("pp/blurscreen")
        ```
]]
function lia.util.getMaterial(materialPath, materialParameters)
    lia.util.cachedMaterials = lia.util.cachedMaterials or {}
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath, materialParameters)
    return lia.util.cachedMaterials[materialPath]
end

--[[
    Purpose:
        Resolves a faction table by name or unique ID and notifies the caller on failure.

    When Called:
        Use in commands or UI when users input a faction identifier.

    Parameters:
        client (Player)
            Player to notify on invalid faction.
        name (string)
            Faction name or uniqueID to search for.

    Returns:
        table|nil
            Matching faction table, or nil if not found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local faction = lia.util.findFaction(ply, "combine")
            if faction then print(faction.name) end
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
        Generates a random full name from provided or default name lists.

    When Called:
        Use when creating placeholder or randomized character names.

    Parameters:
        firstNames (table|nil)
            Optional list of first names to draw from; defaults to built-in list when nil/empty.
        lastNames (table|nil)
            Optional list of last names to draw from; defaults to built-in list when nil/empty.

    Returns:
        string
            Concatenated first and last name.

    Realm:
        Shared

    Example Usage:
        ```lua
            local name = lia.util.generateRandomName()
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
        Sends a localized table UI payload to a client.

    When Called:
        Use when the server needs to present tabular data/options to a specific player.

    Parameters:
        client (Player)
            Recipient player.
        title (string|nil)
            Localization key for the window title; defaults to "tableListTitle".
        columns (table)
            Column definitions; names are localized if present.
        data (table)
            Row data to display.
        options (table|nil)
            Optional menu options to accompany the table.
        characterID (number|nil)
            Optional character identifier to send with the payload.

    Returns:
        nil
            Communicates with the client via net message only.

    Realm:
        Server

    Example Usage:
        ```lua
            lia.util.sendTableUI(ply, "staffList", columns, rows, options, charID)
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
        Finds nearby empty positions around an entity using grid sampling.

    When Called:
        Use when spawning items or players near an entity while avoiding collisions and the void.

    Parameters:
        entity (Entity)
            Origin entity to search around.
        filter (Entity|table|nil)
            Optional trace filter to ignore certain entities; defaults to the origin entity.
        spacing (number)
            Grid spacing between samples; defaults to 32.
        size (number)
            Number of steps in each direction from the origin; defaults to 3.
        height (number)
            Hull height used for traces; defaults to 36.
        tolerance (number)
            Upward offset to avoid starting inside the ground; defaults to 5.

    Returns:
        table
            Sorted list of valid origin positions, nearest to farthest from the entity.

    Realm:
        Server

    Example Usage:
        ```lua
            local spots = lia.util.findEmptySpace(ent, nil, 24)
            local pos = spots[1]
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
        Animates a panel appearing from a scaled, transparent state to its target size and opacity.

    When Called:
        Use when showing popups or menus that should ease into view.

    Parameters:
        panel (Panel)
            Panel to animate.
        targetWidth (number)
            Final width of the panel.
        targetHeight (number)
            Final height of the panel.
        duration (number|nil)
            Duration for size/position easing; defaults to 0.18 seconds.
        alphaDuration (number|nil)
            Duration for alpha easing; defaults to duration.
        callback (function|nil)
            Called when the animation finishes.
        scaleFactor (number|nil)
            Initial size scale relative to target; defaults to 0.8.

    Returns:
        nil
            Mutates the panel over time via its Think hook.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.util.animateAppearance(panel, 300, 200)
        ```
]]
    function lia.util.animateAppearance(panel, targetWidth, targetHeight, duration, alphaDuration, callback, scaleFactor)
        scaleFactor = scaleFactor or 0.8
        if not IsValid(panel) then return end
        duration = (duration and duration > 0) and duration or 0.18
        alphaDuration = (alphaDuration and alphaDuration > 0) and alphaDuration or duration
        local targetX, targetY = panel:GetPos()
        local initialW = targetWidth * (scaleFactor and scaleFactor or scaleFactor)
        local initialH = targetHeight * (scaleFactor and scaleFactor or scaleFactor)
        local initialX = targetX + (targetWidth - initialW) / 2
        local initialY = targetY + (targetHeight - initialH) / 2
        panel:SetSize(initialW, initialH)
        panel:SetPos(initialX, initialY)
        panel:SetAlpha(0)
        local curW, curH = initialW, initialH
        local curX, curY = initialX, initialY
        local curA = 0
        local eps = 0.5
        local alpha_eps = 1
        local speedSize = 3 / math.max(0.0001, duration)
        local speedAlpha = 3 / math.max(0.0001, alphaDuration)
        panel.Think = function()
            if not IsValid(panel) then return end
            local dt = FrameTime()
            curW = lia.util.approachExp(curW, targetWidth, speedSize, dt)
            curH = lia.util.approachExp(curH, targetHeight, speedSize, dt)
            curX = lia.util.approachExp(curX, targetX, speedSize, dt)
            curY = lia.util.approachExp(curY, targetY, speedSize, dt)
            curA = lia.util.approachExp(curA, 255, speedAlpha, dt)
            panel:SetSize(curW, curH)
            panel:SetPos(curX, curY)
            panel:SetAlpha(math.floor(curA + 0.5))
            local doneSize = math.abs(curW - targetWidth) <= eps and math.abs(curH - targetHeight) <= eps
            local donePos = math.abs(curX - targetX) <= eps and math.abs(curY - targetY) <= eps
            local doneAlpha = math.abs(curA - 255) <= alpha_eps
            if doneSize and donePos and doneAlpha then
                panel:SetSize(targetWidth, targetHeight)
                panel:SetPos(targetX, targetY)
                panel:SetAlpha(255)
                panel.Think = nil
                if callback then callback(panel) end
            end
        end
    end

    --[[
    Purpose:
        Keeps a menu panel within the screen bounds, respecting the character logo space.

    When Called:
        Use after positioning a menu to prevent it from going off-screen.

    Parameters:
        panel (Panel)
            Menu panel to clamp.

    Returns:
        nil
            Adjusts the panel position in place.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.util.clampMenuPosition(menu)
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
        Draws a directional gradient rectangle.

    When Called:
        Use in panel paints when you need simple gradient backgrounds.

    Parameters:
        x (number)
            X position of the gradient.
        y (number)
            Y position of the gradient.
        w (number)
            Width of the gradient.
        h (number)
            Height of the gradient.
        direction (number)
            Gradient direction index (1 up, 2 down, 3 left, 4 right).
        colorShadow (Color)
            Color tint for the gradient.
        radius (number|nil)
            Corner radius for drawing helper; defaults to 0.
        flags (number|nil)
            Optional draw flags passed to `drawMaterial`.

    Returns:
        nil
            Performs immediate drawing operations.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.util.drawGradient(0, 0, w, h, 2, Color(0, 0, 0, 180))
        ```
]]
    function lia.util.drawGradient(x, y, w, h, direction, colorShadow, radius, flags)
        local listGradients = {Material("vgui/gradient_up"), Material("vgui/gradient_down"), Material("vgui/gradient-l"), Material("vgui/gradient-r")}
        radius = radius and radius or 0
        lia.derma.drawMaterial(radius, x, y, w, h, colorShadow, listGradients[direction], flags)
    end

    --[[
    Purpose:
        Wraps text to a maximum width using a specified font.

    When Called:
        Use when drawing text that must fit inside a set horizontal space.

    Parameters:
        text (string)
            Text to wrap.
        width (number)
            Maximum width in pixels.
        font (string|nil)
            Font name to measure with; defaults to "LiliaFont.16".

    Returns:
        table, number
            Array of wrapped lines and the widest line width.

    Realm:
        Client

    Example Usage:
        ```lua
            local lines = lia.util.wrapText(description, 300, "LiliaFont.17")
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
        Draws a blurred background behind a panel.

    When Called:
        Use inside a panel's Paint hook to soften the content behind it.

    Parameters:
        panel (Panel)
            Panel whose screen area will be blurred.
        amount (number|nil)
            Blur strength; defaults to 5.
        passes (number|nil)
            Unused; kept for signature compatibility.
        alpha (number|nil)
            Draw color alpha; defaults to 255.

    Returns:
        nil
            Renders blur to the screen.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.util.drawBlur(self, 4)
        ```
]]
    function lia.util.drawBlur(panel, amount, passes, alpha)
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
        Draws a blurred background with a dark overlay in a panel's bounds.

    When Called:
        Use for modal overlays where both blur and darkening are desired.

    Parameters:
        panel (Panel)
            Panel area to blur.
        amount (number|nil)
            Blur strength; defaults to 6.
        passes (number|nil)
            Number of blur passes; defaults to 5.
        alpha (number|nil)
            Blur draw alpha; defaults to 255.
        darkAlpha (number|nil)
            Alpha for the black overlay; defaults to 220.

    Returns:
        nil
            Renders blur and overlay.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.util.drawBlackBlur(self, 6, 4, 255, 200)
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
        Draws a blur effect over a specific rectangle on the screen.

    When Called:
        Use when you need a localized blur that is not tied to a panel.

    Parameters:
        x (number)
            X coordinate of the rectangle.
        y (number)
            Y coordinate of the rectangle.
        w (number)
            Width of the rectangle.
        h (number)
            Height of the rectangle.
        amount (number|nil)
            Blur strength; defaults to 5.
        passes (number|nil)
            Number of blur samples; defaults to 0.2 steps when nil.
        alpha (number|nil)
            Draw alpha; defaults to 255.

    Returns:
        nil
            Renders blur to the specified area.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.util.drawBlurAt(100, 100, 200, 150, 4)
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
        Prompts the user for entity information and forwards the result.

    When Called:
        Use when a client must supply additional data for an entity action.

    Parameters:
        entity (Entity)
            Entity that the information pertains to; removed if the request fails.
        argTypes (table)
            Argument descriptors passed to `requestArguments`.
        callback (function|nil)
            Invoked with the collected information on success.

    Returns:
        nil
            Handles UI flow and optional callback invocation.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.util.requestEntityInformation(ent, argTypes, function(info) print(info) end)
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
        Builds and displays a table UI on the client.

    When Called:
        Use when the client needs to view tabular data with optional menu actions.

    Parameters:
        title (string|nil)
            Localization key for the frame title; defaults to "tableListTitle".
        columns (table)
            Column definitions with `name`, `width`, `align`, and `sortable` fields.
        data (table)
            Row data keyed by column field names.
        options (table|nil)
            Optional menu options with callbacks or net names.
        charID (number|nil)
            Character identifier forwarded with net options.

    Returns:
        Panel, Panel
            The created frame and table list view.

    Realm:
        Client

    Example Usage:
        ```lua
            local frame, list = lia.util.createTableUI("myData", cols, rows)
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

        listView:ForceCommit()
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
        Displays a simple options menu with clickable entries.

    When Called:
        Use to quickly prompt the user with a list of named actions.

    Parameters:
        title (string|nil)
            Title text to show at the top of the menu; defaults to "options".
        options (table)
            Either an array of {name, callback} or a map of name -> callback.

    Returns:
        Panel|nil
            The created frame, or nil if no valid options exist.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.util.openOptionsMenu("choose", {{"Yes", onYes}, {"No", onNo}})
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
        Draws floating text above an entity that eases in based on distance.

    When Called:
        Use in HUD painting to label world entities when nearby.

    Parameters:
        ent (Entity)
            Entity to draw text above.
        text (string)
            Text to display.
        posY (number|nil)
            Vertical offset in screen space; defaults to 0.
        alphaOverride (number|nil)
            Optional alpha multiplier (0-1 or 0-255).

    Returns:
        nil
            Performs drawing only; caches fade state per-entity.

    Realm:
        Client

    Example Usage:
        ```lua
            hook.Add("HUDPaint", "DrawEntLabels", function()
                lia.util.drawEntText(ent, "Storage")
            end)
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
        Draws text at the player's look position with distance-based easing.

    When Called:
        Use to display contextual prompts or hints where the player is aiming.

    Parameters:
        text (string)
            Text to render at the hit position.
        posY (number|nil)
            Screen-space vertical offset; defaults to 0.
        alphaOverride (number|nil)
            Optional alpha multiplier (0-1 or 0-255).
        maxDist (number|nil)
            Maximum trace distance; defaults to 380 units.

    Returns:
        nil
            Draws text when a trace hits within range.

    Realm:
        Client

    Example Usage:
        ```lua
            lia.util.drawLookText("Press E to interact")
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
