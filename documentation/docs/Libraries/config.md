# Configuration Library

Comprehensive user-configurable settings management system for the Lilia framework.

---

Overview

The configuration library provides comprehensive functionality for managing user-configurable settings in the Lilia framework. It handles the creation, storage, retrieval, and persistence of various types of options including boolean toggles, numeric sliders, color pickers, text inputs, and dropdown selections. The library operates on both client and server sides, with automatic persistence to JSON files and optional networking capabilities for server-side options. It includes a complete user interface system for displaying and modifying options through the configuration menu, with support for categories, visibility conditions, and real-time updates. The library ensures that all user preferences are maintained across sessions and provides hooks for modules to react to option changes.

---

### lia.config.add

#### 📋 Purpose
Register a config entry with defaults, UI metadata, and optional callback.

#### ⏰ When Called
During schema/module initialization to expose server-stored configuration.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Unique identifier for the config entry. |
| `name` | **string** | Display text or localization key for UI. |
| `value` | **any** | Default value; type inferred when data.type is omitted. |
| `callback` | **function|nil** | Invoked server-side as callback(oldValue, newValue) after set(). |
| `data` | **table** | Fields such as type, desc, category, options/optionsFunc, noNetworking, etc. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.config.add("MaxThirdPersonDistance", "maxThirdPersonDistance", 100, function(old, new)
        lia.option.set("thirdPersonDistance", math.min(lia.option.get("thirdPersonDistance", new), new))
    end, {category = "categoryGameplay", type = "Int", min = 10, max = 200})

```

---

### lia.config.getOptions

#### 📋 Purpose
Resolve a config entry's selectable options, static list or generated.

#### ⏰ When Called
Before rendering dropdown-type configs or validating submitted values.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Config key to resolve options for. |

#### ↩️ Returns
* table
Options array or key/value table; empty when unavailable.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local opts = lia.config.getOptions("Theme")

```

---

### lia.config.setDefault

#### 📋 Purpose
Override the default value for an already registered config entry.

#### ⏰ When Called
During migrations, schema overrides, or backward-compatibility fixes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Config key to override. |
| `value` | **any** | New default value. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.config.setDefault("StartingMoney", 300)

```

---

### lia.config.forceSet

#### 📋 Purpose
Force-set a config value and fire update hooks without networking.

#### ⏰ When Called
Runtime adjustments (admin tools/commands) or hot reload scenarios.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Config key to change. |
| `value` | **any** | Value to assign. |
| `noSave` | **boolean|nil** | When true, skip persisting to disk. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.config.forceSet("MaxCharacters", 10, false)

```

---

### lia.config.set

#### 📋 Purpose
Set a config value, fire update hooks, run server callbacks, network to clients, and persist.

#### ⏰ When Called
Through admin tools/commands or internal code updating configuration.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Config key to change. |
| `value` | **any** | Value to assign and broadcast. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.config.set("RunSpeed", 420)

```

---

### lia.config.get

#### 📋 Purpose
Retrieve a config value with fallback to its stored default or a provided default.

#### ⏰ When Called
Anywhere configuration influences gameplay or UI logic.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Config key to read. |
| `default` | **any** | Optional fallback when no stored value or default exists. |

#### ↩️ Returns
* any
Stored value, default value, or supplied fallback.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local walkSpeed = lia.config.get("WalkSpeed", 200)

```

---

### lia.config.load

#### 📋 Purpose
Load config values from the database (server) or request them from the server (client).

#### ⏰ When Called
On initialization to hydrate lia.config.stored after database connectivity.

#### ↩️ Returns
* nil
Server path is asynchronous; client path simply sends a request.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("DatabaseConnected", "LoadLiliaConfig", lia.config.load)

```

---

### lia.config.getChangedValues

#### 📋 Purpose
Collect config entries whose values differ from last synced values or their defaults.

#### ⏰ When Called
Prior to sending incremental config updates to clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `includeDefaults` | **boolean|nil** | When true, compare against defaults instead of last synced values. |

#### ↩️ Returns
* table
key → value for configs that changed.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local changed = lia.config.getChangedValues()
    if next(changed) then lia.config.send() end

```

---

### lia.config.hasChanges

#### 📋 Purpose
Check whether any config values differ from the last synced snapshot.

#### ⏰ When Called
To determine if a resync to clients is required.

#### ↩️ Returns
* boolean
True when at least one config value has changed.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    if lia.config.hasChanges() then lia.config.send() end

```

---

### lia.config.send

#### 📋 Purpose
Send config values to one player (full payload) or broadcast only changed values.

#### ⏰ When Called
After config changes or when a player joins the server.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | Target player for full sync; nil broadcasts only changed values. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    hook.Add("PlayerInitialSpawn", "SyncConfig", function(ply) lia.config.send(ply) end)
    lia.config.send() -- broadcast diffs

```

---

### lia.config.save

#### 📋 Purpose
Persist all config values to the database.

#### ⏰ When Called
After changes, on shutdown, or during scheduled saves.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.config.save()

```

---

### lia.config.reset

#### 📋 Purpose
Reset all config values to defaults, then save and sync to clients.

#### ⏰ When Called
During admin resets or troubleshooting.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.config.reset()

```

---

