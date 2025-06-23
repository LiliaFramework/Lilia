# lia.module

---

The `lia.module` library is responsible for loading, initializing, and managing modules within the Lilia Framework. It handles module dependencies, permissions, workshop content, and integrates various components such as languages, factions, classes, attributes, entities, and items. By utilizing this library, developers can efficiently organize and manage different modules, ensuring seamless integration and functionality across the framework.

---

## Functions

### **lia.module.load**

**Description:**  
Loads a module into the system. This function handles the inclusion of module files, manages dependencies, registers permissions, and initializes module-specific data.

**Realm:**  
`Shared`

**Parameters:**  

- `uniqueID` (`string`):  
  The unique identifier of the module.

- `path` (`string`):  
  The file system path to the module.

- `isSingleFile` (`bool`):  
  Specifies if the module is contained in a single file.

- `variable` (`string`):  
  The variable name to assign the module to.

- `firstLoad` (`bool`):  
  Indicates if this is the first load of the module.

**Example Usage:**
```lua
-- Load a module with unique ID "exampleModule"
lia.module.load("exampleModule", "path/to/exampleModule", false, "EXAMPLE_MODULE", true)
```

---

### **lia.module.OnFinishLoad**

**Description:**  
Called after a module finishes loading to load its submodules. This internal function ensures that any submodules within a module are properly loaded and initialized.

**Realm:**  
`Shared`

**Parameters:**  

- `path` (`string`):  
  The file system path to the module.

- `firstLoad` (`bool`):  
  Indicates if this is the first load of the module.

**Example Usage:**
```lua
-- This function is typically called internally by lia.module.load
lia.module.OnFinishLoad("path/to/module", true)
```

---

### **lia.module.initialize**

**Description:**  
Loads and initializes all modules. This function is typically called during the framework's startup to ensure that all core and schema-specific modules are loaded correctly.

**Realm:**  
`Shared`

**Parameters:**  

- `firstLoad` (`bool`):  
  Indicates if this is the first load of the modules.

**Example Usage:**
```lua
-- Initialize all modules on server start
lia.module.initialize(true)
```

---

### **lia.module.loadFromDir**

**Description:**  
Loads modules from a specified directory. It handles both single-file modules and multi-file modules, ensuring that all relevant files and subdirectories are included.

**Realm:**  
`Shared`

**Parameters:**  

- `directory` (`string`):  
  The path to the directory containing modules.

- `group` (`string`):  
  The group of the modules (e.g., "schema" or "module").

- `firstLoad` (`bool`):  
  Indicates if this is the first load of the modules.

**Example Usage:**
```lua
-- Load all modules from the "utilities" directory
lia.module.loadFromDir("lilia/modules/utilities", "module", false)
```

---

### **lia.module.get**

**Description:**  
Retrieves a module by its identifier. This function allows access to the module's properties and functions based on its unique identifier.

**Realm:**  
`Shared`

**Parameters:**  

- `identifier` (`string`):  
  The identifier of the module.

**Returns:**  
`table|nil` - The module object if found, otherwise `nil`.

**Example Usage:**
```lua
-- Retrieve the "exampleModule" module
local exampleModule = lia.module.get("exampleModule")
if exampleModule then
    print("Module Name:", exampleModule.name)
end
```

---

## Variables

### **lia.module.EnabledList**

**Description:**  
A table that keeps track of enabled modules. Each key corresponds to a module's unique identifier, and the value indicates whether the module is enabled (`true`) or disabled (`false`).

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
-- Check if "exampleModule" is enabled
if lia.module.EnabledList["exampleModule"] then
    print("Example Module is enabled.")
else
    print("Example Module is disabled.")
end
```

---

### **lia.module.list**

**Description:**  
A table that stores all loaded modules. Each key is the module's unique identifier, and the value is the module's table containing its properties and functions.

**Realm:**  
`Shared`

**Type:**  
`table`

**Example Usage:**
```lua
-- Iterate through all loaded modules
for uniqueID, module in pairs(lia.module.list) do
    print("Loaded Module:", uniqueID, "Name:", module.name)
end
```

---

