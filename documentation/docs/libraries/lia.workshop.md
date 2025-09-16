# Workshop Library

This page documents the functions for working with Steam Workshop content and addon management.

---

## Overview

The workshop library (`lia.workshop`) provides a comprehensive system for managing Steam Workshop content, addon mounting, and content synchronization in the Lilia framework, enabling seamless integration of community-created content and ensuring consistent player experiences across different client configurations. This library handles sophisticated addon management with support for automatic addon discovery, dependency resolution, and version control to ensure all required content is properly installed and up-to-date. The system features advanced server-side addon tracking with support for addon validation, integrity checking, and automatic updates that maintain content consistency across all connected clients. It includes comprehensive client-side mounting with support for dynamic addon loading, conflict resolution, and performance optimization to ensure smooth gameplay even with large addon collections. The library provides robust content synchronization with support for incremental updates, bandwidth optimization, and error recovery to minimize download times and ensure reliable content delivery. Additional features include addon management interfaces for administrators, player notification systems for required content, and integration with the framework's permission system for controlled addon access, making it essential for maintaining content consistency and providing rich, community-driven gameplay experiences that leverage the full potential of the Steam Workshop ecosystem.

---

### AddWorkshop

**Purpose**

Adds a Workshop addon ID to the server's required addons list and notifies about the addition and download process.

**Parameters**

* `id` (*string*): The Workshop addon ID.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add a Workshop addon
local function addWorkshopAddon(id)
    lia.workshop.AddWorkshop(id)
end

-- Use in a function
local function setupRequiredAddons()
    lia.workshop.AddWorkshop("123456789")
    lia.workshop.AddWorkshop("987654321")
    print("Required addons added")
end

-- Add addon with validation
local function addWorkshopAddonSafe(id)
    if not id or id == "" then
        print("Invalid addon ID")
        return
    end
    lia.workshop.AddWorkshop(tostring(id))
    print("Addon " .. id .. " added to required list")
end
```

---

### gather

**Purpose**

Gathers all Workshop addon IDs from various sources including manually added IDs, mounted addons, and module-specified Workshop content.

**Parameters**

*None*

**Returns**

* `ids` (*table*): Table of all addon IDs with their values set to true.

**Realm**

Server.

**Example Usage**

```lua
-- Gather all addon IDs
local function gatherAddonIDs()
    return lia.workshop.gather()
end

-- Use in a function
local function refreshAddonList()
    local ids = lia.workshop.gather()
    print("Found " .. table.Count(ids) .. " addon IDs")
    return ids
end

-- Check if specific addon is in the gathered list
local function isAddonRequired(addonId)
    local ids = lia.workshop.gather()
    return ids[tostring(addonId)] == true
end

-- Get all addon IDs as a list
local function getAllAddonIDs()
    local ids = lia.workshop.gather()
    local idList = {}
    for id, _ in pairs(ids) do
        table.insert(idList, id)
    end
    return idList
end
```

---

### send

**Purpose**

Sends the addon list to a specific player.

**Parameters**

* `ply` (*Player*): The player to send to.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Send addon list to player
local function sendAddonList(ply)
    lia.workshop.send(ply)
end

-- Use in a function
local function syncAddonsWithPlayer(ply)
    lia.workshop.send(ply)
    print("Addon list sent to " .. ply:Name())
end
```

---

### hasContentToDownload

**Purpose**

Checks if there are addons that need to be downloaded.

**Parameters**

*None*

**Returns**

* `hasContent` (*boolean*): True if there are addons to download.

**Realm**

Client.

**Example Usage**

```lua
-- Check if content needs downloading
local function hasContentToDownload()
    return lia.workshop.hasContentToDownload()
end

-- Use in a function
local function checkDownloadStatus()
    if lia.workshop.hasContentToDownload() then
        print("Content needs to be downloaded")
        return true
    else
        print("All content is up to date")
        return false
    end
end
```

---

### mountContent

**Purpose**

Shows a UI to mount Workshop content.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Show mount content UI
local function showMountUI()
    lia.workshop.mountContent()
end

-- Use in a function
local function openWorkshopManager()
    lia.workshop.mountContent()
    print("Workshop manager opened")
end
```