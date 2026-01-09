# Loader Library

Core initialization and module loading system for the Lilia framework.

---

Overview

The loader library is the core initialization system for the Lilia framework, responsible for managing the loading sequence of all framework components, modules, and dependencies. It handles file inclusion with proper realm detection (client, server, shared), manages module loading order, provides compatibility layer support for third-party addons, and includes update checking functionality. The library ensures that all framework components are loaded in the correct order and context, handles hot-reloading during development, and provides comprehensive logging and error handling throughout the initialization process. It also manages entity registration for weapons, tools, effects, and custom entities, and provides Discord webhook integration for logging and notifications.

---

### lia.loader.include

#### 📋 Purpose
Include a Lua file with realm auto-detection and AddCSLuaFile handling.

#### ⏰ When Called
Throughout bootstrap to load framework, module, and compatibility files.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | **string** | File path. |
| `realm` | **string|nil** | "server" | "client" | "shared". Auto-detected from filename if nil. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Force client-only include for a UI helper.
    lia.loader.include("lilia/gamemode/core/ui/cl_helper.lua", "client")
    -- Auto-detect realm from prefix (sv_/cl_/sh_).
    lia.loader.include("schema/plugins/sv_custom.lua")

```

---

### lia.loader.includeDir

#### 📋 Purpose
Include every Lua file in a directory; optionally recurse subfolders.

#### ⏰ When Called
To load plugin folders or schema-specific directories.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | **string** | Directory relative to gamemode root unless raw=true. |
| `raw` | **boolean|nil** | If true, treat dir as absolute (no schema/gamemode prefix). |
| `deep` | **boolean|nil** | If true, recurse into subfolders. |
| `realm` | **string|nil** | Force realm for all files; auto-detect when nil. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Load all schema hooks recursively.
    lia.loader.includeDir("schema/hooks", false, true)

```

---

### lia.loader.includeGroupedDir

#### 📋 Purpose
Include a directory grouping files by realm (sv_/cl_/sh_) with optional recursion.

#### ⏰ When Called
Loading modular folders (e.g., plugins, languages, meta) with mixed realms.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dir` | **string** | Directory relative to gamemode root unless raw=true. |
| `raw` | **boolean|nil** | If true, treat dir as absolute. |
| `recursive` | **boolean|nil** | Recurse into subfolders when true. |
| `forceRealm` | **string|nil** | Override realm detection for all files. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Load all plugin folders, respecting sv_/cl_/sh_ prefixes.
    lia.loader.includeGroupedDir("schema/plugins", false, true)

```

---

### lia.loader.checkForUpdates

#### 📋 Purpose
Check framework and module versions against remote manifests.

#### ⏰ When Called
During startup or by admin command to report outdated modules.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    concommand.Add("lia_check_updates", function(ply)
        if not IsValid(ply) or ply:IsAdmin() then
            lia.loader.checkForUpdates()
        end
    end)

```

---

### lia.error

#### 📋 Purpose
Logs an error message to the console with proper formatting and color coding.

#### ⏰ When Called
Called throughout the framework when errors occur that need to be logged to the console for debugging purposes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `msg` | **string** | The error message to display in the console. |

#### ↩️ Returns
* nil
This function does not return any value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Log an error when a required file fails to load
    lia.error("Failed to load configuration file: config.json not found")

```

---

### lia.warning

#### 📋 Purpose
Logs a warning message to the console with proper formatting and color coding.

#### ⏰ When Called
Called throughout the framework when non-critical issues occur that should be brought to attention but don't stop execution.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `msg` | **string** | The warning message to display in the console. |

#### ↩️ Returns
* nil
This function does not return any value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Log a warning when an optional dependency is missing
    lia.warning("Optional addon 'advanced_logging' not found, using basic logging instead")

```

---

### lia.information

#### 📋 Purpose
Logs an informational message to the console with proper formatting and color coding.

#### ⏰ When Called
Called throughout the framework to provide general information about system status, initialization progress, or important events.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `msg` | **string** | The informational message to display in the console. |

#### ↩️ Returns
* nil
This function does not return any value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Log information during system initialization
    lia.information("Database connection established successfully")

```

---

### lia.bootstrap

#### 📋 Purpose
Logs bootstrap/initialization messages to the console with section categorization and color coding.

#### ⏰ When Called
Called during the framework initialization process to log progress and status of different loading sections.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `section` | **string** | The name of the bootstrap section being initialized (e.g., "Core", "Modules", "Database"). |
| `msg` | **string** | The message describing what is being initialized or loaded. |

#### ↩️ Returns
* nil
This function does not return any value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Log bootstrap progress during initialization
    lia.bootstrap("Database", "Connecting to MySQL server...")
    lia.bootstrap("Modules", "Loading character system...")

```

---

### lia.relaydiscordMessage

#### 📋 Purpose
Sends formatted messages to a Discord webhook for logging and notifications.

#### ⏰ When Called
Called when important events need to be relayed to Discord, such as server status updates, errors, or administrative actions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `embed` | **table** | A Discord embed object containing message details. Supports fields like title, description, color, timestamp, footer, etc. |

#### ↩️ Returns
* nil
This function does not return any value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Send a notification when a player achieves something special
    lia.relaydiscordMessage({
        title = "Achievement Unlocked!",
        description = player:Name() .. " unlocked the 'Master Trader' achievement",
        color = 16776960, -- Yellow
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    })

```

---

### lia.loader.includeEntities

#### 📋 Purpose
Include and register scripted entities, weapons, and effects under a path.

#### ⏰ When Called
During initialization to load custom entities from addons/schema.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | **string** | Base path containing entities/weapons/effects subfolders. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Load schema-specific entities.
    lia.loader.includeEntities("schema/entities")

```

---

### lia.loader.initializeGamemode

#### 📋 Purpose
Initialize modules, apply reload syncs, and announce hot reloads.

#### ⏰ When Called
On gamemode initialize and OnReloaded; supports hot-reload flow.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `isReload` | **boolean** | true when called from OnReloaded. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Called automatically from GM:Initialize / GM:OnReloaded.
    lia.loader.initializeGamemode(false)

```

---

