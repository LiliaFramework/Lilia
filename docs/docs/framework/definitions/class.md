---

### **Example**

```lua
CLASS.name = "Steve"
CLASS.desc = "The Steves of the Minecrafter Faction."
CLASS.isDefault = true
CLASS.faction = FACTION_MINECRAFTER
CLASS.color = Color(0, 255, 0)
CLASS.weapons = {"gold_pickaxe", "netherite_spade"}
CLASS.pay = 50
CLASS.payTimer = 3600
CLASS.index = CLASS_STEVE
```

---

### **Key Variables Explained**

| **Variable**                           | **Purpose**                                                                                                      | **Type**                       | **Example**                                                                                          |
|----------------------------------------|------------------------------------------------------------------------------------------------------------------|--------------------------------|------------------------------------------------------------------------------------------------------|
| `CLASS.name`                           | The displayed name of the class.                                                                                | `String`                       | `CLASS.name = "Steve"`<br>*Sets the class name to "Steve."*                                           |
| `CLASS.desc`                           | The description or lore of the class.                                                                            | `String`                       | `CLASS.desc = "The Steves of the Minecrafter Faction."`<br>*Provides a description for the class.*     |
| `CLASS.isDefault`                      | Determines if the class is available by default.                                                                 | `Boolean`                         | `CLASS.isDefault = true`<br>*Sets the class as available by default.*                                |
| `CLASS.isWhitelisted` *(Optional)*     | Indicates if the class requires whitelisting.                                                                    | `Boolean`                         | `CLASS.isWhitelisted = false`<br>*If `true`, the class requires players to be whitelisted.*            |
| `CLASS.faction`                        | Links the class to a specific faction.                                                                            | `Number` (Faction Index)       | `CLASS.faction = FACTION_MINECRAFTER`<br>*Associates the class with the Minecrafter faction.*          |
| `CLASS.color` *(Optional)*             | The color associated with the class.                                                                             | `Color`                        | `CLASS.color = Color(0, 255, 0)`<br>*Sets the class color to green.*                                   |
| `CLASS.weapons` *(Optional)*           | Weapons available to class members.                                                                              | `Table` of `Strings`            | `CLASS.weapons = {"gold_pickaxe", "netherite_spade"}`<br>*Assigns specific weapons to the class.*        |
| `CLASS.pay` *(Optional)*               | Payment amount for class members.                                                                                | `Number`                       | `CLASS.pay = 50`<br>*Sets the pay rate to 50 units.*                                                 |
| `CLASS.payLimit` *(Optional)*          | Maximum accumulated pay.                                                                                         | `Number`                       | `CLASS.payLimit = 1000`<br>*Limits the maximum pay a member can accumulate.*                          |
| `CLASS.payTimer` *(Optional)*          | Interval (in seconds) for issuing pay.                                                                          | `Number`                       | `CLASS.payTimer = 3600`<br>*Sets the pay interval to one hour.*                                       |
| `CLASS.limit` *(Optional)*             | Maximum number of players allowed in the class.                                                                    | `Number`                       | `CLASS.limit = 10`<br>*Limits the class to 10 players.*                                               |
| `CLASS.health` *(Optional)*            | Default health for class members.                                                                                  | `Number`                       | `CLASS.health = 150`<br>*Sets the default health to 150.*                                             |
| `CLASS.armor` *(Optional)*             | Default armor for class members.                                                                                   | `Number`                       | `CLASS.armor = 50`<br>*Sets the default armor to 50.*                                                 |
| `CLASS.scale` *(Optional)*             | Adjusts the player model’s size.                                                                                   | `Number`                       | `CLASS.scale = 1.2`<br>*Increases the player model size by 20%.*                                        |
| `CLASS.runSpeed` *(Optional)*          | Default running speed for class members.                                                                          | `Number`                       | `CLASS.runSpeed = 250`<br>*Sets the running speed to 250 units.*                                      |
| `CLASS.runSpeedMultiplier` *(Optional)*| If `true`, multiplies `runSpeed` by the base speed; if `false`, sets it directly.                                 | `Boolean`                         | `CLASS.runSpeedMultiplier = true`<br>*Enables run speed multiplication.*                             |
| `CLASS.walkSpeed` *(Optional)*         | Default walking speed for class members.                                                                          | `Number`                       | `CLASS.walkSpeed = 200`<br>*Sets the walking speed to 200 units.*                                      |
| `CLASS.walkSpeedMultiplier` *(Optional)*| If `true`, multiplies `walkSpeed` by the base speed; if `false`, sets it directly.                                | `Boolean`                         | `CLASS.walkSpeedMultiplier = false`<br>*Sets walk speed directly without multiplication.*             |
| `CLASS.jumpPower` *(Optional)*         | Default jump power for class members.                                                                             | `Number`                       | `CLASS.jumpPower = 200`<br>*Sets the jump power to 200.*                                               |
| `CLASS.jumpPowerMultiplier` *(Optional)*| If `true`, multiplies `jumpPower` by the base jump power; if `false`, sets it directly.                            | `Boolean`                         | `CLASS.jumpPowerMultiplier = true`<br>*Enables jump power multiplication.*                            |
| `CLASS.bloodcolor` *(Optional)*        | Sets the blood color for class members.                                                                           | `Number`                       | `CLASS.bloodcolor = BLOOD_COLOR_RED`<br>*Sets the blood color to red.*                                  |
| `CLASS.bodyGroups` *(Optional)*        | Assigns bodygroup values on spawn.                                                                                  | `Table`                        | `CLASS.bodyGroups = { [1] = 2, [3] = 1 }`<br>*Sets specific bodygroups for the class model.*             |
| `CLASS.model` *(Optional)*             | Model(s) assigned to the class.                                                                                     | `String` or `Table` of `Strings`| `CLASS.model = "models/player/steve.mdl"`<br>*Assigns a single model to the class.*<br><br>`CLASS.model = {"models/player/steve1.mdl", "models/player/steve2.mdl"}`<br>*Assigns multiple models to the class.* |
| `CLASS.index`                           | A unique ID (team index) identifying the class.                                                                    | `Number`                       | `CLASS.index = CLASS_STEVE`<br>*Assigns a unique team index to the class.*                              |

