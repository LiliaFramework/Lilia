--[[
# Loader Library

This page documents the functions for loading and managing Lilia framework components.

---

## Overview

The loader library is responsible for loading and initializing all core components of the Lilia framework. It manages the loading order of libraries, modules, and other framework components, ensuring proper initialization and dependency resolution. The library handles both client and server-side loading with appropriate realm management.
]]
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
        path = "lilia/gamemode/core/libraries/networking.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/admin.lua",
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
        path = "lilia/gamemode/core/libraries/performance.lua",
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
        realm = "server"
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
        path = "lilia/gamemode/core/libraries/webimage.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/websound.lua",
        realm = "client"
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
        path = "lilia/gamemode/core/libraries/thirdperson.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/currency.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/vendor.lua",
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
        path = "lilia/gamemode/core/meta/panel.lua",
        realm = "client"
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
    }
}

local ConditionalFiles = {
    {
        path = "lilia/gamemode/core/libraries/compatibility/vcmod.lua",
        global = "VCMod",
        name = "VCMod",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/vjbase.lua",
        global = "VJ",
        name = "VJ",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/advdupe.lua",
        global = "AdvDupe",
        name = "AdvDupe",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/advdupe2.lua",
        global = "AdvDupe2",
        name = "AdvDupe2",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/pac.lua",
        global = "pac",
        name = "PAC",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/prone.lua",
        global = "prone",
        name = "Prone",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/cami.lua",
        global = "CAMI",
        name = "CAMI",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/ulx.lua",
        global = "ulx",
        name = "ULX",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/serverguard.lua",
        global = "serverguard",
        name = "ServerGuard",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/sam.lua",
        global = "sam",
        name = "SAM | Admin Mod",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/simfphys.lua",
        global = "simfphys",
        name = "Simfphys Vehicles",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/sitanywhere.lua",
        global = "SitAnywhere",
        name = "Sit Anywhere",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/permaprops.lua",
        global = "PermaProps",
        name = "PermaProps",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/lvs.lua",
        global = "LVS",
        name = "LVS",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/arccw.lua",
        global = "ArcCW",
        name = "ArcCW",
        realm = "server"
    }
}

--[[
    lia.include

    Purpose:
        Includes a Lua file into the gamemode, handling the correct realm (server, client, or shared).
        On the server, it will AddCSLuaFile for client files, and include server/shared files as appropriate.
        On the client, it will include the file directly.

    Parameters:
        path (string) - The path to the Lua file to include.
        realm (string, optional) - The realm to include the file in ("server", "client", or "shared").
                                   If not provided, the realm is inferred from the filename or defaults to "shared".

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Include a shared library
        lia.include("lilia/gamemode/core/libraries/util.lua", "shared")

        -- Include a client-only file
        lia.include("lilia/gamemode/core/libraries/keybind.lua", "client")
]]
function lia.include(path, realm)
    if not path then error("[Lilia] " .. L("missingFilePath")) end
    local resolved = realm or RealmIDs[path:match("/([^/]+)%.lua$")] or path:find("sv_") and "server" or path:find("sh_") and "shared" or path:find("cl_") and "client" or "shared"
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
    lia.includeDir

    Purpose:
        Includes all Lua files in a specified directory, optionally recursively including subdirectories.
        Handles realm and schema folder resolution.

    Parameters:
        dir (string) - The directory to include files from.
        raw (boolean, optional) - If true, uses the directory as-is. If false, prepends the schema or gamemode path.
        deep (boolean, optional) - If true, recursively includes subdirectories.
        realm (string, optional) - The realm to include files in ("server", "client", or "shared").

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Include all files in a directory, recursively, as shared
        lia.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)

        -- Include all client derma files
        lia.includeDir("lilia/gamemode/core/derma", true, true, "client")
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
    lia.includeGroupedDir

    Purpose:
        Includes all Lua files in a directory and its subdirectories, grouping by folder.
        Determines the realm for each file based on its prefix or a forced realm.

    Parameters:
        dir (string) - The directory to include files from.
        raw (boolean, optional) - If true, uses the directory as-is. If false, prepends the schema or gamemode path.
        recursive (boolean, optional) - If true, recursively includes subdirectories.
        forceRealm (string, optional) - If provided, forces all files to be included in this realm.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Include all grouped files in a directory recursively
        lia.includeGroupedDir("lilia/gamemode/core/hooks", true, true)

        -- Include all files in a directory as client
        lia.includeGroupedDir("lilia/gamemode/core/derma", true, false, "client")
]]
function lia.includeGroupedDir(dir, raw, recursive, forceRealm)
    local baseDir = raw and dir or (SCHEMA and SCHEMA.folder and SCHEMA.loading and SCHEMA.folder .. "/schema" or "lilia/gamemode") .. "/" .. dir
    local stack = {baseDir}
    while #stack > 0 do
        local path = table.remove(stack)
        local files, folders = file.Find(path .. "/*.lua", "LUA")
        table.sort(files)
        for _, fileName in ipairs(files) do
            local realm = forceRealm
            if not realm then
                local prefix = fileName:sub(1, 3)
                realm = (prefix == "sh_" or fileName == "shared.lua") and "shared" or (prefix == "sv_" or fileName == "server.lua") and "server" or (prefix == "cl_" or fileName == "client.lua") and "client" or "shared"
            end

            local filePath = path .. "/" .. fileName
            if file.Exists(filePath, "LUA") then lia.include(filePath, realm) end
        end

        if recursive then
            for _, subfolder in ipairs(folders) do
                table.insert(stack, path .. "/" .. subfolder)
            end
        end
    end
