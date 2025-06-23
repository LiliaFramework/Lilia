# lia.db

---

The `lia.db` library provides comprehensive functions to manage persistent data storage within the `data/lilia` directory. It supports both SQLite and MySQL (via MySQLOO) database modules, allowing for flexible data handling depending on your server's configuration. This library handles tasks such as setting, retrieving, and deleting data files, managing query queues, handling prepared statements, and ensuring data persistence during map cleanup and server shutdown.

**NOTE:** Ensure that your database configurations are correctly set to prevent connection issues. Always validate and sanitize inputs to maintain data integrity and security.

---

### **lia.db.connect**

**Description:**  
Establishes a connection to the specified database module based on the configuration. If the database is not connected yet or if reconnection is forced, it connects to the database module.

**Realm:**  
`Server`

**Parameters:**  

- `callback` (`function`, optional): A function to be called after the database connection is established.
- `reconnect` (`boolean`, optional, default `false`): Determines whether to force a reconnection to the database module.

**Example Usage:**
```lua
lia.db.connect(function()
    print("Database connected successfully!")
end)
```

---

### **lia.db.convertDataType**

**Description:**  
Converts a Lua value to a format suitable for insertion into the database.

**Realm:**  
`Server`

**Parameters:**  

- `value` (`any`): The value to be converted.
- `noEscape` (`boolean`, optional, default `false`): Whether to skip escaping the value.

**Returns:**  
`string` - The converted value suitable for database insertion.

**Example Usage:**
```lua
local safeValue = lia.db.convertDataType("O'Reilly")
print(safeValue) -- Outputs: 'O\'Reilly'
```

---

### **lia.db.delete**

**Description:**  
Deletes rows from the specified database table based on the given condition.

**Realm:**  
`Server`

**Parameters:**  

- `dbTable` (`string`, optional, default `"character"`): The name of the database table.
- `condition` (`string`, optional): The condition to apply to the deletion.

**Returns:**  
`Deferred` - A deferred object that resolves to a table containing the deletion results and the last inserted ID.

**Example Usage:**
```lua
lia.db.delete("characters", "_id = 1"):next(function(result)
    print("Deletion successful:", result.results)
end)
```

---

### **lia.db.insertTable**

**Description:**  
Inserts a new row into the specified database table with the provided values.

**Realm:**  
`Server`

**Parameters:**  

- `value` (`table`): The values to be inserted into the table.
- `callback` (`function`, optional): A function to be called after the insertion operation is completed.
- `dbTable` (`string`, optional, default `"characters"`): The name of the database table.

**Returns:**  
`Deferred` - A deferred object that resolves to a table containing the insertion results and the last inserted ID.

**Example Usage:**
```lua
lia.db.insertTable({
    _steamID = "STEAM_0:1:123456",
    _name = "John Doe",
    _desc = "A brave warrior.",
    _model = "models/player.mdl",
    _money = 100,
    _faction = "Warriors"
}, function(result)
    print("Character inserted with ID:", result.lastID)
end)
```

---

### **lia.db.loadTables**

**Description:**  
Loads the necessary tables into the database.

**Realm:**  
`Server`
---

### **lia.db.prepare**

**Description:**  
Prepares a SQL statement with the specified key, query string, and value types for later execution.

**Realm:**  
`Server`

**Parameters:**  

- `key` (`string`): The unique key for the prepared statement.
- `str` (`string`): The SQL query string.
- `values` (`table`): A table defining the types of the values (`MYSQLOO_INTEGER`, `MYSQLOO_STRING`, `MYSQLOO_BOOL`).

**Example Usage:**
```lua
lia.db.prepare("insertPlayer", "INSERT INTO lia_players (_steamID, _steamName) VALUES (?, ?)", {MYSQLOO_STRING, MYSQLOO_STRING})
```

---

### **lia.db.preparedCall**

**Description:**  
Executes a prepared SQL statement with the specified key and arguments.

**Realm:**  
`Server`

**Parameters:**  

- `key` (`string`): The unique key for the prepared statement.
- `callback` (`function`): A function to be called after the prepared statement is executed.
- `...` (`any`): Arguments to pass to the prepared statement.

**Example Usage:**
```lua
lia.db.preparedCall("insertPlayer", function(result)
    print("Player inserted successfully with ID:", result.lastID)
end, "STEAM_0:1:123456", "John Doe")
```

---

### **lia.db.select**

**Description:**  
Selects data from the specified database table based on the provided fields, condition, and limit.

**Realm:**  
`Server`

**Parameters:**  

- `fields` (`table|string`): The fields to select from the table.
- `dbTable` (`string`, optional, default `"characters"`): The name of the database table.
- `condition` (`string`, optional): The condition to apply to the selection.
- `limit` (`integer`, optional): The maximum number of rows to retrieve.

**Returns:**  
`Deferred` - A deferred object that resolves to a table containing the selected results and the last inserted ID.

**Example Usage:**
```lua
lia.db.select({"_name", "_money"}, "characters", "_id = 1", 1):next(function(result)
    print("Character Name:", result.results[1]._name)
    print("Money:", result.results[1]._money)
end)
```

---

### **lia.db.upsert**

**Description:**  
Inserts or updates rows in the specified database table with the provided values.

**Realm:**  
`Server`

**Parameters:**  

- `value` (`table`): The values to be inserted or updated in the table.
- `dbTable` (`string`, optional, default `"characters"`): The name of the database table.

**Returns:**  
`Deferred` - A deferred object that resolves to a table containing the insertion or update results and the last inserted ID.

**Example Usage:**
```lua
lia.db.upsert({
    _id = 1,
    _name = "John Doe",
    _money = 150
}, "characters"):next(function(result)
    print("Upsert completed with ID:", result.lastID)
end)
```

---

### **lia.db.waitForTablesToLoad**

**Description:**  
Waits for the database tables to be loaded.

**Realm:**  
`Server`

**Returns:**  
`Deferred` - A deferred object that resolves when the tables are loaded.

**Example Usage:**
```lua
lia.db.waitForTablesToLoad():next(function()
    print("Database tables are loaded and ready.")
end)
```