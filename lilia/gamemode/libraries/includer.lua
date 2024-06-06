--- Top-level library containing all Lilia libraries. A large majority of the framework is split into respective libraries that
-- reside within `lia`.
-- @alibrary lia
lia.RealmIdentifiers = {
    client = "client",
    server = "server",
    shared = "shared",
    config = "shared",
    module = "shared",
    schema = "shared",
    permissions = "shared",
    sconfig = "server",
}

lia.FilesToLoad = {
    {
        path = "lilia/gamemode/libraries/util.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/meta/character.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/character.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/animations.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/config/animations.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/hooks/core/shared.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/hooks/core/client.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/hooks/core/server.lua",
        realm = "server"
    },
    {
        path = "lilia/gamemode/libraries/module.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/chatbox.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/commands.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/objects/commands/client.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/objects/commands/server.lua",
        realm = "server"
    },
    {
        path = "lilia/gamemode/libraries/flags.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/inventory.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/meta/item.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/item.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/languages.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/hooks/languages.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/libraries/networking.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/attributes.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/factions.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/classes.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/currency.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/hooks/currency.lua",
        realm = "server"
    },
    {
        path = "lilia/gamemode/libraries/date.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/meta/inventory.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/hooks/items.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/meta/entity.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/meta/player.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/logger.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/concommands.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/libraries/color.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/libraries/menu.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/libraries/notice.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/libraries/bars.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/hooks/animations.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/netcalls/client.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/netcalls/server.lua",
        realm = "server"
    },
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
    local fileRealm = matchResult and lia.RealmIdentifiers[matchResult] or "NULL"
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

lia.util.include = lia.include
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

lia.includeDir("lilia/gamemode/libraries/thirdparty", true, true)
lia.util.includeDir = lia.includeDir
--- Dynamically loads Lua files for entities, weapons, and effects into the server, client, or shared realm of a Garry's Mod Lua project.
-- This function iterates through a specified directory and its subdirectories, including Lua files for entities, weapons, and effects into the appropriate realm.
-- This function also has a legacy alias lia.util.loadEntities that can be used instead of lia.includeEntities.
-- @string path The directory containing the Lua files to be included.
-- @realm shared
function lia.includeEntities(path)
    local files, folders
    local function IncludeFiles(path2, clientOnly)
        if (SERVER and file.Exists(path2 .. "init.lua", "LUA")) or (CLIENT and file.Exists(path2 .. "cl_init.lua", "LUA")) then
            lia.include(path2 .. "init.lua", clientOnly and "client" or "server")
            if file.Exists(path2 .. "cl_init.lua", "LUA") then lia.include(path2 .. "cl_init.lua", "client") end
            return true
        elseif file.Exists(path2 .. "shared.lua", "LUA") then
            lia.include(path2 .. "shared.lua", "shared")
            return true
        end
        return false
    end

    local function HandleEntityInclusion(folder, variable, register, default, clientOnly)
        files, folders = file.Find(path .. "/" .. folder .. "/*", "LUA")
        default = default or {}
        for _, v in ipairs(folders) do
            local path2 = path .. "/" .. folder .. "/" .. v .. "/"
            _G[variable] = table.Copy(default)
            _G[variable].ClassName = v
            if IncludeFiles(path2, clientOnly) then
                if clientOnly then
                    if CLIENT then register(_G[variable], v) end
                else
                    register(_G[variable], v)
                end
            end

            _G[variable] = nil
        end

        for _, v in ipairs(files) do
            local niceName = string.StripExtension(v)
            _G[variable] = table.Copy(default)
            _G[variable].ClassName = niceName
            lia.include(path .. "/" .. folder .. "/" .. v, clientOnly and "client" or "shared")
            if clientOnly then
                if CLIENT then register(_G[variable], niceName) end
            else
                register(_G[variable], niceName)
            end

            _G[variable] = nil
        end
    end

    HandleEntityInclusion("entities", "ENT", scripted_ents.Register, {
        Type = "anim",
        Base = "base_gmodentity",
        Spawnable = true
    })

    HandleEntityInclusion("weapons", "SWEP", weapons.Register, {
        Primary = {},
        Secondary = {},
        Base = "weapon_base"
    })

    HandleEntityInclusion("effects", "EFFECT", effects and effects.Register, nil, true)
end

lia.util.loadEntities = lia.includeEntities
lia.includeEntities("lilia/gamemode/objects/entities")
for _, filepath in ipairs(lia.FilesToLoad) do
    if filepath.realm == "server" then
        lia.include(filepath.path, "server")
    elseif filepath.realm == "client" then
        lia.include(filepath.path, "client")
    elseif filepath.realm == "shared" then
        lia.include(filepath.path, "shared")
    end
end