end

lia.include("lilia/gamemode/core/libraries/languages.lua", "shared")
lia.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)
lia.includeDir("lilia/gamemode/core/derma", true, true, "client")
lia.include("lilia/gamemode/core/libraries/database.lua", "server")
lia.include("lilia/gamemode/core/libraries/config.lua", "shared")
lia.include("lilia/gamemode/core/libraries/data.lua", "server")
--[[
    lia.error

    Purpose:
        Prints an error message to the console with a Lilia-specific prefix and color formatting.

    Parameters:
        msg (string) - The error message to display.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Print an error message
        lia.error("Failed to load configuration file!")
]]
function lia.error(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Error] ")
    MsgC(Color(255, 0, 0), tostring(msg), "\n")
end

--[[
    lia.deprecated

    Purpose:
        Prints a deprecation warning for a method, optionally calling a callback function.
        The warning is colorized and uses the L function for localization.

    Parameters:
        methodName (string) - The name of the deprecated method.
        callback (function, optional) - A function to call after printing the warning.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Warn that a method is deprecated
        lia.deprecated("lia.oldFunction", function()
            print("This function is deprecated, please use lia.newFunction instead.")
        end)
]]
function lia.deprecated(methodName, callback)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Deprecated] ")
    MsgC(Color(255, 255, 0), L("deprecatedMessage", methodName), "\n")
    if callback and isfunction(callback) then callback() end
end

--[[
    lia.updater

    Purpose:
        Prints an updater message to the console with a Lilia-specific prefix and color formatting.

    Parameters:
        msg (string) - The updater message to display.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Print an updater message
        lia.updater("Schema update available! Please update to the latest version.")
]]
function lia.updater(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Updater] ")
    MsgC(Color(0, 255, 255), tostring(msg), "\n")
end

--[[
    lia.information

    Purpose:
        Prints an informational message to the console with a Lilia-specific prefix and color formatting.

    Parameters:
        msg (string) - The information message to display.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Print an informational message
        lia.information("Server started successfully.")
]]
function lia.information(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Information] ")
    MsgC(Color(83, 143, 239), tostring(msg), "\n")
end

--[[
    lia.admin

    Purpose:
        Prints an admin message to the console with a Lilia-specific prefix and color formatting.

    Parameters:
        msg (string) - The admin message to display.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Print an admin message
        lia.admin("Player JohnDoe has been promoted to admin.")
]]
function lia.admin(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Admin] ")
    MsgC(Color(255, 153, 0), tostring(msg), "\n")
end

