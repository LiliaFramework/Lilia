lia = lia or {
    util = {},
    gui = {},
    meta = {},
    notices = {}
}

local RealmIDs = {
    client = "client",
    server = "server",
    shared = "shared",
    config = "shared",
    module = "shared",
    schema = "shared",
    permissions = "shared",
    commands = "shared",
    pim = "shared"
}

local FilesToLoad = {
    {
        path = "lilia/gamemode/core/libraries/languages.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/workshop.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/fonts.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/keybind.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/option.lua",
        realm = "shared"
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
        path = "lilia/gamemode/core/libraries/salary.lua",
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
}

local ConditionalFiles = {
    {
        path = "lilia/gamemode/core/libraries/pac.lua",
        global = "pac"
    },
    {
        path = "lilia/gamemode/core/libraries/simfphys.lua",
        global = "simfphys"
    },
    {
        path = "lilia/gamemode/core/libraries/sitanywhere.lua",
        global = "SitAnywhere"
    },
    {
        path = "lilia/gamemode/core/libraries/vcmod.lua",
        global = "VCMod"
    },
    {
        path = "lilia/gamemode/core/libraries/vjbase.lua",
        global = "VJ"
    },
    {
        path = "lilia/gamemode/core/libraries/prone.lua",
        global = "prone"
    },
    {
        path = "lilia/gamemode/core/libraries/sam.lua",
        global = "sam"
    },
    {
        path = "lilia/gamemode/core/libraries/ulx.lua",
        global = "ulx"
    },
    {
        path = "lilia/gamemode/core/libraries/serverguard.lua",
        global = "serverguard"
    }
}

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
function lia.include(path, realm)
    if not path then error("[Lilia] missing file path") end
    local base = path:match("/([^/]+)%.lua$")
    local resolved = realm or RealmIDs[base] or path:find("sv_") and "server" or path:find("sh_") and "shared" or path:find("cl_") and "client" or "shared"
    if resolved == "server" then
        if SERVER then include(path) end
    elseif resolved == "client" then
        if SERVER then
            AddCSLuaFile(path)
        else
            include(path)
        end
    else
        if SERVER then AddCSLuaFile(path) end
        include(path)
    end
end

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
       lia.includeDir("lilia/gamemode/core/libraries/shared/thirdparty", true, true)
 ]]
function lia.includeDir(dir, raw, deep, realm)
    local root = raw and dir or (SCHEMA and SCHEMA.folder and SCHEMA.loading and SCHEMA.folder .. "/schema" or "lilia/gamemode") .. "/" .. dir
    local function loadDir(folder)
        for _, fileName in ipairs(file.Find(folder .. "/*.lua", "LUA")) do
            lia.include(folder .. "/" .. fileName, realm)
        end

        if deep then
            for _, subFolder in ipairs(select(2, file.Find(folder .. "/*", "LUA"))) do
                loadDir(folder .. "/" .. subFolder)
            end
        end
    end

    loadDir(root)
end

--[[
    Function: lia.includeGroupedDir

    Description:
       Recursively includes all Lua files in a specified directory.
       Files are grouped by their base name (the part after the realm prefix)
       and for each group loaded in this order:
         1) shared (sh_*)
         2) server (sv_*)
         3) client (cl_*)
       After all file groups are processed, subdirectories are traversed (if recursive).

    Parameters:
       directory (string) — Directory path to include, relative to the gamemode or schema.
       raw (boolean)     — If true, use `directory` as a raw path; otherwise prepend the active schema or gamemode base path.
       recursive (boolean) — If true, recurse into subdirectories after loading files.
       realm (string)    — Optional realm override passed through to `lia.include` for each file.

    Returns:
       nil

    Example Usage:
       lia.includeGroupedDir("lilia/gamemode/core/libraries/thirdparty", true, true, "shared")
]]
function lia.includeGroupedDir(dir, raw, recursive, realm)
    local base = raw and dir or (SCHEMA and SCHEMA.folder and SCHEMA.loading and SCHEMA.folder .. "/schema" or "lilia/gamemode") .. "/" .. dir
    local function loadDir(folder)
        local files, folders = file.Find(folder .. "/*.lua", "LUA")
        local groups, order = {}, {}
        for _, fname in ipairs(files) do
            local prefix, name = fname:match("^(sh|sv|cl)_(.+)%.lua$")
            if prefix then
                if not groups[name] then
                    groups[name] = {}
                    table.insert(order, name)
                end

                groups[name][prefix] = fname
            end
        end

        for _, name in ipairs(order) do
            local g = groups[name]
            if g.sh then lia.include(folder .. "/" .. g.sh, realm) end
            if g.sv then lia.include(folder .. "/" .. g.sv, realm) end
            if g.cl then lia.include(folder .. "/" .. g.cl, realm) end
        end

        if recursive then
            table.sort(folders)
            for _, sub in ipairs(folders) do
                loadDir(folder .. "/" .. sub)
            end
        end
    end

    loadDir(base)
