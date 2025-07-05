# Option Library

This page details the client/server option system.

---

## Overview

The option library stores user and server options with default values. It offers
getters and setters that automatically network changes between client and server.
Define options clientside with `lia.option.add` to make them available for
networking and configuration.

Options are kept inside the shared table `lia.option.stored`. Each entry is a
table containing:
* `name` (string) – Display name shown in configuration menus.
* `desc` (string) – Descriptive text.
* `data` (table) – Extra data such as limits or category.
* `value` (any) – Current option value.
* `default` (any) – Fallback value if none was set.
* `callback` (function|nil) – Called with `(oldValue, newValue)` when the value changes.
* `type` (string) – Automatically detected or overridden control type like `Boolean` or `Int`.
* `visible` (boolean|function|nil) – Controls if the option appears in the config UI.
* `shouldNetwork` (boolean|nil) – When true the server fires the `liaOptionReceived` hook on change.

---

### lia.option.add(key, name, desc, default, callback, data)

**Description:**

Adds a configuration option to the lia.option system.

**Parameters:**

* key (string) — The unique key for the option.


* name (string) — The display name of the option.


* desc (string) — A brief description of the option's purpose.


* default (any) — The default value for this option.

* callback (function) — Called as `callback(oldValue, newValue)` when the option changes (optional).

* data (table) — Extra information controlling the option. Pass an empty table if you do not need any of the following fields:
  * `category` (string) – Category heading in the menu.
  * `min`/`max` (number) – Bounds for numeric options.
  * `decimals` (number) – Rounding precision for floats.
  * `options` (table) – Choice list for table options.
  * `type` (string) – Force a control type such as `Boolean` or `Color`.
  * `visible` (boolean|function) – If false or returns false the option is hidden.
  * `shouldNetwork` (boolean) – If true, server changes trigger `liaOptionReceived`.

**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.option.add
    lia.option.add(
    "thirdPersonEnabled",
    "Third Person Enabled",
    "Toggle third-person view.",
    false,
    function(_, newValue) hook.Run("thirdPersonToggled", newValue) end,
    {category = "Third Person"}
)
```

---

### lia.option.set(key, value)

**Description:**

Sets the value of an option, runs its callback and saves the data. If the option was created with `shouldNetwork = true`, the server fires `liaOptionReceived` for the change.

**Parameters:**

* key (string) — The unique key identifying the option.


* value (any) — The new value to assign to this option.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.option.set
    lia.option.set("thirdPersonEnabled", not lia.option.get("thirdPersonEnabled"))
```

---

### lia.option.get(key, default)

**Description:**

Retrieves the value of a specified option, or returns a default if it doesn't exist.

**Parameters:**

* key (string) — The unique key identifying the option.


* default (any) — The value to return if the option is not found.


**Realm:**

* Client


**Returns:**

* (any) The current value of the option or the provided default.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.option.get
    local dist = lia.option.get("thirdPersonDistance", 50)
```

---

### lia.option.save()

**Description:**

Saves all current option values to a file, named based on the server IP, within the active gamemode folder.

**Parameters:**

* None


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.option.save
    lia.option.save()
```

---

### lia.option.load()

**Description:**

Loads saved option values from disk based on server IP and applies them to `lia.option.stored`.
After loading, the `InitializedOptions` hook is fired.

**Parameters:**

* None


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.option.load
    lia.option.load()
```
