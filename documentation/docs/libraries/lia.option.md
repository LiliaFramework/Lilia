# Option Library

This page details the client/server option system.

---

## Overview

The option library stores user- and server-side options with default values. It provides getters and setters that automatically network changes between client and server.

Options are kept inside `lia.option.stored`; each entry contains:

* `name` (*string*) – Display name for configuration menus.

* `desc` (*string*) – Description text.

* `data` (*table*) – Extra data (limits, category, etc.).

* `value` (*any*) – Current value.

* `default` (*any*) – Fallback value.

* `callback` (*function | nil*) – Runs as `callback(oldValue, newValue)` on change.

* `type` (*string*) – Control type (`Boolean`, `Int`, …).

* `visible` (*boolean | function | nil*) – Whether the option appears in the config UI.

* `shouldNetwork` (*boolean | nil*) – When `true`, the server fires `liaOptionReceived` upon change.

* `isQuick` (*boolean | nil*) – Display this option inside the quick settings panel.

Whenever `lia.option.set` updates a value, the `liaOptionChanged` hook is fired on both realms.

---

### lia.option.add

**Purpose**

Registers a configurable option that can be networked.

**Parameters**

* `key` (*string*): Unique option key.

* `name` (*string*): Display name.

* `desc` (*string*): Brief description.

* `default` (*any*): Default value.

* `callback` (*function | nil*): Runs on change. Optional.

* `data` (*table*): Extra option data. Set `isQuick = true` to also list this option in the quick settings panel.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.option.add(
    "thirdPersonEnabled",
    "Third Person Enabled",
    "Toggle third-person view.",
    false,
    function(_, newValue)
        hook.Run("thirdPersonToggled", newValue)
    end,
    { category = "Third Person" }
)
```

---

### lia.option.set

**Purpose**

Changes the value of an option, runs its callback, saves it, and networks if `shouldNetwork` is `true`.

**Parameters**

* `key` (*string*): Option key.

* `value` (*any*): New value.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Toggle third-person mode
local enabled = lia.option.get("thirdPersonEnabled", false)
lia.option.set("thirdPersonEnabled", not enabled)
```

---

### lia.option.get

**Purpose**

Retrieves an option value or returns a fallback.

**Parameters**

* `key` (*string*): Option key.

* `default` (*any*): Fallback value.

**Realm**

`Client`

**Returns**

* *any*: Current value or fallback.

**Example Usage**

```lua
local dist = lia.option.get("thirdPersonDistance", 50)
```

---

### lia.option.save

**Purpose**

Writes all current option values to disk (file is keyed by server IP).

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.option.save()
```

---

### lia.option.load

**Purpose**

Loads saved option values from disk, applies them to `lia.option.stored`, and fires `InitializedOptions`.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.option.load()
```

---
