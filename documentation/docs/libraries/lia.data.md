# Data Library

This page describes persistent data storage helpers.

---

## Overview

The data library keeps persistent values inside a single `lia_data` database table. Each row is keyed by the current gamemode folder and map using the `_folder` and `_map` columns. All saved key/value pairs are stored together inside the `_data` column as JSON. Values are cached in memory inside `lia.data.stored` for quick access. Entity persistence loaded via `lia.data.loadPersistenceData` is kept in `lia.data.persistCache`.

---

### lia.data.set

**Purpose**

Saves the provided value under the specified key in the single `lia_data` table and caches it in `lia.data.stored`.

**Parameters**

* `key` (*string*): Key under which the data is stored.

* `value` (*any*): Value to store.

* `global` (*boolean*): Store without gamemode or map restrictions.

* `ignoreMap` (*boolean*): Omit the map name from the stored entry.

**Realm**

`Server`

**Returns**

* *string*: The path where the data was saved.

**Example Usage**

```lua
concommand.Add("save_spawn", function(ply)
    if ply:IsAdmin() then
        lia.data.set("spawn_pos", ply:GetPos(), true)
    end
end)
```

---

### lia.data.delete

**Purpose**

Removes the stored value corresponding to the key from the `lia_data` table and clears the cached entry in `lia.data.stored`.

**Parameters**

* `key` (*string*): Key corresponding to the data to delete.

* `global` (*boolean*): Store without gamemode or map restrictions.

* `ignoreMap` (*boolean*): Omit the map name from the stored entry.

**Realm**

`Server`

**Returns**

* *boolean*: Always `true`; the deletion query is queued.

**Example Usage**

```lua
lia.data.delete("spawn_pos")
```

---

### lia.data.get

**Purpose**

Retrieves the stored value for the specified key from the cache.

**Parameters**

* `key` (*string*): Key corresponding to the data.

* `default` (*any*): Default value to return if no data is found.

**Realm**

`Server`

**Returns**

* *any*: The stored value or the default if not found.

**Example Usage**

```lua
hook.Add("PlayerSpawn", "UseSavedSpawn", function(ply)
    local pos = lia.data.get("spawn_pos", vector_origin)
    if pos then
        ply:SetPos(pos)
    end
end)
```

---

### lia.data.loadTables

**Purpose**

Loads the appropriate entry from the `lia_data` table into `lia.data.stored`.

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
### lia.data.encodetable

**Purpose**

Recursively converts vectors, angles, and colours into plain tables so they can be serialised.

**Parameters**

* `value` (*any*): Data to encode.

**Realm**

`Server`

**Returns**

* *any*: The encoded representation.

**Example Usage**

```lua
local tbl = lia.data.encodetable(Vector(0, 0, 0))
```

---

### lia.data.decode

**Purpose**

Restores vectors, angles and colours from data processed by `lia.data.encodetable`.

**Parameters**

* `value` (*any*): Data to decode.

**Realm**

`Server`

**Returns**

* *any*: The decoded value.

**Example Usage**

```lua
local vec = lia.data.decode({0, 0, 0})
```

---

### lia.data.serialize

**Purpose**

Encodes a value and converts it into a JSON string.

**Parameters**

* `value` (*any*): Value to serialize.

**Realm**

`Server`

**Returns**

* *string*: JSON representation of the value.

**Example Usage**

```lua
local json = lia.data.serialize({pos = Vector(1, 2, 3)})
```

---

### lia.data.deserialize

**Purpose**

Parses a stored string and decodes any vectors, angles or colours.

**Parameters**

* `raw` (*string*): Serialized data.

**Realm**

`Server`

**Returns**

* *any | nil*: Decoded value or `nil` on failure.

**Example Usage**

```lua
local val = lia.data.deserialize(jsonData)
```

---

### lia.data.decodeVector

**Purpose**

Converts a stored string back into a `Vector`.

**Parameters**

* `raw` (*string*): Serialized vector.

**Realm**

`Server`

**Returns**

* *Vector | any*: Decoded vector or the original value.

**Example Usage**

```lua
local pos = lia.data.decodeVector("[1, 2, 3]")
```

---

### lia.data.decodeAngle

**Purpose**

Converts a stored string back into an `Angle`.

**Parameters**

* `raw` (*string*): Serialized angle.

**Realm**

`Server`

**Returns**

* *Angle | any*: Decoded angle or the original value.

**Example Usage**

```lua
local ang = lia.data.decodeAngle("{0, 90, 0}")
```

---

### lia.data.loadPersistence

**Purpose**

Ensures the persistence database tables contain all required columns.

**Parameters**

*None*

**Realm**

`Server`

**Returns**

* *deferred*: Resolves once the columns exist.

**Example Usage**

```lua
lia.data.loadPersistence():next(function()
    print("Persistence columns ready")
end)
```

---

### lia.data.savePersistence

**Purpose**

Writes a list of entity tables to the database so they persist across restarts.

**Parameters**

* `entities` (*table*): Entities to save.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.data.savePersistence(myEntities)
```

---

### lia.data.loadPersistenceData

**Purpose**

Loads persisted entity data into `lia.data.persistCache`.

**Parameters**

* `callback` (*function*): Called with the loaded entities.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.data.loadPersistenceData(function(ents)
    print("Loaded", #ents, "entities")
end)
```

---

### lia.data.getPersistence

**Purpose**

Returns the cached entity table populated by `lia.data.loadPersistenceData`.

**Parameters**

*None*

**Realm**

`Server`

**Returns**

* *table*: Cached persistence data.

**Example Usage**

```lua
local saved = lia.data.getPersistence()
```

---
