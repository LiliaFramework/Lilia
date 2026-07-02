--[[
    Folder: Developer - Libraries
    File: lia.loader.md
]]
--[[
    Loader

    Core loading and bootstrap helpers for Lilia files, directories, entities, updates, compatibility, and hot reload flow.
]]
--[[
    Overview:
        The loader library centralizes framework startup behavior under `lia.loader`. It includes Lua files in the correct realm, loads directories of Lua files, registers scripted entities, performs framework and module version checks, initializes modules during startup or reload, and loads compatibility libraries when supported addons are detected.
]]
--[[
    Hooks:
        DiscordRelaySend(table embed)

    Purpose:
        Runs before a Discord relay embed is dispatched through the configured webhook.

    Category:
        Loader

    Parameters:
        embed (table)
            The embed payload being prepared for relay.

    Realm:
        Shared
]]
--[[
    Hooks:
        DiscordRelayUnavailable()

    Purpose:
        Runs when the Discord relay cannot use the CHTTP send path and falls back to the HTTP send path.

    Category:
        Loader

    Realm:
        Shared
]]
--[[
    Hooks:
        DiscordRelayed(table embed)

    Purpose:
        Runs after the Discord relay request has been dispatched.

    Category:
        Loader

    Parameters:
        embed (table)
            The embed payload that was dispatched.

    Realm:
        Shared
]]
--[[
    Hooks:
        SetupDatabase()

    Purpose:
        Runs immediately before the server begins connecting to the configured database.

    Category:
        Loader

    Realm:
        Server
]]
--[[
    Hooks:
        DatabaseConnected()

    Purpose:
        Runs after the database connection succeeds and database tables are loaded.

    Category:
        Loader

    Realm:
        Server
]]
--[[
    Hooks:
        PersistenceSave(string old)

    Purpose:
        Runs before map cleanup when the `sbox_persist` console variable changes.

    Category:
        Loader

    Parameters:
        old (string)
            The previous persistence value being saved.

    Realm:
        Server
]]
--[[
    Hooks:
        PersistenceLoad(string new)

    Purpose:
        Runs after map cleanup when the `sbox_persist` console variable changes to a non-empty value.

    Category:
        Loader

    Parameters:
        new (string)
            The new persistence value being loaded.

    Realm:
        Server
]]
lia = lia or {
    util = {},
    gui = {},
    meta = {},
    loader = {}
}

lia.reloadInProgress = false
lia.isReloading = false
local FilesToLoad = {
    {
        path = "lilia/gamemode/core/libraries/keybind.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/playerinteract.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/dialog.lua",
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
        path = "lilia/gamemode/core/libraries/camera.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/view.lua",
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
        path = "lilia/gamemode/core/libraries/doors.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/time.lua",
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
        name = "PAC3",
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
        realm = "shared"
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
        global = "ArcCWInstalled",
        name = "ArcCW",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/wiremod.lua",
        global = "WireLib",
        name = "Wiremod",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/vmanip.lua",
        global = "VManip",
        name = "VManip",
        realm = "shared"
    },
}

