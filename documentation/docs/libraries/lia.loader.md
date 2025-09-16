# Loader Library

This page documents the functions for loading and including Lua files, managing file dependencies, and handling the framework's initialization process.

---

## Overview

The loader library (`lia.loader`) provides a comprehensive system for managing file loading, dependency management, and framework initialization in the Lilia framework, serving as the foundational loading infrastructure that orchestrates the entire gamemode startup process and supports all other framework components with essential file management functionality. This library handles sophisticated file loading with support for automatic realm detection based on filename prefixes (sv_, cl_, sh_), recursive directory scanning, conditional loading of compatibility modules, and proper entity registration that ensures correct client/server/shared separation throughout the framework. The system features advanced dependency management with support for predefined file lists for core components, dynamic loading based on runtime conditions, and proper loading order that maintains framework stability and prevents initialization conflicts. It includes comprehensive entity loading with support for automatic entity registration, weapon loading, tool registration, and effects loading that seamlessly integrates custom content with the framework's architecture. The library provides robust logging utilities with support for error reporting, warnings, deprecation notices, and bootstrap messaging that ensure proper debugging capabilities and user feedback during the framework's initialization process. Additional features include integration with database setup, persistence management, module initialization, and compatibility system loading that makes it the central hub for all framework startup operations while maintaining flexibility and extensibility for schemas and addons to easily integrate with the core loading system, making it essential for maintaining proper framework initialization and providing consistent file management functionality throughout the entire framework ecosystem.

---

### include

**Purpose**

Includes a Lua file with proper realm handling (client, server, or shared) and automatic realm detection based on filename prefixes.

**Parameters**

* `path` (*string*): The file path to include, relative to the Lua directory.
* `realm` (*string*, optional): The realm to load the file in ("client", "server", or "shared"). If not provided, auto-detects based on filename.

**Returns**

* None

**Realm**

Shared.

**Example Usage**

```lua
-- Include a shared library
lia.loader.include("lilia/gamemode/core/libraries/util.lua", "shared")

-- Include with auto-detection based on filename
lia.loader.include("lilia/gamemode/core/libraries/sv_admin.lua") -- Auto-detects as server
lia.loader.include("lilia/gamemode/core/libraries/cl_menu.lua") -- Auto-detects as client
lia.loader.include("lilia/gamemode/core/libraries/sh_config.lua") -- Auto-detects as shared

-- Include a custom module
lia.loader.include("myaddon/libraries/custom.lua", "shared")

-- Include with error handling
local function safeInclude(path, realm)
    if file.Exists(path, "LUA") then
        lia.loader.include(path, realm)
        return true
    else
        lia.error("File not found: " .. path)
        return false
    end
end

-- Usage
safeInclude("lilia/gamemode/core/libraries/missing.lua", "shared")
```

---

### includeDir

**Purpose**

Recursively includes all Lua files in a directory with optional deep recursion and realm specification.

**Parameters**

* `dir` (*string*): The directory path to scan for Lua files.
* `raw` (*boolean*, optional): If true, uses the directory path as-is. If false, prepends the schema/gamemode path.
* `deep` (*boolean*, optional): If true, recursively searches subdirectories.
* `realm` (*string*, optional): The realm to load all files in ("client", "server", or "shared").

**Returns**

* None

**Realm**

Shared.

**Example Usage**

```lua
-- Include all files in a directory
lia.loader.includeDir("lilia/gamemode/core/libraries", false, false, "shared")

-- Include all files recursively
lia.loader.includeDir("lilia/gamemode/modules", false, true, "shared")

-- Include with raw path (no schema prefix)
lia.loader.includeDir("myaddon/libraries", true, true, "shared")

-- Include client-side UI files
lia.loader.includeDir("lilia/gamemode/core/derma", false, true, "client")

-- Include server-side modules
lia.loader.includeDir("lilia/gamemode/modules/administration", false, false, "server")

-- Custom directory loading function
local function loadCustomModules()
    local moduleDir = "myaddon/modules"
    if file.Exists(moduleDir, "LUA") then
        lia.loader.includeDir(moduleDir, true, true, "shared")
        lia.information("Loaded custom modules from " .. moduleDir)
    end
end
```

---

### includeGroupedDir

**Purpose**

Includes all Lua files in a directory with automatic realm detection based on filename prefixes and optional recursive scanning.

**Parameters**

* `dir` (*string*): The directory path to scan for Lua files.
* `raw` (*boolean*, optional): If true, uses the directory path as-is. If false, prepends the schema/gamemode path.
* `recursive` (*boolean*, optional): If true, recursively searches subdirectories.
* `forceRealm` (*string*, optional): Forces all files to be loaded in the specified realm instead of auto-detecting.

**Returns**

* None

**Realm**

Shared.

**Example Usage**

```lua
-- Include with automatic realm detection
lia.loader.includeGroupedDir("lilia/gamemode/modules/administration", false, true)

-- Force all files to be shared
lia.loader.includeGroupedDir("myaddon/libraries", true, false, "shared")

-- Include with recursive scanning
lia.loader.includeGroupedDir("lilia/gamemode/core", false, true)

-- Include custom modules with auto-detection
lia.loader.includeGroupedDir("myaddon/modules", true, true)

-- Include with custom processing
local function loadModulesWithCallback(dir, callback)
    lia.loader.includeGroupedDir(dir, false, true)
    if callback then callback() end
end

-- Usage
loadModulesWithCallback("lilia/gamemode/modules", function()
    lia.information("All modules loaded successfully")
end)
```

---

### includeEntities

**Purpose**

Loads and registers entities, weapons, tools, and effects from a specified directory with proper realm handling and registration.

**Parameters**

* `path` (*string*): The base directory path containing entity folders.

**Returns**

* None

**Realm**

Shared.

**Example Usage**

```lua
-- Load default Lilia entities
lia.loader.includeEntities("lilia/gamemode/entities")

-- Load custom entities from addon
lia.loader.includeEntities("myaddon/entities")

-- Load entities from current gamemode
lia.loader.includeEntities(engine.ActiveGamemode() .. "/gamemode/entities")

-- Load entities with custom setup
local function loadCustomEntities()
    local entityPath = "myaddon/entities"
    if file.Exists(entityPath, "LUA") then
        lia.loader.includeEntities(entityPath)
        lia.information("Custom entities loaded from " .. entityPath)
    else
        lia.warning("Entity directory not found: " .. entityPath)
    end
end

-- Load entities with error handling
local function safeLoadEntities(path)
    local success, err = pcall(function()
        lia.loader.includeEntities(path)
    end)
    
    if not success then
        lia.error("Failed to load entities from " .. path .. ": " .. tostring(err))
    end
end
```

---

## Rules

- Only document functions from the `lia.*` namespace.  
- Always follow the structure exactly as shown.  
- Always write in clear, concise English.  
- Always generate **full Markdown pages** ready to be placed in documentation.  
- Always provide **extensive usage examples** in GLua code fences.  
- Always format code cleanly and consistently.  
- Always save documentation files as `lia.libraryname.md`.  
- Never omit any of the sections (Purpose, Parameters, Returns, Realm, Example Usage).  
- Never include comments in code unless they clarify the example's intent.  
- Never document hooks, enums, or config variables unless they are explicitly part of the `lia.*` namespace.
