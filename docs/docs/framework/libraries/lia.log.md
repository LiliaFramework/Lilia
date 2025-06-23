# lia.log

---

Logging helper functions.

The `lia.log` library provides robust logging capabilities within the Lilia Framework. It allows developers to categorize, format, and manage log messages efficiently on the server side. By leveraging this system, developers can maintain organized logs for various events, enhancing debugging and administrative oversight.

---

## Functions

### **lia.log.loadTables**

**Description:**  
Creates directories for storing logs. This internal server function ensures that the necessary directory structure exists for log storage.

**Realm:**  
`Server`

**Internal:**  
This function is intended for internal use and should not be called directly.

---

### **lia.log.addType**

**Description:**  
Adds a new log type to the logging system. This function registers a log category with a specific formatting callback and optional color.

**Realm:**  
`Server`

**Parameters:**  

- `logType` (`string`):  
  Log category identifier.

- `func` (`function`):  
  Callback function to format the log string. Signature: `func(client, ...)`

- `category` (`string`):  
  Human-readable category name for the log.

- `color` (`Color`, optional):  
  Color associated with the log category. Defaults to `Color(52, 152, 219)` if not provided.


**Example Usage:**
```lua
-- Define a new log type "playerJoin"
lia.log.addType("playerJoin", function(client, playerName)
    return playerName .. " has joined the game."
end, "Player Join", Color(46, 204, 113))
```

---

### **lia.log.getString**

**Description:**  
Retrieves a formatted log string based on the specified log type and additional arguments. This internal server function processes the log formatting callback associated with the log type.

**Realm:**  
`Server`

**Parameters:**  

- `client` (`Player`):  
  The player entity associated with the log.

- `logType` (`string`):  
  The type of log to generate.

- `...` (`any`):  
  Additional arguments to pass to the log generation function.

**Returns:**  
`string, string, Color|nil`  
Returns the formatted log string, its category, and color. If the log type is invalid, returns `nil`.

**Example Usage:**
```lua
local logString, category, color = lia.log.getString(client, "playerJoin", "Alice")
print(logString)  -- Output: "Alice has joined the game."
```

---

### **lia.log.add**

**Description:**  
Adds a log message to the logging system. It formats the log based on its type and appends it to the corresponding log file. Additionally, it triggers the `OnServerLog` hook for further processing.

**Realm:**  
`Server`

**Parameters:**  

- `client` (`Player`):  
  The player entity who instigated the log.

- `logType` (`string`):  
  The category of the log.

- `...` (`any`):  
  Arguments to pass to the log formatting function.

**Example Usage:**
```lua
-- Log a player joining the game
lia.log.add(player, "playerJoin", player:GetName())
```

---

### **lia.log.send**

**Description:**  
Sends a log message to a specified client. This function transmits the log string using the `liaLogStream` network message.

**Realm:**  
`Server`

**Parameters:**  

- `client` (`Player`):  
  The client to whom the log message will be sent.

- `logString` (`string`):  
  The log message to be sent.

**Example Usage:**
```lua
-- Send a custom log message to a client
lia.log.send(targetPlayer, "You have received a special item!")
```