--[[
    Purpose:
        Includes a Lua file in the requested realm and sends clientside files to clients when needed.

    Parameters:
        path (string)
            The Lua file path to include. Backslashes are normalized to forward slashes.
        realm (string|nil)
            Optional realm override. Valid values are `server`, `client`, and `shared`. When omitted, the realm is inferred from filename prefixes such as `sv_`, `cl_`, or `sh_`, or from `server`, `client`, and `shared` filenames.

    Example Usage:
        ```lua
        lia.loader.include("lilia/gamemode/core/libraries/config.lua", "shared")
        lia.loader.include("lilia/gamemode/core/hooks/server.lua")
        ```

    Realm:
        Shared
]]
function lia.loader.include(path, realm)
    if not path then lia.error(L("missingFilePath")) end
    path = path:gsub("\\", "/")
    local resolved = realm
    if not resolved then
        local filename = path:match("([^/\\]+)%.lua$")
        if filename then
            local prefix = filename:sub(1, 3)
            if prefix == "sv_" or filename == "server" then
                resolved = "server"
            elseif prefix == "cl_" or filename == "client" then
                resolved = "client"
            elseif prefix == "sh_" or filename == "shared" then
                resolved = "shared"
            end
        end

        resolved = resolved or "shared"
    end

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
    Purpose:
        Includes every Lua file in a directory, optionally recursing into subdirectories.

    Parameters:
        dir (string)
            The directory to load.
        raw (boolean|nil)
            When true, uses `dir` as a raw Lua path. When false or nil, resolves it relative to the active schema path while schema loading, or `lilia/gamemode` otherwise.
        deep (boolean|nil)
            When true, recursively loads Lua files in child folders.
        realm (string|nil)
            Optional realm override passed to `lia.loader.include` for every file.

    Example Usage:
        ```lua
        lia.loader.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)
        lia.loader.includeDir("lilia/gamemode/core/derma", true, true, "client")
        ```

    Realm:
        Shared
]]
function lia.loader.includeDir(dir, raw, deep, realm)
    local root = raw and dir or (SCHEMA and SCHEMA.folder and SCHEMA.loading and SCHEMA.folder .. "/schema" or "lilia/gamemode") .. "/" .. dir
    local function loadDir(folder)
        for _, fileName in ipairs(file.Find(folder .. "/*.lua", "LUA")) do
            lia.loader.include(folder .. "/" .. fileName, realm)
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
    Purpose:
        Includes Lua files from a directory in sorted order while resolving each file realm from filename prefixes unless a realm override is provided.

    Parameters:
        dir (string)
            The directory to load.
        raw (boolean|nil)
            When true, uses `dir` as a raw Lua path. When false or nil, resolves it relative to the active schema path while schema loading, or `lilia/gamemode` otherwise.
        recursive (boolean|nil)
            When true, walks child folders and loads matching Lua files from them as well.
        forceRealm (string|nil)
            Optional realm override for every included file. When omitted, files are resolved from `sh_`, `sv_`, `cl_`, `shared.lua`, `server.lua`, and `client.lua` names.

    Example Usage:
        ```lua
        lia.loader.includeGroupedDir("modules/example/libs", false, true)
        lia.loader.includeGroupedDir("lilia/gamemode/core/derma", true, true, "client")
        ```

    Realm:
        Shared
]]
function lia.loader.includeGroupedDir(dir, raw, recursive, forceRealm)
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
            if file.Exists(filePath, "LUA") then lia.loader.include(filePath, realm) end
        end

        if recursive then
            for _, subfolder in ipairs(folders) do
                table.insert(stack, path .. "/" .. subfolder)
            end
        end
    end
end

lia.loader.include("lilia/gamemode/core/libraries/languages.lua", "shared")
local hasChttp = util.IsBinaryModuleInstalled("chttp")
if hasChttp then require("chttp") end
local function fetchURL(url, onSuccess, onError)
    if hasChttp then
        CHTTP({
            url = url,
            method = "GET",
            success = function(code, body) onSuccess(body, code) end,
            failed = function(err) onError(err) end
        })
    else
        http.Fetch(url, function(body, _, _, code) onSuccess(body, code) end, function(err) onError(err) end)
    end
end

