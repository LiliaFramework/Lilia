lia.util.cachedMaterials = lia.util.cachedMaterials or {}
ALWAYS_RAISED = ALWAYS_RAISED or {}
ALWAYS_RAISED["weapon_physgun"] = true
ALWAYS_RAISED["gmod_tool"] = true
ALWAYS_RAISED["lia_poshelper"] = true

-- @type function lia.util.include
-- @typeCommentStart
-- This function is used to include Lua files based on their state (server, shared, or client).
-- It checks the file name and the state parameter to determine how to include the file.
-- If the file is server-side and the server is running, it uses the `include` function.
-- If the file is shared, it includes the file on both server and client by sending it to the client using `AddCSLuaFile`.
-- If the file is client-side and the server is running, it sends the file to the client using `AddCSLuaFile` and includes it on the client.
-- @typeCommentEnd
-- @classmod Util
-- @realm shared
-- @usageStart
-- Example usage:
-- lia.util.include("sv_myfile.lua", "server")
-- @usageEnd
function lia.util.include(fileName, state)
    if not fileName then
        error("[Lilia] No file name specified for including.")
    end

    -- Only include server-side if we're on the server.
    if (state == "server" or fileName:find("sv_")) and SERVER then
        return include(fileName)
    elseif state == "shared" or fileName:find("sh_") then
        -- Shared is included by both server and client.
        if SERVER then
            -- Send the file to the client if shared so they can run it.
            AddCSLuaFile(fileName)
        end

        return include(fileName)
    elseif state == "client" or fileName:find("cl_") then
        -- File is sent to client, included on client.
        if SERVER then
            AddCSLuaFile(fileName)
        else
            return include(fileName)
        end
    end
end

-- @type function lia.util.includeDir
-- @typeCommentStart
-- Includes Lua files from a directory based on their prefix.
-- It allows including files recursively if specified.
-- @typeCommentEnd
-- @classmod Util
-- @realm shared
-- @usageStart
-- Example usage:
-- lia.util.includeDir("mydirectory", true, true)
-- @usageEnd
function lia.util.includeDir(directory, fromLua, recursive)
    -- By default, we include relatively to Lilia.
    local baseDir = "lilia"

    -- If we're in a schema, include relative to the schema.
    if SCHEMA and SCHEMA.folder and SCHEMA.loading then
        baseDir = SCHEMA.folder .. "/schema/"
    else
        baseDir = baseDir .. "/gamemode/"
    end

    if recursive then
        local function AddRecursive(folder)
            local files, folders = file.Find(folder .. "/*", "LUA")

            if not files then
                MsgN("Warning! This folder is empty!")

                return
            end

            for k, v in pairs(files) do
                lia.util.include(folder .. "/" .. v)
            end

            for k, v in pairs(folders) do
                AddRecursive(folder .. "/" .. v)
            end
        end

        AddRecursive((fromLua and "" or baseDir) .. directory)
    else
        -- Find all of the files within the directory.
        for k, v in ipairs(file.Find((fromLua and "" or baseDir) .. directory .. "/*.lua", "LUA")) do
            -- Include the file from the prefix.
            lia.util.include(directory .. "/" .. v)
        end
    end
end

-- @type function lia.util.getAddress
-- @typeCommentStart
-- Legacy Code, here to avoid breaking stuff
-- @typeCommentEnd
-- @classmod Util
-- @realm shared
-- @usageStart
-- N/A
-- @usageEnd
-- Returns the address:port of the server.
function lia.util.getAddress()
    ErrorNoHalt("lia.util.getAddress() is deprecated, use game.GetIPAddress()\n")

    return game.GetIPAddress()
end

