# Workshop Library

This page documents helpers for managing Steam Workshop addons.

---

## Overview

The workshop library tracks required Workshop addon IDs and mounts them on clients to ensure players have the assets needed for the gamemode. When the **`AutoDownloadWorkshop`** configuration is enabled, connecting players automatically receive the cached list of IDs so missing content can be downloaded.

Workshop IDs added via `lia.workshop.AddWorkshop` are stored in `lia.workshop.ids`. After all modules are initialised, `lia.workshop.cache` holds the combined set that clients will download. For convenience, `resource.AddWorkshop` is aliased to `lia.workshop.AddWorkshop`.

Clients store the list received from the server in `lia.workshop.serverIds`, which drives the in-game display and download queue.

The server sends this list a short time after each player spawns. When the client opts to download the addons—either automatically or via the prompt—it requests them and `lia.workshop.send` transmits the IDs. Clients may run `workshop_force_redownload` in the console to forcibly re-download all configured addons. Lilia's own content (Workshop ID `3527535922`) is registered automatically and is ignored when checking for missing downloads.

---

### lia.workshop.AddWorkshop

**Purpose**

Registers a Steam Workshop addon ID so clients will download it. The `id` is internally coerced to a string. If the ID was not previously registered, a bootstrap `workshopAdded` message is shown once. A `workshopDownloading` message is always displayed to indicate the download has started.

**Parameters**

* `id` (*string | number*): Workshop item ID.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Add a custom model pack
lia.workshop.AddWorkshop("1234567890")
```

---

### lia.workshop.gather

**Purpose**

Collects Workshop IDs from every registered source, including mounted addons and each module's `WorkshopContent` field. Newly discovered IDs are added to `lia.workshop.known` and trigger a one-time `workshopAdded` notification so duplicates are avoided.

**Parameters**

* *None*

**Realm**

`Server`

**Returns**

* *table*: Set of Workshop IDs pending download.

**Example Usage**

```lua
local ids = lia.workshop.gather()
for id in pairs(ids) do
    print("Needs addon:", id)
end
```

---

### lia.workshop.send

**Purpose**

Sends the cached Workshop-ID list to a player using the `WorkshopDownloader_Start` net message.

**Parameters**

* `ply` (*Player*): Target player.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
hook.Add("PlayerInitialSpawn", "SendWorkshopList", function(ply)
    lia.workshop.send(ply)
end)
```

---


### lia.workshop.hasContentToDownload

**Purpose**

Checks whether the client is missing any Workshop content required by the server. The Lilia base package (`3527535922`) is ignored. Mounted addons and cached `.gma` files in the data folder are considered before deciding content is missing.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* `boolean`: `true` if there is content to download, `false` otherwise.

**Example Usage**

```lua
if lia.workshop.hasContentToDownload() then
    print("You need to download additional Workshop content!")
end
```

---

### lia.workshop.mountContent

**Purpose**

Prompts the user to download and mount all missing Workshop content. IDs already mounted or cached locally are skipped; the built-in Lilia ID is ignored. If no addons are missing, a `workshopAllInstalled` message is shown. Otherwise, `steamworks.FileInfo` gathers total size and a confirmation dialog appears. On acceptance, the client requests downloads via `WorkshopDownloader_Request`, mounting each addon with a short delay (3 seconds by default).

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Mount all missing Workshop content when a button is pressed
concommand.Add("lia_mount_workshop", function()
    lia.workshop.mountContent()
end)
```

---
