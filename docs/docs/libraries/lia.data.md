# Data Library


This page describes persistent data storage helpers.


---


## Overview


The data library persists key/value pairs either on disk or through the database backend. It supplies convenience methods for saving, retrieving, and deleting stored data.


---


### lia.data.set(key, value, global, ignoreMap)

**Description:**


Saves the provided value under the specified key to persistent storage.

The data is written to a file whose path is constructed based on the folder, map, and flags.

Also caches the value in lia.data.stored.


**Parameters:**


* key (string) – The key under which the data is stored.


* value (any) – The value to store.


* global (boolean) – If true, uses a global path; otherwise, includes folder and map.


* ignoreMap (boolean) – If true, ignores the map directory.


**Realm:**


* Shared


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


### lia.data.delete(key, global, ignoreMap)

**Description:**


Deletes the stored data file corresponding to the specified key.

Also removes the value from the cached storage.


**Parameters:**


* key (string) – The key corresponding to the data to be deleted.


* global (boolean) – If true, uses a global path; otherwise, includes folder and map.


* ignoreMap (boolean) – If true, ignores the map directory.


**Realm:**


* Shared


**Returns:**


* boolean – True if the file was deleted, false otherwise.


**Example Usage:**


```lua
    -- This snippet demonstrates a common usage of lia.data.delete
    lia.data.delete("spawn_pos")
```


---


### lia.data.get(key, default, global, ignoreMap, refresh)

**Description:**


Retrieves the stored data for the specified key.

If refresh is not set and data exists in cache, returns the cached data.

Otherwise, reads from the file, decodes, and caches the value.


**Parameters:**


* key (string) – The key corresponding to the data.


* default (any) – The default value to return if no data is found.


* global (boolean) – If true, uses a global path; otherwise, includes folder and map.


* ignoreMap (boolean) – If true, ignores the map directory.


* refresh (boolean) – If true, forces reading from file instead of cache.


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

