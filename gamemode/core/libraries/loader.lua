--[[
    Loader Library

    The loader library is the core initialization system for the Lilia framework, responsible for
    managing the loading sequence of all framework components, modules, and dependencies. It handles
    file inclusion with proper realm detection (client, server, shared), manages module loading order,
    provides compatibility layer support for third-party addons, and includes update checking
    functionality. The library ensures that all framework components are loaded in the correct order
    and context, handles hot-reloading during development, and provides comprehensive logging and
    error handling throughout the initialization process. It also manages entity registration for
    weapons, tools, effects, and custom entities, and provides Discord webhook integration for
    logging and notifications.
]]
lia = lia or {
    util = {},
    gui = {},
    meta = {},
    loader = {}
}

lia.reloadInProgress = false
lia.lastReloadTime = 0
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
    Purpose: Includes a Lua file with automatic realm detection and proper client/server handling
    When Called: During framework initialization, module loading, or when manually including files
    Parameters:
        - path (string): The file path to include (e.g., "lilia/gamemode/core/libraries/util.lua")
        - realm (string, optional): The realm to load the file in ("client", "server", "shared")
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Include a shared library file
        lia.loader.include("lilia/gamemode/core/libraries/util.lua")
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Include a file with explicit realm specification
        lia.loader.include("lilia/gamemode/core/libraries/logger.lua", "server")
        ```

        High Complexity Example:
        ```lua
        -- High: Include files based on conditions with error handling
        local filesToLoad = {
            "lilia/gamemode/core/libraries/net.lua",
            "lilia/gamemode/core/libraries/commands.lua"
        }
        for _, filePath in ipairs(filesToLoad) do
            if file.Exists(filePath, "LUA") then
                lia.loader.include(filePath)
            else
                lia.warning("File not found: " .. filePath)
            end
        end
        ```
]]
function lia.loader.include(path, realm)
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

--[[
    Purpose: Recursively includes all Lua files in a directory with optional deep traversal
    When Called: During framework initialization to load entire directories of files
    Parameters:
        - dir (string): The directory path to scan for Lua files
        - raw (boolean, optional): If true, uses the exact path; if false, resolves relative to gamemode/schema
        - deep (boolean, optional): If true, recursively searches subdirectories
        - realm (string, optional): The realm to load files in ("client", "server", "shared")
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Include all files in a directory
        lia.loader.includeDir("lilia/gamemode/core/libraries")
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Include files with specific realm and deep search
        lia.loader.includeDir("lilia/gamemode/modules", false, true, "shared")
        ```

        High Complexity Example:
        ```lua
        -- High: Include multiple directories with different settings
        local dirsToLoad = {
            {path = "lilia/gamemode/core/libraries", raw = false, deep = false, realm = "shared"},
            {path = "lilia/gamemode/modules", raw = false, deep = true, realm = "shared"},
            {path = "custom/scripts", raw = true, deep = true, realm = "client"}
        }
        for _, dir in ipairs(dirsToLoad) do
            lia.loader.includeDir(dir.path, dir.raw, dir.deep, dir.realm)
        end
        ```
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
    Purpose: Includes files from a directory with automatic realm detection based on filename prefixes
    When Called: During framework initialization to load files with automatic realm detection
    Parameters:
        - dir (string): The directory path to scan for Lua files
        - raw (boolean, optional): If true, uses the exact path; if false, resolves relative to gamemode/schema
        - recursive (boolean, optional): If true, recursively searches subdirectories
        - forceRealm (string, optional): Forces all files to be loaded in this realm instead of auto-detection
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Include files with automatic realm detection
        lia.loader.includeGroupedDir("lilia/gamemode/core/libraries")
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Include files recursively with forced realm
        lia.loader.includeGroupedDir("lilia/gamemode/modules", false, true, "shared")
        ```

        High Complexity Example:
        ```lua
        -- High: Include multiple directories with different settings and error handling
        local dirsToLoad = {
            {path = "lilia/gamemode/core/libraries", raw = false, recursive = false, forceRealm = nil},
            {path = "lilia/gamemode/modules", raw = false, recursive = true, forceRealm = "shared"},
            {path = "custom/scripts", raw = true, recursive = true, forceRealm = "client"}
        }
        for _, dir in ipairs(dirsToLoad) do
            if file.Exists(dir.path, "LUA") then
                lia.loader.includeGroupedDir(dir.path, dir.raw, dir.recursive, dir.forceRealm)
            else
                lia.warning("Directory not found: " .. dir.path)
            end
        end
        ```
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
        for num in tostring(v):gmatch("%d+") do
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
    Purpose: Checks for updates to both the Lilia framework and installed modules by querying remote version data
    When Called: During server startup or when manually triggered to check for available updates
    Parameters: None
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check for updates during server startup
        lia.loader.checkForUpdates()
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Check for updates with custom error handling
        local function safeUpdateCheck()
            local success, err = pcall(lia.loader.checkForUpdates)
            if not success then
                lia.error("Update check failed: " .. tostring(err))
            end
        end
        safeUpdateCheck()
        ```

        High Complexity Example:
        ```lua
        -- High: Check for updates with custom timing and logging
        local function scheduledUpdateCheck()
            timer.Create("update_checker", 3600, 0, function() -- Check every hour
                lia.information("Checking for updates...")
                lia.loader.checkForUpdates()
                lia.information("Update check completed")
            end)
        end
        scheduledUpdateCheck()
        ```
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
lia.loader.include("lilia/gamemode/core/libraries/config.lua", "shared")
lia.loader.include("lilia/gamemode/core/libraries/color.lua", "shared")
lia.loader.include("lilia/gamemode/core/libraries/derma.lua", "client")
lia.loader.includeDir("lilia/gamemode/core/derma", true, true, "client")
lia.loader.include("lilia/gamemode/core/libraries/database.lua", "server")
lia.loader.include("lilia/gamemode/core/libraries/config.lua", "shared")
lia.loader.include("lilia/gamemode/core/libraries/data.lua", "server")
--[[
    Purpose: Outputs error messages to the console with Lilia branding and red color formatting
    When Called: When critical errors occur during framework operation or module loading
    Parameters:
        - msg (string): The error message to display
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Display a basic error message
        lia.error("Failed to load module")
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Display error with context information
        local function loadConfig()
            local success, err = pcall(function()
                -- Config loading code here
            end)
            if not success then
                lia.error("Config loading failed: " .. tostring(err))
            end
        end
        ```

        High Complexity Example:
        ```lua
        -- High: Display detailed error with stack trace and context
        local function safeModuleLoad(moduleName)
            local success, err = pcall(function()
                -- Module loading code here
            end)
            if not success then
                local errorMsg = string.format(
                    "Module '%s' failed to load: %s\nStack trace: %s",
                    moduleName,
                    tostring(err),
                    debug.traceback()
                )
                lia.error(errorMsg)
            end
        end
        ```
]]
function lia.error(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logError") .. "] ")
    MsgC(Color(255, 0, 0), tostring(msg), "\n")
end

--[[
    Purpose: Outputs warning messages to the console with Lilia branding and yellow color formatting
    When Called: When non-critical issues occur that should be brought to attention
    Parameters:
        - msg (string): The warning message to display
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Display a basic warning message
        lia.warning("Module version mismatch detected")
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Display warning with context information
        local function checkModuleCompatibility(module)
            if module.version < "1.0.0" then
                lia.warning("Module '" .. module.name .. "' is using an outdated version")
            end
        end
        ```

        High Complexity Example:
        ```lua
        -- High: Display warning with detailed information and conditional logic
        local function validateModuleDependencies(module)
            local missingDeps = {}
            for _, dep in ipairs(module.dependencies or {}) do
                if not lia.module.list[dep] then
                    table.insert(missingDeps, dep)
                end
            end

            if #missingDeps > 0 then
                local warningMsg = string.format(
                    "Module '%s' is missing dependencies: %s",
                    module.name,
                    table.concat(missingDeps, ", ")
                )
                lia.warning(warningMsg)
            end
        end
        ```
]]
function lia.warning(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logWarning") .. "] ")
    MsgC(Color(255, 255, 0), tostring(msg), "\n")
