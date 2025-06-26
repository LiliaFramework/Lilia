---

### **Example**

```lua
MODULE.name = "My Module"
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `name`                                  | Identifies the module in logs and UI elements. | `string`    | `MODULE.name = "My Module"` |

---

### **Detailed Descriptions**

#### 1. `name`

- **Purpose:**  
    Identifies the module in logs and UI elements.

- **Type:**  
    `string`

- **Example Usage:
    ```lua
MODULE.name = "My Module"
    ```

---

---

### **Example**

```lua
MODULE.author = "Samael"
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `author`                                  | Name or SteamID64 of the module's author. | `string`    | `MODULE.author = "Samael"` |

---

### **Detailed Descriptions**

#### 1. `author`

- **Purpose:**  
    Name or SteamID64 of the module's author.

- **Type:**  
    `string`

- **Example Usage:
    ```lua
MODULE.author = "Samael"
    ```

---

---

### **Example**

```lua
MODULE.discord = "@liliaplayer"
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `discord`                                  | Discord tag or support channel for the module. | `string`    | `MODULE.discord = "@liliaplayer"` |

---

### **Detailed Descriptions**

#### 1. `discord`

- **Purpose:**  
    Discord tag or support channel for the module.

- **Type:**  
    `string`

- **Example Usage:
    ```lua
MODULE.discord = "@liliaplayer"
    ```

---

---

### **Example**

```lua
MODULE.version = "1.0"
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `version`                                  | Version string used for compatibility checks. | `string`    | `MODULE.version = "1.0"` |

---

### **Detailed Descriptions**

#### 1. `version`

- **Purpose:**  
    Version string used for compatibility checks.

- **Type:**  
    `string`

- **Example Usage:
    ```lua
MODULE.version = "1.0"
    ```

---

---

### **Example**

```lua
MODULE.desc = "Adds a Chatbox"
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `desc`                                  | Short description of what the module provides. | `string`    | `MODULE.desc = "Adds a Chatbox"` |

---

### **Detailed Descriptions**

#### 1. `desc`

- **Purpose:**  
    Short description of what the module provides.

- **Type:**  
    `string`

- **Example Usage:
    ```lua
MODULE.desc = "Adds a Chatbox"
    ```

---

---

### **Example**

```lua
MODULE.identifier = "example_mod"
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `identifier`                                  | Unique key used to reference this module globally. | `string`    | `MODULE.identifier = "example_mod"` |

---

### **Detailed Descriptions**

#### 1. `identifier`

- **Purpose:**  
    Unique key used to reference this module globally.

- **Type:**  
    `string`

- **Example Usage:
    ```lua
MODULE.identifier = "example_mod"
    ```

---

---

### **Example**

```lua
MODULE.CAMIPrivileges = {
{Name = "Staff Permissions - Admin Chat", MinAccess = "admin"}
}
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `CAMIPrivileges`                                  | Table defining CAMI privileges required or provided by the module. | `table`    | `MODULE.CAMIPrivileges = {
{Name = "Staff Permissions - Admin Chat", MinAccess = "admin"}
}` |

---

### **Detailed Descriptions**

#### 1. `CAMIPrivileges`

- **Purpose:**  
    Table defining CAMI privileges required or provided by the module.

- **Type:**  
    `table`

- **Example Usage:
    ```lua
MODULE.CAMIPrivileges = {
{Name = "Staff Permissions - Admin Chat", MinAccess = "admin"}
}
    ```

---

---

### **Example**

```lua
MODULE.WorkshopContent = {"2959728255"}
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `WorkshopContent`                                  | Steam Workshop add-on IDs required by this module. | `table`    | `MODULE.WorkshopContent = {"2959728255"}` |

---

### **Detailed Descriptions**

#### 1. `WorkshopContent`

- **Purpose:**  
    Steam Workshop add-on IDs required by this module.

- **Type:**  
    `table`

- **Example Usage:
    ```lua
MODULE.WorkshopContent = {"2959728255"}
    ```

---

---

### **Example**

