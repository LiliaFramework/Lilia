# lia.data

---

The `lia.data` library provides functions to manage persistent data storage within the `data/lilia` directory. This includes setting, retrieving, and deleting data files, as well as handling data persistence during map cleanup and server shutdown. This library ensures that data is consistently saved and loaded, maintaining the integrity of player and game-related information across sessions.

**NOTE:** Always ensure that data paths and keys are correctly specified to prevent data loss or corruption.

---

### **lia.data.set**

**Description:**  
Populates a file in the `data/lilia` folder with serialized data.

**Realm:**  
`Server`

**Parameters:**  

- `key` (`string`): Name of the file to save.
- `value` (`any`): Data to save.
- `global` (`boolean`, optional, default `false`): Determines whether to write directly to the `data/lilia` folder (`true`) or to the `data/lilia/schema` folder (`false`).
- `ignoreMap` (`boolean`, optional, default `false`): If `true`, saves in the schema folder instead of `data/lilia/schema/map`.

**Returns:**  
`string` - The path where the file is saved.

**Example Usage:**
```lua
lia.data.set("playerStats", {kills = 10, deaths = 2}, false, false)
```

---

### **lia.data.delete**

**Description:**  
Deletes the contents of a saved file in the `data/lilia` folder.

**Realm:**  
`Server`

**Parameters:**  

- `key` (`string`): Name of the file to delete.
- `global` (`boolean`, optional, default `false`): Determines whether to delete from the `data/lilia` folder (`true`) or the `data/lilia/schema` folder (`false`).
- `ignoreMap` (`boolean`, optional, default `false`): If `true`, deletes from the schema folder instead of `data/lilia/schema/map`.

**Returns:**  
`boolean` - Whether the deletion succeeded.

**Example Usage:**
```lua
local success = lia.data.delete("playerStats")
if success then
    print("Player stats deleted successfully.")
else
    print("Failed to delete player stats.")
end
```

---

### **lia.data.get**

**Description:**  
Retrieves the contents of a saved file in the `data/lilia` folder.

**Realm:**  
`Shared`

**Parameters:**  

- `key` (`string`): Name of the file to load.
- `default` (`any`): Value to return if the file could not be loaded successfully.
- `global` (`boolean`, optional, default `false`): Determines whether to load from the `data/lilia` folder (`true`) or the `data/lilia/schema` folder (`false`).
- `ignoreMap` (`boolean`, optional, default `false`): If `true`, loads from the schema folder instead of `data/lilia/schema/map`.
- `refresh` (`boolean`, optional, default `false`): If `true`, skips the cache and forcefully loads from disk.

**Returns:**  
`any` - Value associated with the key, or the default value if it doesn't exist.

**Example Usage:**
```lua
local playerStats = lia.data.get("playerStats", {kills = 0, deaths = 0})
print("Kills:", playerStats.kills)
print("Deaths:", playerStats.deaths)
```

---

### **lia.data.set**

**Description:**  
Initializes currency settings based on the configuration after a short delay.

**Internal:**  

This function is intended for internal use and should not be called directly.

**Example Usage:**
```lua
timer.Simple(1, function()
    lia.currency.set(lia.config.CurrencySymbol, lia.config.CurrencySingularName, lia.config.CurrencyPluralName)
end)
```

---