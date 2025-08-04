# Classes Library

This page details the class system functions.

---

## Overview

The classes library loads Lua definitions that describe player classes. Classes act like temporary jobs within a faction. The library stores available classes, registers default attributes, and provides lookup functions by name or index.

See [Class Fields](../definitions/class.md) for configurable `CLASS` properties and [Class Hooks](../hooks/class_hooks.md) for customization callbacks.

---

### lia.class.loadFromDir

**Purpose**

Loads all Lua files within the supplied directory. Each file should define a `CLASS` table inserted into `lia.class.list` with an automatic index.

**Parameters**

* `directory` (*string*): Folder path containing class Lua files, typically `"schema/classes"` in a schema.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Load all classes for the schema
lia.class.loadFromDir("schema/classes")
```

---

### lia.class.canBe

**Purpose**

Checks faction and limit rules. It also runs the `CanPlayerJoinClass` gamemode hook and the class’s `OnCanBe` method to determine if the client may join. This function does not automatically enforce class whitelists.

**Parameters**

* `client` (*Player*): Player attempting to join.

* `class` (*number*): Class index to join.

**Realm**

`Shared`

**Returns**

* *boolean*, *string?*: `false` and a reason when denied; on success, returns the class’s `isDefault` flag.

**Example Usage**

```lua
local canJoin, reason = lia.class.canBe(client, classID)
if not canJoin then
    print(reason)
end
```

---

### lia.class.get

**Purpose**

Retrieves the class table associated with the given numeric index.

**Parameters**

* `identifier` (*number*): Numeric index of the class.

**Realm**

`Shared`

**Returns**

* *table | nil*: Class table if found.

**Example Usage**

```lua
-- Retrieve the class table for the engineer class
local classData = lia.class.get(CLASS_ENGINEER)
```

---

### lia.class.getPlayers

**Purpose**

Returns an array of players whose characters belong to the given class.

**Parameters**

* `class` (*number*): Class index to check.

**Realm**

`Shared`

**Returns**

* *table*: List of player objects.

**Example Usage**

```lua
for _, ply in ipairs(lia.class.getPlayers(classID)) do
    print(ply:Nick())
end
```

---

### lia.class.getPlayerCount

**Purpose**

Counts the number of players currently in the specified class.

**Parameters**

* `class` (*number*): Class index to check.

**Realm**

`Shared`

**Returns**

* *number*: Player count.

**Example Usage**

```lua
local count = lia.class.getPlayerCount(classID)
print("Players in class:", count)
```

---

### lia.class.retrieveClass

**Purpose**

Finds a class whose `uniqueID` or `name` matches the given text (case-insensitive).

**Parameters**

* `class` (*string*): Name or `uniqueID` to look up.

**Realm**

`Shared`

**Returns**

* *number | nil*: Matching class index or `nil` if not found.

**Example Usage**

```lua
local id = lia.class.retrieveClass("police")
print("Class index:", id)
```

---

### lia.class.hasWhitelist

**Purpose**

Checks if the class requires a whitelist. Default classes and invalid class indices always return `false`.

**Parameters**

* `class` (*number*): Class index to check.

**Realm**

`Shared`

**Returns**

* *boolean*: `true` if the class is whitelisted; otherwise `false`.

**Example Usage**

```lua
-- Check whether the class is whitelisted
if lia.class.hasWhitelist(classID) then
    print("Whitelist required")
end
```

---
