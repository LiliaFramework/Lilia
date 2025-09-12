local hasInitializedModules = false
lia = lia or {
    util = {},
    gui = {},
    meta = {},
    notices = {},
    lastReloadTime = 0,
    reloadCooldown = 5,
    loadingState = {
        databaseConnected = false,
        databaseTablesLoaded = false,
        modulesInitialized = false,
        filesLoaded = false,
        loadingFailed = false,
        failureReason = "",
        failureDetails = "",
        errors = {}
    }
}

local FilesToLoad = {
    {
        path = "lilia/gamemode/core/libraries/net.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/keybind.lua",
        realm = "shared"
    },
    {
        path = "lilia/gamemode/core/libraries/playerinteract.lua",
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
        path = "lilia/gamemode/core/libraries/color.lua",
        realm = "client"
    },
    {
        path = "lilia/gamemode/core/libraries/logger.lua",
        realm = "server"
    },
    {
        path = "lilia/gamemode/core/libraries/discord.lua",
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

function lia.include(path, realm)
    if not path then lia.error(L("missingFilePath")) end
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
function lia.error(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logError") .. "] ")
    MsgC(Color(255, 0, 0), tostring(msg), "\n")
end

function lia.warning(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logWarning") .. "] ")
    MsgC(Color(255, 255, 0), tostring(msg), "\n")
end

function lia.deprecated(methodName, callback)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logDeprecated") .. "] ")
    MsgC(Color(255, 255, 0), L("deprecatedMessage", methodName), "\n")
    if callback and isfunction(callback) then callback() end
end

function lia.updater(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logUpdater") .. "] ")
    MsgC(Color(0, 255, 255), tostring(msg), "\n")
end

function lia.information(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logInformation") .. "] ")
    MsgC(Color(83, 143, 239), tostring(msg), "\n")
end

function lia.admin(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logAdmin") .. "] ")
    MsgC(Color(255, 153, 0), tostring(msg), "\n")
end

function lia.bootstrap(section, msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logBootstrap") .. "] ")
    MsgC(Color(0, 255, 0), "[" .. section .. "] ")
    MsgC(Color(255, 255, 255), tostring(msg), "\n")
end

function lia.notifyAdmin(notification)
    for _, client in player.Iterator() do
        if IsValid(client) and client:hasPrivilege("canSeeAltingNotifications") then client:notify(notification) end
    end
end

function lia.printLog(category, logString)
    MsgC(Color(83, 143, 239), "[LOG] ")
    MsgC(Color(0, 255, 0), "[" .. L("logCategory") .. ": " .. tostring(category) .. "] ")
    MsgC(Color(255, 255, 255), tostring(logString) .. "\n")
end

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
local originalError = error
function error(message, level)
    lia.addLoadingError(message)
    if string.find(message, "CRITICAL") or string.find(message, "failed to load") then
        lia.loadingState.loadingFailed = true
        lia.loadingState.failureReason = "Critical Error"
        lia.loadingState.failureDetails = message
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "CRITICAL ERROR DETECTED: ", message, "\n")
    end
    return originalError(message, level)
end

function lia.hasGamemodeLoadedSuccessfully()
    return not lia.loadingState.loadingFailed and lia.loadingState.databaseConnected and lia.loadingState.databaseTablesLoaded and lia.loadingState.modulesInitialized and lia.loadingState.filesLoaded
end

function lia.parseLuaError(errorMessage)
    local pattern = "%[Lilia%] ([^:]+):(%d+): (.+)"
    local errFile, line, message = errorMessage:match(pattern)
    if errFile and line and message then
        return {
            message = message,
            line = tonumber(line),
            file = errFile
        }
    end

    local fallbackPattern = "([^:]+):(%d+): (.+)"
    errFile, line, message = errorMessage:match(fallbackPattern)
    if errFile and line and message then
        return {
            message = message,
            line = tonumber(line),
            file = errFile
        }
    end
    return {
        message = errorMessage,
        line = "N/A",
        file = "Unknown"
    }
