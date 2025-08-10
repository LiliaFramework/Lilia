# Option Library

This page details the client/server option system.

---

## Overview

The option library stores configurable values with defaults and provides helpers to manage them. Changes can optionally be networked to the server through the `liaOptionReceived` hook.

Options are kept inside `lia.option.stored`; each entry contains:

* `name` (*string*) – Display name for configuration menus. String values are localized automatically.
* `desc` (*string*) – Description text. String values are localized automatically.
* `data` (*table*) – Extra data (limits, category, etc.).
* `value` (*any*) – Current value.
* `default` (*any*) – Fallback value.
* `callback` (*function | nil*) – Runs as `callback(oldValue, newValue)` when the option changes.
* `type` (*string*) – Control type (`Boolean`, `Int`, `Float`, `Color`, or `Generic`).
* `visible` (*boolean | function | nil*) – Whether the option appears in the config UI.
* `shouldNetwork` (*boolean | nil*) – When `true`, calling `lia.option.set` on the server fires the `liaOptionReceived` hook.
* `isQuick` (*boolean | nil*) – Display this option inside the quick settings panel.

Whenever `lia.option.set` updates a value, the `liaOptionChanged` hook is fired.

---

### lia.option.add

**Purpose**

Registers a configurable option.

**Parameters**

* `key` (*string*): Unique option key.

* `name` (*string*): Display name. Localized automatically with `L`.

* `desc` (*string | nil*): Brief description. Localized automatically with `L` when provided.

* `default` (*any*): Default value.

* `callback` (*function | nil*): Runs on change. Optional. Receives the old value and the new value.
* `data` (*table*): Additional option data. This table is required even if empty. Fields may include:
  * `category` (*string*): Grouping for configuration menus. Localized automatically.
  * `min` (*number*): Minimum numeric value. Defaults to half of `default` for numeric types.
  * `max` (*number*): Maximum numeric value. Defaults to double `default` for numeric types.
  * `options` (*table*): Discrete choices; string entries are localized automatically.
  * `type` (*string*): Overrides automatic type detection (`Boolean`, `Int`, `Float`, `Color`, `Generic`).
  * `visible` (*boolean | function*): Whether the option is shown in the configuration UI.
  * `shouldNetwork` (*boolean*): When `true`, calling `lia.option.set` on the server triggers `liaOptionReceived`.
  * `isQuick` (*boolean*): Include this option in the quick settings panel.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.option.add(
    "thirdPersonEnabled",
    "thirdPersonEnabled",
    "thirdPersonEnabledDesc",
    false,
    function(_, newValue)
        hook.Run("thirdPersonToggled", newValue)
    end,
    { category = "thirdPerson" }
)
```

---

### lia.option.set

**Purpose**

Changes the value of an option, runs its callback, saves it, and networks if `shouldNetwork` is `true`. If the option key is unregistered, the call is ignored.

**Parameters**

* `key` (*string*): Option key.

* `value` (*any*): New value.

**Realm**

`Shared`

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

Retrieves an option value or returns a fallback. Checks the current value first, then the option's default, then the provided fallback.

**Parameters**

* `key` (*string*): Option key.

* `default` (*any*): Fallback value.

**Realm**

`Shared`

**Returns**

* *any*: Current value or fallback.

**Example Usage**

```lua
local dist = lia.option.get("thirdPersonDistance", 50)
```

---

### lia.option.save

**Purpose**

Writes all current option values to `data/lilia/options/<gamemode>/<serverip>.txt` in JSON format. Only options with non-`nil` values are written.

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

Loads saved option values from `data/lilia/options/<gamemode>/<serverip>.txt`, applies them to `lia.option.stored`, and fires `InitializedOptions`.

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
