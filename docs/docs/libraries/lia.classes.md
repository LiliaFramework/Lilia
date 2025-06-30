# Classes Library

This page details the class system functions.

---

## Overview

The classes library loads Lua definitions that describe player classes. Classes act like temporary jobs within a faction. The library stores available classes, registers default attributes, and provides lookup functions by name or index.

### lia.class.loadFromDir(directory)


**Description:**

Loads all class definitions from the given directory and stores them in lia.class.list.
**Parameters:**

* directory (string) – Folder path containing class Lua files.

**Returns:**

* nil

**Realm:**

* Shared

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.class.loadFromDir
    lia.class.loadFromDir("schema/classes")
```

---


### lia.class.canBe(client, class)


**Description:**

Determines if the given client may become the specified class.
**Parameters:**

* client (Player) – Player attempting to join.

* class (string|number) – Class identifier.

**Returns:**

* boolean – False with a message if denied; default status when allowed.

**Realm:**

* Shared

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.class.canBe
    local allowed = lia.class.canBe(client, classID)
```

---


### lia.class.get(identifier)


**Description:**

Retrieves the class table associated with the given identifier.
**Parameters:**

* identifier (string|number) – Unique identifier for the class.

**Returns:**

* table|nil – Class table if found.

**Realm:**

* Shared

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.class.get
    local classData = lia.class.get(1)
```

---


### lia.class.getPlayers(class)


**Description:**

Returns a table of players whose characters belong to the given class.
**Parameters:**

* class (string|number) – Class identifier.

**Returns:**

* table – List of player objects.

**Realm:**

* Shared

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.class.getPlayers
    local players = lia.class.getPlayers(classID)
```

---


### lia.class.getPlayerCount(class)


**Description:**

Counts how many players belong to the given class.
**Parameters:**

* class (string|number) – Class identifier.

**Returns:**

* number – Player count.

**Realm:**

* Shared

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.class.getPlayerCount
    local count = lia.class.getPlayerCount(classID)
```

---


### lia.class.retrieveClass(class)


**Description:**

Searches the class list for a class whose ID or name matches the given text.
**Parameters:**

* class (string) – Search text.

**Returns:**

* string|nil – Matching class identifier or nil.

**Realm:**

* Shared

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.class.retrieveClass
    local id = lia.class.retrieveClass("police")
```

---


### lia.class.hasWhitelist(class)


**Description:**

Returns whether the specified class requires a whitelist.
**Parameters:**

* class (string|number) – Class identifier.

**Returns:**

* boolean – True if the class is whitelisted.

**Realm:**

* Shared

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.class.hasWhitelist
    if lia.class.hasWhitelist(classID) then
        print("Whitelist required")
    end
```