end

lia.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)
lia.includeDir("lilia/gamemode/core/derma", true, true, "client")
lia.include("lilia/gamemode/core/libraries/database.lua", "server")
lia.include("lilia/gamemode/core/libraries/config.lua", "shared")
lia.include("lilia/gamemode/core/libraries/data.lua", "shared")
function lia.error(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Error] ")
    MsgC(Color(255, 0, 0), msg, "\n")
end

function lia.deprecated(methodName, callback)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Deprecated] ")
    MsgC(Color(255, 255, 0), string.format("%s is deprecated. Please use the new methods for optimization purposes.", methodName), "\n")
    if callback and isfunction(callback) then callback() end
end

function lia.updater(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Updater] ")
    MsgC(Color(0, 255, 255), msg, "\n")
end

function lia.information(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Information] ")
    MsgC(Color(83, 143, 239), msg, "\n")
end

function lia.bootstrap(section, msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Bootstrap] ")
    MsgC(Color(0, 255, 0), "[" .. section .. "] ")
    MsgC(Color(255, 255, 255), msg, "\n")
end

for _, files in ipairs(FilesToLoad) do
    lia.include(files.path, files.realm)
end

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

    local function stripRealmPrefix(name)
        local prefix = name:sub(1, 3)
        return (prefix == "sh_" or prefix == "sv_" or prefix == "cl_") and name:sub(4) or name
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
    }, false, nil)

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

lia.includeEntities("lilia/gamemode/entities")
lia.includeEntities(engine.ActiveGamemode() .. "/gamemode/entities")
if SERVER then
    local function SetupDatabase()
        hook.Run("SetupDatabase")
        lia.db.connect(function()
            lia.db.loadTables()
            lia.log.loadTables()
            hook.Run("DatabaseConnected")
        end)
    end

    local function SetupPersistence()
        cvars.AddChangeCallback("sbox_persist", function(_, old, new)
            timer.Create("sbox_persist_change_timer", 1, 1, function()
                hook.Run("PersistenceSave", old)
                game.CleanUpMap(false, nil, function() end)
                if new ~= "" then hook.Run("PersistenceLoad", new) end
            end)
        end, "sbox_persist_load")
    end

    local function BootstrapLilia()
        timer.Simple(0, SetupDatabase)
        SetupPersistence()
    end

    BootstrapLilia()
else
    local oldLocalPlayer = LocalPlayer
    function LocalPlayer()
        lia.localClient = IsValid(lia.localClient) and lia.localClient or oldLocalPlayer()
        return lia.localClient
    end

    timer.Remove("HintSystem_OpeningMenu")
    timer.Remove("HintSystem_Annoy1")
    timer.Remove("HintSystem_Annoy2")
end

local hasInitializedModules = false
function GM:Initialize()
    if engine.ActiveGamemode() == "lilia" then lia.error("No schema loaded. Please place the schema in your gamemodes folder, then set it as your gamemode.") end
    lia.config.load()
    if not hasInitializedModules then
        lia.module.initialize()
        hasInitializedModules = true
    end

    if CLIENT then
        lia.option.load()
        lia.keybind.load()
    end
end

function GM:OnReloaded()
    lia.config.load()
    lia.module.refreshChanged()
    lia.faction.formatModelData()
    if CLIENT then
        lia.option.load()
        lia.keybind.load()
    end
end

for _, data in ipairs(ConditionalFiles) do
    if _G[data.global] then
        local name = data.global:sub(1, 1):upper() .. data.global:sub(2)
        lia.bootstrap("Compatibility", "Compatibility system for " .. name .. " initialized.")
        lia.include(data.path, "shared")
    end
end

if game.IsDedicated() then concommand.Remove("gm_save") end