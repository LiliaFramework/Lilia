# Option Library

User-configurable settings management system for the Lilia framework.

---

Overview

The option library provides comprehensive functionality for managing user-configurable settings in the Lilia framework. It handles the creation, storage, retrieval, and persistence of various types of options including boolean toggles, numeric sliders, color pickers, text inputs, and dropdown selections. The library operates on both client and server sides, with automatic persistence to JSON files and optional networking capabilities for server-side options. It includes a complete user interface system for displaying and modifying options through the configuration menu, with support for categories, visibility conditions, and real-time updates. The library ensures that all user preferences are maintained across sessions and provides hooks for modules to react to option changes.

---

### lia.option.add

#### 📋 Purpose
Register a configurable option with defaults, callbacks, and metadata.

#### ⏰ When Called
During initialization to expose settings to the config UI/system.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Option identifier to resolve choices for. |
| `name` | **string** | Display name or localization key. |
| `desc` | **string** | Description or localization key. |
| `default` | **any** | Default value; determines inferred type. |
| `callback` | **function|nil** | function(old, new) invoked on change. |
| `data` | **table** | Extra fields: category, min/max, options, visible, shouldNetwork, isQuick, type, etc. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.option.add("hudScale", "HUD Scale", "Scale HUD elements", 1.0, function(old, new)
        hook.Run("HUDScaleChanged", old, new)
    end, {
        category = "categoryInterface",
        min = 0.5,
        max = 1.5,
        decimals = 2,
        isQuick = true
    })

```

---

### lia.option.getOptions

#### 📋 Purpose
Resolve option choices (static or generated) for dropdowns.

#### ⏰ When Called
By the config UI before rendering a Table option.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** |  |

#### ↩️ Returns
* table
Array/map of options.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local list = lia.option.getOptions("weaponSelectorPosition")
    for _, opt in pairs(list) do print("Choice:", opt) end

```

---

### lia.option.set

#### 📋 Purpose
Set an option value, run callbacks/hooks, persist and optionally network it.

#### ⏰ When Called
From UI interactions or programmatic changes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** |  |
| `value` | **any** |  |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.option.set("BarsAlwaysVisible", true)

```

---

### lia.option.get

#### 📋 Purpose
Retrieve an option value with fallback to default or provided default.

#### ⏰ When Called
Anywhere an option influences behavior or UI.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** |  |
| `default` | **any** |  |

#### ↩️ Returns
* any

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local showTime = lia.option.get("ChatShowTime", false)

```

---

### lia.option.save

#### 📋 Purpose
Persist option values to disk (data/lilia/options.json).

#### ⏰ When Called
After option changes; auto-called by lia.option.set.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.option.save()

```

---

### lia.option.load

#### 📋 Purpose
Load option values from disk or initialize defaults when missing.

#### ⏰ When Called
On client init or config menu load.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("Initialize", "LoadLiliaOptions", lia.option.load)

```

---