local function versionCompare(localVersion, remoteVersion)
    local function toParts(v)
        local parts = {}
        if not v then return parts end
        local str
        if type(v) == "number" then
            str = string.format("%.3f", v)
        else
            str = tostring(v)
        end

        for num in str:gmatch("%d+") do
            table.insert(parts, tonumber(num))
        end
        return parts
    end

    local lParts = toParts(localVersion)
    local rParts = toParts(remoteVersion)
    local len = math.max(#lParts, #rParts)
    for i = 1, len do
        local l = lParts[i] or 0
        local r = rParts[i] or 0
        if l < r then return -1 end
        if l > r then return 1 end
    end
    return 0
end

local publicURL = "https://liliaframework.github.io/versioning/modules.json"
local privateURL = "https://bleonheart.github.io/modules.json"
local versionURL = "https://liliaframework.github.io/versioning/lilia.json"
--[[
    Purpose:
        Checks public modules, private modules, and the framework version against remote version manifests, then logs any outdated or missing version data.

    Example Usage:
        ```lua
        lia.loader.checkForUpdates()
        ```

    Realm:
        Shared
]]
function lia.loader.checkForUpdates()
    local publicModules = {}
    local privateModules = {}
    for _, mod in pairs(lia.module.list) do
        if mod.versionID then
            if string.StartsWith(mod.versionID, "public_") then
                publicModules[#publicModules + 1] = mod
            elseif string.StartsWith(mod.versionID, "private_") then
                privateModules[#privateModules + 1] = mod
            end
        end
    end

    local function processModuleUpdates(modules, remoteData, isPrivate)
        for _, mod in ipairs(modules) do
            local match
            for _, m in ipairs(remoteData) do
                if m.versionID == mod.versionID then
                    match = m
                    break
                end
            end

            if not match then
                MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logUpdater") .. "] ")
                MsgC(Color(0, 255, 255), L("moduleUniqueIDNotFound", mod.versionID), "\n")
            elseif not match.version then
                MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logUpdater") .. "] ")
                MsgC(Color(0, 255, 255), L("moduleNoRemoteVersion", mod.name), "\n")
            elseif mod.version and versionCompare(mod.version, match.version) < 0 then
                MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logUpdater") .. "] ")
                if isPrivate then
                    MsgC(Color(0, 255, 255), L("privateModuleOutdated", mod.name), "\n")
                else
                    MsgC(Color(0, 255, 255), L("moduleOutdated", mod.name, match.version), "\n")
                end
            end
        end
    end

    local function logError(message)
        MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logUpdater") .. "] ")
        MsgC(Color(0, 255, 255), message, "\n")
    end

    if #publicModules then
        fetchURL(publicURL, function(body, code)
            if code ~= 200 then
                logError(L("moduleListHTTPError", code))
                return
            end

            local remote = util.JSONToTable(body)
            if not remote then
                logError(L("moduleDataParseError"))
                return
            end

            processModuleUpdates(publicModules, remote, false)
        end, function(err) logError(L("moduleListError", err)) end)
    end

    if #privateModules then
        fetchURL(privateURL, function(body, code)
            if code ~= 200 then
                logError(L("privateModuleListHTTPError", code))
                return
            end

            local remote = util.JSONToTable(body)
            if not remote then
                logError(L("privateModuleDataParseError"))
                return
            end

            processModuleUpdates(privateModules, remote, true)
        end, function(err) logError(L("privateModuleListError", err)) end)
    end

    fetchURL(versionURL, function(body, code)
        if code ~= 200 then
            logError(L("frameworkVersionHTTPError", code))
            return
        end

        local remote = util.JSONToTable(body)
        if not remote or not remote.version then
            logError(L("frameworkVersionDataParseError"))
            return
        end

        local localVersion = GAMEMODE.version
        if not localVersion then
            logError(L("localFrameworkVersionError"))
            return
        end

        if versionCompare(localVersion, remote.version) < 0 then
            local localNum, remoteNum = tonumber(localVersion), tonumber(remote.version)
            if localNum and remoteNum then
                local diff = remoteNum - localNum
                diff = math.Round(diff, 3)
                if diff > 0 then
                    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logUpdater") .. "] ")
                    MsgC(Color(0, 255, 255), L("frameworkBehindCount", diff), "\n")
                end
            end

            MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logUpdater") .. "] ")
            MsgC(Color(0, 255, 255), L("frameworkOutdated"), "\n")
        end
    end, function(err) logError(L("frameworkVersionError", err)) end)
end

lia.loader.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)
lia.loader.include("lilia/gamemode/core/libraries/net.lua", "shared")
lia.loader.include("lilia/gamemode/core/libraries/config.lua", "shared")
lia.loader.include("lilia/gamemode/core/libraries/color.lua", "shared")
lia.loader.include("lilia/gamemode/core/libraries/derma.lua", "client")
lia.loader.includeDir("lilia/gamemode/core/derma", true, true, "client")
lia.loader.include("lilia/gamemode/core/libraries/database.lua", "server")
lia.loader.include("lilia/gamemode/core/libraries/data.lua", "shared")
function lia.error(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logError") .. "] ")
    MsgC(Color(255, 0, 0), tostring(msg), "\n")
end

function lia.warning(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("warning") .. "] ")
    MsgC(Color(255, 255, 0), tostring(msg), "\n")
end

function lia.information(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("information") .. "] ")
    MsgC(Color(83, 143, 239), tostring(msg), "\n")
end

function lia.bootstrap(section, msg)
    if lia.isReloading and section ~= "HotReload" then return end
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logBootstrap") .. "] ")
    MsgC(Color(0, 255, 0), "[" .. section .. "] ")
    MsgC(Color(255, 255, 255), tostring(msg), "\n")
