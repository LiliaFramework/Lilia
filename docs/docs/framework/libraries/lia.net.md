# lia.net

---

Networking helper functions.

The `lia.net` library provides essential networking utilities within the Lilia Framework. It facilitates the management of global networked variables, ensuring synchronized data between the server and clients. Additionally, it integrates with various game hooks to maintain network integrity and handle events related to entities and characters.

---

## Functions

### **lia.net.setNetVar**

**Description:**  
Sets the value of a networked global variable. This function updates the global variable and notifies clients of the change, ensuring that all connected clients have the latest value.

**Realm:**  
`Server`

**Parameters:**  

- `key` (`string`):  
  The key of the networked global variable.

- `value` (`any`):  
  The value to set for the global variable.

- `receiver` (`Player`, optional):  
  The specific client to receive the network update. If omitted, all clients are notified.

**Example Usage:**
```lua
-- Set a global variable "gameState" to "active" for all clients
lia.net.setNetVar("gameState", "active")

-- Set a global variable "playerScore" to 100 for a specific client
lia.net.setNetVar("playerScore", 100, targetPlayer)
```

---

### **lia.net.getNetVar**

**Description:**  
Retrieves the value of a networked global variable. If the variable does not exist, it returns the provided default value.

**Realm:**  
`Shared`

**Parameters:**  

- `key` (`string`):  
  The key of the networked global variable.

- `default` (`any`):  
  The default value to return if the variable is not found.

**Returns:**  
`any` - The value of the networked global variable, or the default value if not found.

**Example Usage:**
```lua
-- Get the current game state, defaulting to "inactive" if not set
local currentState = lia.net.getNetVar("gameState", "inactive")
print("Current Game State:", currentState)
```

---

### **lia.net.checkBadType**

**Description:**  
Checks if the provided object or any of its nested elements contain an unsupported type. This internal function ensures that only valid data types are used for networked variables, preventing potential runtime errors.

**Realm:**  
`Server`

**Parameters:**  

- `name` (`string`):  
  The name of the networked variable being checked.

- `object` (`any`):  
  The object to be checked for unsupported types.

**Returns:**  
`bool` - `True` if a bad type is found, `false` otherwise.

**Internal:**  
This function is intended for internal use and should not be called directly.

**Example Usage:**
```lua
-- Internal usage within lia.net
local hasBadType = lia.net.checkBadType("playerData", someObject)
if hasBadType then
    print("Invalid data type detected for playerData.")
end
```

