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
        path = "lilia/gamemode/core/libraries/core/keybind.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/playerinteract.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/sit.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/dialog.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/admin.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/workshop.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/fonts.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/option.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/util.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/notice.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/meta/character.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/character.lua",
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
        path = "lilia/gamemode/core/libraries/core/logger.lua",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/core/modularity.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/chatbox.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/commands.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/flags.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/inventory.lua",
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
        path = "lilia/gamemode/core/libraries/core/item.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/webcontent.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/core/attributes.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/factions.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/classes.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/camera.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/core/view.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/core/currency.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/vendor.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/doors.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/time.lua",
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
        path = "lilia/gamemode/core/libraries/core/darkrp.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/core/menu.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/core/bars.lua",
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
        path = "lilia/gamemode/core/libraries/compatibility/vcmod/vcmod.lua",
        global = "VCMod",
        name = "VCMod",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/vjbase/vjbase.lua",
        global = "VJ",
        name = "VJ",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/advdupe/advdupe.lua",
        global = "AdvDupe",
        name = "AdvDupe",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/advdupe2/advdupe2.lua",
        global = "AdvDupe2",
        name = "AdvDupe2",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/mediaplayer/mediaplayer.lua",
        global = "MediaPlayer",
        name = "Media Player",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/pac/pac.lua",
        global = "pac",
        name = "PAC3",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/prone/prone.lua",
        global = "prone",
        name = "Prone",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/cami/cami.lua",
        global = "CAMI",
        name = "CAMI",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/ulx/ulx.lua",
        global = "ulx",
        name = "ULX",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/serverguard/serverguard.lua",
        global = "serverguard",
        name = "ServerGuard",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/sam/sam.lua",
        global = "sam",
        name = "SAM | Admin Mod",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/sadmin/sadmin.lua",
        condition = function() return SERVER and concommand.GetTable().sa ~= nil end,
        name = "SAdmin",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/simfphys/simfphys.lua",
        global = "simfphys",
        name = "Simfphys Vehicles",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/sitanywhere/sitanywhere.lua",
        global = "SitAnywhere",
        name = "Sit Anywhere",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/permaprops/permaprops.lua",
        global = "PermaProps",
        name = "PermaProps",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/lvs/lvs.lua",
        global = "LVS",
        name = "LVS",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/arccw/arccw.lua",
        global = "ArcCWInstalled",
        name = "ArcCW",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/wiremod/wiremod.lua",
        global = "WireLib",
        name = "Wiremod",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/compatibility/vmanip/vmanip.lua",
        global = "VManip",
        name = "VManip",
        realm = "shared"
    },
}

function lia.loader.include(path, realm)
    if not path then lia.error("Missing file path") end
    path = path:gsub("\\", "/")
    local libraryPrefix = "lilia/gamemode/core/libraries/"
    if path:sub(1, #libraryPrefix) == libraryPrefix then
        local libraryPath = path:sub(#libraryPrefix + 1)
        local libraryGroup = libraryPath:match("^([^/]+)/")
        if libraryGroup and libraryGroup ~= "core" and libraryGroup ~= "compatibility" and libraryGroup ~= "thirdparty" then path = libraryPrefix .. "core/" .. libraryPath end
    end

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

function lia.loader.includeLibraryItems(path)
    path = path:gsub("\\", "/")
    local libraryPath = path:match("^(.-)/core%.lua$")
    local itemsPath = libraryPath and libraryPath .. "/items"
    if itemsPath and file.IsDir(itemsPath, "LUA") then lia.item.loadFromDir(itemsPath) end
end

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

lia.loader.include("lilia/gamemode/core/libraries/core/languages.lua", "shared")
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
local privateURL = "https://bleonheart.github.io/.jsons/modules.json"
local versionURL = "https://liliaframework.github.io/versioning/lilia.json"
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
                MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Updater" .. "] ")
                MsgC(Color(0, 255, 255), string.format("Module with uniqueID '%s' not found", mod.versionID), "\n")
            elseif not match.version then
                MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Updater" .. "] ")
                MsgC(Color(0, 255, 255), string.format("Module '%s' has no remote version info", mod.name), "\n")
            elseif mod.version and versionCompare(mod.version, match.version) < 0 then
                MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Updater" .. "] ")
                if isPrivate then
                    MsgC(Color(0, 255, 255), string.format("Module '%s' is outdated, please report back to the author", mod.name), "\n")
                else
                    MsgC(Color(0, 255, 255), string.format("Module '%s' is outdated. Update to version %s", mod.name, match.version), "\n")
                end
            end
        end
    end

    local function logError(message)
        MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Updater" .. "] ")
        MsgC(Color(0, 255, 255), message, "\n")
    end

    if #publicModules then
        fetchURL(publicURL, function(body, code)
            if code ~= 200 then
                logError(string.format("Error fetching module list (HTTP %s) - which is the public repository", code))
                return
            end

            local remote = util.JSONToTable(body)
            if not remote then
                logError("Error parsing module data")
                return
            end

            processModuleUpdates(publicModules, remote, false)
        end, function(err) logError(string.format("Error fetching module list: %s", err)) end)
    end

    if #privateModules then
        fetchURL(privateURL, function(body, code)
            if code ~= 200 then
                logError(string.format("Error fetching module list (HTTP %s) - which is the private repository", code))
                return
            end

            local remote = util.JSONToTable(body)
            if not remote then
                logError("Error parsing private module data")
                return
            end

            processModuleUpdates(privateModules, remote, true)
        end, function(err) logError(string.format("Error fetching private module list: %s", err)) end)
    end

    fetchURL(versionURL, function(body, code)
        if code ~= 200 then
            logError(string.format("Error fetching framework version (HTTP %s)", code))
            return
        end

        local remote = util.JSONToTable(body)
        if not remote or not remote.version then
            logError("Error parsing framework version data")
            return
        end

        local localVersion = GAMEMODE.version
        if not localVersion then
            logError("Error reading local framework version")
            return
        end

        if versionCompare(localVersion, remote.version) < 0 then
            local localNum, remoteNum = tonumber(localVersion), tonumber(remote.version)
            if localNum and remoteNum then
                local diff = remoteNum - localNum
                diff = math.Round(diff, 3)
                if diff > 0 then
                    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Updater" .. "] ")
                    MsgC(Color(0, 255, 255), string.format("Your Lilia installation is %s versions behind.", diff), "\n")
                end
            end

            MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Updater" .. "] ")
            MsgC(Color(0, 255, 255), "Framework is outdated. Restart the Server to update it", "\n")
        end
    end, function(err) logError(string.format("Error fetching framework version: %s", err)) end)