--[[
    lia.bootstrap

    Purpose:
        Prints a bootstrap message to the console, indicating a section and message, with color formatting.

    Parameters:
        section (string) - The section name (e.g., "Database", "Compatibility").
        msg (string) - The message to display.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Print a bootstrap message for the database section
        lia.bootstrap("Database", "Database connection established successfully.")
]]
function lia.bootstrap(section, msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[Bootstrap] ")
    MsgC(Color(0, 255, 0), "[" .. section .. "] ")
    MsgC(Color(255, 255, 255), tostring(msg), "\n")
end

--[[
    lia.notifyAdmin

    Purpose:
        Sends a notification to all players with the privilege to see admin notifications.
        Only valid players with the appropriate privilege will receive the notification.

    Parameters:
        notification (string) - The notification message to send.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        -- Notify all admins about a suspicious player
        lia.notifyAdmin("Player JohnDoe is suspected of cheating.")
]]
function lia.notifyAdmin(notification)
    for _, client in player.Iterator() do
        if IsValid(client) and client:hasPrivilege(L("canSeeAltingNotifications")) then client:notify(notification) end
    end
end

--[[
    lia.printLog

    Purpose:
        Prints a log message to the console with a category and color formatting.

    Parameters:
        category (string) - The log category (e.g., "Database", "Admin").
        logString (string) - The log message to display.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Print a log message for the "Admin" category
        lia.printLog("Admin", "Player JohnDoe has been banned for cheating.")
]]
function lia.printLog(category, logString)
    MsgC(Color(83, 143, 239), "[LOG] ")
    MsgC(Color(0, 255, 0), "[" .. tostring(category) .. "] ")
    MsgC(Color(255, 255, 255), tostring(logString) .. "\n")
end

--[[
    lia.applyPunishment

    Purpose:
        Applies a punishment to a client for a given infraction, optionally kicking or banning them.
        Uses the administrator command system to execute the punishment.

    Parameters:
        client (Player) - The player to punish.
        infraction (string) - The reason for the punishment.
        kick (boolean) - Whether to kick the player.
        ban (boolean) - Whether to ban the player.
        time (number, optional) - The ban duration in minutes (0 for permanent).
        kickKey (string, optional) - Localization key for the kick message.
        banKey (string, optional) - Localization key for the ban message.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        -- Kick a player for spamming
        lia.applyPunishment(player.GetByID(1), "spamming", true, false)

        -- Ban a player for cheating for 60 minutes
        lia.applyPunishment(player.GetByID(2), "cheating", false, true, 60)
]]
function lia.applyPunishment(client, infraction, kick, ban, time, kickKey, banKey)
    local bantime = time or 0
    kickKey = kickKey or "kickedForInfraction"
    banKey = banKey or "bannedForInfraction"
    if kick then lia.administrator.execCommand("kick", client, nil, L(kickKey, infraction)) end
    if ban then lia.administrator.execCommand("ban", client, bantime, L(banKey, infraction)) end
end

for _, files in ipairs(FilesToLoad) do
    lia.include(files.path, files.realm)
end

--[[
    lia.includeEntities

    Purpose:
        Loads and registers all entities, weapons, tools, and effects from a specified path.
        Handles both folder-based and file-based definitions, and supports custom creation and completion hooks.

    Parameters:
        path (string) - The base path to search for entity, weapon, tool, and effect definitions.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Include all entities from the default Lilia entities directory
        lia.includeEntities("lilia/gamemode/entities")

        -- Include all entities from the current schema's entities directory
        lia.includeEntities(engine.ActiveGamemode() .. "/gamemode/entities")
]]
function lia.includeEntities(path)
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
        local files, folders = file.Find(path .. "/" .. folder .. "/*", "LUA")
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

            IncludeFiles(path2)
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
    }, false)

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
    if engine.ActiveGamemode() == "lilia" then lia.error(L("noSchemaLoaded")) end
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
    lia.module.initialize()
    lia.config.load()
    lia.faction.formatModelData()
    if SERVER then
        lia.config.send()
    else
        lia.option.load()
        lia.keybind.load()
    end
end

local loadedCompatibility = {}
for _, file in ipairs(ConditionalFiles) do
    local shouldLoad = false
    if isfunction(file.condition) then
        local ok, result = pcall(file.condition)
        if ok then
            shouldLoad = result
        else
            lia.error(L("compatibilityConditionError", tostring(result)))
        end
    elseif file.global then
        shouldLoad = _G[file.global] ~= nil
    end

    if shouldLoad then
        lia.include(file.path, file.realm or "shared")
        loadedCompatibility[#loadedCompatibility + 1] = file.name
    end
end

if #loadedCompatibility > 0 then lia.bootstrap(L("compatibility"), #loadedCompatibility == 1 and L("compatibilityLoadedSingle", loadedCompatibility[1]) or L("compatibilityLoadedMultiple", table.concat(loadedCompatibility, ", "))) end
if game.IsDedicated() then concommand.Remove("gm_save") end