end

function lia.addLoadingError(errorMessage)
    local parsedError = lia.parseLuaError(errorMessage)
    table.insert(lia.loadingState.errors, parsedError)
    if #lia.loadingState.errors > 10 then table.remove(lia.loadingState.errors, 1) end
end

function lia.getLoadingFailureInfo()
    if not lia.loadingState.loadingFailed then return nil end
    return {
        reason = lia.loadingState.failureReason,
        details = lia.loadingState.failureDetails,
        errors = lia.loadingState.errors
    }
end

function lia.clearLoadingState()
    lia.loadingState = {
        databaseConnected = false,
        databaseTablesLoaded = false,
        modulesInitialized = false,
        filesLoaded = false,
        loadingFailed = false,
        failureReason = "",
        failureDetails = "",
        errors = {}
    }

    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Loading state cleared for debugging.\n")
end

if SERVER then
    local function SetupDatabase()
        hook.Run("SetupDatabase")
        lia.db.connect(function(success, errorMsg)
            if success then
                lia.loadingState.databaseConnected = true
                lia.db.loadTables()
            else
                lia.loadingState.loadingFailed = true
                lia.loadingState.failureReason = "Database Connection Failed"
                lia.loadingState.failureDetails = "Failed to connect to database: " .. tostring(errorMsg)
                local errorMsgFull = "[Database] Failed to connect to database: " .. tostring(errorMsg)
                lia.addLoadingError(errorMsgFull)
                lia.error(errorMsgFull)
                MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "CRITICAL: Database connection failed! Server may not function properly.\n")
                hook.Run("DatabaseConnectionFailed", errorMsg)
            end
        end)
    end

    local function BootstrapLilia()
        -- Initialize database immediately so it's available before anything else
        SetupDatabase()
        cvars.AddChangeCallback("sbox_persist", function(_, old, new)
            timer.Create("sbox_persist_change_timer", 1, 1, function()
                hook.Run("PersistenceSave", old)
                game.CleanUpMap(false, nil, function() end)
                if new ~= "" then hook.Run("PersistenceLoad", new) end
            end)
        end, "sbox_persist_load")
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

function GM:Initialize()
    if engine.ActiveGamemode() == "lilia" then
        lia.loadingState.loadingFailed = true
        lia.loadingState.failureReason = "No Schema Loaded"
        lia.loadingState.failureDetails = "The gamemode failed to load because no schema is loaded"
        lia.error(L("noSchemaLoaded"))
    end

    if not hasInitializedModules then
        if SERVER then
            lia.db.waitForTablesToLoad():next(function()
                local success, errorMsg = pcall(lia.module.initialize)
                if not success then
                    lia.loadingState.loadingFailed = true
                    lia.loadingState.failureReason = "Module Initialization Failed"
                    lia.loadingState.failureDetails = "Failed to initialize modules: " .. tostring(errorMsg)
                    local errorMsgFull = "Module initialization failed: " .. tostring(errorMsg)
                    lia.addLoadingError(errorMsgFull)
                    lia.error(errorMsgFull)
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "CRITICAL: Module initialization failed! Server may not function properly.\n")
                else
                    hasInitializedModules = true
                    lia.loadingState.modulesInitialized = true
                end
            end)
        else
            local success, errorMsg = pcall(lia.module.initialize)
            if not success then
                lia.loadingState.loadingFailed = true
                lia.loadingState.failureReason = "Module Initialization Failed"
                lia.loadingState.failureDetails = "Failed to initialize modules: " .. tostring(errorMsg)
                local errorMsgFull = "Module initialization failed: " .. tostring(errorMsg)
                lia.addLoadingError(errorMsgFull)
                lia.error(errorMsgFull)
                MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "CRITICAL: Module initialization failed! Server may not function properly.\n")
            else
                hasInitializedModules = true
                lia.loadingState.modulesInitialized = true
            end
        end
    end
