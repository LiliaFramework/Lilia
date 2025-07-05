# Keybind Library

This page describes functions to register custom keybinds.

---

## Overview

The keybind library stores user-defined keyboard bindings. It is loaded **client side** and automatically loads any saved bindings from `data/lilia/keybinds/`. Press and release callbacks are dispatched through the `PlayerButtonDown` and `PlayerButtonUp` hooks. The library also adds a "Keybinds" page to the configuration menu via the `PopulateConfigurationButtons` hook so players can change their binds in game.

---

### lia.keybind.add

**Description:**

Registers a new keybind for a given action.

Converts the provided key identifier to its corresponding key constant (if it's a string),

and stores the keybind settings. When the keybind does not yet have a saved value its
default key will be set to the provided key.  The optional release callback will be executed
when the key is released.

Also maps the key code back to the action identifier for reverse lookup.

**Parameters:**

* `k` (`string or number`) – The key identifier, either as a string (to be converted) or as a key code.


* `d` (`string`) – The unique identifier for the keybind action.


* `cb` (`function`) – The callback function to be executed when the key is pressed.


* `rcb` (`function, optional`) – The callback function to be executed when the key is released.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
-- Bind F1 to open the inventory while held
local inv
lia.keybind.add(KEY_F1, "Open Inventory",
    function()
        inv = vgui.Create("liaMenu")
        inv:setActiveTab(L("inv"))
    end,
    function()
        if IsValid(inv) then inv:Close() end
    end
)
```

---

### lia.keybind.get

**Description:**

Retrieves the key code currently assigned to a keybind action.  The stored value
is returned if present, otherwise the default key registered with `lia.keybind.add`
is used.  If both are missing the optional fallback value is returned.

**Parameters:**

* `a` (`string`) – The unique identifier for the keybind action.


* `df` (`number`) – An optional default key code to return if the keybind is not set.


**Realm:**

* Client


**Returns:**

* number – The key code associated with the keybind action, or the default/fallback value if not set.


**Example Usage:**

```lua
-- Retrieve the key currently bound to opening the inventory
local invKey = lia.keybind.get("Open Inventory", KEY_I)
print("Inventory key:", input.GetKeyName(invKey))
```

---

### lia.keybind.save

**Description:**

Persists all keybinds to disk. The library creates a folder under
`data/lilia/keybinds/` named after the active gamemode and writes a file based on
the server IP address.  The file contains a JSON table mapping action identifiers
to key codes.

**Parameters:**

* None


**Realm:**

* Client


    Internal Function:

    true

**Returns:**

* None


**Example Usage:**

```lua
-- Manually save current keybinds (normally handled automatically)
lia.keybind.save()
```

---

### lia.keybind.load

**Description:**

Loads keybind settings from disk.  The file is read from the same location used
by `lia.keybind.save`.  If no saved binds exist the defaults defined via
`lia.keybind.add` are applied and then written to disk.  After loading, a reverse
lookup table (key code → action) is built and the `InitializedKeybinds` hook is
triggered.
This function is automatically called when the gamemode initializes or reloads.

**Parameters:**

* None


**Realm:**

* Client


    Internal Function:

    true

**Returns:**

* None


**Example Usage:**

```lua
-- Reload keybinds and notify when done
hook.Add("InitializedKeybinds", "NotifyKeybinds", function()
    chat.AddText("Keybinds loaded")
end)
lia.keybind.load()
```
