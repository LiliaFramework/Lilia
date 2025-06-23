# lia.faction

---

The `lia.faction` library facilitates the creation, retrieval, and management of factions within the Lilia Framework. It allows developers to load faction data from directories, access faction details, manage associated classes and players, and handle faction categories. This library ensures that factions are consistently integrated into the game environment, enhancing organization and functionality.

**NOTE:** Ensure that faction files are correctly structured and placed in the specified directories to prevent loading issues. Always validate faction data to maintain consistency and integrity.

---

### **lia.faction.loadFromDir**

**Description:**  
Loads factions from a specified directory. It reads all Lua files within the given directory, processes each faction file, sets up the faction within the framework, and ensures that all necessary properties are defined. If essential properties are missing, default values are assigned, and warnings are logged.

**Realm:**  
`Shared`

**Parameters:**  

- `directory` (`string`): The path to the faction files.

**Example Usage:**
```lua
lia.faction.loadFromDir("schema/factions")
```

---

### **lia.faction.get**

**Description:**  
Retrieves a faction table based on its index or name. This function allows access to all properties and methods associated with a specific faction.

**Realm:**  
`Shared`

**Parameters:**  

- `identifier` (`int|string`): Index or name of the faction.

**Returns:**  
`table|nil` - The faction table if found, otherwise `nil`.

**Example Usage:**
```lua
local faction = lia.faction.get(1)
if faction then
    print("Faction Name:", faction.name)
end
```

---

### **lia.faction.getIndex**

**Description:**  
Retrieves the index of a faction based on its unique identifier. Useful for obtaining the numerical representation of a faction when you have its unique string ID.

**Realm:**  
`Shared`

**Parameters:**  

- `uniqueID` (`string`): Unique ID of the faction.

**Returns:**  
`number|nil` - The faction index if found, otherwise `nil`.

**Example Usage:**
```lua
local index = lia.faction.getIndex("police")
if index then
    print("Police Faction Index:", index)
end
```

---

### **lia.faction.getClasses**

**Description:**  
Returns a table containing all classes associated with a specific faction. Classes typically define roles or job types within a faction.

**Realm:**  
`Shared`

**Parameters:**  

- `faction` (`int`): The index of the faction.

**Returns:**  
`table` - A table containing the classes associated with the faction.

**Example Usage:**
```lua
local classes = lia.faction.getClasses(1)
for _, class in ipairs(classes) do
    print("Class Name:", class.name)
end
```

---

### **lia.faction.getPlayers**

**Description:**  
Returns a table containing all players belonging to a specific faction. This function iterates through all connected players and filters those who are part of the specified faction.

**Realm:**  
`Shared`

**Parameters:**  

- `faction` (`int`): The index of the faction.

**Returns:**  
`table` - A table containing the players belonging to the specified faction.

**Example Usage:**
```lua
local policePlayers = lia.faction.getPlayers(1)
for _, player in ipairs(policePlayers) do
    print("Police Officer:", player:Nick())
end
```

---

### **lia.faction.getPlayerCount**

**Description:**  
Returns the number of players belonging to a specific faction. Useful for tracking faction sizes and managing game balance.

**Realm:**  
`Shared`

**Parameters:**  

- `faction` (`int`): The index of the faction.

**Returns:**  
`number` - The number of players in the specified faction.

**Example Usage:**
```lua
local count = lia.faction.getPlayerCount(1)
print("Number of Police Officers:", count)
```

---

### **lia.faction.isFactionCategory**

**Description:**  
Checks if a given faction is part of a specified category of factions. Useful for grouping factions into broader categories for organizational purposes.

**Realm:**  
`Shared`

**Parameters:**  

- `faction` (`int`): The index of the faction to check.
- `categoryFactions` (`table`): A table containing faction indices that define the category.

**Returns:**  
`bool` - `true` if the faction is in the category, `false` otherwise.

**Example Usage:**
```lua
local isLawEnforcement = lia.faction.isFactionCategory(1, {1, 2, 3})
if isLawEnforcement then
    print("Faction is part of Law Enforcement.")
end
```

---

### **lia.faction.jobGenerate**

**Description:**  
Generates a custom faction by defining its properties such as index, name, color, default status, and associated models. This function is an example of how to create a custom faction programmatically. It is recommended to use faction files for defining factions to ensure consistency and prevent unexpected behavior.

**Realm:**  
`Shared`

**Parameters:**  

- `index` (`int`): The unique numerical identifier for the faction.
- `name` (`string`): The name of the faction.
- `color` (`Color`): The color representing the faction.
- `default` (`bool`): Indicates whether the faction is default.
- `models` (`table`): A table of models associated with the faction.

**Returns:**  
`table` - The generated faction table.

**Example Usage:**
```lua
local customFaction = lia.faction.jobGenerate(9, "Custom Faction", Color(255, 0, 0), false, {"models/player/custom_model.mdl", "models/player/custom_accessory.mdl"})
print("Custom Faction Created:", customFaction.name)
```

---

### **lia.faction.formatModelData**

**Description:**  
Iterates through faction model data and formats the model groups to ensure consistency and correctness. This function processes model group information, handling both server and client-side model precaching and group assignments.

**Realm:**  
`Shared`

**Example Usage:**
```lua
lia.faction.formatModelData()
```

**Note:**  
This function is intended for internal use within the `lia.faction` library and is not exposed for external use.

---

### **lia.faction.getDefaultClass**

**Description:**  
Retrieves the default class of a specified faction. The default class is determined based on the faction index and the `isDefault` flag set for each class.

**Realm:**  
`Shared`

**Parameters:**  

- `id` (`int`): The index of the faction for which to retrieve the default class.

**Returns:**  
`table|nil` - Information about the default class if found, `nil` otherwise.

**Example Usage:**
```lua
local defaultClass = lia.faction.getDefaultClass(1)
if defaultClass then
    print("Default Class:", defaultClass.name)
end
```

---

### **lia.faction.hasWhitelist**

**Description:**  
Determines whether a faction requires a whitelist. Useful for restricting access to certain factions based on predefined whitelist criteria.

**Realm:**  
`Client`

**Parameters:**  

- `faction` (`int`): Index of the faction.

**Returns:**  
`bool` - `true` if the faction requires a whitelist, `false` otherwise.

**Example Usage:**
```lua
if lia.faction.hasWhitelist(1) then
    print("Police faction requires a whitelist.")
end
```

---