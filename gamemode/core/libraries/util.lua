--[[
    Folder: Developer - Libraries
    File: lia.util.md
]]
--[[
    Utility

    General-purpose helpers for Lilia bodygroups, player lookup, entity ownership queries, world-space placement, string formatting, cached materials, table UI handling, and clientside drawing utilities.
]]
--[[
    Overview:
        The utility library centralizes common helpers under `lia.util`. Shared helpers normalize and apply bodygroups, find players and player-owned entities, format strings, cache materials, resolve factions, generate names, and register feature-position callbacks. Server-only helpers send table UI data and find open world positions. Client-only helpers provide menu animation, blur effects, text wrapping, table UI creation, world text drawing, and feature-position interactions.
]]
--[[
    Purpose:
        Normalizes a bodygroup identifier into either a numeric bodygroup index or a trimmed bodygroup name.

    Parameters:
        key (any)
            The bodygroup key to normalize. Numeric values and numeric strings are converted to numbers; non-empty strings are trimmed.

    Returns:
        number|string|nil
            The normalized bodygroup index or name. Returns nil when the key cannot be normalized.

    Example Usage:
        ```lua
        local key = lia.util.normalizeBodygroupKey("  headgear  ")
        local numericKey = lia.util.normalizeBodygroupKey("2")
        ```

    Realm:
        Shared
]]
function lia.util.normalizeBodygroupKey(key)
    local numericKey = tonumber(key)
    if numericKey ~= nil then return numericKey end
    if isstring(key) and key ~= "" then return string.Trim(key) end
end

--[[
    Purpose:
        Resolves a bodygroup identifier against an entity or player into a numeric bodygroup index.

    Parameters:
        target (Entity|Player)
            The entity whose bodygroups should be checked.
        identifier (number|string)
            The bodygroup index, numeric string, or bodygroup name to resolve.

    Returns:
        number|nil
            The resolved bodygroup index. Returns nil when the target is invalid or the identifier cannot be matched.

    Example Usage:
        ```lua
        local index = lia.util.resolveBodygroupIndex(client, "headgear")
        if index then client:SetBodygroup(index, 1) end
        ```

    Realm:
        Shared
]]
function lia.util.resolveBodygroupIndex(target, identifier)
    local numericIdentifier = tonumber(identifier)
    if numericIdentifier ~= nil then return numericIdentifier end
    if not IsValid(target) or not isstring(identifier) then return nil end
    local trimmedIdentifier = string.Trim(identifier)
    if trimmedIdentifier == "" then return nil end
    local directMatch = target:FindBodygroupByName(trimmedIdentifier)
    if isnumber(directMatch) and directMatch > -1 then return directMatch end
    local loweredIdentifier = string.lower(trimmedIdentifier)
    for _, groupData in ipairs(target:GetBodyGroups() or {}) do
        if isstring(groupData.name) and string.lower(groupData.name) == loweredIdentifier then return groupData.id end
    end
end

--[[
    Purpose:
        Converts supported bodygroup table formats into a simple identifier-to-value lookup table.

    Parameters:
        bodygroups (table)
            A bodygroup table containing array entries, keyed values, or both.

    Returns:
        table
            A normalized table where each key is a bodygroup identifier and each value is a numeric bodygroup value.

    Example Usage:
        ```lua
        local bodygroups = lia.util.normalizeBodygroups({{name = "headgear", value = 1}, [2] = 0})
        ```

    Realm:
        Shared
]]
function lia.util.normalizeBodygroups(bodygroups)
    local normalized = {}
    if not istable(bodygroups) then return normalized end
    for _, entry in ipairs(bodygroups) do
        if istable(entry) then
            local index = lia.util.normalizeBodygroupKey(entry.id or entry.index or entry.bodygroup or entry.bodygroupID or entry.name or entry[1])
            local value = tonumber(entry.value or entry.val or entry[2] or 0) or 0
            if index ~= nil then normalized[index] = value end
        end
    end

    for key, value in pairs(bodygroups) do
        local index = lia.util.normalizeBodygroupKey(key)
        if index ~= nil and not istable(value) then normalized[index] = tonumber(value) or 0 end
    end
    return normalized