-- @type function lia.util.getAdmins
-- @typeCommentStart
-- Returns any person with Admin Permissions. If bool is true, SuperAdmins are also called. 
-- @typeCommentEnd
-- @classmod Util
-- @realm shared
-- @intParam isSuper Set to true to get super admins, false to get regular admins.
-- @return admins A table containing the list of admins.
-- @usageStart
-- lia.util.getAdmins(bool)
-- @usageEnd
function lia.util.getAdmins(isSuper)
    local admins = {}

    for k, v in ipairs(player.GetAll()) do
        if isSuper then
            if v:IsSuperAdmin() then
                admins[#admins + 1] = v
            end
        else
            if v:IsAdmin() then
                admins[#admins + 1] = v
            end
        end
    end

    return admins
end

-- @type function lia.util.isSteamID
-- @typeCommentStart
-- Checks if a given value is a valid SteamID.
-- @typeCommentEnd
-- @classmod Util
-- @realm shared
-- @param value The value to check if it's a SteamID.
-- @return boolean Returns true if the value is a valid SteamID, false otherwise.
-- @usageStart
-- Example usage:
-- local isSteamID = lia.util.isSteamID("STEAM_0:1:12345678")
-- @usageEnd
function lia.util.isSteamID(value)
    if string.match(value, "STEAM_(%d+):(%d+):(%d+)") then return true end

    return false
end

-- @type function lia.util.findPlayer
-- @typeCommentStart
-- Finds a player by matching their name or SteamID.
-- @typeCommentEnd
-- @classmod Util
-- @realm shared
-- @param identifier The name or SteamID of the player to find.
-- @param allowPatterns Set to true to allow pattern matching for the identifier.
-- @return player|nil Returns the found player or nil if no player was found.
-- @usageStart
-- Example usage:
-- local player = lia.util.findPlayer("JohnDoe", false)
-- @usageEnd
function lia.util.findPlayer(identifier, allowPatterns)
    if lia.util.isSteamID(identifier) then return player.GetBySteamID(identifier) end

    if not allowPatterns then
        identifier = string.PatternSafe(identifier)
    end

    for k, v in ipairs(player.GetAll()) do
        if lia.util.stringMatches(v:Name(), identifier) then return v end
    end
end

-- @type function lia.util.gridVector
-- @typeCommentStart
-- Rounds the components of a vector to the nearest multiple of a grid size.
-- @typeCommentEnd
-- @classmod Util
-- @realm shared
-- @param vec The vector to round.
-- @param gridSize The size of the grid.
-- @return Vector Returns the rounded vector.
-- @usageStart
-- Example usage:
-- local roundedVector = lia.util.gridVector(Vector(1.2, 2.5, 3.7), 0.5)
-- @usageEnd
function lia.util.gridVector(vec, gridSize)
    if gridSize <= 0 then
        gridSize = 1
    end

    for i = 1, 3 do
        vec[i] = vec[i] / gridSize
        vec[i] = math.Round(vec[i])
        vec[i] = vec[i] * gridSize
    end

    return vec
end

-- @type function lia.util.getAllChar
-- @typeCommentStart
-- Retrieves the IDs of all characters owned by players.
-- @typeCommentEnd
-- @classmod Util
-- @realm shared
-- @return table Returns a table containing the IDs of all characters owned by players.
-- @usageStart
-- Example usage:
-- local charIDs = lia.util.getAllChar()
-- for k, id in ipairs(charIDs) do
--     print(id)
-- end
-- @usageEnd
function lia.util.getAllChar()
    local charTable = {}

    for k, v in ipairs(player.GetAll()) do
        if v:getChar() then
            table.insert(charTable, v:getChar():getID())
        end
    end

    return charTable
end

-- @type function lia.util.getMaterial
-- @typeCommentStart
-- Retrieves a material from the cache or creates a new one if it doesn't exist.
-- @typeCommentEnd
-- @param string materialPath The path to the material.
-- @return Material The material object.
-- @classmod Util
-- @realm shared
-- @usageStart
-- Example usage:
-- local material = lia.util.getMaterial("materials/my_material.vmt")
-- @usageEnd
function lia.util.getMaterial(materialPath)
    -- Cache the material.
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath)

    return lia.util.cachedMaterials[materialPath]
end

lia.util.includeDir("lilia/gamemode/core/util", true)