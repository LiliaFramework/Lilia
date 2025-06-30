# Option Library

This page details the client/server option system.

---

## Overview

The option library stores user and server options with default values. It offers getters and setters that automatically network changes between client and server. Define options clientside with `lia.option.add` to make them available for networking and configuration.

---

### lia.option.add(key, name, desc, default, callback, data)

**Description:**

Adds a configuration option to the lia.option system.

**Parameters:**

* key (string) — The unique key for the option.


* name (string) — The display name of the option.


* desc (string) — A brief description of the option's purpose.


* default (any) — The default value for this option.


* callback (function) — A function to call when the option’s value changes (optional).


* data (table) — Additional data describing the option (e.g., min, max, type, category, visible, shouldNetwork).


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.option.add
    lia.option.add("showHints", "Show Hints", "Display hints", true)
```

---

### lia.option.set(key, value)

**Description:**

Sets the value of a specified option, saves locally, and optionally networks to the server.

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
    lia.option.set("showHints", false)
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
    local show = lia.option.get("showHints", true)
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

Loads saved option values from disk based on server IP and applies them to lia.option.stored.

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