end

--[[
    Purpose:
        Resolves a bodygroup table into numeric bodygroup indices for a specific target entity.

    Parameters:
        target (Entity|Player)
            The entity whose bodygroups should be resolved.
        bodygroups (table)
            The bodygroup data to normalize and resolve.

    Returns:
        table
            A table of resolved numeric bodygroup indices mapped to numeric bodygroup values.

    Example Usage:
        ```lua
        local resolved = lia.util.resolveBodygroups(client, {headgear = 1})
        ```

    Realm:
        Shared
]]
function lia.util.resolveBodygroups(target, bodygroups)
    local resolved = {}
    for identifier, value in pairs(lia.util.normalizeBodygroups(bodygroups)) do
        local index = lia.util.resolveBodygroupIndex(target, identifier)
        if index ~= nil then resolved[index] = tonumber(value) or 0 end
    end
    return resolved
end

--[[
    Purpose:
        Applies bodygroup values to a valid entity after resolving bodygroup names or identifiers.

    Parameters:
        target (Entity|Player)
            The entity receiving the bodygroup changes.
        bodygroups (table)
            The bodygroup data to apply.

    Returns:
        table
            The resolved bodygroups that were applied. Returns an empty table when the target is invalid.

    Example Usage:
        ```lua
        lia.util.applyBodygroups(client, {headgear = 1, [2] = 0})
        ```

    Realm:
        Shared
]]
function lia.util.applyBodygroups(target, bodygroups)
    if not IsValid(target) then return {} end
    local resolved = lia.util.resolveBodygroups(target, bodygroups)
    for index, value in pairs(resolved) do
        target:SetBodygroup(index, value)
    end
    return resolved
end

