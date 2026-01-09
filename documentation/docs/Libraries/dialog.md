# Dialog Library

Comprehensive NPC dialog management system for the Lilia framework.

---

Overview

The dialog library provides comprehensive functionality for managing NPC conversations and dialog systems in the Lilia framework. It handles NPC registration, conversation filtering, client synchronization, and provides both server-side data management and client-side UI interactions. The library supports complex conversation trees with conditional options, server-only callbacks, and dynamic NPC customization. It includes automatic data sanitization, conversation filtering based on player permissions, and seamless integration with the framework's networking system. The library ensures secure and efficient dialog handling across both server and client realms.

---

### lia.dialog.isTableEqual

#### 📋 Purpose
Performs a deep comparison of two tables to detect changes, avoiding infinite loops from circular references.

#### ⏰ When Called
Before syncing dialog data to clients to prevent unnecessary network traffic.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tbl1` | **table** | First table to compare. |
| `tbl2` | **table** | Second table to compare. |
| `checked` | **table|nil** | Internal table used to track visited references and prevent cycles. |

#### ↩️ Returns
* boolean
True if tables are identical, false otherwise.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if not lia.dialog.isTableEqual(oldData, newData) then
        lia.dialog.syncDialogs()
    end

```

---

### lia.dialog.registerConfiguration

#### 📋 Purpose
Registers or updates an NPC configuration entry for customization panels.

#### ⏰ When Called
During gamemode initialization to define available NPC configuration options.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Unique identifier for the configuration. |
| `data` | **table** | Configuration data containing fields like name, order, shouldShow, onOpen, onApply, etc. |

#### ↩️ Returns
* table
The stored configuration table.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.dialog.registerConfiguration("shop_inventory", {
        name = "Shop Inventory",
        order = 5,
        shouldShow = function(ply) return ply:IsAdmin() end,
        onOpen = function(npc) OpenShopConfig(npc) end
    })

```

---

### lia.dialog.getConfiguration

#### 📋 Purpose
Retrieves a registered configuration entry by its unique identifier.

#### ⏰ When Called
When accessing configuration menus or checking configuration availability.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique identifier of the configuration to retrieve. |

#### ↩️ Returns
* table|nil
The configuration table if found, nil otherwise.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local cfg = lia.dialog.getConfiguration("appearance")
    if cfg and cfg.shouldShow(LocalPlayer()) then
        cfg.onOpen(npc)
    end

```

---

### lia.dialog.getNPCData

#### 📋 Purpose
Retrieves sanitized NPC dialog data by unique identifier.

#### ⏰ When Called
Server-side when preparing dialog data for clients or internal operations.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npcID` | **string** | The unique identifier of the NPC dialog. |

#### ↩️ Returns
* table|nil
Sanitized NPC dialog data, or nil if not found.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local npcData = lia.dialog.getNPCData("tutorial_guide")
    if npcData then PrintTable(npcData) end

```

---

### lia.dialog.getOriginalNPCData

#### 📋 Purpose
Returns the original unsanitized NPC dialog definition including server-only callbacks.

#### ⏰ When Called
Server-side when re-filtering conversation options per-player or rebuilding client payloads.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npcID` | **string** | The unique identifier of the NPC dialog. |

#### ↩️ Returns
* table|nil
Original NPC dialog data, or nil if not found.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local raw = lia.dialog.getOriginalNPCData("tutorial_guide")
    if raw and raw.Conversation then
        -- inspect server-only callbacks before sanitizing
    end

```

---

### lia.dialog.syncToClients

#### 📋 Purpose
Sends sanitized dialog data to a specific client or all connected players.

#### ⏰ When Called
After dialog registration, changes, or on-demand admin refreshes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | Specific player to sync to, or nil to broadcast to all players. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    concommand.Add("lia_dialog_resync", function(admin)
        if IsValid(admin) and admin:IsAdmin() then
            lia.dialog.syncToClients()
            admin:notifyLocalized("dialogResynced")
        end
    end)

```

---

### lia.dialog.syncDialogs

#### 📋 Purpose
Broadcasts all dialog data to all connected clients.

#### ⏰ When Called
After bulk changes, during scheduled refreshes, or maintenance operations.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    timer.Create("ResyncDialogsHourly", 3600, 0, lia.dialog.syncDialogs)

```