end

function lia.debug(...)
    if not lia.DevMode then return end
    local args = {...}
    local prefixColor = Color(83, 143, 239)
    local debugColor = Color(255, 184, 77)
    local sectionColor = Color(0, 255, 0)
    local textColor = Color(220, 220, 220)
    local detailColor = Color(151, 211, 255)
    local separatorColor = Color(120, 120, 120)
    local boolColors = {
        ["true"] = Color(110, 255, 140),
        ["false"] = Color(255, 120, 120)
    }

    local function writeValue(value)
        local text = tostring(value)
        MsgC(boolColors[text] or textColor, text)
    end

    local function isKeyToken(value)
        local text = tostring(value)
        return text:sub(-1) == "=" and #text > 1
    end

    MsgC(prefixColor, "[Lilia] ", debugColor, "[" .. L("logDebug") .. "] ")
    local index = 1
    if isstring(args[1]) and args[1]:match("^%b[]$") then
        MsgC(sectionColor, args[1], " ")
        index = 2
    end

    if args[index] ~= nil then
        writeValue(args[index])
        index = index + 1
    end

    while index <= #args do
        MsgC(separatorColor, " | ")
        if args[index + 1] ~= nil and isKeyToken(args[index]) then
            MsgC(detailColor, tostring(args[index]))
            writeValue(args[index + 1])
            index = index + 2
        else
            writeValue(args[index])
            index = index + 1
        end
    end

    MsgC(textColor, "\n")
end

function lia.relaydiscordMessage(embed)
    if not lia.discordWebhook or not istable(embed) then return end
    local ForceHTTPMode = not util.IsBinaryModuleInstalled("chttp")
    embed.title = embed.title or L("Lilia")
    embed.color = tonumber(embed.color) or 7506394
    embed.timestamp = embed.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")
    embed.footer = embed.footer or {
        text = L("discordRelayLiliaDiscordRelay")
    }

    local payload = {
        embeds = {embed},
        username = L("discordRelayLiliaLogger")
    }

    hook.Run("DiscordRelaySend", embed)
    if util.IsBinaryModuleInstalled("chttp") and not ForceHTTPMode then
        require("chttp")
        CHTTP({
            url = lia.discordWebhook,
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json"
            },
            body = util.TableToJSON(payload)
        })
    else
        if not ForceHTTPMode then hook.Run("DiscordRelayUnavailable") end
        http.Post(lia.discordWebhook, {
            payload_json = util.TableToJSON(payload)
        }, function() end, function(err) lia.error("Discord relay HTTP failed: " .. tostring(err)) end)
    end

    hook.Run("DiscordRelayed", embed)
end

for _, files in ipairs(FilesToLoad) do
    lia.loader.include(files.path, files.realm)
end

--[[
    Purpose:
        Loads and registers scripted entities, weapons, and effects from a base path.

    Parameters:
        path (string)
            The base path containing `entities`, `weapons`, and `effects` folders.

    Example Usage:
        ```lua
        lia.loader.includeEntities("lilia/gamemode")
        lia.loader.includeEntities(SCHEMA.folder .. "/schema")
        ```

    Realm:
        Shared
]]
function lia.loader.includeEntities(path)
    local function IncludeFiles(path2)
        if file.Exists(path2 .. "init.lua", "LUA") then lia.loader.include(path2 .. "init.lua", "server") end
        if file.Exists(path2 .. "shared.lua", "LUA") then lia.loader.include(path2 .. "shared.lua", "shared") end
        if file.Exists(path2 .. "cl_init.lua", "LUA") then lia.loader.include(path2 .. "cl_init.lua", "client") end
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
            local hasInit = file.Exists(path2 .. "init.lua", "LUA")
            local hasShared = file.Exists(path2 .. "shared.lua", "LUA")
            local hasClientInit = file.Exists(path2 .. "cl_init.lua", "LUA")
            if v ~= "gmod_tool" and not hasInit and not hasShared and not hasClientInit then
                local childFiles, childFolders = file.Find(path2 .. "*", "LUA")
                if #childFiles == 0 and #childFolders == 0 then continue end
                lia.error("Warning: No init.lua, shared.lua, or cl_init.lua found in entity folder: " .. path2 .. ". This may make the entity not load properly.")
                continue
            end

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

            lia.loader.include(path .. "/" .. folder .. "/" .. v, clientOnly and "client" or "shared")
            if clientOnly then
                if CLIENT then register(_G[variable], niceName) end
            else
                register(_G[variable], niceName)
            end

            if isfunction(complete) then complete(_G[variable]) end
            _G[variable] = nil
        end
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

    HandleEntityInclusion("effects", "EFFECT", effects and effects.Register, nil, true)