--[[
    Purpose:
        Finds all players inside an axis-aligned world-space box.

    Parameters:
        mins (Vector)
            The minimum corner of the search box.
        maxs (Vector)
            The maximum corner of the search box.

    Returns:
        table
            A sequential table containing every valid player found inside the box.

    Example Usage:
        ```lua
        local players = lia.util.findPlayersInBox(Vector(-128, -128, 0), Vector(128, 128, 128))
        ```

    Realm:
        Shared
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
        Requests argument input from a client for an entity and removes the entity if the request is cancelled.

    Parameters:
        client (Player)
            The player receiving the argument request.
        entity (Entity)
            The entity associated with the request.
        argTypes (table)
            The argument definitions passed to `client:requestArguments`.
        callback (function|nil)
            Optional callback called with the submitted information when the request succeeds.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.requestEntityInformation(client, entity, args, function(information)
            entity.information = information
        end)
        ```

    Realm:
        Shared
]]
function lia.util.requestEntityInformation(client, entity, argTypes, callback)
    if not IsValid(entity) then
        ErrorNoHalt("[lia.util.requestEntityInformation] Invalid entity provided\n")
        return
    end

    client:requestArguments(L("entityInformation"), argTypes, function(success, information)
        if not success then
            if IsValid(entity) then entity:Remove() end
        else
            if isfunction(callback) then callback(information) end
        end
    end)
end

--[[
    Purpose:
        Finds an online player with an active character by SteamID or SteamID64.

    Parameters:
        steamID (string)
            The SteamID or SteamID64 to search for.

    Returns:
        Player|nil
            The matching player with a loaded character, or nil when no match is found.

    Example Usage:
        ```lua
        local client = lia.util.getBySteamID("STEAM_0:1:123456")
        ```

    Realm:
        Shared
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
        Finds all players within a radius of a world position.

    Parameters:
        origin (Vector)
            The center point of the sphere.
        radius (number)
            The search radius in Source units.

    Returns:
        table
            A sequential table containing players within the radius.

    Example Usage:
        ```lua
        local nearby = lia.util.findPlayersInSphere(entity:GetPos(), 256)
        ```

    Realm:
        Shared
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
        Resolves a player from a command-style identifier, SteamID, SteamID64, self marker, trace marker, or partial name.

    Parameters:
        client (Player|nil)
            The player performing the lookup. Used for `^`, `@`, and localized error notifications.
        identifier (string)
            The player identifier to resolve.

    Returns:
        Player|nil
            The matching player, or nil when no valid player is found.

    Example Usage:
        ```lua
        local target = lia.util.findPlayer(client, "@")
        local byName = lia.util.findPlayer(client, "samael")
        ```

    Realm:
        Shared
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
        Finds all spawned item entities created by a specific player.

    Parameters:
        client (Player)
            The player whose created item entities should be returned.

    Returns:
        table
            A sequential table containing matching item entities.

    Example Usage:
        ```lua
        local items = lia.util.findPlayerItems(client)
        ```

    Realm:
        Shared
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
        Finds spawned item entities created by a player that match a specific item ID.

    Parameters:
        client (Player)
            The player whose created item entities should be searched.
        class (string)
            The item ID stored in the entity network variable.

    Returns:
        table
            A sequential table containing matching item entities.

    Example Usage:
        ```lua
        local radios = lia.util.findPlayerItemsByClass(client, "handheld_radio")
        ```

    Realm:
        Shared
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
        Finds entities created by, or assigned to, a specific player, optionally filtered by entity class.

    Parameters:
        client (Player)
            The player whose entities should be found.
        class (string|nil)
            Optional entity class filter.

    Returns:
        table
            A sequential table containing matching entities.

    Example Usage:
        ```lua
        local doors = lia.util.findPlayerEntities(client, "prop_door_rotating")
        local owned = lia.util.findPlayerEntities(client)
        ```

    Realm:
        Shared
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
        Performs a case-sensitive and case-insensitive substring or exact-string comparison.

    Parameters:
        a (string)
            The source string to compare.
        b (string)
            The string or pattern-safe fragment to look for.

    Returns:
        boolean
            True when the strings match exactly or when `b` is found within `a`; otherwise false.

    Example Usage:
        ```lua
        if lia.util.stringMatches(client:Name(), "sam") then
            print(client:Name())
        end
        ```

    Realm:
        Shared
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
        Collects all online players that pass the framework staff check.

    Parameters:
        None.

    Returns:
        table
            A sequential table containing online staff players.

    Example Usage:
        ```lua
        for _, staff in ipairs(lia.util.getAdmins()) do
            staff:notify("Staff notice")
        end
        ```

    Realm:
        Shared
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
        Finds an online player by converting a SteamID64 into a SteamID first.

    Parameters:
        SteamID64 (string)
            The SteamID64 to convert and search for.

    Returns:
        Player|nil
            The matching player, or nil when conversion fails or no player matches.

    Example Usage:
        ```lua
        local client = lia.util.findPlayerBySteamID64("76561198000000000")
        ```

    Realm:
        Shared
]]
function lia.util.findPlayerBySteamID64(SteamID64)
    local SteamID = util.SteamIDFrom64(SteamID64)
    if not SteamID then return nil end
    return lia.util.findPlayerBySteamID(SteamID)
end

--[[
    Purpose:
        Finds an online player by SteamID.

    Parameters:
        SteamID (string)
            The SteamID to search for.

    Returns:
        Player|nil
            The matching player, or nil when no player matches.

    Example Usage:
        ```lua
        local client = lia.util.findPlayerBySteamID("STEAM_0:1:123456")
        ```

    Realm:
        Shared
]]
function lia.util.findPlayerBySteamID(SteamID)
    for _, client in player.Iterator() do
        if client:SteamID() == SteamID then return client end
    end
    return nil
end

--[[
    Purpose:
        Checks whether a hull can fit at a world position without hitting player-solid geometry.

    Parameters:
        pos (Vector)
            The position to test.
        mins (Vector|nil)
            Optional hull minimums. Defaults to `Vector(16, 16, 0)` and is inverted when positive.
        maxs (Vector|nil)
            Optional hull maximums. Defaults to `mins`.
        filter (Entity|table|nil)
            Optional trace filter.

    Returns:
        boolean
            True when the hull does not hit anything; otherwise false.

    Example Usage:
        ```lua
        if lia.util.canFit(spawnPos, nil, nil, client) then
            client:SetPos(spawnPos)
        end
        ```

    Realm:
        Shared
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
        Finds valid players within a radius of a world position.

    Parameters:
        pos (Vector)
            The center of the search area.
        dist (number)
            The radius to search, in Source units.

    Returns:
        table
            A sequential table containing players inside the radius.

    Example Usage:
        ```lua
        local players = lia.util.playerInRadius(entity:GetPos(), 128)
        ```

    Realm:
        Shared
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
        Replaces `{name}` or ordered placeholder tokens in a string with table or vararg values.

    Parameters:
        format (string)
            The format string containing `{token}` placeholders.
        ... (table|any)
            Either a lookup table of named replacements or ordered replacement values.

    Returns:
        string
            The formatted string with placeholders replaced.

    Example Usage:
        ```lua
        local text = lia.util.formatStringNamed("Hello, {name}", {name = client:Name()})
        local ordered = lia.util.formatStringNamed("{first} {second}", "Hello", "World")
        ```

    Realm:
        Shared
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
        Returns a cached material instance for a material path and optional material parameters.

    Parameters:
        materialPath (string)
            The material path to load.
        materialParameters (string|nil)
            Optional material parameters passed to `Material` on first load.

    Returns:
        IMaterial
            The cached or newly created material.

    Example Usage:
        ```lua
        local blur = lia.util.getMaterial("pp/blurscreen")
        ```

    Realm:
        Shared
]]
function lia.util.getMaterial(materialPath, materialParameters)
    lia.util.cachedMaterials = lia.util.cachedMaterials or {}
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath, materialParameters)
    return lia.util.cachedMaterials[materialPath]
end

--[[
    Purpose:
        Finds a faction by numeric/team key, name, or unique ID, and notifies the client when no match is found.

    Parameters:
        client (Player)
            The player to notify when the faction cannot be found.
        name (any)
            The faction key, display name, or unique ID to search for.

    Returns:
        table|nil
            The matching faction table, or nil when no faction matches.

    Example Usage:
        ```lua
        local faction = lia.util.findFaction(client, "citizen")
        ```

    Realm:
        Shared
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
        Generates a random full name from provided first-name and last-name lists or built-in fallback lists.

    Parameters:
        firstNames (table|nil)
            Optional list of first names.
        lastNames (table|nil)
            Optional list of last names.

    Returns:
        string
            A generated first-name and last-name combination.

    Example Usage:
        ```lua
        local name = lia.util.generateRandomName()
        local custom = lia.util.generateRandomName({"Alex"}, {"Morgan"})
        ```

    Realm:
        Shared
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

lia.util.positionCallbacks = lia.util.positionCallbacks or {}
lia.util.featurePositionTypes = lia.util.featurePositionTypes or {}
--[[
    Purpose:
        Registers or updates a named feature-position callback definition.

    Parameters:
        name (string)
            The display name for the position callback.
        data (table)
            Callback data containing `onRun`, `onSelect`, and optional `onRemove`, `HUDPaint`, `serverOnly`, and `color` fields.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.setPositionCallback("Vendor Spawn", {
            onRun = function(pos, client, typeId) end,
            onSelect = function() end
        })
        ```

    Realm:
        Shared
]]
function lia.util.setPositionCallback(name, data)
    if not isstring(name) or not istable(data) then return end
    if not isfunction(data.onRun) or not isfunction(data.onSelect) then return end
    local id = string.lower(name):gsub("%s+", "_")
    local serverOnly = data.serverOnly == true
    local color = data.color or Color(255, 255, 255)
    lia.util.positionCallbacks[id] = {
        id = id,
        name = name,
        color = color,
        onRun = data.onRun,
        onRemove = data.onRemove,
        onSelect = data.onSelect,
        HUDPaint = data.HUDPaint,
        serverOnly = serverOnly
    }

    local found = false
    for i = 1, #lia.util.featurePositionTypes do
        if lia.util.featurePositionTypes[i].id == id then
            lia.util.featurePositionTypes[i].name = name
            lia.util.featurePositionTypes[i].color = color
            found = true
            break
        end
    end

    if not found then
        table.insert(lia.util.featurePositionTypes, {
            id = id,
            name = name,
            color = color
        })
    end
