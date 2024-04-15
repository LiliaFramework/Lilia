--- Top-level library containing all Lilia libraries. A large majority of the framework is split into respective libraries that
-- reside within `lia`.
-- @module lia
lia.config.RealmIdentifiers = {
    client = "client",
    server = "server",
    shared = "shared",
    config = "shared",
    module = "shared",
    schema = "shared",
    permissions = "shared",
    sconfig = "server",
}

--- Loads a Lua file into the server, client, or shared realm.
-- This function includes a Lua file into the server, client, or shared realm depending on the specified state.
-- This function has an legacy alias *lia.util.include* that can be used instead of lia.include.
-- @string fileName The name of the Lua file to be included.
-- @string state The state in which the Lua file should be included: "server", "client", or "shared".
-- @return If the Lua file is included on the server and the state is "server", it returns the included file; otherwise, no return value.
-- @realm shared
function lia.include(fileName, state)
    if not fileName then error("[Lilia] No file name specified for inclusion.") end
    local matchResult = string.match(fileName, "/([^/]+)%.lua$")
    local fileRealm = matchResult and lia.config.RealmIdentifiers[matchResult] or "NULL"
    if (state == "server" or fileRealm == "server" or fileName:find("sv_")) and SERVER then
        return include(fileName)
    elseif state == "shared" or fileRealm == "shared" or fileName:find("sh_") then
        if SERVER then AddCSLuaFile(fileName) end
        return include(fileName)
    elseif state == "client" or fileRealm == "client" or fileName:find("cl_") then
        if SERVER then
            AddCSLuaFile(fileName)
        else
            return include(fileName)
        end
    end
end

--- Loads Lua files from a directory into the server, client, or shared realm.
-- This function recursively includes Lua files from a directory into the specified realm.
-- This function has a legacy alias *lia.util.includeDir* that can be used instead of lia.includeDir.
-- @string directory The directory containing the Lua files to be included.
-- @bool fromLua Specifies if the Lua files are located in the lua/ folder.
-- @bool recursive Specifies if subdirectories should be included recursively.
-- @string realm string The realm in which the Lua files should be included: "server", "client", or "shared".
-- @realm shared
function lia.includeDir(directory, fromLua, recursive, realm)
    local baseDir = "lilia"
    if SCHEMA and SCHEMA.folder and SCHEMA.loading then
        baseDir = SCHEMA.folder .. "/schema/"
    else
        baseDir = baseDir .. "/gamemode/"
    end

    if recursive then
        local function AddRecursive(folder, baseFolder)
            local files, folders = file.Find(folder .. "/*", "LUA")
            if not files then
                MsgN("Warning! This folder is empty!")
                return
            end

            for _, v in pairs(files) do
                local fullPath = folder .. "/" .. v
                lia.include(fullPath, realm)
            end

            for _, v in pairs(folders) do
                local subFolder = baseFolder .. "/" .. v
                AddRecursive(folder .. "/" .. v, subFolder)
            end
        end

        local initialFolder = (fromLua and "" or baseDir) .. directory
        AddRecursive(initialFolder, initialFolder)
    else
        for _, v in ipairs(file.Find((fromLua and "" or baseDir) .. directory .. "/*.lua", "LUA")) do
            local fullPath = directory .. "/" .. v
            lia.include(fullPath, realm)
        end
    end
end

--[[
Legacy Includer Support :)
]]
lia.util.include = lia.include
lia.util.includeDir = lia.includeDir
