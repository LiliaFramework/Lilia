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

### lia.option.add

**Purpose**

Registers a configurable option that can be networked between client and server.

**Parameters**

* `key` (*string*): Unique key for the option.
* `name` (*string*): Display name of the option.
* `desc` (*string*): Brief description of the option.
* `default` (*any*): Default value.
* `callback` (*function*): Called with `(oldValue, newValue)` when changed.
* `data` (*table*): Extra option information.

**Realm**

`Shared`

**Returns**

* `nil`

**Example**

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

### lia.option.set

**Purpose**

Sets the value of an option, runs its callback and saves the data. If `shouldNetwork` is true the server fires `liaOptionReceived`.

**Parameters**

* `key` (*string*): Unique option identifier.
* `value` (*any*): New value to assign.

**Realm**

`Client`

**Returns**

* `nil`

**Example**

```lua
-- This snippet demonstrates a common usage of lia.option.set
lia.option.set("thirdPersonEnabled", not lia.option.get("thirdPersonEnabled"))

---

### lia.option.get

**Purpose**

Retrieves the value of a specified option, or returns a default if it doesn't exist.

**Parameters**

* `key` (*string*): Unique key identifying the option.
* `default` (*any*): Value to return if not found.

**Realm**

`Client`

**Returns**

* *any*: Current value or provided default.

**Example**

```lua
-- This snippet demonstrates a common usage of lia.option.get
local dist = lia.option.get("thirdPersonDistance", 50)

---

### lia.option.save

**Purpose**

Saves all current option values to disk in a file based on server IP.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `nil`

**Example**

```lua
-- This snippet demonstrates a common usage of lia.option.save
lia.option.save()

---

### lia.option.load

**Purpose**

Loads saved option values from disk based on server IP and applies them to `lia.option.stored`. Fires `InitializedOptions` when done.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `nil`

**Example**

```lua
-- This snippet demonstrates a common usage of lia.option.load
lia.option.load()
```

---

#### Library Conventions

1. **Namespace**
   When formatting libraries, make sure to only document lia.* functions of that type. For example if you are documenting workshop.lua, you'd document lia.workshop functions .

2. **Shared Definitions**
   Omit any parameters or fields already documented in `docs/definitions.lua`.

3. **Internal-Only Functions**
   If this function is not meant to be used outside the internal scope of the gamemode, such as lia.module.load, add the “Internal function” note (see above).
