# Workshop Library

This page documents the functions for working with Steam Workshop content and addon management.

---

## Overview

The workshop library (`lia.workshop`) provides a comprehensive system for managing Steam Workshop content, addon mounting, and content synchronization in the Lilia framework, enabling seamless integration of community-created content and ensuring consistent player experiences across different client configurations. This library handles sophisticated addon management with support for automatic addon discovery, dependency resolution, and version control to ensure all required content is properly installed and up-to-date. The system features advanced server-side addon tracking with support for addon validation, integrity checking, and automatic updates that maintain content consistency across all connected clients. It includes comprehensive client-side mounting with support for dynamic addon loading, conflict resolution, and performance optimization to ensure smooth gameplay even with large addon collections. The library provides robust content synchronization with support for incremental updates, bandwidth optimization, and error recovery to minimize download times and ensure reliable content delivery. Additional features include addon management interfaces for administrators, player notification systems for required content, and integration with the framework's permission system for controlled addon access, making it essential for maintaining content consistency and providing rich, community-driven gameplay experiences that leverage the full potential of the Steam Workshop ecosystem.

---

### lia.workshop.Add

**Purpose**

Adds a Workshop addon ID to the server's required addons list.

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
    lia.workshop.Add(id)
end

-- Use in a function
local function setupRequiredAddons()
    lia.workshop.Add("123456789")
    lia.workshop.Add("987654321")
    print("Required addons added")
end
```

---

### lia.workshop.Gather

**Purpose**

Gathers all Workshop addon IDs from various sources.

**Parameters**

*None*

**Returns**

* `ids` (*table*): Table of all addon IDs.

**Realm**

Server.

**Example Usage**

```lua
-- Gather all addon IDs
local function gatherAddonIDs()
    return lia.workshop.Gather()
end

-- Use in a function
local function refreshAddonList()
    local ids = lia.workshop.Gather()
    print("Found " .. table.Count(ids) .. " addon IDs")
    return ids
end
```

---

### lia.workshop.Send

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
    lia.workshop.Send(ply)
end

-- Use in a function
local function syncAddonsWithPlayer(ply)
    lia.workshop.Send(ply)
    print("Addon list sent to " .. ply:Name())
end
```

---

### lia.workshop.IsMounted

**Purpose**

Checks if a Workshop addon is mounted on the client.

**Parameters**

* `id` (*string*): The Workshop addon ID.

**Returns**

* `isMounted` (*boolean*): True if the addon is mounted.

**Realm**

Client.

**Example Usage**

```lua
-- Check if addon is mounted
local function isAddonMounted(id)
    return lia.workshop.IsMounted(id)
end

-- Use in a function
local function checkAddonStatus(id)
    if lia.workshop.IsMounted(id) then
        print("Addon " .. id .. " is mounted")
        return true
    else
        print("Addon " .. id .. " is not mounted")
        return false
    end
end
```

---

### lia.workshop.Enqueue

**Purpose**

Adds a Workshop addon to the download queue.

**Parameters**

* `id` (*string*): The Workshop addon ID.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Queue addon for download
local function queueAddon(id)
    lia.workshop.Enqueue(id)
end

-- Use in a function
local function downloadAddon(id)
    lia.workshop.Enqueue(id)
    print("Addon " .. id .. " queued for download")
end
```

---

### lia.workshop.ProcessQueue

**Purpose**

Processes the download queue for Workshop addons.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Process download queue
local function processQueue()
    lia.workshop.ProcessQueue()
end

-- Use in a function
local function startDownloadProcess()
    lia.workshop.ProcessQueue()
    print("Download process started")
end
```

---

### lia.workshop.hasContentToDownload

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

### lia.workshop.mountContent

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

---

### lia.workshop.ids

**Purpose**

Stores server-side addon IDs.

**Parameters**

*None*

**Returns**

* `ids` (*table*): Table of addon IDs.

**Realm**

Server.

**Example Usage**

```lua
-- Get server addon IDs
local function getServerAddonIDs()
    return lia.workshop.ids
end

-- Use in a function
local function listServerAddons()
    for id, _ in pairs(lia.workshop.ids) do
        print("Server addon: " .. id)
    end
end
```

---

### lia.workshop.known

**Purpose**

Stores known addon IDs.

**Parameters**

*None*

**Returns**

* `known` (*table*): Table of known addon IDs.

**Realm**

Server.

**Example Usage**

```lua
-- Get known addon IDs
local function getKnownAddonIDs()
    return lia.workshop.known
end

-- Use in a function
local function listKnownAddons()
    for id, _ in pairs(lia.workshop.known) do
        print("Known addon: " .. id)
    end
end
```

---

### lia.workshop.cache

**Purpose**

Stores cached addon data.

**Parameters**

*None*

**Returns**

* `cache` (*table*): Table of cached addon data.

**Realm**

Server.

**Example Usage**

```lua
-- Get cached addon data
local function getCachedAddonData()
    return lia.workshop.cache
end

-- Use in a function
local function listCachedAddons()
    for id, _ in pairs(lia.workshop.cache) do
        print("Cached addon: " .. id)
    end
end
```

---

### lia.workshop.serverIds

**Purpose**

Stores client-side server addon IDs.

**Parameters**

*None*

**Returns**

* `serverIds` (*table*): Table of server addon IDs.

**Realm**

Client.

**Example Usage**

```lua
-- Get server addon IDs on client
local function getServerAddonIDs()
    return lia.workshop.serverIds
end

-- Use in a function
local function listServerAddons()
    for id, _ in pairs(lia.workshop.serverIds) do
        print("Server addon: " .. id)
    end
end
```

---

### lia.workshop.mounted

**Purpose**

Stores mounted addon status.

**Parameters**

*None*

**Returns**

* `mounted` (*table*): Table of mounted addon status.

**Realm**

Client.

**Example Usage**

```lua
-- Get mounted addon status
local function getMountedAddons()
    return lia.workshop.mounted
end

-- Use in a function
local function listMountedAddons()
    for id, mounted in pairs(lia.workshop.mounted) do
        print("Addon " .. id .. ": " .. (mounted and "mounted" or "not mounted"))
    end
end
```

---

### lia.workshop.mountCounts

**Purpose**

Stores file counts for mounted addons.

**Parameters**

*None*

**Returns**

* `mountCounts` (*table*): Table of file counts.

**Realm**

Client.

**Example Usage**

```lua
-- Get mount file counts
local function getMountCounts()
    return lia.workshop.mountCounts
end

-- Use in a function
local function listMountCounts()
    for id, count in pairs(lia.workshop.mountCounts) do
        print("Addon " .. id .. ": " .. count .. " files")
    end
end
```

---

### lia.workshop.queue

**Purpose**

Stores the download queue.

**Parameters**

*None*

**Returns**

* `queue` (*table*): Table of queued addon IDs.

**Realm**

Client.

**Example Usage**

```lua
-- Get download queue
local function getDownloadQueue()
    return lia.workshop.queue
end

-- Use in a function
local function listDownloadQueue()
    for i, id in ipairs(lia.workshop.queue) do
        print("Queue " .. i .. ": " .. id)
    end
end
```

---

### lia.workshop.active

**Purpose**

Stores the active download status.

**Parameters**

*None*

**Returns**

* `active` (*boolean*): True if downloading is active.

**Realm**

Client.

**Example Usage**

```lua
-- Check if download is active
local function isDownloadActive()
    return lia.workshop.active
end

-- Use in a function
local function checkDownloadStatus()
    if lia.workshop.active then
        print("Download is currently active")
    else
        print("Download is not active")
    end
end
```