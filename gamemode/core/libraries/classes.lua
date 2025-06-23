lia.class = lia.class or {}
lia.class.list = lia.class.list or {}
--[[
    lia.class.loadFromDir(directory)

    Description:
        Loads all class definitions from the given directory and stores them in lia.class.list.

    Parameters:
        directory (string) – Folder path containing class Lua files.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        lia.class.loadFromDir("schema/classes")
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
            ErrorNoHalt("Class '" .. niceName .. "' does not have a valid faction!\n")
            CLASS = nil
            continue
        end

        if not CLASS.OnCanBe then CLASS.OnCanBe = function() return true end end
        lia.class.list[index] = CLASS
        CLASS = nil
    end
end

--[[
    lia.class.canBe(client, class)

    Description:
        Determines if the given client may become the specified class.

    Parameters:
        client (Player) – Player attempting to join.
        class (string|number) – Class identifier.

    Returns:
        boolean – False with a message if denied; default status when allowed.

    Realm:
        Shared

    Example Usage:
        local allowed = lia.class.canBe(client, classID)
]]
function lia.class.canBe(client, class)
    local info = lia.class.list[class]
    if not info then return false, L("classNoInfo") end
    if client:Team() ~= info.faction then return false, L("classWrongTeam") end
    if client:getChar():getClass() == class then return false, L("classAlreadyIn") end
    if info.limit > 0 and #lia.class.getPlayers(info.index) >= info.limit then return false, L("classFull") end
    if hook.Run("CanPlayerJoinClass", client, class, info) == false then return false end
    if info.OnCanBe and not info:OnCanBe(client) then return false end
    return info.isDefault
end

--[[
    lia.class.get(identifier)

    Description:
        Retrieves the class table associated with the given identifier.

    Parameters:
        identifier (string|number) – Unique identifier for the class.

    Returns:
        table|nil – Class table if found.

    Realm:
        Shared

    Example Usage:
        local classData = lia.class.get(1)
]]
function lia.class.get(identifier)
    return lia.class.list[identifier]
end

--[[
    lia.class.getPlayers(class)

    Description:
        Returns a table of players whose characters belong to the given class.

    Parameters:
        class (string|number) – Class identifier.

    Returns:
        table – List of player objects.

    Realm:
        Shared

    Example Usage:
        local players = lia.class.getPlayers(classID)
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
    lia.class.getPlayerCount(class)

    Description:
        Counts how many players belong to the given class.

    Parameters:
        class (string|number) – Class identifier.

    Returns:
        number – Player count.

    Realm:
        Shared

    Example Usage:
        local count = lia.class.getPlayerCount(classID)
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
    lia.class.retrieveClass(class)

    Description:
        Searches the class list for a class whose ID or name matches the given text.

    Parameters:
        class (string) – Search text.

    Returns:
        string|nil – Matching class identifier or nil.

    Realm:
        Shared

    Example Usage:
        local id = lia.class.retrieveClass("police")
]]
function lia.class.retrieveClass(class)
    for key, classTable in pairs(lia.class.list) do
        if lia.util.stringMatches(classTable.uniqueID, class) or lia.util.stringMatches(classTable.name, class) then return key end
    end
    return nil
end

--[[
    lia.class.hasWhitelist(class)

    Description:
        Returns whether the specified class requires a whitelist.

    Parameters:
        class (string|number) – Class identifier.

    Returns:
        boolean – True if the class is whitelisted.

    Realm:
        Shared

    Example Usage:
        if lia.class.hasWhitelist(classID) then
            print("Whitelist required")
        end
]]
function lia.class.hasWhitelist(class)
    local info = lia.class.list[class]
    if not info then return false end
    if info.isDefault then return false end
    return info.isWhitelisted
end