```lua
MODULE.enabled = true
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `enabled`                                  | Boolean or function that controls whether the module loads. | `boolean or function`    | `MODULE.enabled = true` |

---

### **Detailed Descriptions**

#### 1. `enabled`

- **Purpose:**  
    Boolean or function that controls whether the module loads.

- **Type:**  
    `boolean or function`

- **Example Usage:
    ```lua
MODULE.enabled = true
    ```

---

---

### **Example**

```lua
MODULE.Dependencies = {
{File = "logs.lua", Realm = "server"}
}
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `Dependencies`                                  | Files or folders that this module requires to run. | `table`    | `MODULE.Dependencies = {
{File = "logs.lua", Realm = "server"}
}` |

---

### **Detailed Descriptions**

#### 1. `Dependencies`

- **Purpose:**  
    Files or folders that this module requires to run.

- **Type:**  
    `table`

- **Example Usage:
    ```lua
MODULE.Dependencies = {
{File = "logs.lua", Realm = "server"}
}
    ```

---

---

### **Example**

```lua
print(MODULE.folder)
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `folder`                                  | Filesystem path where the module is located. | `string`    | `print(MODULE.folder)` |

---

### **Detailed Descriptions**

#### 1. `folder`

- **Purpose:**  
    Filesystem path where the module is located.

- **Type:**  
    `string`

- **Example Usage:
    ```lua
print(MODULE.folder)
    ```

---

---

### **Example**

```lua
print(MODULE.path)
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `path`                                  | Absolute path to the module's root directory. | `string`    | `print(MODULE.path)` |

---

### **Detailed Descriptions**

#### 1. `path`

- **Purpose:**  
    Absolute path to the module's root directory.

- **Type:**  
    `string`

- **Example Usage:
    ```lua
print(MODULE.path)
    ```

---

---

### **Example**

```lua
print(MODULE.uniqueID)
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `uniqueID`                                  | Identifier used internally for the module list. | `string`    | `print(MODULE.uniqueID)` |

---

### **Detailed Descriptions**

#### 1. `uniqueID`

- **Purpose:**  
    Identifier used internally for the module list.

- **Type:**  
    `string`

- **Example Usage:
    ```lua
print(MODULE.uniqueID)
    ```

---

---

### **Example**

```lua
if MODULE.loading then return end
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `loading`                                  | True while the module is in the process of loading. | `boolean`    | `if MODULE.loading then return end` |

---

### **Detailed Descriptions**

#### 1. `loading`

- **Purpose:**  
    True while the module is in the process of loading.

- **Type:**  
    `boolean`

- **Example Usage:
    ```lua
if MODULE.loading then return end
    ```

---

---

### **Example**

```lua
function MODULE:ModuleLoaded()
print("Module fully initialized")
end
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `ModuleLoaded`                                  | Optional callback run after the module finishes loading. | `function`    | `function MODULE:ModuleLoaded()
print("Module fully initialized")
end` |

---

### **Detailed Descriptions**

#### 1. `ModuleLoaded`

- **Purpose:**  
    Optional callback run after the module finishes loading.

- **Type:**  
    `function`

- **Example Usage:
    ```lua
function MODULE:ModuleLoaded()
print("Module fully initialized")
end
    ```

---

---

### **Example**

```lua
MODULE.Public = true
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `Public`                                  | When true, the module participates in public version checks. | `boolean`    | `MODULE.Public = true` |

---

### **Detailed Descriptions**

#### 1. `Public`

- **Purpose:**  
    When true, the module participates in public version checks.

- **Type:**  
    `boolean`

- **Example Usage:
    ```lua
MODULE.Public = true
    ```

---

---

### **Example**

```lua
MODULE.Private = true
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `Private`                                  | When true, the module uses private version checking. | `boolean`    | `MODULE.Private = true` |

---

### **Detailed Descriptions**

#### 1. `Private`

- **Purpose:**  
    When true, the module uses private version checking.

- **Type:**  
    `boolean`

- **Example Usage:
    ```lua
MODULE.Private = true
    ```

---

