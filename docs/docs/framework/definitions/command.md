---

## **Example**

```lua
lia.command.add("charsetskin", {
    adminOnly = true,
    syntax = "[string name] [number skin]",
    privilege = "Manage Character Stats",
    AdminStick = {
        Name = "Set Character Skin",
        Category = "Player Informations",
        SubCategory = "Set Informations",
        Icon = "icon16/user_gray.png",
        ExtraFields = {
            ["skin"] = "number"
        }
    },
    onRun = function(client, arguments)
        local name = arguments[1]
        local skin = tonumber(arguments[2])
        local target = lia.util.findPlayer(client, name)
        if IsValid(target) and target:getChar() then
            target:getChar():setData("skin", skin)
            target:SetSkin(skin or 0)
            client:notifyLocalized("cChangeSkin", client:Name(), target:Name(), skin or 0)
        else
            client:notify("Invalid Target")
        end
    end
})
```

---

## **Key Variables Explained**

| **Variable**                         | **Purpose**                                                                                                       | **Type**         | **Example**                                                                                                        |
|--------------------------------------|---------------------------------------------------------------------------------------------------------------------|------------------|--------------------------------------------------------------------------------------------------------------------|
| `adminOnly` *(Optional)*            | If `true`, restricts the command to administrators only.                                                            | `bool`           | `adminOnly = true`<br>*Only admins can run this command.*                                                          |
| `superAdminOnly` *(Optional)*       | If `true`, restricts the command to super administrators only.                                                     | `bool`           | `superAdminOnly = false`<br>*Admins or any user with the correct privilege can use the command.*                   |
| `privilege`                          | Specifies the permission level or “privilege” required to use the command.                                         | `String`         | `privilege = "Manage Character Stats"`<br>*Users must have the "Manage Character Stats" privilege.*                |
| `syntax` *(Optional)*               | Describes the expected argument format.                                                                             | `String`         | `syntax = "[string name] [number skin]"`<br>*Indicates the command expects a player name and a skin number.*       |
| `AdminStick` *(Optional)*           | Stores extra metadata for admin interfaces (e.g., a GUI or categorization).                                         | `Table`          | See [AdminStick Details](#5-adminstick-optional) below for a breakdown.                                                     |
| `onRun`                              | The core logic or “payload” of the command, executed when the command is called.                                   | `Function`       | See [onRun Example](#6-onrun) below.                                                                               |

---

## **Detailed Descriptions**

### 1. `adminOnly` *(Optional)*
- **Purpose:**  
  Restricts the command to administrators if set to `true`.
  
- **Type:**  
  `bool`

- **Example Usage:**
  ```lua
  adminOnly = true
  ```
  *Only administrators can run this command.*

---

### 2. `superAdminOnly` *(Optional)*
- **Purpose:**  
  Restricts the command to super administrators if set to `true`.  

- **Type:**  
  `bool`

- **Example Usage:**
  ```lua
  superAdminOnly = false
  ```
  *Allows admins or any user with the correct privilege to run the command; not superadmin-exclusive.*

---

### 3. `privilege`
- **Purpose:**  
  Specifies the permission level or “privilege” required to use the command.  
  This can be tied into your permission system to group and manage commands collectively under a single permission name.

- **Type:**  
  `String`

- **Example Usage:**
  ```lua
  privilege = "Manage Character Stats"
  ```
  *Users must have the "Manage Character Stats" privilege (e.g., an admin or manager role) to run the command.*

---

### 4. `syntax` *(Optional)*
- **Purpose:**  
  Provides a reference for how to structure the command’s arguments.

- **Type:**  
  `String`

- **Example Usage:**
  ```lua
  syntax = "[string name] [number skin]"
  ```
  *Indicates that the command accepts a player name (string) and a skin ID (number) as parameters.*

---

### 5. `AdminStick` *(Optional)*
- **Purpose:**  
  A table for storing additional metadata about the command, often used for custom admin interfaces.  
  - `Name`: Display name of the command in an admin menu.  
  - `Category`: High-level grouping for the command (e.g., “Player Informations”).  
  - `SubCategory`: Further categorization (e.g., “Set Informations”).  
  - `Icon`: Icon path (e.g., `"icon16/user_gray.png"`).  
  - `ExtraFields`: Additional data fields and their types (e.g., `["skin"] = "number"`).

- **Type:**  
  `Table`

- **Example Usage:**
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
  *Defines how the command is represented in an administrative interface.*

---

### 6. `onRun`
- **Purpose:**  
  Contains the main logic of the command. Executes every time the command is used.

- **Type:**  
  `Function`

- **Example Usage:**
  ```lua
  onRun = function(client, arguments)
      local name = arguments[1]
      local skin = tonumber(arguments[2])
      local target = lia.util.findPlayer(client, name)
      if IsValid(target) and target:getChar() then
          target:getChar():setData("skin", skin)
          target:SetSkin(skin or 0)
          client:notifyLocalized("cChangeSkin", client:Name(), target:Name(), skin or 0)
      else
          client:notify("Invalid Target")
      end
  end
  ```
  *Finds the target player by name, updates the character’s skin data, and sets the new skin value. If the target is invalid, notifies the admin.*

---