end

function GM:OnReloaded()
    local currentTime = CurTime()
    local timeSinceLastReload = currentTime - lia.lastReloadTime
    if timeSinceLastReload < lia.reloadCooldown then return end
    lia.lastReloadTime = currentTime
    if SERVER then
        -- Reset database and loading states for proper reload
        lia.db.connected = false
        lia.db.tablesLoaded = false
        lia.db.status.connected = false
        lia.db.status.tablesLoaded = false
        lia.loadingState.databaseConnected = false
        lia.loadingState.databaseTablesLoaded = false
        lia.loadingState.modulesInitialized = false
        lia.loadingState.filesLoaded = false
        lia.loadingState.loadingFailed = false
        lia.bootstrap("Reload", "Resetting database state for reload...")
        -- Reconnect to database and ensure tables are loaded
        lia.db.connect(function(success, errorMsg)
            if not success then
                lia.error("[Reload] Database connection failed: " .. tostring(errorMsg))
                lia.loadingState.loadingFailed = true
                lia.loadingState.failureReason = "Database Reconnection Failed"
                lia.loadingState.failureDetails = "Failed to reconnect to database during reload: " .. tostring(errorMsg)
                return
            end

            lia.loadingState.databaseConnected = true
            lia.bootstrap("Reload", "Database reconnected, loading tables...")
            -- Force reload tables to ensure they're properly accessible
            lia.db.loadTables()
            lia.db.waitForTablesToLoad():next(function()
                lia.loadingState.databaseTablesLoaded = true
                lia.bootstrap("Reload", "Tables loaded, initializing modules...")
                local moduleSuccess, moduleError = pcall(lia.module.initialize)
                if not moduleSuccess then
                    lia.error("[Reload] Module initialization failed: " .. tostring(moduleError))
                    lia.loadingState.loadingFailed = true
                    lia.loadingState.failureReason = "Module Initialization Failed"
                    lia.loadingState.failureDetails = "Failed to initialize modules during reload: " .. tostring(moduleError)
                    return
                end

                lia.loadingState.modulesInitialized = true
                lia.config.load()
                lia.faction.formatModelData()
                lia.config.send()
                lia.administrator.sync()
                lia.playerinteract.syncToClients()

                -- Restore character lists for existing players after reload
                lia.bootstrap("Reload", "Restoring character lists for existing players...")

                -- Add a small delay to ensure modules are fully initialized
                timer.Simple(0.5, function()
                    for _, client in player.Iterator() do
                        if IsValid(client) and not client:IsBot() then
                            -- Reset the client's loaded state to force proper reload
                            client.liaLoaded = false
                            client.liaCharList = nil

                            -- Trigger the full character loading process
                            hook.Run("PlayerLiliaDataLoaded", client)
                            lia.information("[Reload] Triggered character reload for " .. client:Name())
                        end
                    end
                end)

                lia.loadingState.filesLoaded = true
                lia.bootstrap("Reload", "Reload completed successfully")
            end):catch(function(err)
                lia.error("[Reload] Table loading failed: " .. tostring(err))
                lia.loadingState.loadingFailed = true
                lia.loadingState.failureReason = "Table Loading Failed"
                lia.loadingState.failureDetails = "Failed to load database tables during reload: " .. tostring(err)
            end)
        end, true)
    end

    -- Client-side reload
    lia.module.initialize()
    lia.config.load()
    lia.faction.formatModelData()
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
        lia.include(compatFile.path, compatFile.realm or "shared")
        loadedCompatibility[#loadedCompatibility + 1] = compatFile.name
    end
end

if #loadedCompatibility > 0 then lia.bootstrap(L("compatibility"), #loadedCompatibility == 1 and L("compatibilityLoadedSingle", loadedCompatibility[1]) or L("compatibilityLoadedMultiple", table.concat(loadedCompatibility, ", "))) end
if game.IsDedicated() then concommand.Remove("gm_save") end