end

--[[
    Purpose: Outputs informational messages to the console with Lilia branding and blue color formatting
    When Called: When providing general information about framework operations or status updates
    Parameters:
        - msg (string): The informational message to display
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Display a basic information message
        lia.information("Framework initialized successfully")
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Display information with context
        local function reportModuleStatus(module)
            lia.information("Module '" .. module.name .. "' loaded successfully")
        end
        ```

        High Complexity Example:
        ```lua
        -- High: Display detailed information with statistics
        local function reportFrameworkStatus()
            local moduleCount = table.Count(lia.module.list)
            local loadedModules = 0
            for _, module in pairs(lia.module.list) do
                if module.loaded then loadedModules = loadedModules + 1 end
            end

            local statusMsg = string.format(
                "Framework Status: %d/%d modules loaded, %d entities registered",
                loadedModules,
                moduleCount,
                table.Count(scripted_ents.GetList())
            )
            lia.information(statusMsg)
        end
        ```
]]
function lia.information(msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logInformation") .. "] ")
    MsgC(Color(83, 143, 239), tostring(msg), "\n")
end

--[[
    Purpose: Outputs bootstrap progress messages to the console with Lilia branding and section-specific formatting
    When Called: During framework initialization to report progress of different bootstrap phases
    Parameters:
        - section (string): The bootstrap section name (e.g., "Database", "Modules", "HotReload")
        - msg (string): The bootstrap message to display
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Display a basic bootstrap message
        lia.bootstrap("Database", "Connection established")
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Display bootstrap progress with context
        local function reportModuleLoading(moduleName, status)
            lia.bootstrap("Modules", "Loading " .. moduleName .. ": " .. status)
        end
        ```

        High Complexity Example:
        ```lua
        -- High: Display detailed bootstrap progress with timing and statistics
        local function reportBootstrapProgress(section, current, total, startTime)
            local elapsed = CurTime() - startTime
            local progress = math.floor((current / total) * 100)
            local msg = string.format(
                "Progress: %d/%d (%d%%) - Elapsed: %.2fs",
                current,
                total,
                progress,
                elapsed
            )
            lia.bootstrap(section, msg)
        end
        ```
]]
function lia.bootstrap(section, msg)
    MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logBootstrap") .. "] ")
    MsgC(Color(0, 255, 0), "[" .. section .. "] ")
    MsgC(Color(255, 255, 255), tostring(msg), "\n")
