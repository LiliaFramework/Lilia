--[[--
Helper library for loading/getting class information.

Classes are temporary assignments for characters - analogous to a "job" in a faction. For example, you may have a police faction
in your schema, and have "police recruit" and "police chief" as different classes in your faction. Anyone can join a class in
their faction by default, but you can restrict this as you need with `CLASS.onCanBe`.

If you are looking for the class structure, you can find it [here](https://liliaframework.github.io/manual/structure_class.html).
]]
-- @module lia.class
lia.class = lia.class or {}
lia.class.list = lia.class.list or {}
--- Loads class information from Lua files in the specified directory.
-- @realm shared
-- @string directory The directory path from which to load class Lua files.
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

        if halt == true then continue end
        CLASS = {
            index = index,
            uniqueID = niceName
        }

        CLASS.name = "Unknown"
        CLASS.desc = "No description available."
        CLASS.limit = 0
        if MODULE then CLASS.module = MODULE.uniqueID end
        lia.include(directory .. "/" .. v, "shared")
        if not CLASS.faction or not team.Valid(CLASS.faction) then
            ErrorNoHalt("Class '" .. niceName .. "' does not have a valid faction!\n")
            CLASS = nil
            continue
        end

        if not CLASS.onCanBe then CLASS.onCanBe = function(_) return true end end
        lia.class.list[index] = CLASS
        CLASS = nil
    end
end
--- Checks if a player can join a particular class.
-- @realm shared
-- @client client The player wanting to join the class.
-- @int class The identifier of the class.
-- @return bool Whether the player can join the class.
-- @return string Reason for the failure, if any.

function lia.class.canBe(client, class)
    local info = lia.class.list[class]
    if not info then return false, "no info" end
    if client:Team() ~= info.faction then return false, "not correct team" end
    if client:getChar():getClass() == class then return false, "same class request" end
    if info.limit > 0 and #lia.class.getPlayers(info.index) >= info.limit then return false, "class is full" end
    if hook.Run("CanPlayerJoinClass", client, class, info) == false then return false end
    return info:onCanBe(client)
end
--- Retrieves information about a class.
-- @realm shared
-- @int identifier The identifier of the class.
-- @return tab Information about the class.

function lia.class.get(identifier)
    return lia.class.list[identifier]
end
--- Retrieves a list of players belonging to a specific class.
-- @realm shared
-- @int class The identifier of the class.
-- @return tab List of players belonging to the class.

function lia.class.getPlayers(class)
    local players = {}
    for _, v in ipairs(player.GetAll()) do
        local character = v:getChar()
        if character and character:getClass() == class then table.insert(players, v) end
    end
    return players
end
--- Retrieves the count of players belonging to a specific class.
-- @realm shared
-- @int class The identifier of the class.
-- @return int The count of players belonging to the class.

function lia.class.getPlayerCount(class)
    local count = 0
    for _, v in ipairs(player.GetAll()) do
        local character = v:getChar()
        if character and character:getClass() == class then count = count + 1 end
    end
    return count
end
--- Retrieves the identifier of a class based on its unique ID or name.
-- @realm shared
-- @string class The unique ID or name of the class.
-- @return int The identifier of the class if found, nil otherwise.

function lia.class.retrieveClass(class)
    for key, classTable in pairs(lia.class.list) do
        if lia.util.stringMatches(classTable.uniqueID, class) or lia.util.stringMatches(classTable.name, class) then return key end
    end
    return nil
end
