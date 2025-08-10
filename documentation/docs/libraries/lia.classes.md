# Classes Library

This page details the class system functions.

---

## Overview

The classes library loads Lua definitions that describe player classes. Classes act like temporary jobs within a faction. The library stores available classes, applies default values, and provides lookup functions by index or text search.

See [Class Fields](../definitions/class.md) for configurable `CLASS` properties and [Class Hooks](../hooks/class_hooks.md) for customization callbacks.

---

### lia.class.register

**Purpose**

Registers a new class or updates an existing one with matching `uniqueID`.
Applies default values and validates that the provided faction exists.

**Parameters**

* `uniqueID` (*string*): Unique identifier for the class.
* `data` (*table*): Properties such as `name`, `desc`, `faction`, `limit`, etc.

**Realm**

`Shared`

**Returns**

* *table | nil*: The registered class table, or `nil` if the faction is invalid.

**Edge Cases**

* Sets defaults of `name` to `L("unknown")`, `desc` to `L("noDesc")`, `limit` to `0`, and `OnCanBe` to a function returning `true` when those fields are missing.
* Logs an error and returns `nil` when `faction` is missing or not a valid team.

**Example Usage**

```lua
-- Register a class for the Combine faction
local class = lia.class.register("overwatch", {
    name = "Overwatch Soldier",
    desc = "Transhuman soldier of the Combine.",
    faction = FACTION_COMBINE,
    limit = 4,
    isWhitelisted = true
})
```

---

### lia.class.loadFromDir

**Purpose**

Loads every `.lua` file within the supplied directory. Each file should define a `CLASS` table inserted into `lia.class.list` with an automatic index.
Skips files whose `uniqueID` already exists and requires each class to have a valid `faction`.
Defaults `name` to `L("unknown")`, `desc` to `L("noDesc")`, `limit` to `0`, and `OnCanBe` to a function returning `true`.
Files prefixed with `sh_` have the prefix stripped when determining `uniqueID`.

**Parameters**

* `directory` (*string*): Folder path containing class Lua files, typically `"schema/classes"` in a schema.

**Edge Cases**

* After inclusion, the temporary global `CLASS` is cleared to avoid leaking state.

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

Validates faction membership, current class, and population limits before calling the `CanPlayerJoinClass` gamemode hook and the class’s `OnCanBe` method. This function does not automatically enforce class whitelists.

**Parameters**

* `client` (*Player*): Player attempting to join.

* `class` (*number*): Class index to join.

**Realm**

`Shared`

**Returns**

* *boolean | nil*, *string?*: `false` and a localized reason when basic checks fail. If either the hook or `OnCanBe` returns `false`, this function simply returns `false`. On success, returns the class’s `isDefault` flag (`true` for default classes, otherwise `nil`).

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

Retrieves the class table associated with the given index.

**Parameters**

* `index` (*number*): Class index to look up.

**Realm**

`Shared`

**Returns**

* *table | nil*: Class table if found, or `nil` for an invalid index.

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

* *table*: List of player objects. Returns an empty table when no players are in the class.

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

* *number*: Player count (returns `0` if none).

**Example Usage**

```lua
local count = lia.class.getPlayerCount(classID)
print("Players in class:", count)
```

---

### lia.class.retrieveClass

**Purpose**

Finds a class whose `uniqueID` or `name` matches the given text (case-insensitive, partial matches allowed).

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

### lia.class.retrieveJoinable

**Purpose**

Returns all classes the specified client is eligible to join by calling `lia.class.canBe` on each registered class.

**Parameters**

* `client` (*Player?*): Player to check. Defaults to `LocalPlayer()` when called on the client.
  If invalid or omitted on the server, an empty table is returned.

**Realm**

`Shared`

**Returns**

* *table*: List of class tables the client can join. Returns an empty table if the client is invalid.

**Example Usage**

```lua
for _, class in ipairs(lia.class.retrieveJoinable(client)) do
    print("Can join:", class.name)
end
```

---
