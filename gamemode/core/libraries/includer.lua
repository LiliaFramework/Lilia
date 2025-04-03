local RealmIdentifiers = {
    client = "client",
    server = "server",
    shared = "shared",
    config = "shared",
    module = "shared",
    schema = "shared",
    permissions = "shared",
    commands = "shared",
    pim = "shared",
}

local FilesToLoad = {
    {
        path = "lilia/gamemode/core/libraries/languages.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/fonts.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/keybind.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/option.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/util.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/notice.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/character.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/character.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/hooks/shared.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/hooks/client.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/hooks/server.lua",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/skin.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/color.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/logger.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/modularity.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/chatbox.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/commands.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/flags.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/inventory.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/inventory.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/gridinv.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/item.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/tool.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/item.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/networking.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/attributes.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/factions.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/classes.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/currency.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/time.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/vector.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/entity.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/player.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/darkrp.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/menu.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/bars.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/netcalls/client.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/netcalls/server.lua",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/easyicons.lua",
        realm = "client"
    },
}

local function stripRealmPrefix(name)
    local prefix = name:sub(1, 3)
    return (prefix == "sh_" or prefix == "sv_" or prefix == "cl_") and name:sub(4) or name
end

--[[
    Function: lia.include

    Description:
       Includes a Lua file based on its realm. It determines the realm from the file name or provided state,
       and handles server/client inclusion logic.

    Parameters:
       fileName (string) - The path to the Lua file.
       state (string) - The realm state ("server", "client", "shared", etc.).

    Returns:
       The result of the include, if applicable.

    Realm:
       Depends on the file realm.

    Example Usage:
       lia.include("lilia/gamemode/core/libraries/util.lua", "shared")
 ]]
function lia.include(fileName, state)
    if not fileName then error("[Lilia] No file name specified for inclusion.") end
    local matchResult = string.match(fileName, "/([^/]+)%.lua$")
    local fileRealm = matchResult and RealmIdentifiers[matchResult] or "NULL"
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
--[[
    Function: lia.includeDir

    Description:
       Includes all Lua files in a specified directory.
       If recursive is true, it recursively includes files from subdirectories.
       It determines the base directory based on the active schema or gamemode.

    Parameters:
       directory (string) - The directory path to include.
       fromLua (boolean) - Whether to use the raw Lua directory path.
       recursive (boolean) - Whether to include files recursively.
       realm (string) - The realm state to use ("client", "server", "shared").

    Returns:
       nil

    Realm:
       Depends on file inclusion.

    Example Usage:
       lia.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)
 ]]
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

            for _, v in ipairs(files) do
                local fullPath = folder .. "/" .. v
                lia.include(fullPath, realm)
            end

            for _, v in ipairs(folders) do
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

lia.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)
lia.util.includeDir = lia.includeDir
--[[
    Function: lia.includeEntities

    Description:
       Includes entity files from the specified directory.
       It checks for standard entity files ("init.lua", "shared.lua", "cl_init.lua"),
       handles the inclusion and registration of entities, weapons, tools, and effects,
       and supports recursive inclusion within entity folders.

    Parameters:
       path (string) - The directory path containing entity files.

    Returns:
       nil

    Realm:
       Client/Server (depending on the file names)

    Example Usage:
       lia.includeEntities("lilia/entities")
 ]]
function lia.includeEntities(path)
    local files, folders
    local function IncludeFiles(path2)
        if file.Exists(path2 .. "init.lua", "LUA") then lia.include(path2 .. "init.lua", "server") end
        if file.Exists(path2 .. "shared.lua", "LUA") then lia.include(path2 .. "shared.lua", "shared") end
        if file.Exists(path2 .. "cl_init.lua", "LUA") then lia.include(path2 .. "cl_init.lua", "client") end
    end

    local function HandleEntityInclusion(folder, variable, register, default, clientOnly, create, complete)
        files, folders = file.Find(path .. "/" .. folder .. "/*", "LUA")
        default = default or {}
        for _, v in ipairs(folders) do
            local path2 = path .. "/" .. folder .. "/" .. v .. "/"
            v = stripRealmPrefix(v)
            _G[variable] = table.Copy(default)
            if not isfunction(create) then
                _G[variable].ClassName = v
            else
                create(v)
            end

            IncludeFiles(path2, clientOnly)
            if clientOnly then
                if CLIENT then register(_G[variable], v) end
            else
                register(_G[variable], v)
            end

            if isfunction(complete) then complete(_G[variable]) end
            _G[variable] = nil
        end

        for _, v in ipairs(files) do
            local niceName = stripRealmPrefix(string.StripExtension(v))
            _G[variable] = table.Copy(default)
            if not isfunction(create) then
                _G[variable].ClassName = niceName
            else
                create(niceName)
            end

            lia.include(path .. "/" .. folder .. "/" .. v, clientOnly and "client" or "shared")
            if clientOnly then
                if CLIENT then register(_G[variable], niceName) end
            else
                register(_G[variable], niceName)
            end

            if isfunction(complete) then complete(_G[variable]) end
            _G[variable] = nil
        end
    end

    local function RegisterTool(tool, className)
        local gmodTool = weapons.GetStored("gmod_tool")
        if gmodTool then gmodTool.Tool[className] = tool end
    end

    HandleEntityInclusion("entities", "ENT", scripted_ents.Register, {
        Type = "anim",
        Base = "base_gmodentity",
        Spawnable = true
    }, false, nil, function(ent) if SERVER and ent.Holdable then lia.allowedHoldableClasses[ent.ClassName] = true end end)

    HandleEntityInclusion("weapons", "SWEP", weapons.Register, {
        Primary = {},
        Secondary = {},
        Base = "weapon_base"
    })

    HandleEntityInclusion("tools", "TOOL", RegisterTool, {}, false, function(className)
        TOOL = lia.meta.tool:Create()
        TOOL.Mode = className
        TOOL:CreateConVars()
    end)

    HandleEntityInclusion("effects", "EFFECT", effects and effects.Register, nil, true)
end

lia.util.loadEntities = lia.includeEntities
lia.includeEntities("lilia/gamemode/entities")
lia.includeEntities(engine.ActiveGamemode() .. "/gamemode/entities")
for _, files in ipairs(FilesToLoad) do
    lia.include(files.path, files.realm)
end