---

### lia.dialog.registerNPC

#### 📋 Purpose
Registers an NPC dialog definition and optionally synchronizes changes to clients.

#### ⏰ When Called
During gamemode initialization or when hot-loading NPC dialog data.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Unique identifier for the NPC dialog. |
| `data` | **table** | Complete NPC dialog definition including Conversation, PrintName, Greeting, etc. |
| `shouldSync` | **boolean|nil** | Whether to sync changes to clients immediately (defaults to true). |

#### ↩️ Returns
* boolean
True if successfully registered, false otherwise.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.dialog.registerNPC("quests_barkeep", {
        PrintName = "Barkeep",
        Greeting = "What'll it be?",
        Conversation = {
            ["Got any work?"] = {
                Response = "A few rats in the cellar. Interested?",
                options = {
                    ["I'm in."] = {serverOnly = true, Callback = function(client) StartQuest(client, "cellar_rats") end},
                    ["No thanks."] = {Response = "Suit yourself."}
                }
            }
        }
    })

```

---

### lia.dialog.openDialog

#### 📋 Purpose
Opens an NPC dialog for a player, filtering conversation options based on player permissions.

#### ⏰ When Called
When a player interacts with an NPC entity.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player to open the dialog for. |
| `npc` | **Entity** | The NPC entity being interacted with. |
| `npcID` | **string** | The unique identifier of the NPC dialog type. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    hook.Add("PlayerUse", "HandleDialogNPCs", function(ply, ent)
        if ent:GetClass() == "lia_npc" then
            lia.dialog.openDialog(ply, ent, ent.uniqueID or "tutorial_guide")
            return false
        end
    end)

```

---

### lia.dialog.getNPCData

#### 📋 Purpose
Retrieves sanitized NPC dialog data on the client.

#### ⏰ When Called
When client UI needs to render or access dialog information.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npcID` | **string** | The unique identifier of the NPC dialog. |

#### ↩️ Returns
* table|nil
Sanitized NPC dialog data, or nil if not found.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local data = lia.dialog.getNPCData("tutorial_guide")
    if data then print("Greeting:", data.Greeting) end

```

---

### lia.dialog.submitConfiguration

#### 📋 Purpose
Sends NPC customization data to the server for processing.

#### ⏰ When Called
When submitting changes from NPC customization UI.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `configID` | **string** | The configuration identifier. |
| `npc` | **Entity** | The NPC entity being customized. |
| `payload` | **table** | The customization data payload. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.dialog.submitConfiguration("appearance", npc, {model = "models/barney.mdl"})

```

---

### lia.dialog.openCustomizationUI

#### 📋 Purpose
Opens a comprehensive UI for customizing NPC appearance, animations, and dialog types.

#### ⏰ When Called
From properties menu or configuration picker interfaces.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npc` | **Entity** | The NPC entity to customize. |
| `configID` | **string|nil** | Configuration identifier, defaults to "appearance". |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    properties.Add("CustomNPCConfig", {
        Filter = function(_, ent) return ent:GetClass() == "lia_npc" end,
        Action = function(_, ent) lia.dialog.openCustomizationUI(ent, "appearance") end
    })

```

---

### lia.dialog.getAvailableConfigurations

#### 📋 Purpose
Returns available NPC configurations for a player, sorted by order and name.

#### ⏰ When Called
Before displaying configuration picker UI to filter accessible options.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player to check permissions for. |
| `npc` | **Entity|nil** | The NPC entity being configured. |
| `npcID` | **string|nil** | The NPC's unique identifier. |

#### ↩️ Returns
* table
Array of accessible configuration tables.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local configs = lia.dialog.getAvailableConfigurations(LocalPlayer(), npc, npc.uniqueID)
    for _, cfg in ipairs(configs) do print("Config:", cfg.id) end

```

---

### lia.dialog.openConfigurationPicker

#### 📋 Purpose
Opens the NPC configuration picker UI, prioritizing appearance configuration.

#### ⏰ When Called
When a player selects "Configure NPC" from the properties menu.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npc` | **Entity** | The NPC entity to configure. |
| `npcID` | **string|nil** | The NPC's unique identifier. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.dialog.openConfigurationPicker(ent, ent.uniqueID)

```

---

