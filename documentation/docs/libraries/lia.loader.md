# Loader Library

Core initialization and module loading system for the Lilia framework.

---

## Overview

The loader library is the core initialization system for the Lilia framework, responsible for managing the loading sequence of all framework components, modules, and dependencies. It handles file inclusion with proper realm detection (client, server, shared), manages module loading order, provides compatibility layer support for third-party addons, and includes update checking functionality. The library ensures that all framework components are loaded in the correct order and context, handles hot-reloading during development, and provides comprehensive logging and error handling throughout the initialization process. It also manages entity registration for weapons, tools, effects, and custom entities, and provides Discord webhook integration for logging and notifications.

---

### include

**Purpose**

Includes a Lua file with automatic realm detection and proper client/server handling

**When Called**

During framework initialization, module loading, or when manually including files

**Parameters**

* `path` (*string*): The file path to include (e.g., "lilia/gamemode/core/libraries/util.lua")
* `realm` (*string, optional*): The realm to load the file in ("client", "server", "shared")

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Include a shared library file
lia.loader.include("lilia/gamemode/core/libraries/util.lua")
```

---

### includeDir

**Purpose**

Recursively includes all Lua files in a directory with optional deep traversal

**When Called**

During framework initialization to load entire directories of files

**Parameters**

* `dir` (*string*): The directory path to scan for Lua files
* `raw` (*boolean, optional*): If true, uses the exact path; if false, resolves relative to gamemode/schema
* `deep` (*boolean, optional*): If true, recursively searches subdirectories
* `realm` (*string, optional*): The realm to load files in ("client", "server", "shared")

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Include all files in a directory
lia.loader.includeDir("lilia/gamemode/core/libraries")
```

---

### includeGroupedDir

**Purpose**

Includes files from a directory with automatic realm detection based on filename prefixes

**When Called**

During framework initialization to load files with automatic realm detection

**Parameters**

* `dir` (*string*): The directory path to scan for Lua files
* `raw` (*boolean, optional*): If true, uses the exact path; if false, resolves relative to gamemode/schema
* `recursive` (*boolean, optional*): If true, recursively searches subdirectories
* `forceRealm` (*string, optional*): Forces all files to be loaded in this realm instead of auto-detection

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Include files with automatic realm detection
lia.loader.includeGroupedDir("lilia/gamemode/core/libraries")
```

---

### checkForUpdates

**Purpose**

Checks for updates to both the Lilia framework and installed modules by querying remote version data

**When Called**

During server startup or when manually triggered to check for available updates

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check for updates during server startup
lia.loader.checkForUpdates()
```

---

### error

**Purpose**

Outputs error messages to the console with Lilia branding and red color formatting

**When Called**

When critical errors occur during framework operation or module loading

**Parameters**

* `msg` (*string*): The error message to display

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display a basic error message
lia.error("Failed to load module")
```

---

### warning

**Purpose**

Outputs warning messages to the console with Lilia branding and yellow color formatting

**When Called**

When non-critical issues occur that should be brought to attention

**Parameters**

* `msg` (*string*): The warning message to display

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display a basic warning message
lia.warning("Module version mismatch detected")
```

---

### information

**Purpose**

Outputs informational messages to the console with Lilia branding and blue color formatting

**When Called**

When providing general information about framework operations or status updates

**Parameters**

* `msg` (*string*): The informational message to display

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display a basic information message
lia.information("Framework initialized successfully")
```

---

### bootstrap

**Purpose**

Outputs bootstrap progress messages to the console with Lilia branding and section-specific formatting

**When Called**

During framework initialization to report progress of different bootstrap phases

**Parameters**

* `section` (*string*): The bootstrap section name (e.g., "Database", "Modules", "HotReload")
* `msg` (*string*): The bootstrap message to display

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display a basic bootstrap message
lia.bootstrap("Database", "Connection established")
```

---

### relaydiscordMessage

**Purpose**

Sends formatted messages to Discord webhook with embed support and automatic fallback handling

**When Called**

When logging important events or sending notifications to Discord channels

**Parameters**

* `embed` (*table*): Discord embed object containing message data (title, description, color, fields, etc.)

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Send a basic Discord message
lia.relaydiscordMessage({
title = "Server Started",
description = "The server has been initialized successfully"
})
```

---

### includeEntities

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Parameters**

* `path` (*string*): The base path containing entity folders (e.g., "lilia/gamemode/entities")

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```

---

### lia.LocalPlayer

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Parameters**

* `path` (*string*): The base path containing entity folders (e.g., "lilia/gamemode/entities")

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```

---

### lia.GM:Initialize

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Parameters**

* `path` (*string*): The base path containing entity folders (e.g., "lilia/gamemode/entities")

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```

---

### lia.GM:OnReloaded

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Parameters**

* `path` (*string*): The base path containing entity folders (e.g., "lilia/gamemode/entities")

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```

---

