--[[
    Folder: Developer - Libraries
    File: lia.class.md
]]
--[[
    Class

    Character class helpers for registering, loading, retrieving, counting, validating, and resolving playable classes.
]]
--[[
    Overview:
        The class library centralizes shared character class behavior under `lia.class`. It stores class definitions in `lia.class.list`, loads class files, validates whether a player can join a class, resolves class identifiers, manages whitelist checks, reports class membership counts, and applies default or overridden bodygroups for characters.
]]
--[[
    Hooks:
        CanPlayerJoinClass(Player client, number class, table classData)

    Purpose:
        Allows plugins or modules to block a player from joining a class during class eligibility checks.

    Category:
        Classes

    Parameters:
        client (Player)
            The player attempting to join the class.

        class (number)
            The class index being checked.

        classData (table)
            The registered class data for the class being checked.

    Example Usage:
        ```lua
        hook.Add("CanPlayerJoinClass", "liaExampleCanPlayerJoinClass", function(client, class, classData)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

    Returns:
        boolean|nil
            Return false to prevent the player from joining the class. Return nil or any non-false value to continue normal class validation.

    Realm:
        Shared
]]
lia.class = lia.class or {}
lia.class.list = lia.class.list or {}
--[[
    Purpose:
        Retrieves the normalized bodygroup table configured for a class.

    Parameters:
        class (table|number|string)
            Class data table or class identifier used to look up registered class data.

    Returns:
        table
            Normalized bodygroup values from `bodyGroups` or `bodygroups`, or an empty table when no class data exists.

    Example Usage:
        ```lua
        local bodygroups = lia.class.getBodygroups(CLASS_CITIZEN)
        ```

    Realm:
        Shared
]]
function lia.class.getBodygroups(class)
    local classData = istable(class) and class or lia.class.get(class)
    if not classData then return {} end
    return lia.util.normalizeBodygroups(classData.bodyGroups or classData.bodygroups)
end

--[[
    Purpose:
        Builds the effective bodygroup table for a character by combining class defaults with character-specific overrides.

    Parameters:
        character (Character)
            Character whose class bodygroups and stored bodygroup overrides should be merged.

    Returns:
        table
            Merged normalized bodygroup table where character overrides take priority over class defaults.

    Example Usage:
        ```lua
        local bodygroups = lia.class.getMergedBodygroups(character)
        ```

    Realm:
        Shared
]]
function lia.class.getMergedBodygroups(character)
    local merged = {}
    if character and character.getClass then
        for index, value in pairs(lia.class.getBodygroups(character:getClass())) do
            merged[index] = value
        end
    end

    local overrides = character and character.vars and character.vars.bodygroups or nil
    for index, value in pairs(lia.util.normalizeBodygroups(overrides)) do
        merged[index] = value
    end
    return merged
end

--[[
    Purpose:
        Registers or updates a character class with a unique identifier and class data.

    Parameters:
        uniqueID (string)
            Unique string identifier for the class.

        data (table)
            Class definition data to store, including a valid `faction` value and optional class configuration.

    Returns:
        number|nil
            Registered class index, or nil if registration fails because the class has no valid faction.

        table|nil
            Registered class table, or nil if registration fails because the class has no valid faction.

    Example Usage:
        ```lua
        local classIndex = lia.class.register("medic", {
            name = "Medic",
            desc = "A trained field medic.",
            faction = FACTION_CITIZEN
        })
        ```

    Realm:
        Shared
]]
function lia.class.register(uniqueID, data)
    assert(isstring(uniqueID), L("itemUniqueIDString"))
    assert(istable(data), L("classDataTable"))
    local existing
    local constantName = "CLASS_" .. string.upper(uniqueID)
    local providedIndex = tonumber(data.index)
    local constantIndex = tonumber(_G[constantName])
    local index = providedIndex or constantIndex
    for i, v in ipairs(lia.class.list) do
        if v.uniqueID == uniqueID then
            existing = v
            index = index or i
            break
        end
    end

    index = index or #lia.class.list + 1
    assert(not lia.class.list[index] or lia.class.list[index] == existing, "class index is already in use")
    local class = existing or {
        index = index
    }

    for k, v in pairs(data) do
        class[k] = v
    end

    class.index = index
    class.uniqueID = uniqueID
    class.name = lia.lang.resolveToken(class.name) or lia.lang.resolveToken("@unknown")
    class.desc = lia.lang.resolveToken(class.desc) or lia.lang.resolveToken("@noDesc")
    class.limit = class.limit or 0
    if not class.faction or not team.Valid(class.faction) then
        lia.error(L("classNoValidFaction", uniqueID))
        return
    end

    if not class.OnCanBe then class.OnCanBe = function() return true end end
    lia.class.list[index] = class
    _G[constantName] = class.index
    return class.index, class
end

--[[
    Purpose:
        Loads class definition files from a directory and adds valid class definitions to the registered class list.

    Parameters:
        directory (string)
            Lua directory path containing class files to load.

    Returns:
        None

    Example Usage:
        ```lua
        lia.class.loadFromDir("schema/classes")
        ```

    Realm:
        Shared
]]
function lia.class.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local index = #lia.class.list + 1
        local halt
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5)
        end

        for _, class in ipairs(lia.class.list) do
            if class.uniqueID == niceName then halt = true end
        end

        if halt then continue end
        CLASS = {
            index = index,
            uniqueID = niceName
        }

        CLASS.name = "@unknown"
        CLASS.desc = "@noDesc"
        CLASS.limit = 0
        lia.loader.include(directory .. "/" .. v, "shared")
        if not CLASS.faction or not team.Valid(CLASS.faction) then
            lia.error(L("classNoValidFaction", niceName))
            CLASS = nil
            continue
        end

        if not CLASS.OnCanBe then CLASS.OnCanBe = function() return true end end
        CLASS.name = lia.lang.resolveToken(CLASS.name)
        CLASS.desc = lia.lang.resolveToken(CLASS.desc)
        lia.class.list[index] = CLASS
        CLASS = nil
    end
end

--[[
    Purpose:
        Checks whether a player is allowed to join a specific class.

    Parameters:
        client (Player)
            Player being checked.

        class (number)
            Class index being checked.

    Returns:
        boolean
            True if the player can join the class, otherwise false.

        string|nil
            Localized failure reason when class validation fails.

    Example Usage:
        ```lua
        local canJoin, reason = lia.class.canBe(client, CLASS_MEDIC)
        ```

    Realm:
        Shared
]]
function lia.class.canBe(client, class)
    if not lia.class.list then return false, L("classNoInfo") end
    local info = lia.class.list[class]
    if not info then return false, L("classNoInfo") end
    if client:Team() ~= info.faction then return false, L("classWrongTeam") end
    local character = client:getChar()
    if character and character:getClass() == class then return false, L("alreadyInClass") end
    local currentCount = #lia.class.getPlayers(info.index)
    if info.limit > 0 and currentCount >= info.limit then return false, L("classFull") end
    if info.isDefault == false and lia.class.hasWhitelist(class) and character and not character:getClasswhitelists()[class] then return false, L("classWhitelistRequired") end
    local hookResult = hook.Run("CanPlayerJoinClass", client, class, info)
    if hookResult == false then return false end
    if info.OnCanBe then
        local onCanBeResult = info:OnCanBe(client)
        if not onCanBeResult then return false end
    end
    return true
end

--[[
    Purpose:
        Retrieves registered class data by identifier.

    Parameters:
        identifier (number|string)
            Class list key used to retrieve the class data.

    Returns:
        table|nil
            Registered class data when found, otherwise nil.

    Example Usage:
        ```lua
        local classData = lia.class.get(CLASS_MEDIC)
        ```

    Realm:
        Shared
]]
function lia.class.get(identifier)
    if not lia.class.list then return nil end
    return lia.class.list[identifier]
end

--[[
    Purpose:
        Returns all players whose active character is assigned to a class.

    Parameters:
        class (number)
            Class index to match against active characters.

    Returns:
        table
            Sequential table of players currently in the class.

    Example Usage:
        ```lua
        local medics = lia.class.getPlayers(CLASS_MEDIC)
        ```

    Realm:
        Shared
]]
function lia.class.getPlayers(class)
    if not lia.class.list then return {} end
    local players = {}
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getClass() == class then table.insert(players, v) end
    end
    return players
end

--[[
    Purpose:
        Counts players whose active character is assigned to a class.

    Parameters:
        class (number)
            Class index to count.

    Returns:
        number
            Number of players currently in the class.

    Example Usage:
        ```lua
        local medicCount = lia.class.getPlayerCount(CLASS_MEDIC)
        ```

    Realm:
        Shared
]]
function lia.class.getPlayerCount(class)
    if not lia.class.list then return 0 end
    local count = 0
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getClass() == class then count = count + 1 end
    end
    return count
end

--[[
    Purpose:
        Finds a registered class index by matching a class unique ID or display name.

    Parameters:
        class (string)
            Class unique ID or class name to search for.

    Returns:
        number|nil
            Matching class index when found, otherwise nil.

    Example Usage:
        ```lua
        local classIndex = lia.class.retrieveClass("medic")
        ```

    Realm:
        Shared
]]
function lia.class.retrieveClass(class)
    if not lia.class.list then return nil end
    for key, classTable in pairs(lia.class.list) do
        if lia.util.stringMatches(classTable.uniqueID, class) or lia.util.stringMatches(classTable.name, class) then return key end
    end
    return nil
end

--[[
    Purpose:
        Checks whether a class requires whitelist access.

    Parameters:
        class (number)
            Class index to check.

    Returns:
        boolean
            True if the class requires whitelist access, otherwise false.

    Example Usage:
        ```lua
        if lia.class.hasWhitelist(CLASS_MEDIC) then
            client:notifyInfo("This class requires whitelist access.")
        end
        ```

    Realm:
        Shared
]]
function lia.class.hasWhitelist(class)
    if not lia.class.list then return false end
    local info = lia.class.list[class]
    if not info then return false end
    if info.isDefault then return false end
    if info.isWhitelisted ~= nil then return info.isWhitelisted end
    return true
end

--[[
    Purpose:
        Returns classes that a player is currently eligible to join.

    Parameters:
        client (Player|nil)
            Player to check. Defaults to the local player on the client when omitted.

    Returns:
        table
            Sequential table of class data tables that the player can join.

    Example Usage:
        ```lua
        local classes = lia.class.retrieveJoinable(client)
        ```

    Realm:
        Shared
]]
function lia.class.retrieveJoinable(client)
    client = client or CLIENT and LocalPlayer() or nil
    if not IsValid(client) then return {} end
    if not lia.class.list then return {} end
    local classes = {}
    for _, class in pairs(lia.class.list) do
        if lia.class.canBe(client, class.index) then classes[#classes + 1] = class end
    end
    return classes
end