end

--[[
    Purpose: Sends formatted messages to Discord webhook with embed support and automatic fallback handling
    When Called: When logging important events or sending notifications to Discord channels
    Parameters:
        - embed (table): Discord embed object containing message data (title, description, color, fields, etc.)
    Returns: None
    Realm: Server
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send a basic Discord message
        lia.relaydiscordMessage({
            title = "Server Started",
            description = "The server has been initialized successfully"
        })
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Send a detailed Discord message with custom formatting
        local function notifyPlayerJoin(player)
            lia.relaydiscordMessage({
                title = "Player Joined",
                description = player:Name() .. " has joined the server",
                color = 0x00ff00,
                fields = {
                    {name = "Steam ID", value = player:SteamID(), inline = true},
                    {name = "IP Address", value = player:IPAddress(), inline = true}
                }
            })
        end
        ```

        High Complexity Example:
        ```lua
        -- High: Send complex Discord message with error handling and custom logic
        local function sendServerStatus()
            local players = player.GetAll()
            local embed = {
                title = "Server Status Report",
                description = "Current server statistics and health",
                color = 0x0099ff,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                fields = {
                    {name = "Players Online", value = #players, inline = true},
                    {name = "Server Uptime", value = string.format("%.1f hours", CurTime() / 3600), inline = true},
                    {name = "Map", value = game.GetMap(), inline = true}
                },
                footer = {text = "Lilia Framework Status Bot"}
            }

            if #players > 0 then
                local playerList = {}
                for _, ply in ipairs(players) do
                    table.insert(playerList, ply:Name())
                end
                embed.fields[#embed.fields + 1] = {
                    name = "Player List",
                    value = table.concat(playerList, "\n"),
                    inline = false
                }
            end

            lia.relaydiscordMessage(embed)
        end
        ```
]]
function lia.relaydiscordMessage(embed)
    if not lia.discordWebhook or not istable(embed) then return end
    local ForceHTTPMode = not util.IsBinaryModuleInstalled("chttp")
    embed.title = embed.title or L("discordRelayLilia")
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
        }, function() end, function(err) print(L("discordRelayHTTPFailed") .. " " .. tostring(err)) end)
    end

    hook.Run("DiscordRelayed", embed)
end

for _, files in ipairs(FilesToLoad) do
    lia.loader.include(files.path, files.realm)
end

--[[
    Purpose: Registers and includes all entity types (entities, weapons, tools, effects) from a specified path
    When Called: During framework initialization to register all custom entities, weapons, and tools
    Parameters:
        - path (string): The base path containing entity folders (e.g., "lilia/gamemode/entities")
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Include entities from the default gamemode path
        lia.loader.includeEntities("lilia/gamemode/entities")
        ```

        Medium Complexity Example:
        ```lua
        -- Medium: Include entities from multiple paths with error handling
        local entityPaths = {
            "lilia/gamemode/entities",
            "custom/entities"
        }
        for _, path in ipairs(entityPaths) do
            if file.Exists(path, "LUA") then
                lia.loader.includeEntities(path)
            else
                lia.warning("Entity path not found: " .. path)
            end
        end
        ```

        High Complexity Example:
        ```lua
        -- High: Include entities with custom registration and validation
        local function safeEntityInclusion(path)
            local success, err = pcall(function()
                lia.loader.includeEntities(path)
            end)
            if not success then
                lia.error("Failed to include entities from " .. path .. ": " .. tostring(err))
            else
                lia.information("Successfully loaded entities from " .. path)
            end
        end
        safeEntityInclusion("lilia/gamemode/entities")
        ```
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

lia.loader.includeEntities("lilia/gamemode/entities")
lia.loader.includeEntities(engine.ActiveGamemode() .. "/gamemode/entities")
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
end

function GM:OnReloaded()
    local currentTime = CurTime()
    local timeSinceLastReload = currentTime - lia.lastReloadTime
    if lia.config then lia.reloadCooldown = 5 end
    if timeSinceLastReload < lia.reloadCooldown then
        local remaining = math.ceil(lia.reloadCooldown - timeSinceLastReload)
        if SERVER then
            MsgC(Color(0, 255, 0), "[Lilia] ", "[" .. L("logBootstrap") .. "] ")
            MsgC(Color(0, 255, 0), "[HotReload] ")
            MsgC(Color(255, 255, 255), L("reloadCooldownActive", remaining) .. "\n")
        end
        return
    end

    lia.reloadInProgress = true
    lia.lastReloadTime = currentTime
    lia.module.initialize()
    lia.config.load()
    lia.faction.formatModelData()
    if SERVER then
        timer.Simple(0.5, function() lia.config.send() end)
        timer.Simple(2.0, function() lia.administrator.sync() end)
        timer.Simple(3.5, function() lia.playerinteract.syncToClients() end)
        timer.Simple(5.0, function()
            lia.bootstrap("HotReload", L("gamemodeHotreloadedSuccessfully"))
            lia.reloadInProgress = false
        end)
    else
        chat.AddText(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), L("gamemodeHotreloadedSuccessfully"))
    end
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

if #loadedCompatibility > 0 then lia.bootstrap(L("compatibility"), #loadedCompatibility == 1 and L("compatibilityLoadedSingle", loadedCompatibility[1]) or L("compatibilityLoadedMultiple", table.concat(loadedCompatibility, ", "))) end
if game.IsDedicated() then concommand.Remove("gm_save") end