---

### **Detailed Descriptions**

#### 1. `CLASS.name`

- **Purpose:**  
  The displayed name of the class.

- **Type:**  
  `String`

- **Example Usage:**
    ```lua
    CLASS.name = "Steve"
    ```
    *Sets the class name to "Steve."*

---

#### 2. `CLASS.desc`

- **Purpose:**  
  The description or lore of the class.

- **Type:**  
  `String`

- **Example Usage:**
    ```lua
    CLASS.desc = "The Steves of the Minecrafter Faction."
    ```
    *Provides a description for the class.*

---

#### 3. `CLASS.isDefault`

- **Purpose:**  
  Determines if the class is available by default.

- **Type:**  
  `Boolean`

- **Example Usage:**
    ```lua
    CLASS.isDefault = true
    ```
    *Sets the class as available by default.*

---

#### 4. `CLASS.isWhitelisted` *(Optional)*

- **Purpose:**  
  Indicates if the class requires whitelisting.

- **Type:**  
  `Boolean`

- **Example Usage:**
    ```lua
    CLASS.isWhitelisted = false
    ```
    *If `true`, the class requires players to be whitelisted.*

---

#### 5. `CLASS.faction`

- **Purpose:**  
  Links the class to a specific faction.

- **Type:**  
  `Number` (Faction Index)

- **Example Usage:**
    ```lua
    CLASS.faction = FACTION_MINECRAFTER
    ```
    *Associates the class with the Minecrafter faction.*

---

#### 6. `CLASS.color` *(Optional)*

- **Purpose:**  
  The color associated with the class.

- **Type:**  
  `Color`

- **Example Usage:**
    ```lua
    CLASS.color = Color(0, 255, 0)
    ```
    *Sets the class color to green.*

---

#### 7. `CLASS.weapons` *(Optional)*

- **Purpose:**  
  Weapons available to class members.

- **Type:**  
  `Table` of `Strings`

- **Example Usage:**
    ```lua
    CLASS.weapons = {"gold_pickaxe", "netherite_spade"}
    ```
    *Assigns specific weapons to the class.*

---

#### 8. `CLASS.pay` *(Optional)*

