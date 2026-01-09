# Keybind Library

Keyboard binding registration, storage, and execution system for the Lilia framework.

---

Overview

The keybind library provides comprehensive functionality for managing keyboard bindings in the Lilia framework. It handles registration, storage, and execution of custom keybinds that can be triggered by players. The library supports both client-side and server-side keybind execution, with automatic networking for server-only keybinds. It includes persistent storage of keybind configurations, user interface for keybind management, and validation to prevent key conflicts. The library operates on both client and server sides, with the client handling input detection and UI, while the server processes server-only keybind actions. It ensures proper key mapping, callback execution, and provides a complete keybind management system for the gamemode.

---

### lia.keybind.add

#### 📋 Purpose
Register a keybind action with callbacks and optional metadata.

#### ⏰ When Called
During initialization to expose actions to the keybind system/UI.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `k` | **string|number** | Key code or key name (or actionName when using table config form). |
| `d` | **string|table** | Action name or config table when first arg is action name. |
| `desc` | **string|nil** | Description when using legacy signature. |
| `cb` | **table|nil** | Callback table {onPress, onRelease, shouldRun, serverOnly}. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Table-based registration with shouldRun and serverOnly.
    lia.keybind.add("toggleMap", {
        keyBind = KEY_M,
        desc = "Open the world map",
        serverOnly = false,
        shouldRun = function(client) return client:Alive() end,
        onPress = function(client)
            if IsValid(client.mapPanel) then
                client.mapPanel:Close()
                client.mapPanel = nil
            else
                client.mapPanel = vgui.Create("liaWorldMap")
            end
        end
    })

```

---

### lia.keybind.get

#### 📋 Purpose
Get the key code assigned to an action, with default fallback.

#### ⏰ When Called
When populating keybind UI or triggering actions manually.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `a` | **string** | Action name. |
| `df` | **number|nil** | Default key code if not set. |

#### ↩️ Returns
* number|nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local key = lia.keybind.get("openInventory", KEY_I)
    print("Inventory key is:", input.GetKeyName(key))

```

---

### lia.keybind.save

#### 📋 Purpose
Persist current keybind overrides to disk.

#### ⏰ When Called
After users change keybinds in the config UI.

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.keybind.save()

```

---

### lia.keybind.load

#### 📋 Purpose
Load keybind overrides from disk, falling back to defaults if missing.

#### ⏰ When Called
On client init/config load; rebuilds reverse lookup table for keys.

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("Initialize", "LoadLiliaKeybinds", lia.keybind.load)

```

---