end

if SERVER then
    --[[
    Purpose:
        Sends localized table UI data to a player through the large-table networking helper.

    Parameters:
        client (Player)
            The player who should receive the table UI.
        title (string|nil)
            Optional localization key for the table title.
        columns (table)
            Column definitions, with names localized before sending.
        data (table)
            Row data for the table UI.
        options (table|nil)
            Optional row action definitions.
        characterID (number|nil)
            Optional character ID associated with row actions.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.sendTableUI(client, "players", columns, rows, options, client:getChar():getID())
        ```

    Realm:
        Server
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
        Finds nearby empty world positions around an entity using trace checks and distance sorting.

    Parameters:
        entity (Entity)
            The entity used as the search origin and default filter.
        filter (Entity|table|nil)
            Optional trace filter. Defaults to the entity.
        spacing (number|nil)
            Distance between checked grid positions. Defaults to 32.
        size (number|nil)
            Number of grid steps to search in each direction. Defaults to 3.
        height (number|nil)
            Height used for vertical trace checks. Defaults to 36.
        tolerance (number|nil)
            Vertical offset used to avoid immediate ground contact. Defaults to 5.

    Returns:
        table
            A distance-sorted table of valid empty positions.

    Example Usage:
        ```lua
        local positions = lia.util.findEmptySpace(entity, client, 32, 4)
        local nearest = positions[1]
        ```

    Realm:
        Server
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
        Animates a panel from a scaled, transparent state to its target size, position, and full opacity.

    Parameters:
        panel (Panel)
            The panel to animate.
        targetWidth (number)
            The final panel width.
        targetHeight (number)
            The final panel height.
        duration (number|nil)
            Approximate size and position animation duration. Defaults to 0.18.
        alphaDuration (number|nil)
            Approximate alpha animation duration. Defaults to `duration`.
        callback (function|nil)
            Optional callback called with the panel when the animation finishes.
        scaleFactor (number|nil)
            Initial scale multiplier. Defaults to 0.8.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.animateAppearance(frame, 400, 300, 0.2)
        ```

    Realm:
        Client
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
        Keeps a panel inside the screen bounds and avoids overlapping the character menu logo when present.

    Parameters:
        panel (Panel)
            The panel whose position should be clamped.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.clampMenuPosition(menu)
        ```

    Realm:
        Client
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
        Draws one of the built-in VGUI gradient materials through the Lilia Derma material helper.

    Parameters:
        x (number)
            The x position to draw at.
        y (number)
            The y position to draw at.
        w (number)
            The gradient width.
        h (number)
            The gradient height.
        direction (number)
            Gradient material index: up, down, left, or right.
        colorShadow (Color)
            The color used to draw the gradient.
        radius (number|nil)
            Optional rounded radius. Defaults to 0.
        flags (number|nil)
            Optional drawing flags passed to the Derma helper.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.drawGradient(0, 0, 200, 40, 2, Color(0, 0, 0, 180))
        ```

    Realm:
        Client
]]
    function lia.util.drawGradient(x, y, w, h, direction, colorShadow, radius, flags)
        local listGradients = {Material("vgui/gradient_up"), Material("vgui/gradient_down"), Material("vgui/gradient-l"), Material("vgui/gradient-r")}
        radius = radius and radius or 0
        lia.derma.drawMaterial(radius, x, y, w, h, colorShadow, listGradients[direction], flags)
    end

    --[[
    Purpose:
        Wraps text into multiple lines that fit within a target pixel width for a specific font.

    Parameters:
        text (string)
            The text to wrap.
        width (number)
            The maximum line width in pixels.
        font (string|nil)
            Font name used for measuring. Defaults to `LiliaFont.16`.

    Returns:
        table, number
            The wrapped lines and the widest measured line width.

    Example Usage:
        ```lua
        local lines, maxWidth = lia.util.wrapText(description, 300, "LiliaFont.16")
        ```

    Realm:
        Client
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
        Draws a screen-space blur behind a panel.

    Parameters:
        panel (Panel)
            The panel whose screen position determines the blur offset.
        amount (number|nil)
            Blur strength. Defaults to 5.
        passes (number|nil)
            Present for compatibility; the function uses a fixed internal pass count.
        alpha (number|nil)
            Blur draw alpha. Defaults to 255.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        frame.Paint = function(self)
            lia.util.drawBlur(self, 4)
        end
        ```

    Realm:
        Client
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
        Draws a blur behind a panel and overlays a dark rectangle over the panel area.

    Parameters:
        panel (Panel)
            The panel to draw behind and darken.
        amount (number|nil)
            Blur strength. Defaults to 6.
        passes (number|nil)
            Number of blur passes. Defaults to 5.
        alpha (number|nil)
            Blur draw alpha. Defaults to 255.
        darkAlpha (number|nil)
            Alpha for the dark overlay. Defaults to 220.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.drawBlackBlur(frame, 6, 5, 255, 200)
        ```

    Realm:
        Client
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
        Draws a localized blur over a rectangular screen area.

    Parameters:
        x (number)
            The x position of the blur rectangle.
        y (number)
            The y position of the blur rectangle.
        w (number)
            The blur rectangle width.
        h (number)
            The blur rectangle height.
        amount (number|nil)
            Blur strength. Defaults to 5.
        passes (number|nil)
            Starting blur-loop value. Defaults to 0.2.
        alpha (number|nil)
            Blur draw alpha. Defaults to 255.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.drawBlurAt(20, 20, 300, 120, 6)
        ```

    Realm:
        Client
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
        Creates a clientside table window with localized columns, row data, copy support, and optional row actions.

    Parameters:
        title (string|nil)
            Optional localization key for the frame title.
        columns (table)
            Column definitions used to build the table.
        data (table)
            Row data displayed in the table.
        options (table|nil)
            Optional row action definitions that may send net messages.
        charID (number|nil)
            Character ID written with row action net messages.

    Returns:
        Panel, Panel
            The created frame and table panel.

    Example Usage:
        ```lua
        local frame, listView = lia.util.createTableUI("players", columns, rows, options, charID)
        ```

    Realm:
        Client
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
            listView:AddMenuOption(option.name and L(option.name) or option.name, function(rowData, rowIndex)
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
                        net.WriteTable(rowData)
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
                    net.WriteTable(rowData)
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
        Opens a small centered options menu from either an array of option tables or a name-to-callback table.

    Parameters:
        title (string|nil)
            Optional localization key for the menu title.
        options (table)
            Options to show. Array entries need `name` and `callback`; keyed entries use the key as the name and value as the callback.

    Returns:
        Panel|nil
            The created menu frame, or nil when no valid options are provided.

    Example Usage:
        ```lua
        lia.util.openOptionsMenu("options", {
            inspect = function() print("Inspect") end
        })
        ```

    Realm:
        Client
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
        lia.derma.rect(bx, by, bw, bh - 6):Radii(12, 12, 0, 0):Color(headerColor):Shape(lia.derma.SHAPE_IOS):Draw()
        local themeColor = theme.theme or color_white
        surface.SetDrawColor(themeColor.r, themeColor.g, themeColor.b, math.floor(40 * fadeAlpha))
        surface.DrawRect(bx, by + bh - 6 - 1, bw, 1)
        lia.derma.rect(bx, by + bh - 6, bw, 6):Radii(0, 0, 12, 12):Color(accentColor):Draw()
        draw.SimpleText(text, "LiliaFont.24", math.Round(x), math.Round(y - 2), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        return bh
    end

    local function DrawEntityInfoBoxAt(x, y, title, rows, fade, xOffset)
        local theme = lia.color.theme or defaultTheme
        local fadeAlpha = math.Clamp(fade, 0, 1)
        local accent = theme.accent or theme.theme or defaultTheme.accent or color_white
        local titleText = string.Trim(tostring(title or ""))
        local cleanRows = {}
        for i = 1, #(rows or {}) do
            local row = rows[i]
            if istable(row) then
                if row.divider then
                    cleanRows[#cleanRows + 1] = {
                        divider = true
                    }
                else
                    local preparedRow = table.Copy(row)
                    if isstring(preparedRow.text) then preparedRow.text = string.Trim(preparedRow.text) end
                    if isstring(preparedRow.label) then preparedRow.label = string.Trim(preparedRow.label) end
                    if isstring(preparedRow.value) then preparedRow.value = string.Trim(preparedRow.value) end
                    if isstring(preparedRow.section) then preparedRow.section = string.Trim(preparedRow.section) end
                    if preparedRow.section and preparedRow.section ~= "" then
                        cleanRows[#cleanRows + 1] = {
                            section = preparedRow.section
                        }
                    elseif (preparedRow.text and preparedRow.text ~= "") or (preparedRow.label and preparedRow.label ~= "") or (preparedRow.value and preparedRow.value ~= "") then
                        cleanRows[#cleanRows + 1] = preparedRow
                    end
                end
            else
                local textRow = string.Trim(tostring(row or ""))
                if textRow ~= "" then cleanRows[#cleanRows + 1] = textRow end
            end
        end

        if titleText == "" and #cleanRows == 0 then return end
        return lia.derma.drawBoxWithText(nil, math.Round(x + (xOffset or 28)), math.Round(y), {
            title = titleText ~= "" and titleText or nil,
            rows = cleanRows,
            font = "LiliaFont.18",
            textAlignX = TEXT_ALIGN_LEFT,
            textAlignY = TEXT_ALIGN_TOP,
            padding = 12,
            rowHeight = 18,
            autoSize = true,
            richText = false,
            backgroundColor = Color(3, 18, 22, math.floor(232 * fadeAlpha)),
            borderColor = Color(accent.r, accent.g, accent.b, math.floor(110 * fadeAlpha)),
            textColor = scaleColorAlpha(theme.text or defaultTheme.text, fadeAlpha),
            mutedTextColor = scaleColorAlpha(theme.mutedText or theme.text or defaultTheme.text, fadeAlpha),
            accentColor = Color(accent.r, accent.g, accent.b, math.floor(255 * fadeAlpha)),
            accentAlpha = math.floor(210 * fadeAlpha),
            shadow = {
                enabled = true,
                color = Color(0, 0, 0, math.floor(125 * fadeAlpha)),
                offsetX = 8,
                offsetY = 14
            },
            blur = {
                enabled = true,
                amount = 2,
                passes = 2,
                alpha = 0.65 * fadeAlpha
            },
            overlapMargin = 4
        })
    end

    lia.util.entsScales = lia.util.entsScales or {}
    --[[
    Purpose:
        Draws animated styled text above an entity when the local player is close enough to see it.

    Parameters:
        ent (Entity)
            The entity to draw text above.
        text (string)
            The text to display.
        posY (number|nil)
            Optional screen-space vertical offset.
        alphaOverride (number|nil)
            Optional alpha multiplier or 0-255 alpha value.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.drawEntText(entity, "Open", 0, 255)
        ```

    Realm:
        Client
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

    function lia.util.drawEntInfoBox(ent, data, alphaOverride)
        if not (IsValid(ent) and istable(data)) then return end
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
        DrawEntityInfoBoxAt(screenPos.x, screenPos.y + (data.posY or 0), data.title, data.rows, fade, data.xOffset)
    end

    --[[
    Purpose:
        Draws animated styled text at the point the local player is looking at within a maximum distance.

    Parameters:
        text (string)
            The text to display.
        posY (number|nil)
            Optional screen-space vertical offset.
        alphaOverride (number|nil)
            Optional alpha multiplier or 0-255 alpha value.
        maxDist (number|nil)
            Maximum trace distance. Defaults to 380.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.drawLookText("Interact", 0, 255, 256)
        ```

    Realm:
        Client
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

    --[[
    Purpose:
        Defines an empty clientside placeholder for setting a feature position before the implemented definition later in the file replaces it.

    Parameters:
        pos (Vector)
            The position argument accepted by the placeholder.
        typeId (string)
            The feature-position callback ID accepted by the placeholder.

    Returns:
        nil
            This placeholder does not return a value.

    Example Usage:
        ```lua
        lia.util.setFeaturePosition(pos, typeId)
        ```

    Realm:
        Client
]]
    function lia.util.setFeaturePosition(pos, typeId)
    end

    --[[
    Purpose:
        Draws animated styled text at the point the local player is looking at within a maximum distance.

    Parameters:
        text (string)
            The text to display.
        posY (number|nil)
            Optional screen-space vertical offset.
        alphaOverride (number|nil)
            Optional alpha multiplier or 0-255 alpha value.
        maxDist (number|nil)
            Maximum trace distance. Defaults to 380.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.drawLookText("Interact", 0, 255, 256)
        ```

    Realm:
        Client
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

    --[[
    Purpose:
        Runs a registered feature-position callback for a clientside position selection.

    Parameters:
        pos (Vector)
            The selected world position.
        typeId (string)
            The registered feature-position callback ID.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.setFeaturePosition(trace.HitPos, "vendor_spawn")
        ```

    Realm:
        Client
]]
    function lia.util.setFeaturePosition(pos, typeId)
        if not isvector(pos) or not isstring(typeId) then return end
        local callback = lia.util.positionCallbacks[typeId]
        if not callback or not callback.onRun then return end
        local client = LocalPlayer()
        if not IsValid(client) then return end
        if callback.serverOnly then
            callback.onRun(pos, client, typeId)
        else
            callback.onRun(pos, client, typeId)
        end
    end

    --[[
    Purpose:
        Removes or requests removal of a feature position using the registered callback for a type ID.

    Parameters:
        pos (Vector)
            The world position to remove.
        typeId (string)
            The registered feature-position callback ID.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.util.removeFeaturePosition(trace.HitPos, "vendor_spawn")
        ```

    Realm:
        Client
]]
    function lia.util.removeFeaturePosition(pos, typeId)
        if not isvector(pos) or not isstring(typeId) then return end
        local callback = lia.util.positionCallbacks[typeId]
        if not callback or not callback.onRemove then return end
        local client = LocalPlayer()
        if not IsValid(client) then return end
        if callback.serverOnly then
            net.Start("liaRemoveFeaturePosition")
            net.WriteString(typeId)
            net.WriteVector(pos)
            net.SendToServer()
        else
            callback.onRemove(pos, client, typeId)
        end
    end

    --[[
    Purpose:
        Draws styled ESP text with a themed background, blur, accent bar, and fade alpha.

    Parameters:
        text (string)
            The ESP text to draw.
        x (number)
            The horizontal screen position.
        y (number)
            The vertical screen position.
        espColor (Color|nil)
            Optional accent color. Defaults to the active theme accent.
        font (string)
            Font used to measure and draw the text.
        fadeAlpha (number|nil)
            Alpha multiplier from 0 to 1. Defaults to 1.

    Returns:
        number
            The height of the styled text block.

    Example Usage:
        ```lua
        lia.util.drawESPStyledText("Target", x, y, Color(255, 255, 255), "LiliaFont.24", 1)
        ```

    Realm:
        Client
]]
    function lia.util.drawESPStyledText(text, x, y, espColor, font, fadeAlpha)
        fadeAlpha = fadeAlpha or 1
        surface.SetFont(font)
        local tw, th = surface.GetTextSize(text)
        local bx, by = math.Round(x - tw * 0.5 - 8), math.Round(y - 8)
        local bw, bh = tw + 16, th + 16
        local theme = lia.color.theme or defaultTheme
        local headerColor = scaleColorAlpha(theme.background_panelpopup or theme.header or defaultTheme.header, fadeAlpha)
        local accentColor = scaleColorAlpha(espColor or theme.theme or theme.text or defaultTheme.accent, fadeAlpha)
        local textColor = scaleColorAlpha(theme.text or defaultTheme.text, fadeAlpha)
        lia.util.drawBlurAt(bx, by, bw, bh - 6, 6, 0.2, math.floor(fadeAlpha * 255))
        lia.derma.rect(bx, by, bw, bh - 6):Radii(8, 8, 0, 0):Color(headerColor):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(bx, by + bh - 6, bw, 6):Radii(0, 0, 8, 8):Color(accentColor):Draw()
        draw.SimpleText(text, font, math.Round(x), math.Round(y - 2), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        return bh
    end
end