- **Purpose:**  
  Payment amount for class members.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.pay = 50
    ```
    *Sets the pay rate to 50 units.*

---

#### 9. `CLASS.payLimit` *(Optional)*

- **Purpose:**  
  Maximum accumulated pay.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.payLimit = 1000
    ```
    *Limits the maximum pay a member can accumulate.*

---

#### 10. `CLASS.payTimer` *(Optional)*

- **Purpose:**  
  Interval (in seconds) for issuing pay.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.payTimer = 3600
    ```
    *Sets the pay interval to one hour.*

---

#### 11. `CLASS.limit` *(Optional)*

- **Purpose:**  
  Maximum number of players allowed in the class.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.limit = 10
    ```
    *Limits the class to 10 players.*

---

#### 12. `CLASS.health` *(Optional)*

- **Purpose:**  
  Default health for class members.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.health = 150
    ```
    *Sets the default health to 150.*

---

#### 13. `CLASS.armor` *(Optional)*

- **Purpose:**  
  Default armor for class members.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.armor = 50
    ```
    *Sets the default armor to 50.*

---

#### 14. `CLASS.scale` *(Optional)*

- **Purpose:**  
  Adjusts the player model’s size.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.scale = 1.2
    ```
    *Increases the player model size by 20%.*

---

#### 15. `CLASS.runSpeed` *(Optional)*

- **Purpose:**  
  Default running speed for class members.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.runSpeed = 250
    ```
    *Sets the running speed to 250 units.*

---

#### 16. `CLASS.runSpeedMultiplier` *(Optional)*

- **Purpose:**  
  If `true`, multiplies `runSpeed` by the base speed; if `false`, sets it directly.

- **Type:**  
  `Boolean`

- **Example Usage:**
    ```lua
    CLASS.runSpeedMultiplier = true
    ```
    *Enables run speed multiplication.*

---

#### 17. `CLASS.walkSpeed` *(Optional)*

- **Purpose:**  
  Default walking speed for class members.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.walkSpeed = 200
    ```
    *Sets the walking speed to 200 units.*

---

#### 18. `CLASS.walkSpeedMultiplier` *(Optional)*

- **Purpose:**  
  If `true`, multiplies `walkSpeed` by the base speed; if `false`, sets it directly.

- **Type:**  
  `Boolean`

- **Example Usage:**
    ```lua
    CLASS.walkSpeedMultiplier = false
    ```
    *Sets walk speed directly without multiplication.*

---

#### 19. `CLASS.jumpPower` *(Optional)*

- **Purpose:**  
  Default jump power for class members.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.jumpPower = 200
    ```
    *Sets the jump power to 200.*

---

#### 20. `CLASS.jumpPowerMultiplier` *(Optional)*

- **Purpose:**  
  If `true`, multiplies `jumpPower` by the base jump power; if `false`, sets it directly.

- **Type:**  
  `Boolean`

- **Example Usage:**
    ```lua
    CLASS.jumpPowerMultiplier = true
    ```
    *Enables jump power multiplication.*

---

#### 21. `CLASS.bloodcolor` *(Optional)*

- **Purpose:**  
  Sets the blood color for class members.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.bloodcolor = BLOOD_COLOR_RED
    ```
    *Sets the blood color to red.*

---

#### 22. `CLASS.bodyGroups` *(Optional)*

- **Purpose:**  
  Assigns bodygroup values on spawn.

- **Type:**  
  `Table`

- **Example Usage:**
    ```lua
    CLASS.bodyGroups = { [1] = 2, [3] = 1 }
    ```
    *Sets specific bodygroups for the class model.*

---

#### 23. `CLASS.model` *(Optional)*

- **Purpose:**  
  Model(s) assigned to the class.

- **Type:**  
  `String` or `Table` of `Strings`

- **Example Usage:**
    ```lua
    CLASS.model = "models/player/steve.mdl"
    ```
    *Assigns a single model to the class.*
    
    or
    
    ```lua
    CLASS.model = {"models/player/steve1.mdl", "models/player/steve2.mdl"}
    ```
    *Assigns multiple models to the class.*

---

#### 24. `CLASS.index`

- **Purpose:**  
  A unique ID (team index) identifying the class.

- **Type:**  
  `Number`

- **Example Usage:**
    ```lua
    CLASS.index = CLASS_STEVE
    ```
    *Assigns a unique team index to the class.*

---