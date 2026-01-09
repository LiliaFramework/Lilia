# Workshop Library

Steam Workshop addon downloading, mounting, and management system for the Lilia framework.

---

Overview

The workshop library provides comprehensive functionality for managing Steam Workshop addons in the Lilia framework. It handles automatic downloading, mounting, and management of workshop content required by the gamemode and its modules. The library operates on both server and client sides, with the server gathering workshop IDs from modules and mounted addons, while the client handles downloading and mounting of required content. It includes user interface elements for download progress tracking and addon information display. The library ensures that all required workshop content is available before gameplay begins.

---

### lia.workshop.addWorkshop

#### 📋 Purpose
Queue a workshop addon for download and notify the admin UI.

#### ⏰ When Called
During module initialization or whenever a new workshop dependency is registered.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string|number** | Workshop addon ID to download (will be converted to string). |

#### ↩️ Returns
* nil
Nothing.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Register a workshop addon dependency
    lia.workshop.addWorkshop("3527535922")
    lia.workshop.addWorkshop(1234567890) -- Also accepts numbers

```

---

### lia.workshop.gather

#### 📋 Purpose
Gather every known workshop ID from mounted addons and registered modules.

#### ⏰ When Called
Once modules are initialized to cache which workshop addons are needed.

#### ↩️ Returns
* table
Set of workshop IDs that should be downloaded/mounted.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Gather all workshop IDs that need to be downloaded
    local workshopIds = lia.workshop.gather()
    lia.workshop.cache = workshopIds

```

---

### lia.workshop.send

#### 📋 Purpose
Send the cached workshop IDs to a player so the client knows what to download.

#### ⏰ When Called
Automatically when a player initially spawns.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player entity to notify. |

#### ↩️ Returns
* nil
Nothing.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Send workshop cache to a specific player
    lia.workshop.send(player.GetByID(1))

```

---

### lia.workshop.hasContentToDownload

#### 📋 Purpose
Determine whether there is any extra workshop content the client needs to download.

#### ⏰ When Called
Before prompting the player to download server workshop addons.

#### ↩️ Returns
* boolean
true if the client is missing workshop content that needs to be fetched.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Check if client needs to download workshop content
    if lia.workshop.hasContentToDownload() then
        -- Show download prompt to player
    end

```

---

### lia.workshop.mountContent

#### 📋 Purpose
Initiate mounting (downloading) of server-required workshop addons.

#### ⏰ When Called
When the player explicitly asks to install missing workshop content from the info panel.

#### ↩️ Returns
* nil
Nothing.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Start downloading missing workshop content
    lia.workshop.mountContent()

```

---

