# Keybind Library

This page describes functions for registering and managing custom keybinds.

---

## Overview

The keybind library runs **client-side** and stores user-defined key bindings in `lia.keybind.stored`. Bindings are saved to `data/lilia/keybinds/<gamemode>/<server-ip>.json` (using the server IP with dots replaced by underscores) and loaded automatically on start. If a legacy `.txt` file exists it is migrated to the new JSON format. Press and release callbacks are dispatched through `PlayerButtonDown` and `PlayerButtonUp`, and a “Keybinds” page is added to the configuration menu via `PopulateConfigurationButtons`. Editing in this menu can be disabled with the `AllowKeybindEditing` configuration option.

Each entry in `lia.keybind.stored` contains:

* `default` (*number*) – key code assigned on registration.
* `value` (*number*) – current key code (initially the default).
* `callback` (*function | nil*) – invoked when the key is pressed. The player is passed as the sole argument.
* `release` (*function | nil*) – invoked when the key is released. The player is passed as the sole argument.

Numeric key codes are also mapped back to their action identifiers for reverse lookup. The library registers some actions by default (e.g. `openInventory` and `adminMode`) but leaves them unbound.

---

### lia.keybind.add

**Purpose**

Register a keybind action and optional callbacks. The default key is stored and a reverse mapping from key code to action is created. Existing user selections are preserved.

**Parameters**

* `k` (*string | number*): Key identifier. A string is matched case-insensitively against the internal key map. Invalid keys abort registration.
* `d` (*string*): Action identifier.
* `cb` (*function | nil*): Called when the key is pressed. Receives the player as its only argument. Optional.
* `rcb` (*function | nil*): Called when the key is released. Receives the player as its only argument. Optional.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Bind F1 to open the inventory while held
local inv
lia.keybind.add(
    KEY_F1,
    "Open Inventory",
    function(client)
        inv = vgui.Create("liaMenu")
        inv:setActiveTab("Inventory")
    end,
    function(client)
        if IsValid(inv) then
            inv:Close()
        end
    end
)
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
local invKey = lia.keybind.get("Open Inventory", KEY_I)
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
