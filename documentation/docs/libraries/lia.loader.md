# Loader Library

Core initialization and module loading system for the Lilia framework.

---

## Overview

The loader library is the core initialization system for the Lilia framework, responsible for managing the loading sequence of all framework components, modules, and dependencies. It handles file inclusion with proper realm detection (client, server, shared), manages module loading order, provides compatibility layer support for third-party addons, and includes update checking functionality. The library ensures that all framework components are loaded in the correct order and context, handles hot-reloading during development, and provides comprehensive logging and error handling throughout the initialization process. It also manages entity registration for weapons, tools, effects, and custom entities, and provides Discord webhook integration for logging and notifications.

---

### lia.loader.include

**Purpose**

Includes a Lua file with automatic realm detection and proper client/server handling

**When Called**

During framework initialization, module loading, or when manually including files

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include a shared library file
lia.loader.include("lilia/gamemode/core/libraries/util.lua")
```
```

---

### lia.loader.includeDir

**Purpose**

Recursively includes all Lua files in a directory with optional deep traversal

**When Called**

During framework initialization to load entire directories of files

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include all files in a directory
lia.loader.includeDir("lilia/gamemode/core/libraries")
```
```

---

### lia.loadDir

**Purpose**

Recursively includes all Lua files in a directory with optional deep traversal

**When Called**

During framework initialization to load entire directories of files

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include all files in a directory
lia.loader.includeDir("lilia/gamemode/core/libraries")
```
```

---

### lia.loader.includeGroupedDir

**Purpose**

Includes files from a directory with automatic realm detection based on filename prefixes

**When Called**

During framework initialization to load files with automatic realm detection

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include files with automatic realm detection
lia.loader.includeGroupedDir("lilia/gamemode/core/libraries")
```
```

---

### lia.fetchURL

**Purpose**

Includes files from a directory with automatic realm detection based on filename prefixes

**When Called**

During framework initialization to load files with automatic realm detection

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include files with automatic realm detection
lia.loader.includeGroupedDir("lilia/gamemode/core/libraries")
```
```

---

### lia.versionCompare

**Purpose**

Includes files from a directory with automatic realm detection based on filename prefixes

**When Called**

During framework initialization to load files with automatic realm detection

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include files with automatic realm detection
lia.loader.includeGroupedDir("lilia/gamemode/core/libraries")
```
```

---

### lia.toParts

**Purpose**

Includes files from a directory with automatic realm detection based on filename prefixes

**When Called**

During framework initialization to load files with automatic realm detection

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include files with automatic realm detection
lia.loader.includeGroupedDir("lilia/gamemode/core/libraries")
```
```

---

### lia.safeUpdateCheck

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
```lua
-- Simple: Check for updates during server startup
lia.loader.checkForUpdates()
```
```

---

### lia.scheduledUpdateCheck

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
```lua
-- Simple: Check for updates during server startup
lia.loader.checkForUpdates()
```
```

---

### lia.loader.checkForUpdates

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
```lua
-- Simple: Check for updates during server startup
lia.loader.checkForUpdates()
```
```

---

### lia.processModuleUpdates

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
```lua
-- Simple: Check for updates during server startup
lia.loader.checkForUpdates()
```
```

---

