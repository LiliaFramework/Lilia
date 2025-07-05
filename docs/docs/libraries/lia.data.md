# Data Library

This page describes persistent data storage helpers.

---

## Overview

The data library stores key/value pairs in the `lia_data` database table. Values are cached in memory inside `lia.data.stored` for quick access.

---

### lia.data.set

**Description:**

Saves the provided value under the specified key in the `lia_data` table.

The value is cached in `lia.data.stored` and automatically written to the database.

**Parameters:**

* `key` (`string`) – The key under which the data is stored.


* `value` (`any`) – The value to store.


* `global` (`boolean`) – When true, the entry is stored without gamemode or map restrictions.


* `ignoreMap` (`boolean`) – When true, the map name is omitted from the stored entry.


**Realm:**

* Server


**Returns:**

* string – The path where the data was saved.


**Example Usage:**

```lua
    -- Save the admin's position as the global spawn point with a command
    concommand.Add("save_spawn", function(ply)
        if ply:IsAdmin() then
            lia.data.set("spawn_pos", ply:GetPos(), true)
        end
    end)
```

---

### lia.data.delete

**Description:**

Removes the stored value corresponding to the key from the `lia_data` table.

The cached entry inside `lia.data.stored` is also cleared.

**Parameters:**

* `key` (`string`) – The key corresponding to the data to be deleted.


* `global` (`boolean`) – When true, the entry is stored without gamemode or map restrictions.


* `ignoreMap` (`boolean`) – When true, the map name is omitted from the stored entry.


**Realm:**

* Server


**Returns:**

* boolean – Always true; the deletion query is queued for the database.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.data.delete
    lia.data.delete("spawn_pos")
```

---

### lia.data.get

**Description:**

Retrieves the stored value for the specified key. This function no longer

consults the database directly; all values are preloaded at startup and cached

in `lia.data.stored`.

The `global`, `ignoreMap`, and `refresh` parameters are legacy placeholders kept

for backward compatibility.

**Parameters:**

* `key` (`string`) – The key corresponding to the data.


* `default` (`any`) – The default value to return if no data is found.


* `global` (`boolean`) – Legacy parameter currently ignored.


* `ignoreMap` (`boolean`) – Legacy parameter currently ignored.


* `refresh` (`boolean`) – Unused legacy parameter kept for compatibility.


**Realm:**

* Shared


**Returns:**

* any – The stored value, or the default if not found.


**Example Usage:**

```lua
    -- Teleport players to the saved spawn point when they spawn
    hook.Add("PlayerSpawn", "UseSavedSpawn", function(ply)
        local pos = lia.data.get("spawn_pos", Vector(0, 0, 0), true)
        if pos then
            ply:SetPos(pos)
        end
    end)
```

---

### lia.data.loadTables

**Description:**

Loads all entries from the `lia_data` table into `lia.data.stored`. If the table

is empty but legacy files exist, `lia.data.convertToDatabase` is automatically

executed.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- Called automatically when the framework finishes connecting to the
    -- database. Can be invoked manually to reload data.
    lia.data.loadTables()
```

---

### lia.data.convertToDatabase

**Description:**

Imports legacy `.txt` files from `data/lilia` into the `lia_data` SQL table. While the conversion runs players are prevented from joining. If `changeMap` is true, the current map reloads once conversion finishes.

**Parameters:**

* `changeMap` (`boolean`) – Whether to reload the current map when finished.

**Realm:**

* Server

**Returns:**

* None

**Example Usage:**

```lua
    -- Force data conversion and reload the map
    lia.data.convertToDatabase(true)
```
