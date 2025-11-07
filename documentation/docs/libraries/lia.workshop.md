# Workshop Library

Steam Workshop addon downloading, mounting, and management system for the Lilia framework.

---

Overview

The workshop library provides comprehensive functionality for managing Steam Workshop addons in the Lilia framework. It handles automatic downloading, mounting, and management of workshop content required by the gamemode and its modules. The library operates on both server and client sides, with the server gathering workshop IDs from modules and mounted addons, while the client handles downloading and mounting of required content. It includes user interface elements for download progress tracking and addon information display. The library ensures that all required workshop content is available before gameplay begins.

---

### lia.workshop.addWorkshop

#### 📋 Purpose
Adds a workshop addon ID to the server's required workshop content list

#### ⏰ When Called
Called when modules or addons need specific workshop content

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string/number** | The Steam Workshop ID of the addon to add |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add a single workshop addon
    lia.workshop.addWorkshop("1234567890")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add workshop addon from module configuration
    local workshopId = module.WorkshopContent
    if workshopId then
        lia.workshop.addWorkshop(workshopId)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Add multiple workshop addons with validation
    local workshopIds = {"1234567890", "0987654321", "1122334455"}
    for _, id in ipairs(workshopIds) do
        if id and id ~= "" then
            lia.workshop.addWorkshop(id)
        end
    end

```

---

### lia.workshop.gather

#### 📋 Purpose
Gathers all workshop IDs from mounted addons and module configurations

#### ⏰ When Called
Called during module initialization to collect all required workshop content

#### ↩️ Returns
* table - Table containing all workshop IDs that need to be downloaded

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Gather workshop IDs
    local workshopIds = lia.workshop.gather()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Gather and validate workshop IDs
    local workshopIds = lia.workshop.gather()
    local count = table.Count(workshopIds)
    print("Found " .. count .. " workshop addons")

```

#### ⚙️ High Complexity
```lua
    -- High: Gather workshop IDs and send to specific players
    local workshopIds = lia.workshop.gather()
    for _, ply in player.Iterator() do
        if ply:IsAdmin() then
            net.Start("liaWorkshopDownloaderStart")
            net.WriteTable(workshopIds)
            net.Send(ply)
        end
    end

```

---

### lia.workshop.send

#### 📋 Purpose
Sends the cached workshop IDs to a specific player to initiate download

#### ⏰ When Called
Called when a player requests workshop content or during initial spawn

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player to send workshop IDs to |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Send workshop IDs to a player
    lia.workshop.send(player.GetByID(1))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Send workshop IDs to admin players only
    for _, ply in player.Iterator() do
        if ply:IsAdmin() then
            lia.workshop.send(ply)
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Send workshop IDs with validation and logging
    local function sendToPlayer(ply)
        if IsValid(ply) and ply:IsConnected() then
            lia.workshop.send(ply)
            print("Sent workshop IDs to " .. ply:Name())
        end
    end
    hook.Add("PlayerInitialSpawn", "CustomWorkshopSend", function(ply)
        timer.Simple(5, function()
            sendToPlayer(ply)
        end)
    end)

```

---

### lia.workshop.hasContentToDownload

#### 📋 Purpose
Checks if there are any workshop addons that need to be downloaded

#### ⏰ When Called
Called to determine if the client needs to download workshop content

#### ↩️ Returns
* boolean - True if content needs to be downloaded, false otherwise

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check if downloads are needed
    if lia.workshop.hasContentToDownload() then
        print("Workshop content needs to be downloaded")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check and show notification
    if lia.workshop.hasContentToDownload() then
        notification.AddLegacy("Workshop content available for download", NOTIFY_GENERIC, 5)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Check downloads and create custom UI
    local function checkDownloads()
        if lia.workshop.hasContentToDownload() then
            local frame = vgui.Create("DFrame")
            frame:SetTitle("Workshop Downloads Available")
            frame:SetSize(400, 200)
            frame:Center()
            frame:MakePopup()
            local btn = vgui.Create("DButton", frame)
            btn:SetText("Download Now")
            btn:Dock(BOTTOM)
            btn.DoClick = function()
                lia.workshop.mountContent()
                frame:Close()
            end
        end
    end
    hook.Add("OnEntityCreated", "CheckWorkshopDownloads", function(ent)
        if ent == LocalPlayer() then
            timer.Simple(1, checkDownloads)
        end
    end)

```

---

### lia.workshop.mountContent

#### 📋 Purpose
Initiates the mounting process for required workshop content with user confirmation

#### ⏰ When Called
Called when the client needs to download and mount workshop addons

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Mount workshop content
    lia.workshop.mountContent()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Mount content with custom callback
    lia.workshop.mountContent()
    hook.Add("Think", "CheckMountComplete", function()
        if not lia.workshop.hasContentToDownload() then
            print("All workshop content mounted successfully")
            hook.Remove("Think", "CheckMountComplete")
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Mount content with progress tracking and custom UI
    local function mountWithProgress()
        local needed = {}
        local ids = lia.workshop.serverIds or {}
        for id in pairs(ids) do
            if id ~= "3527535922" and not mounted(id) and not mountLocal(id) then
                needed[#needed + 1] = id
            end
        end
        if #needed > 0 then
            local frame = vgui.Create("DFrame")
            frame:SetTitle("Workshop Content Download")
            frame:SetSize(500, 300)
            frame:Center()
            frame:MakePopup()
            local progress = vgui.Create("DProgress", frame)
            progress:Dock(TOP)
            progress:SetHeight(30)
            local function updateProgress(current, total)
                progress:SetFraction(current / total)
                progress:SetText(current .. "/" .. total)
            end
            lia.workshop.mountContent()
        end
    end
    hook.Add("PlayerInitialSpawn", "MountWorkshopContent", function(ply)
        if ply == LocalPlayer() then
            timer.Simple(3, mountWithProgress)
        end
    end)

```

---

