# Data Library

Helpers for serializing Lua data and storing persistent values.

---

## Overview

The data library stores arbitrary key/value pairs in the `lia_data` SQL table. Each entry is
scoped by the gamemode folder and map and cached in `lia.data.stored`. Serialization helpers
encode vectors, angles and colour tables into simple tables so they can be stored in JSON
and later restored.

---

### lia.data.encodetable

**Purpose**

Recursively converts values (including `Vector`, `Angle` and colour tables) into
serialisable tables.

**Parameters**

* `value` (*any*): Data to encode.

**Realm**

`Server`

**Returns**

* *any*: Encoded representation.

**Example Usage**

```lua
local encoded = lia.data.encodetable({pos = Vector(1, 2, 3)})
-- encoded.pos == {1, 2, 3}
```

---

### lia.data.decode

**Purpose**

Recursively restores values encoded by `lia.data.encodetable`, turning
tables or strings representing vectors or angles back into their original types.

**Parameters**

* `value` (*any*): Data to decode.

**Realm**

`Server`

**Returns**

* *any*: Decoded value.

**Example Usage**

```lua
local vec = lia.data.decode({1, 2, 3})
-- vec == Vector(1, 2, 3)
```

---

### lia.data.serialize

**Purpose**

Encodes a value with `lia.data.encodetable` and converts it to a JSON string.

**Parameters**

* `value` (*any*): Value to serialise.

**Realm**

`Server`

**Returns**

* *string*: JSON representation.

**Example Usage**

```lua
local json = lia.data.serialize({pos = Vector(1, 2, 3)})
```

---

### lia.data.deserialize

**Purpose**

Attempts to parse JSON or PON strings (or tables) and decodes any vectors or
angles contained within. Non-string/table values are returned as-is.

**Parameters**

* `raw` (*any*): Serialised data to decode.

**Realm**

`Server`

**Returns**

* *any | nil*: Decoded value, or `nil` if the input is `nil` or cannot be
  parsed.

**Example Usage**

```lua
local data = lia.data.deserialize(json)
```

---

### lia.data.decodeVector

**Purpose**

Converts a `Vector`, table or string in common vector formats (including JSON,
PON and pattern-based representations like `[x y z]` or `Vector(x, y, z)`) into
a `Vector`.

**Parameters**

* `raw` (*any*): Data to decode.

**Realm**

`Server`

**Returns**

* *Vector | nil*: Resulting vector, or `nil` if `raw` is `nil` or cannot be
  converted.

**Example Usage**

```lua
local pos = lia.data.decodeVector("[1, 2, 3]")
```

---

### lia.data.decodeAngle

**Purpose**

Converts an `Angle`, table or string in common angle formats (including JSON,
PON and pattern-based representations like `{p y r}` or `Angle(p, y, r)`) into
an `Angle`.

**Parameters**

* `raw` (*any*): Data to decode.

**Realm**

`Server`

**Returns**

* *Angle | nil*: Resulting angle, or `nil` if `raw` is `nil` or cannot be
  converted.

**Example Usage**

```lua
local ang = lia.data.decodeAngle("{0, 90, 0}")
```

---

### lia.data.set

**Purpose**

Stores a value under the given key and writes the entire cache to the `lia_data`
table. Data can be scoped to a specific gamemode and map.

**Parameters**

* `key` (*string*): Storage key.
* `value` (*any*): Value to store.
* `global` (*boolean*, default = `false`): If `true`, ignore gamemode and map.
* `ignoreMap` (*boolean*, default = `false`): Ignore the map but still use the
  gamemode.

**Realm**

`Server`

**Returns**

* *string*: Path such as `lilia/<gamemode>/<map>/` indicating where the data was
  saved.

**Example Usage**

```lua
lia.data.set("spawnPos", Vector(0, 0, 0))
```

---

### lia.data.delete

**Purpose**

Removes a key from the cache and updates the `lia_data` table.

**Parameters**

* `key` (*string*): Key to remove.
* `global` (*boolean*, default = `false`): If `true`, ignore gamemode and map.
* `ignoreMap` (*boolean*, default = `false`): Ignore the map but still use the
  gamemode.

**Realm**

`Server`

**Returns**

* *boolean*: Always `true`; the deletion is queued asynchronously.

**Example Usage**

```lua
lia.data.delete("spawnPos")
```

---

### lia.data.get

**Purpose**

Retrieves a stored value, deserialising it if required.

**Parameters**

* `key` (*string*): Key to fetch.
* `default` (*any*, optional): Value returned when the key does not exist.

**Realm**

`Server`

**Returns**

* *any*: Stored value or the provided default (which defaults to `nil`).

**Example Usage**

```lua
local pos = lia.data.get("spawnPos", Vector(0, 0, 0))
```

---

### lia.data.loadTables

**Purpose**

Loads global, gamemode and map‑specific entries from the `lia_data` table
into `lia.data.stored`.

**Parameters**

*None*

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.data.loadTables()
```

---

### lia.data.loadPersistence

**Purpose**

Ensures all default columns exist in the `lia_persistence` table.

**Parameters**

*None*

**Realm**

`Server`

**Returns**

* *Promise*: Resolves once the columns are present.

**Example Usage**

```lua
lia.data.loadPersistence():next(function()
    print("Ready")
end)
```

---

### lia.data.savePersistence

**Purpose**

Writes a list of entity tables to `lia_persistence`. Extra fields on entities
are stored in dynamically created columns. The cache `lia.data.persistCache`
is updated.

**Parameters**

* `entities` (*table*): Entities to save.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.data.savePersistence({
    {class = "prop_physics", pos = Vector(1,2,3), angles = Angle(0,0,0), model = "models/props_c17/oildrum001.mdl"}
})
```

---

### lia.data.loadPersistenceData

**Purpose**

Fetches persisted entities for the current gamemode and map, decodes all fields
and stores the result in `lia.data.persistCache`. The optional callback is
invoked with the decoded entities once loading completes.

**Parameters**

* `callback` (*function*, optional): Receives the loaded entities once loading
  completes.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.data.loadPersistenceData(function(entities)
    print(#entities, "entities loaded")
end)
```

---

### lia.data.getPersistence

**Purpose**

Returns the cached entities loaded by `lia.data.loadPersistenceData`.

**Parameters**

*None*

**Realm**

`Server`

**Returns**

* *table*: Cached entity data.

**Example Usage**

```lua
local entities = lia.data.getPersistence()
```

---
