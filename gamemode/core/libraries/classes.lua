--[[
    Folder: Libraries
    File: class.md
]]
--[[
    Classes Library

    Character class management and validation system for the Lilia framework.
]]
--[[
    Overview:
        The classes library provides comprehensive functionality for managing character classes in the Lilia framework. It handles registration, validation, and management of player classes within factions. The library operates on both server and client sides, allowing for dynamic class creation, whitelist management, and player class assignment validation. It includes functionality for loading classes from directories, checking class availability, retrieving class information, and managing class limits. The library ensures proper faction validation and provides hooks for custom class behavior and restrictions.
]]
lia.class = lia.class or {}
lia.class.list = lia.class.list or {}
--[[
    Purpose:
        Registers or updates a class definition within the global class list.

    When Called:
        Invoked during schema initialization or dynamic class creation to
        ensure a class entry exists before use.

    Parameters:
        uniqueID (string)
            Unique identifier for the class; must be consistent across loads.
        data (table)
            Class metadata such as name, desc, faction, limit, OnCanBe, etc.

    Returns:
        table
            The registered class table with applied defaults.

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.class.register("soldier", {
            name = "Soldier",
            faction = FACTION_MILITARY,
            limit = 4
        })
        ```
]]
function lia.class.register(uniqueID, data)
    assert(isstring(uniqueID), L("classUniqueIDString"))
    assert(istable(data), L("classDataTable"))
    local index = #lia.class.list + 1
    local existing
    for i, v in ipairs(lia.class.list) do
        if v.uniqueID == uniqueID then
            index = i
            existing = v
            break
        end
    end

    local class = existing or {
        index = index
    }

    for k, v in pairs(data) do
        class[k] = v
    end

    class.uniqueID = uniqueID
    class.name = class.name or L("unknown")
    class.desc = class.desc or L("noDesc")
    class.limit = class.limit or 0
    if not class.faction or not team.Valid(class.faction) then
        lia.error(L("classNoValidFaction", uniqueID))
        return
    end

    if not class.OnCanBe then class.OnCanBe = function() return true end end
    lia.class.list[index] = class
    return class
end

--[[
    Purpose:
        Loads and registers all class definitions from a directory.

    When Called:
        Used during schema loading to automatically include class files in a
        folder following the naming convention.

    Parameters:
        directory (string)
            Path to the directory containing class Lua files.

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.class.loadFromDir("lilia/gamemode/classes")
        ```
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

        CLASS.name = L("unknown")
        CLASS.desc = L("noDesc")
        CLASS.limit = 0
        lia.loader.include(directory .. "/" .. v, "shared")
        if not CLASS.faction or not team.Valid(CLASS.faction) then
            lia.error(L("classNoValidFaction", niceName))
            CLASS = nil
            continue
        end

        if not CLASS.OnCanBe then CLASS.OnCanBe = function() return true end end
        CLASS.name = L(CLASS.name)
        CLASS.desc = L(CLASS.desc)
        lia.class.list[index] = CLASS
        CLASS = nil
    end
end

--[[
    Purpose:
        Determines whether a client can join a specific class.

    When Called:
        Checked before class selection to enforce faction, limits, whitelist,
        and custom restrictions.

    Parameters:
        client (Player)
            Player attempting to join the class.
        class (number|string)
            Class index or unique identifier.

    Returns:
        boolean|string
            False and a reason string on failure; otherwise returns the
            class's isDefault value.

    Realm:
        Shared

    Example Usage:
        ```lua
        local ok, reason = lia.class.canBe(ply, CLASS_CITIZEN)
        if ok then
            -- proceed with class change
        end
        ```
]]
function lia.class.canBe(client, class)
    if not lia.class.list then return false, L("classNoInfo") end
    local info = lia.class.list[class]
    if not info then return false, L("classNoInfo") end
    if client:Team() ~= info.faction then return false, L("classWrongTeam") end
    local character = client:getChar()
    if character and character:getClass() == class then return false, L("alreadyInClass") end
    if info.limit > 0 and #lia.class.getPlayers(info.index) >= info.limit then return false, L("classFull") end
    if hook.Run("CanPlayerJoinClass", client, class, info) == false then return false end
    if info.OnCanBe and not info:OnCanBe(client) then return false end
    return info.isDefault
end

--[[
    Purpose:
        Retrieves a class table by index or unique identifier.

    When Called:
        Used whenever class metadata is needed given a known identifier.

    Parameters:
        identifier (number|string)
            Class list index or unique identifier.

    Returns:
        table|nil
            The class table if found; otherwise nil.

    Realm:
        Shared

    Example Usage:
        ```lua
        local classData = lia.class.get("soldier")
        ```
]]
function lia.class.get(identifier)
    if not lia.class.list then return nil end
    return lia.class.list[identifier]
end

--[[
    Purpose:
        Collects all players currently assigned to the given class.

    When Called:
        Used when enforcing limits or displaying membership lists.

    Parameters:
        class (number|string)
            Class list index or unique identifier.

    Returns:
        table
            Array of player entities in the class.

    Realm:
        Shared

    Example Usage:
        ```lua
        for _, ply in ipairs(lia.class.getPlayers("soldier")) do
            -- notify class members
        end
        ```
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
        Counts how many players are in the specified class.

    When Called:
        Used to check class limits or display class population.

    Parameters:
        class (number|string)
            Class list index or unique identifier.

    Returns:
        number
            Current number of players in the class.

    Realm:
        Shared

    Example Usage:
        ```lua
        local count = lia.class.getPlayerCount(CLASS_ENGINEER)
        ```
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
        Finds the class index by matching uniqueID or display name.

    When Called:
        Used to resolve user input to a class entry before further lookups.

    Parameters:
        class (string)
            Text to match against class uniqueID or name.

    Returns:
        number|nil
            The class index if a match is found; otherwise nil.

    Realm:
        Shared

    Example Usage:
        ```lua
        local idx = lia.class.retrieveClass("Engineer")
        ```
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
        Checks whether a class uses whitelist access.

    When Called:
        Queried before allowing class selection or displaying class info.

    Parameters:
        class (number|string)
            Class list index or unique identifier.

    Returns:
        boolean
            True if the class is whitelisted and not default; otherwise false.

    Realm:
        Shared

    Example Usage:
        ```lua
        if lia.class.hasWhitelist(CLASS_PILOT) then
            -- restrict to whitelisted players
        end
        ```
]]
function lia.class.hasWhitelist(class)
    if not lia.class.list then return false end
    local info = lia.class.list[class]
    if not info then return false end
    if info.isDefault then return false end
    return info.isWhitelisted
end

--[[
    Purpose:
        Returns a list of classes the provided client is allowed to join.

    When Called:
        Used to build class selection menus and enforce availability.

    Parameters:
        client (Player|nil)
            Target player; defaults to LocalPlayer on the client.

    Returns:
        table
            Array of class tables the client can currently join.

    Realm:
        Shared

    Example Usage:
        ```lua
        local options = lia.class.retrieveJoinable(ply)
        ```
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