end

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
--[[
    Purpose:
        Initializes or hot-reloads the gamemode by loading modules, formatting faction model data, refreshing reload-sensitive state, and synchronizing changed server data after reloads.

    Parameters:
        isReload (boolean|nil)
            True when initialization is being performed during a hot reload. False or nil during normal startup.

    Example Usage:
        ```lua
        lia.loader.initializeGamemode(false)
        lia.loader.initializeGamemode(true)
        ```

    Realm:
        Shared
]]
function lia.loader.initializeGamemode(isReload)
    if isReload then
        if lia.reloadInProgress then return end
        timer.Remove("liaReloadConfigSync")
        timer.Remove("liaReloadAdminSync")
        timer.Remove("liaReloadPlayerInteractSync")
        timer.Remove("liaReloadComplete")
        lia.net.buffers = {}
        lia.net.sendq = {}
        lia.net.cache = {}
        lia.reloadInProgress = true
        lia.isReloading = true
    end

    if isReload or not hasInitializedModules then
        lia.module.initialize()
        if not isReload then hasInitializedModules = true end
    end

    lia.faction.formatModelData()
    if SERVER and isReload then
        lia.config.load()
        local adminHasChanges = lia.admin.hasChanges()
        local playerInteractHasChanges = lia.playerinteract.hasChanges()
        timer.Create("liaReloadConfigSync", 0.5, 1, function()
            for _, client in player.Iterator() do
                if IsValid(client) then lia.config.send(client) end
            end
        end)

        timer.Create("liaReloadAdminSync", 2.0, 1, function() if adminHasChanges then lia.admin.sync() end end)
        timer.Create("liaReloadPlayerInteractSync", 3.5, 1, function() if playerInteractHasChanges then lia.playerinteract.sync() end end)
        timer.Create("liaReloadComplete", 5.0, 1, function()
            lia.reloadInProgress = false
            timer.Simple(1.0, function() collectgarbage("collect") end)
        end)
    end

    if isReload then
        lia.bootstrap("HotReload", L("gamemodeHotreloadedSuccessfully"))
        lia.isReloading = false
    end
end

local function CreateCharacterSaveTimer()
    local saveInterval = lia.config.get("CharacterDataSaveInterval")
    local saveTimer = function()
        for _, client in player.Iterator() do
            if IsValid(client) and client:getChar() then client:getChar():save() end
        end
    end

    if timer.Exists("liaSaveCharGlobal") then
        timer.Adjust("liaSaveCharGlobal", saveInterval, 0, saveTimer)
    else
        timer.Create("liaSaveCharGlobal", saveInterval, 0, saveTimer)
    end
end

function GM:Initialize()
    if engine.ActiveGamemode() == "lilia" then lia.error(L("noSchemaLoaded")) end
    lia.loader.initializeGamemode(false)
    if SERVER then CreateCharacterSaveTimer() end
end

function GM:OnReloaded()
    lia.loader.initializeGamemode(true)
    if SERVER then CreateCharacterSaveTimer() end
end

local loadedCompatibility = {}
for _, compatFile in ipairs(ConditionalFiles) do
    local shouldLoad = false
    if isfunction(compatFile.condition) then
        local ok, result = pcall(compatFile.condition)
        if ok then
            shouldLoad = result
        else
            lia.error(L("compatibilityConditionError", tostring(result)))
        end
    elseif compatFile.global then
        shouldLoad = _G[compatFile.global] ~= nil
    end

    if shouldLoad then
        lia.loader.include(compatFile.path, compatFile.realm or "shared")
        loadedCompatibility[#loadedCompatibility + 1] = compatFile.name
    end
end

if #loadedCompatibility > 0 then lia.bootstrap(L("compatibility"), L("compatibilityLoadedSingle", table.concat(loadedCompatibility, ", "))) end
if game.IsDedicated() then concommand.Remove("gm_save") end
