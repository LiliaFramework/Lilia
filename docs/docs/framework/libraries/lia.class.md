# lia.class

---

Classes are temporary assignments for characters—analogous to a "job" in a faction. For example, you may have a police faction in your schema and have "police recruit" and "police chief" as different classes in your faction. Anyone can join a class in their faction by default, but you can restrict this as needed with `CLASS.OnCanBe`.

If you are looking for the class structure, you can find it [here](./framework/definitions/class).

---

### **lia.class.loadFromDir**

**Description:**  
Loads class information from Lua files in the specified directory.

**Realm:**  
`Shared`

**Parameters:**  

- `directory` (`string`): The directory path from which to load class Lua files.

**Example Usage:**
```lua
lia.class.loadFromDir("schema/classes")
```

---

### **lia.class.canBe**

**Description:**  
Checks if a player can join a particular class.

**Realm:**  
`Shared`

**Parameters:**  

- `client` (`Player`): The player wanting to join the class.
- `class` (`integer`): The identifier of the class.

**Returns:**  
- `boolean`: Whether the player can join the class.
- `string`: Reason for the failure, if any.

**Example Usage:**
```lua
local canJoin, reason = lia.class.canBe(playerInstance, 2)
if canJoin then
    print("Player can join the class.")
else
    print("Cannot join class:", reason)
end
```

---

### **lia.class.get**

**Description:**  
Retrieves information about a class.

**Realm:**  
`Shared`

**Parameters:**  

- `identifier` (`integer`): The identifier of the class.

**Returns:**  
`table`: Information about the class.

**Example Usage:**
```lua
local classInfo = lia.class.get(1)
print(classInfo.name) -- Outputs the name of the class
```

---

### **lia.class.getPlayers**

**Description:**  
Retrieves a list of players belonging to a specific class.

**Realm:**  
`Shared`

**Parameters:**  

- `class` (`integer`): The identifier of the class.

**Returns:**  
`table`: List of players belonging to the class.

**Example Usage:**
```lua
local policePlayers = lia.class.getPlayers(3)
for _, player in ipairs(policePlayers) do
    print(player:Nick() .. " is a police officer.")
end
```

---

### **lia.class.getPlayerCount**

**Description:**  
Retrieves the count of players belonging to a specific class.

**Realm:**  
`Shared`

**Parameters:**  

- `class` (`integer`): The identifier of the class.

**Returns:**  
`integer`: The count of players belonging to the class.

**Example Usage:**
```lua
local count = lia.class.getPlayerCount(3)
print("Number of police officers:", count)
```

---

### **lia.class.retrieveClass**

**Description:**  
Retrieves the identifier of a class based on its unique ID or name.

**Realm:**  
`Shared`

**Parameters:**  

- `class` (`string`): The unique ID or name of the class.

**Returns:**  
`integer|nil`: The identifier of the class if found, `nil` otherwise.

**Example Usage:**
```lua
local classID = lia.class.retrieveClass("police_chief")
if classID then
    print("Class ID:", classID)
else
    print("Class not found.")
end
```

---

### **lia.class.hasWhitelist**

**Description:**  
Checks if a class has a whitelist.

**Realm:**  
`Shared`

**Parameters:**  

- `class` (`integer`): The identifier of the class.

**Returns:**  
`boolean`: `true` if the class has a whitelist, `false` otherwise.

**Example Usage:**
```lua
local hasWL = lia.class.hasWhitelist(2)
if hasWL then
    print("This class has a whitelist.")
else
    print("This class does not have a whitelist.")
end
```
---
