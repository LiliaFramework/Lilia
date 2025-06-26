---

### **Example**

```lua
alias = {"chargiveflag", "giveflag"}
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `alias`                                  | Alternative command names that also trigger the same command.
Can be a single string or a table of strings. | `Unknown`    | `alias = {"chargiveflag", "giveflag"}` |

---

### **Detailed Descriptions**

#### 1. `alias`

- **Purpose:**  
    Alternative command names that also trigger the same command.
Can be a single string or a table of strings.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
alias = {"chargiveflag", "giveflag"}
    ```

---

---

### **Example**

```lua
adminOnly = true
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `adminOnly`                                  | When true only players with admin privileges (or higher)
may run the command. A CAMI privilege is registered
automatically. | `Unknown`    | `adminOnly = true` |

---

### **Detailed Descriptions**

#### 1. `adminOnly`

- **Purpose:**  
    When true only players with admin privileges (or higher)
may run the command. A CAMI privilege is registered
automatically.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
adminOnly = true
    ```

---

---

### **Example**

```lua
superAdminOnly = true
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `superAdminOnly`                                  | Restricts usage to super administrators. Like adminOnly this
registers a CAMI privilege if needed. | `Unknown`    | `superAdminOnly = true` |

---

### **Detailed Descriptions**

#### 1. `superAdminOnly`

- **Purpose:**  
    Restricts usage to super administrators. Like adminOnly this
registers a CAMI privilege if needed.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
superAdminOnly = true
    ```

---

---

### **Example**

```lua
privilege = "Manage Doors"
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `privilege`                                  | Name of the CAMI privilege checked when running the command.
If omitted, the command name itself is used as the privilege. | `Unknown`    | `privilege = "Manage Doors"` |

---

### **Detailed Descriptions**

#### 1. `privilege`

- **Purpose:**  
    Name of the CAMI privilege checked when running the command.
If omitted, the command name itself is used as the privilege.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
privilege = "Manage Doors"
    ```

---

---

### **Example**

```lua
syntax = "[string target] [number amount]"
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `syntax`                                  | Human readable syntax string shown in help menus. This has
no effect on parsing but informs players how to format
the arguments. | `Unknown`    | `syntax = "[string target] [number amount]"` |

---

### **Detailed Descriptions**

#### 1. `syntax`

- **Purpose:**  
    Human readable syntax string shown in help menus. This has
no effect on parsing but informs players how to format
the arguments.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
syntax = "[string target] [number amount]"
    ```

---

---

### **Example**

```lua
desc = L("doorbuyDesc")
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `desc`                                  | Short description of what the command does. Displayed in
command lists and menus. | `Unknown`    | `desc = L("doorbuyDesc")` |

---

### **Detailed Descriptions**

#### 1. `desc`

- **Purpose:**  
    Short description of what the command does. Displayed in
command lists and menus.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
desc = L("doorbuyDesc")
    ```

---

---

### **Example**

```lua
AdminStick = {
Name = "Set Character Skin",
Category = "Player Informations",
SubCategory = "Set Informations",
Icon = "icon16/user_gray.png",
ExtraFields = {
["skin"] = "number"
}
}
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `AdminStick`                                  | Table describing how the command should appear in admin
utilities. Common keys include:
Name        - display text in the menu.
Category    - top level grouping.
SubCategory - secondary grouping.
Icon        - 16x16 icon path.
ExtraFields - additional field definitions. | `Unknown`    | `AdminStick = {
Name = "Set Character Skin",
Category = "Player Informations",
SubCategory = "Set Informations",
Icon = "icon16/user_gray.png",
ExtraFields = {
["skin"] = "number"
}
}` |

---

### **Detailed Descriptions**

#### 1. `AdminStick`

- **Purpose:**  
    Table describing how the command should appear in admin
utilities. Common keys include:
Name        - display text in the menu.
Category    - top level grouping.
SubCategory - secondary grouping.
Icon        - 16x16 icon path.
ExtraFields - additional field definitions.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
AdminStick = {
Name = "Set Character Skin",
Category = "Player Informations",
SubCategory = "Set Informations",
Icon = "icon16/user_gray.png",
ExtraFields = {
["skin"] = "number"
}
}
    ```

---

---

### **Example**

```lua
onRun = function(client, arguments)
local target = lia.util.findPlayer(client, arguments[1])
if target then
target:Kill()
end
end
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `onRun(client, arguments)`                                  | Function executed when the command is run. Arguments are
already parsed and provided as a table.
Return a string to notify the caller or nothing to stay silent. | `Unknown`    | `onRun = function(client, arguments)
local target = lia.util.findPlayer(client, arguments[1])
if target then
target:Kill()
end
end` |

---

### **Detailed Descriptions**

#### 1. `onRun(client, arguments)`

- **Purpose:**  
    Function executed when the command is run. Arguments are
already parsed and provided as a table.
Return a string to notify the caller or nothing to stay silent.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
onRun = function(client, arguments)
local target = lia.util.findPlayer(client, arguments[1])
if target then
target:Kill()
end
end
    ```

---

