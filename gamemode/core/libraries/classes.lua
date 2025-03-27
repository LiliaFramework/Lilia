lia.class = lia.class or {}
lia.class.list = lia.class.list or {}
--[[
   Function: lia.class.loadFromDir

   Description:
      Loads class definitions from Lua files located in the specified directory.
      For each valid Lua file, the function includes the file and adds a class table
      to the class list. It also validates that each class has a valid faction.

   Parameters:
      directory (string) - The directory path containing the class Lua files.

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      lia.class.loadFromDir("classes")
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

        if not CLASS.OnCanBe then CLASS.OnCanBe = function() return true end end
        lia.class.list[index] = CLASS
        CLASS = nil
    end
end

--[[
   Function: lia.class.canBe

   Description:
      Determines whether the specified client is allowed to join the given class.
      It checks team alignment, if the client already belongs to the class, class capacity,
      and any additional custom conditions via hooks and OnCanBe callback.

   Parameters:
      client (Player) - The player attempting to join the class.
      class (string/number) - The identifier of the class to check.

   Returns:
      boolean, string (optional) - Returns false with an error message if access is denied,
      or the default status (info.isDefault) of the class if allowed.

   Realm:
      Shared

   Example Usage:
      local allowed, reason = lia.class.canBe(client, "warrior")
]]
function lia.class.canBe(client, class)
    local info = lia.class.list[class]
    if not info then return false, "no info" end
    if client:Team() ~= info.faction then return false, "not correct team" end
    if client:getChar():getClass() == class then return false, "same class request" end
    if info.limit > 0 and #lia.class.getPlayers(info.index) >= info.limit then return false, "class is full" end
    if hook.Run("CanPlayerJoinClass", client, class, info) == false then return false end
    if info.OnCanBe and not info:OnCanBe(client) then return false end
    return info.isDefault
end

--[[
   Function: lia.class.get

   Description:
      Retrieves the class information table from the class list using the provided identifier.

   Parameters:
      identifier (string/number) - The unique identifier for the class.

   Returns:
      table/nil - The class table if found, or nil if it does not exist.

   Realm:
      Shared

   Example Usage:
      local classInfo = lia.class.get("mage")
]]
function lia.class.get(identifier)
    return lia.class.list[identifier]
end

--[[
   Function: lia.class.getPlayers

   Description:
      Returns a list of players whose characters belong to the specified class.

   Parameters:
      class (string/number) - The identifier of the class to filter players by.

   Returns:
      table - A table containing player objects in the specified class.

   Realm:
      Shared

   Example Usage:
      local playersInClass = lia.class.getPlayers("archer")
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
   Function: lia.class.getPlayerCount

   Description:
      Counts the number of players whose characters belong to the specified class.

   Parameters:
      class (string/number) - The identifier of the class to count players in.

   Returns:
      number - The total count of players in the class.

   Realm:
      Shared

   Example Usage:
      local count = lia.class.getPlayerCount("healer")
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
   Function: lia.class.retrieveClass

   Description:
      Searches through the class list to find a class that matches the provided search string.
      The function checks both the uniqueID and the name of each class for a match.

   Parameters:
      class (string) - The search string to match against class uniqueID or name.

   Returns:
      string/nil - The key (identifier) of the matching class, or nil if no match is found.

   Realm:
      Shared

   Example Usage:
      local classKey = lia.class.retrieveClass("warrior")
]]
function lia.class.retrieveClass(class)
    for key, classTable in pairs(lia.class.list) do
        if lia.util.stringMatches(classTable.uniqueID, class) or lia.util.stringMatches(classTable.name, class) then return key end
    end
    return nil
end

--[[
   Function: lia.class.hasWhitelist

   Description:
      Checks if the specified class requires a whitelist for access.
      Default classes do not require a whitelist.

   Parameters:
      class (string/number) - The identifier of the class to check.

   Returns:
      boolean - True if the class is whitelisted, false otherwise.

   Realm:
      Shared

   Example Usage:
      local isWhitelisted = lia.class.hasWhitelist("rogue")
]]
function lia.class.hasWhitelist(class)
    local info = lia.class.list[class]
    if not info then return false end
    if info.isDefault then return false end
    return info.isWhitelisted
end

hook.Add("CreateMenuButtons", "ClassesMenuButtons", function(tabs) if #lia.faction.getClasses(LocalPlayer():getChar():getFaction()) > 1 then tabs["classes"] = function(panel) panel:Add("liaClasses") end end end)