end

lia.loader.includeDir("lilia/gamemode/core/libraries/thirdparty", true, true)
lia.loader.include("lilia/gamemode/core/libraries/core/net.lua", "shared")
lia.loader.include("lilia/gamemode/core/libraries/core/config.lua", "shared")
lia.loader.include("lilia/gamemode/core/libraries/core/color.lua", "shared")
lia.loader.include("lilia/gamemode/core/libraries/core/derma.lua", "client")
lia.loader.includeDir("lilia/gamemode/core/derma", true, true, "client")
lia.loader.include("lilia/gamemode/core/libraries/core/database.lua", "server")
lia.loader.include("lilia/gamemode/core/libraries/core/data.lua", "shared")
function lia.error(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Error" .. "] ")
    MsgC(Color(255, 0, 0), tostring(msg), "\n")
end

function lia.warning(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Warning" .. "] ")
    MsgC(Color(255, 255, 0), tostring(msg), "\n")
end

function lia.information(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Information" .. "] ")
    MsgC(Color(83, 143, 239), tostring(msg), "\n")
end

function lia.bootstrap(section, msg)
    if lia.isReloading and section ~= "HotReload" then return end
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Bootstrap" .. "] ")
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

    MsgC(prefixColor, "[Lilia] ", debugColor, "[" .. "Debug" .. "] ")
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
    embed.title = embed.title or "Lilia"
    embed.color = tonumber(embed.color) or 7506394
    embed.timestamp = embed.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")
    embed.footer = embed.footer or {
        text = "Lilia Discord Relay"
    }

    local payload = {
        embeds = {embed},
        username = "Lilia Logger"
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
    lia.loader.includeLibraryItems(files.path)
end

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
        print("Connecting to database...")
        hook.Run("SetupDatabase")
        lia.db.connect(function()
            lia.db.loadTables()
            print("Database connected successfully.")
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
        lia.bootstrap("HotReload", "Gamemode hotreloaded successfully!")
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
    if engine.ActiveGamemode() == "lilia" then lia.error("No schema loaded. Please place the schema in your gamemodes folder, then set it as your gamemode.") end
    lia.loader.initializeGamemode(false)
    if SERVER then CreateCharacterSaveTimer() end
end

function GM:OnReloaded()
    lia.loader.initializeGamemode(true)
    if CLIENT then
        hook.Run("PreLiliaLoaded")
        lia.option.load()
        lia.keybind.load()
        hook.Run("LiliaLoaded")
    end

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
            lia.error(string.format("Compatibility condition error: %s", tostring(result)))
        end
    elseif compatFile.global then
        shouldLoad = _G[compatFile.global] ~= nil
    end

    if shouldLoad then
        lia.loader.include(compatFile.path, compatFile.realm or "shared")
        lia.loader.includeLibraryItems(compatFile.path)
        loadedCompatibility[#loadedCompatibility + 1] = compatFile.name
    end
end

if #loadedCompatibility > 0 then lia.bootstrap("Compatibility", string.format("Loaded compatibility for the following addons: %s", table.concat(loadedCompatibility, ", "))) end
if game.IsDedicated() then concommand.Remove("gm_save") end
