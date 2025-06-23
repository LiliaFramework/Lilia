
---
    
### **Example**
    
```lua
ATTRIBUTE.name = "Strength"
ATTRIBUTE.desc = "Strength Skill."
ATTRIBUTE.noStartBonus = false
ATTRIBUTE.maxValue = 50
ATTRIBUTE.startingMax = 15

function ATTRIBUTE:OnSetup(client, value)
    if value > 5 then 
        client:ChatPrint("You are very Strong!")
    end
end
```
    
---
    
### **Key Variables Explained**
    
| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `ATTRIBUTE.name`                             | Specifies the display name of the attribute.                                                                    | `String`   | `ATTRIBUTE.name = "Strength"`         |
| `ATTRIBUTE.desc`                             | Provides a short description of the attribute.                                                                  | `String`   | `ATTRIBUTE.desc = "Strength Skill."`   |
| `ATTRIBUTE.noStartBonus` *(Optional)*        | Determines whether the attribute can receive a bonus at the start of the game.                                 | `Boolean`     | `ATTRIBUTE.noStartBonus = false`      |
| `ATTRIBUTE.maxValue` *(Optional)*            | Specifies the maximum value the attribute can reach.                                                           | `Number`   | `ATTRIBUTE.maxValue = 50`              |
| `ATTRIBUTE.startingMax` *(Optional)*         | Defines the maximum value the attribute can start with.                                                        | `Number`   | `ATTRIBUTE.startingMax = 15`           |
| `ATTRIBUTE:OnSetup(client, value)` *(Optional)* | Executes custom logic when the attribute is set up for a player, such as notifications or additional effects. | `Function` | `ATTRIBUTE:OnSetup(client, value)`     |
    
---
    
### **Detailed Descriptions**
    
#### 1. `ATTRIBUTE.name`
    
- **Purpose:**  
  Specifies the display name of the attribute.
    
- **Type:**  
  `String`
    
- **Example Usage:**
    ```lua
    ATTRIBUTE.name = "Strength"
    ```
    *Sets the attribute's name to "Strength."*
    
---
    
#### 2. `ATTRIBUTE.desc`
    
- **Purpose:**  
  Provides a short description of the attribute.
    
- **Type:**  
  `String`
    
- **Example Usage:**
    ```lua
    ATTRIBUTE.desc = "Strength Skill."
    ```
    *Sets the description of the attribute to "Strength Skill."*
    
---
    
#### 3. `ATTRIBUTE.noStartBonus` *(Optional)*
    
- **Purpose:**  
  Determines whether the attribute can receive a bonus at the start of the game.
    
- **Type:**  
  `Boolean`
    
- **Example Usage:**
    ```lua
    ATTRIBUTE.noStartBonus = false
    ```
    *If set to `false`, players can assign a starting bonus for this attribute.*
    
---
    
#### 4. `ATTRIBUTE.maxValue` *(Optional)*
    
- **Purpose:**  
  Specifies the maximum value the attribute can reach.
    
- **Type:**  
  `Number`
    
- **Example Usage:**
    ```lua
    ATTRIBUTE.maxValue = 50
    ```
    *Sets the maximum value for this attribute to 50.*
    
---
    
#### 5. `ATTRIBUTE.startingMax` *(Optional)*
    
- **Purpose:**  
  Defines the maximum value the attribute can start with.
    
- **Type:**  
  `Number`
    
- **Example Usage:**
    ```lua
    ATTRIBUTE.startingMax = 15
    ```
    *Limits the starting value of the attribute to 15.*
    
---
    
#### 6. `ATTRIBUTE:OnSetup(client, value)` *(Optional)*
    
- **Purpose:**  
  Runs custom logic when the attribute is set up for a player. This can include notifications or additional effects.
    
- **Type:**  
  `Function`
    
- **Example Usage:**
    ```lua
    function ATTRIBUTE:OnSetup(client, value)
        if value > 5 then 
            client:ChatPrint("You are very Strong!")
        end
    end
    ```
    *Displays a chat message to the player if their Strength attribute exceeds 5.*
    
---