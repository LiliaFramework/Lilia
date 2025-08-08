--[[
# Classes Library

This page documents the functions for working with character classes and job systems.

---

## Overview

The classes library provides a system for managing character classes, jobs, and roles within the Lilia framework. It handles class registration, faction association, limits, and provides utilities for class validation and management. The library supports class-specific permissions, whitelisting, and provides a foundation for role-playing game mechanics.
]]
lia.class = lia.class or {}
lia.class.list = lia.class.list or {}
--[[
    lia.class.register

    Purpose:
        Registers a new class with the system, or updates an existing one if the uniqueID already exists.
        Ensures the class has required fields, validates its faction, and stores it in lia.class.list.

    Parameters:
        uniqueID (string) - The unique identifier for the class.
        data (table)      - Table containing class properties (name, desc, faction, limit, etc).

    Returns:
        class (table) - The registered or updated class table.

    Realm:
        Shared.

    Example Usage:
        -- Register a new class for the "Combine" faction
        lia.class.register("overwatch", {
            name = "Overwatch Soldier",
            desc = "A transhuman soldier of the Combine.",
            faction = FACTION_COMBINE,
            limit = 4,
            isDefault = false,
            isWhitelisted = true,
            OnCanBe = function(self, client)
                return client:IsAdmin()
            end
        })
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
    lia.class.loadFromDir

    Purpose:
        Loads all class definition files from the specified directory, registering each as a class.
        Each file should define a CLASS table. Ensures each class has required fields and a valid faction.

    Parameters:
        directory (string) - The directory path to search for class files (should be relative to the gamemode).

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Load all classes from the "classes" directory
        lia.class.loadFromDir("gamemode/schema/classes")
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
        lia.include(directory .. "/" .. v, "shared")
        if not CLASS.faction or not team.Valid(CLASS.faction) then
            lia.error(L("classNoValidFaction", niceName))
            CLASS = nil
            continue
        end

        if not CLASS.OnCanBe then CLASS.OnCanBe = function() return true end end
        lia.class.list[index] = CLASS
        CLASS = nil
    end
end

--[[
    lia.class.canBe

    Purpose:
        Determines if a client is eligible to join a specified class.
        Checks faction, current class, class limit, hooks, and custom OnCanBe logic.

    Parameters:
        client (Player) - The player to check eligibility for.
        class (number)  - The class index to check.

    Returns:
        (boolean, string|none) - True if the client can join, or false and a reason string if not.

    Realm:
        Shared.

    Example Usage:
        -- Check if a player can join class 2
        local canJoin, reason = lia.class.canBe(ply, 2)
        if not canJoin then
            print("Cannot join class:", reason)
        end
]]
function lia.class.canBe(client, class)
    local info = lia.class.list[class]
    if not info then return false, L("classNoInfo") end
    if client:Team() ~= info.faction then return false, L("classWrongTeam") end
    if client:getChar():getClass() == class then return false, L("alreadyInClass") end
    if info.limit > 0 and #lia.class.getPlayers(info.index) >= info.limit then return false, L("classFull") end
    if hook.Run("CanPlayerJoinClass", client, class, info) == false then return false end
    if info.OnCanBe and not info:OnCanBe(client) then return false end
    return info.isDefault
end

--[[
    lia.class.get

    Purpose:
        Retrieves the class table for the given identifier (index or uniqueID).

    Parameters:
        identifier (number|string) - The class index or uniqueID.

    Returns:
        class (table|none) - The class table if found, or none.

    Realm:
        Shared.

    Example Usage:
        -- Get the class table for index 1
        local class = lia.class.get(1)
        -- Get the class table for uniqueID "overwatch"
        local class2 = lia.class.get("overwatch")
]]
function lia.class.get(identifier)
    return lia.class.list[identifier]
end

--[[
    lia.class.getPlayers

    Purpose:
        Returns a table of all players currently in the specified class.

    Parameters:
        class (number) - The class index to search for.

    Returns:
        players (table) - Table of player entities in the class.

    Realm:
        Shared.

    Example Usage:
        -- Get all players in class 3
        local players = lia.class.getPlayers(3)
        for _, ply in ipairs(players) do
            print(ply:Name())
        end
]]
function lia.class.getPlayers(class)
    local players = {}
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getClass() == class then table.insert(players, v) end
    end
    return players
end

--[[
    lia.class.getPlayerCount

    Purpose:
        Returns the number of players currently in the specified class.

    Parameters:
        class (number) - The class index to count.

    Returns:
        count (number) - The number of players in the class.

    Realm:
        Shared.

    Example Usage:
        -- Print the number of players in class 2
        print("Players in class 2:", lia.class.getPlayerCount(2))
]]
function lia.class.getPlayerCount(class)
    local count = 0
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getClass() == class then count = count + 1 end
    end
    return count
end

--[[
    lia.class.retrieveClass

    Purpose:
        Finds the class index for a class by matching its uniqueID or name (case-insensitive, partial match allowed).

    Parameters:
        class (string) - The uniqueID or name (or partial) to search for.

    Returns:
        index (number|none) - The class index if found, or none.

    Realm:
        Shared.

    Example Usage:
        -- Retrieve the class index for "overwatch"
        local idx = lia.class.retrieveClass("overwatch")
        if idx then
            print("Class index is:", idx)
        end
]]
function lia.class.retrieveClass(class)
    for key, classTable in pairs(lia.class.list) do
        if lia.util.stringMatches(classTable.uniqueID, class) or lia.util.stringMatches(classTable.name, class) then return key end
    end
    return nil
end

--[[
    lia.class.hasWhitelist

    Purpose:
        Checks if the specified class requires a whitelist (i.e., is not default and is marked as whitelisted).

    Parameters:
        class (number) - The class index to check.

    Returns:
        (boolean) - True if the class is whitelisted, false otherwise.

    Realm:
        Shared.

    Example Usage:
        -- Check if class 4 is whitelisted
        if lia.class.hasWhitelist(4) then
            print("Class 4 requires a whitelist.")
        end
]]
function lia.class.hasWhitelist(class)
    local info = lia.class.list[class]
    if not info then return false end
    if info.isDefault then return false end
    return info.isWhitelisted
end

--[[
    lia.class.retrieveJoinable

    Purpose:
        Returns a table of all classes that the given client is eligible to join.

    Parameters:
        client (Player) - The player to check joinable classes for. If nil, uses LocalPlayer() on client.

    Returns:
        classes (table) - Table of class tables the client can join.

    Realm:
        Shared.

    Example Usage:
        -- Get all joinable classes for a player
        local joinable = lia.class.retrieveJoinable(ply)
        for _, class in ipairs(joinable) do
            print("Can join:", class.name)
        end
]]
function lia.class.retrieveJoinable(client)
    client = client or CLIENT and LocalPlayer() or nil
    if not IsValid(client) then return {} end
    local classes = {}
    for _, class in pairs(lia.class.list) do
        if lia.class.canBe(client, class.index) then classes[#classes + 1] = class end
    end
    return classes
end