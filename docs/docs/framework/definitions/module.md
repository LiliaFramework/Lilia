---

## **Example**

```lua
MODULE.name = "A Module"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.version = "Stock"
MODULE.desc = "This is an Example Module."
MODULE.WorkshopContent = {"2959728255"}
MODULE.enabled = true
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Kekw",
        MinAccess = "superadmin",
        Description = "Allows access to kewking.",
    },
}
MODULE.Dependencies = {
    {
        File = MODULE.path .. "/nicebogusfile.lua",
        Realm = "server",
    },
    {
        File = MODULE.path .. "/badbogusfile.lua",
        Realm = "client",
    },
}
```

---

## **Key Variables Explained**

| **Variable**                      | **Purpose**                                                            | **Type**                         | **Example**                                                                                  |
|----------------------------------|------------------------------------------------------------------------|----------------------------------|----------------------------------------------------------------------------------------------|
| `MODULE.name`                     | Identifies the module by name.                                         | `String`                         | `MODULE.name = "A Module"`<br>*Names the module “A Module.”*                                 |
| `MODULE.author`                   | Specifies the module’s author (e.g., STEAMID64 or a name).             | `String`                         | `MODULE.author = "Samael"`<br>*Sets the author’s SteamID64.*                      |
| `MODULE.discord` *(Optional)*     | Provides the Discord handle of the author or support channel.          | `String`                         | `MODULE.discord = "@liliaplayer"`<br>*Displays the author’s Discord tag.*                    |
| `MODULE.version` *(Optional)*     | Tracks the module’s version or release state.                          | `String`                         | `MODULE.version = "Stock"`<br>*Marks the module’s version as “Stock.”*                       |
| `MODULE.desc`                     | Describes the module’s functionality or purpose.                       | `String`                         | `MODULE.desc = "This is an Example Module."`<br>*Gives a short overview of the module.*      |
| `MODULE.identifier` *(Optional)*  | A unique identifier for external references to this module.            | `String`                         | `MODULE.identifier = "example_mod"`<br>*Helps in referencing the module externally.*         |
| `MODULE.CAMIPrivileges` *(Optional)* | Defines CAMI permissions for the module.                             | `Table`                          | See [CAMIPrivileges Details](#7-modulecamiprivileges-optional).                                      |
| `MODULE.WorkshopContent` *(Optional)* | Lists Workshop add-on IDs required by the module.                   | `Table` of `Strings`              | `MODULE.WorkshopContent = {"2959728255"}`<br>*Includes relevant Workshop items.*             |
| `MODULE.enabled` *(Optional)*     | Toggles module activation.                                             | `Boolean`                           | `MODULE.enabled = true`<br>*Enables the module.*                                             |
| `MODULE.Dependencies` *(Optional)*| Specifies files and realms this module depends on.                     | `Table` of `Table`               | See [Dependencies Details](#10-moduledependencies-optional).                                           |

---

## **Detailed Descriptions**

### 1. `MODULE.name`
- **Purpose:**  
  Names the module and is used for identification in logs or load orders.

- **Type:**  
  `String`

- **Example Usage:**
  ```lua
  MODULE.name = "A Module"
  ```
  *Sets the module’s name to “A Module.”*

---

### 2. `MODULE.author`
- **Purpose:**  
  Specifies the module’s author (e.g., STEAMID64 or a name).

- **Type:**  
  `String`

- **Example Usage:**
  ```lua
  MODULE.author = "Samael"
  ```
  *Sets the author’s SteamID64.*

---

### 3. `MODULE.discord` *(Optional)*
- **Purpose:**  
  Provides a Discord handle or server invite for support or communication.

- **Type:**  
  `String`

- **Example Usage:**
  ```lua
  MODULE.discord = "@liliaplayer"
  ```
  *Displays the author’s or module support’s Discord tag.*

---

### 4. `MODULE.version` *(Optional)*
- **Purpose:**  
  Tracks the module’s version or release state.

- **Type:**  
  `String`

- **Example Usage:**
  ```lua
  MODULE.version = "Stock"
  ```
  *Sets the module version to “Stock.” Can help in version control.*

---

### 5. `MODULE.desc`
- **Purpose:**  
  Describes the module’s functionality or purpose.

- **Type:**  
  `String`

- **Example Usage:**
  ```lua
  MODULE.desc = "This is an Example Module."
  ```
  *Gives users a quick summary of what the module does.*

---

### 6. `MODULE.identifier` *(Optional)*
- **Purpose:**  
  A unique identifier for external references to this module.

- **Type:**  
  `String`

- **Example Usage:**
  ```lua
  MODULE.identifier = "example_mod"
  ```
  *Allows other scripts or systems to reference this specific module.*

---

### 7. `MODULE.CAMIPrivileges` *(Optional)*
- **Purpose:**  
  Defines CAMI (Custom Admin Mod Interface) permissions required or provided by the module.  
  Each privilege can have keys like `Name`, `MinAccess`, and `Description`.

- **Type:**  
  `Table`

- **Example Usage:**
  ```lua
  MODULE.CAMIPrivileges = {
      {
          Name = "Staff Permissions - Kekw",
          MinAccess = "superadmin",
          Description = "Allows access to kewking.",
      },
  }
  ```
  *Sets up privileges using the CAMI system so admin mods can integrate these permissions.*

---

### 8. `MODULE.WorkshopContent` *(Optional)*
- **Purpose:**  
  Lists Workshop add-on IDs required by the module, enabling automatic downloading if your server or client references them.

- **Type:**  
  `Table` of `Strings`

- **Example Usage:**
  ```lua
  MODULE.WorkshopContent = {"2959728255"}
  ```
  *Ensures users download the specified Workshop add-ons.*

---

### 9. `MODULE.enabled` *(Optional)*
- **Purpose:**  
  Toggles module activation. If `false`, the module may not load or function.

- **Type:**  
  `Boolean`

- **Example Usage:**
  ```lua
  MODULE.enabled = true
  ```
  *Indicates that the module is currently active.*

---

### 10. `MODULE.Dependencies` *(Optional)*
- **Purpose:**  
  Specifies additional files or libraries needed by this module, along with where (client or server) they should load.

- **Type:**  
  `Table` of `Table`

- **Example Usage:**
  ```lua
  MODULE.Dependencies = {
      {
          File = MODULE.path .. "/nicebogusfile.lua",
          Realm = "server",
      },
      {
          File = MODULE.path .. "/badbogusfile.lua",
          Realm = "client",
      },
  }
  ```
  *Ensures the server or client includes any files on which this module depends.*

---

## **Automatically Included Files and Folders**

When you place standard named files or folders in your module’s directory, many frameworks will auto-include them by default. Here’s a brief overview:

### **Files**  
1. **`client.lua`**  
   - Runs exclusively on the clients. Usually used for shorter modules.

2. **`server.lua`**  
   - Runs exclusively on the server. Usually used for shorter modules.

3. **`config.lua`**  
   - Stores configuration variables shared across the module. This file is shared between the server and client.

4. **`commands.lua`**  
   - Contains command definitions. This file is shared between the server and client.

### **Folders**

1. **`config`**  
   Stores configuration files for customizing addon settings without modifying core scripts.

2. **`dependencies`**  
   Contains essential libraries or resources that must load before other scripts.

3. **`libs`**  
   Includes utility scripts or global helper functions used across the addon.

4. **`hooks`**  
   Houses scripts to register and manage Garry's Mod or custom hooks.

5. **`libraries`**  
   Contains standalone systems or major subsystems for the addon.

6. **`commands`**  
   Defines custom chat (`/command`) or console commands.

7. **`netcalls`**  
   Manages client-server communication using the `net` library.

8. **`meta`**  
   Extends or modifies metatables for core objects like `Player` or `Entity`.

9. **`derma`**  
   Creates visual GUI elements like panels, menus, or HUDs.

10. **`pim`**  
    Focuses on Player Interaction Menu definitions and actions.
    
---