### lia.logError

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
```lua
-- Simple: Check for updates during server startup
lia.loader.checkForUpdates()
```
```

---

### lia.loadConfig

**Purpose**

Outputs error messages to the console with Lilia branding and red color formatting

**When Called**

When critical errors occur during framework operation or module loading

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic error message
lia.error("Failed to load module")
```
```

---

### lia.safeModuleLoad

**Purpose**

Outputs error messages to the console with Lilia branding and red color formatting

**When Called**

When critical errors occur during framework operation or module loading

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic error message
lia.error("Failed to load module")
```
```

---

### lia.error

**Purpose**

Outputs error messages to the console with Lilia branding and red color formatting

**When Called**

When critical errors occur during framework operation or module loading

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic error message
lia.error("Failed to load module")
```
```

---

### lia.checkModuleCompatibility

**Purpose**

Outputs warning messages to the console with Lilia branding and yellow color formatting

**When Called**

When non-critical issues occur that should be brought to attention

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic warning message
lia.warning("Module version mismatch detected")
```
```

---

### lia.validateModuleDependencies

**Purpose**

Outputs warning messages to the console with Lilia branding and yellow color formatting

**When Called**

When non-critical issues occur that should be brought to attention

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic warning message
lia.warning("Module version mismatch detected")
```
```

---

### lia.warning

**Purpose**

Outputs warning messages to the console with Lilia branding and yellow color formatting

**When Called**

When non-critical issues occur that should be brought to attention

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic warning message
lia.warning("Module version mismatch detected")
```
```

---

### lia.reportModuleStatus

**Purpose**

Outputs informational messages to the console with Lilia branding and blue color formatting

**When Called**

When providing general information about framework operations or status updates

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic information message
lia.information("Framework initialized successfully")
```
```

---

### lia.reportFrameworkStatus

**Purpose**

Outputs informational messages to the console with Lilia branding and blue color formatting

**When Called**

When providing general information about framework operations or status updates

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic information message
lia.information("Framework initialized successfully")
```
```

---

### lia.information

**Purpose**

Outputs informational messages to the console with Lilia branding and blue color formatting

**When Called**

When providing general information about framework operations or status updates

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic information message
lia.information("Framework initialized successfully")
```
```

---

### lia.reportModuleLoading

**Purpose**

Outputs bootstrap progress messages to the console with Lilia branding and section-specific formatting

**When Called**

During framework initialization to report progress of different bootstrap phases

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic bootstrap message
lia.bootstrap("Database", "Connection established")
```
```

---

### lia.reportBootstrapProgress

**Purpose**

Outputs bootstrap progress messages to the console with Lilia branding and section-specific formatting

**When Called**

During framework initialization to report progress of different bootstrap phases

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic bootstrap message
lia.bootstrap("Database", "Connection established")
```
```

---

### lia.bootstrap

**Purpose**

Outputs bootstrap progress messages to the console with Lilia branding and section-specific formatting

**When Called**

During framework initialization to report progress of different bootstrap phases

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Display a basic bootstrap message
lia.bootstrap("Database", "Connection established")
```
```

---

### lia.notifyPlayerJoin

**Purpose**

Sends formatted messages to Discord webhook with embed support and automatic fallback handling

**When Called**

When logging important events or sending notifications to Discord channels

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Send a basic Discord message
lia.relaydiscordMessage({
title = "Server Started",
description = "The server has been initialized successfully"
})
```
```

---

### lia.sendServerStatus

**Purpose**

Sends formatted messages to Discord webhook with embed support and automatic fallback handling

**When Called**

When logging important events or sending notifications to Discord channels

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Send a basic Discord message
lia.relaydiscordMessage({
title = "Server Started",
description = "The server has been initialized successfully"
})
```
```

---

### lia.relaydiscordMessage

**Purpose**

Sends formatted messages to Discord webhook with embed support and automatic fallback handling

**When Called**

When logging important events or sending notifications to Discord channels

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Send a basic Discord message
lia.relaydiscordMessage({
title = "Server Started",
description = "The server has been initialized successfully"
})
```
```

---

### lia.safeEntityInclusion

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.loader.includeEntities

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.IncludeFiles

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.stripRealmPrefix

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.HandleEntityInclusion

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.RegisterTool

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.SetupDatabase

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.SetupPersistence

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.BootstrapLilia

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.LocalPlayer

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.GM:Initialize

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

### lia.GM:OnReloaded

**Purpose**

Registers and includes all entity types (entities, weapons, tools, effects) from a specified path

**When Called**

During framework initialization to register all custom entities, weapons, and tools

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Include entities from the default gamemode path
lia.loader.includeEntities("lilia/gamemode/entities")
```
```

---

