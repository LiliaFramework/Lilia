# Keybind Library

This page describes functions for registering and managing custom keybinds in the Lilia framework.

---

## Overview

The keybind library runs **client-side** and stores user-defined key bindings in `lia.keybind.stored`. Bindings are saved to `data/lilia/keybinds/<gamemode>/<server-ip>.json` (using the server IP with dots replaced by underscores) and loaded automatically on start. If a legacy `.txt` file exists it is migrated to the new JSON format.

Keybinds are triggered through `PlayerButtonDown` and `PlayerButtonUp` hooks, and a "Keybinds" page is added to the configuration menu via `PopulateConfigurationButtons`. Editing in this menu can be disabled with the `AllowKeybindEditing` configuration option.

Each entry in `lia.keybind.stored` contains:

* `default` (*number*) – key code assigned on registration
* `value` (*number*) – current key code (initially the default)
* `callback` (*function | nil*) – invoked when the key is pressed
* `release` (*function | nil*) – invoked when the key is released
* `shouldRun` (*function | nil*) – optional validation function that must return true for the keybind to execute
* `serverOnly` (*boolean | nil*) – if true, the callback runs server-side via networking

The library also maintains reverse mappings from key codes to action identifiers for efficient lookup.

---

## Functions

### lia.keybind.add

**Purpose**

Register a keybind action with callbacks and optional validation. The default key is stored and a reverse mapping from key code to action is created.

**Parameters**

* `k` (*string | number*): Key identifier. A string is matched case-insensitively against the internal key map. Invalid keys abort registration.
* `d` (*string*): Action identifier (will be localized using `L()` function).
* `cb` (*table*): Callback table containing:
  * `onPress` (*function*): Called when the key is pressed. Receives the player as its only argument.
  * `onRelease` (*function | nil*): Called when the key is released. Receives the player as its only argument. Optional.
  * `shouldRun` (*function | nil*): Validation function that must return true for the keybind to execute. Optional.
  * `serverOnly` (*boolean | nil*): If true, the callback runs server-side via networking. Optional.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Bind F1 to open the inventory while held
local inv
lia.keybind.add(KEY_F1, "Open Inventory", {
    shouldRun = function(client)
        -- Check if player can perform this action
        return client:IsValid() and not client:IsDead()
    end,
    
    onPress = function(client)
        inv = vgui.Create("liaMenu")
        inv:setActiveTab("inv")
    end,
    
    onRelease = function(client)
        if IsValid(inv) then
            inv:Close()
        end
    end
})

-- Simple keybind with only onPress
lia.keybind.add(KEY_F2, "Simple Action", {
    onPress = function(client)
        client:ChatPrint("F2 pressed!")
    end
})

-- Server-side keybind
lia.keybind.add(KEY_F3, "Server Action", {
    shouldRun = function(client)
        return client:IsValid() and client:hasPermission("admin")
    end,
    
    onPress = function(client)
        client:addMoney(100)
    end,
    
    serverOnly = true
})
```

---

### lia.keybind.get

**Purpose**

Fetch the key code for a keybind action. It checks the current value, then the registered default, and finally the caller-supplied fallback.

**Parameters**

* `a` (*string*): Action identifier.
* `df` (*number | nil*): Fallback key code if the action is unknown. Optional.

**Realm**

`Client`

**Returns**

* *number | nil*: Key code associated with the action or the fallback.

**Example Usage**

```lua
local invKey = lia.keybind.get("openInventory", KEY_I)
print("Inventory key:", input.GetKeyName(invKey or KEY_NONE))
```

---

### lia.keybind.save

**Purpose**

Persist all current keybinds to `data/lilia/keybinds/<gamemode>/<server-ip>.json`. Only entries with a `value` field are written and legacy `.txt` files are cleaned up.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Manually save current keybinds
lia.keybind.save()
```

---

### lia.keybind.load

**Purpose**

Load keybinds from disk. Legacy `.txt` files are automatically converted to `.json`. If no keybind file exists, defaults registered via `lia.keybind.add` are applied and saved. After loading, numeric indexes are cleared, reverse lookup mappings are rebuilt, and the `InitializedKeybinds` hook fires.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
hook.Add("InitializedKeybinds", "NotifyKeybinds", function()
    chat.AddText("Keybinds loaded")
end)

-- Reload keybinds
lia.keybind.load()
```

---

## Key Mapping

The library provides a comprehensive mapping of key names to key codes, including:

* **Alphanumeric keys**: `a`, `b`, `c`, etc.
* **Function keys**: `f1`, `f2`, `f3`, etc.
* **Special keys**: `space`, `enter`, `tab`, `escape`, etc.
* **Arrow keys**: `up`, `down`, `left`, `right`
* **Modifier keys**: `lshift`, `rshift`, `lctrl`, `rctrl`, `lalt`, `ralt`
* **Numpad keys**: `kp_0`, `kp_1`, `kp_plus`, `kp_minus`, etc.

Keys can be specified either as strings (e.g., `"f1"`) or as constants (e.g., `KEY_F1`).

---

## Server-Side Execution

When `serverOnly` is set to true in a keybind callback, the action is executed server-side via networking:

1. The client sends a `liaKeybindServer` net message with the action name and player entity
2. The server receives the message and executes the callback function
3. The same process occurs for release actions with `_release` suffix

This allows server-side validation and execution while maintaining the responsive feel of client-side keybinds.

---

## Configuration Menu

The keybind system automatically adds a "Keybinds" page to the configuration menu (`PopulateConfigurationButtons` hook). This page provides:

* A searchable list of all registered keybinds
* Dropdown menus to change key assignments
* Unbind buttons to remove key assignments
* A reset button to restore all default keybinds
* Automatic conflict detection (prevents multiple actions on the same key)

The editing functionality can be disabled by setting `lia.config.get("AllowKeybindEditing", false)`.

---

## Default Keybinds

The library registers several default keybinds:

* `openInventory` - Opens the F1 menu with inventory tab active
* `adminMode` - Switches to/from staff character mode (server-side only)

These default keybinds are initially unbound (`KEY_NONE`) and must be assigned by the user.

---

## Hooks

* `InitializedKeybinds` - Fired after keybinds are loaded and initialized

---

## File Storage

Keybinds are stored in JSON format at:
```
data/lilia/keybinds/<gamemode>/<server-ip>.json
```

Where `<server-ip>` has dots replaced with underscores (e.g., `192_168_1_1.json`).

Legacy `.txt` files are automatically migrated to the new JSON format and then deleted.
