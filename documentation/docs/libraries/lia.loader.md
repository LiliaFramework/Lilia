# Loader Library

Core initialization and module loading system for the Lilia framework.

---

Overview

The loader library is the core initialization system for the Lilia framework, responsible for managing the loading sequence of all framework components, modules, and dependencies. It handles file inclusion with proper realm detection (client, server, shared), manages module loading order, provides compatibility layer support for third-party addons, and includes update checking functionality. The library ensures that all framework components are loaded in the correct order and context, handles hot-reloading during development, and provides comprehensive logging and error handling throughout the initialization process. It also manages entity registration for weapons, tools, effects, and custom entities, and provides Discord webhook integration for logging and notifications.

---

### lia.loader.include

#### 📋 Purpose
Includes a Lua file with automatic realm detection and proper client/server handling

#### ⏰ When Called
During framework initialization, module loading, or when manually including files

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | **string** | The file path to include (e.g., "lilia/gamemode/core/libraries/util.lua") |
| `realm` | **string, optional** | The realm to load the file in ("client", "server", "shared") |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Include a shared library file
    lia.loader.include("lilia/gamemode/core/libraries/util.lua")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Include a file with explicit realm specification
    lia.loader.include("lilia/gamemode/core/libraries/logger.lua", "server")

```

#### ⚙️ High Complexity
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

---

### lia.loader.includeDir

#### 📋 Purpose
Recursively includes all Lua files in a directory with optional deep traversal

#### ⏰ When Called
During framework initialization to load entire directories of files

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | **string** | The directory path to scan for Lua files |
| `raw` | **boolean, optional** | If true, uses the exact path; if false, resolves relative to gamemode/schema |
| `deep` | **boolean, optional** | If true, recursively searches subdirectories |
| `realm` | **string, optional** | The realm to load files in ("client", "server", "shared") |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Include all files in a directory
    lia.loader.includeDir("lilia/gamemode/core/libraries")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Include files with specific realm and deep search
    lia.loader.includeDir("lilia/gamemode/modules", false, true, "shared")

```

#### ⚙️ High Complexity
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

---

### lia.loader.includeGroupedDir

#### 📋 Purpose
Includes files from a directory with automatic realm detection based on filename prefixes

#### ⏰ When Called
During framework initialization to load files with automatic realm detection

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | **string** | The directory path to scan for Lua files |
| `raw` | **boolean, optional** | If true, uses the exact path; if false, resolves relative to gamemode/schema |
| `recursive` | **boolean, optional** | If true, recursively searches subdirectories |
| `forceRealm` | **string, optional** | Forces all files to be loaded in this realm instead of auto-detection |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Include files with automatic realm detection
    lia.loader.includeGroupedDir("lilia/gamemode/core/libraries")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Include files recursively with forced realm
    lia.loader.includeGroupedDir("lilia/gamemode/modules", false, true, "shared")

```

#### ⚙️ High Complexity
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

---

### lia.loader.checkForUpdates

#### 📋 Purpose
Checks for updates to both the Lilia framework and installed modules by querying remote version data

#### ⏰ When Called
During server startup or when manually triggered to check for available updates

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check for updates during server startup
    lia.loader.checkForUpdates()

```

#### 📊 Medium Complexity
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

#### ⚙️ High Complexity
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

---

### lia.error

#### 📋 Purpose
Outputs error messages to the console with Lilia branding and red color formatting

#### ⏰ When Called
When critical errors occur during framework operation or module loading

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `msg` | **string** | The error message to display |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display a basic error message
    lia.error("Failed to load module")

```

#### 📊 Medium Complexity
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

#### ⚙️ High Complexity
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

---

### lia.warning

#### 📋 Purpose
Outputs warning messages to the console with Lilia branding and yellow color formatting

#### ⏰ When Called
When non-critical issues occur that should be brought to attention

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `msg` | **string** | The warning message to display |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display a basic warning message
    lia.warning("Module version mismatch detected")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display warning with context information
    local function checkModuleCompatibility(module)
        if module.version < "1.0.0" then
            lia.warning("Module '" .. module.name .. "' is using an outdated version")
        end
    end

```

#### ⚙️ High Complexity
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

---

### lia.information

#### 📋 Purpose
Outputs informational messages to the console with Lilia branding and blue color formatting

#### ⏰ When Called
When providing general information about framework operations or status updates

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `msg` | **string** | The informational message to display |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display a basic information message
    lia.information("Framework initialized successfully")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display information with context
    local function reportModuleStatus(module)
        lia.information("Module '" .. module.name .. "' loaded successfully")
    end

```

#### ⚙️ High Complexity
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

---

### lia.bootstrap

#### 📋 Purpose
Outputs bootstrap progress messages to the console with Lilia branding and section-specific formatting

#### ⏰ When Called
During framework initialization to report progress of different bootstrap phases

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `section` | **string** | The bootstrap section name (e.g., "Database", "Modules", "HotReload") |
| `msg` | **string** | The bootstrap message to display |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display a basic bootstrap message
    lia.bootstrap("Database", "Connection established")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display bootstrap progress with context
    local function reportModuleLoading(moduleName, status)
        lia.bootstrap("Modules", "Loading " .. moduleName .. ": " .. status)
    end

```

#### ⚙️ High Complexity
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

---

### lia.relaydiscordMessage

#### 📋 Purpose
Sends formatted messages to Discord webhook with embed support and automatic fallback handling

#### ⏰ When Called
When logging important events or sending notifications to Discord channels

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `embed` | **table** | Discord embed object containing message data (title, description, color, fields, etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Send a basic Discord message
    lia.relaydiscordMessage({
    title = "Server Started",
    description = "The server has been initialized successfully"
    })

```

#### 📊 Medium Complexity
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

#### ⚙️ High Complexity
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

---

### lia.loader.includeEntities

#### 📋 Purpose
Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

#### ⏰ When Called
During framework initialization to register all custom entities, weapons, and tools

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | **string** | The base path containing entity folders (e.g., "lilia/gamemode/entities") |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Include entities from the default gamemode path
    lia.loader.includeEntities("lilia/gamemode/entities")

```

#### 📊 Medium Complexity
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

#### ⚙️ High Complexity
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

---

### lia.loader.initializeGamemode

#### 📋 Purpose
Initializes or re-initializes the Lilia gamemode, including modules, config, factions, and compatibility files

#### ⏰ When Called
Called during initial gamemode startup (GM:Initialize) or during hot reloads (GM:OnReloaded)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `isReload` | **boolean** | true if this is a hot reload, false if this is initial gamemode startup |

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Initial gamemode startup
    lia.loader.initializeGamemode(false)
    -- Hot reload
    lia.loader.initializeGamemode(true)

```

---

