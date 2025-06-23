---

## **Example**

```lua
FACTION.name = "Minecrafters"
FACTION.desc = "Surviving and crafting in the blocky world."
FACTION.isDefault = false
FACTION.color = Color(0, 255, 0)
FACTION.models = {"minecraft_model_1.mdl", "minecraft_model_2.mdl", "minecraft_model_3.mdl"}
FACTION.weapons = {"stone_sword", "iron_pickaxe"}
FACTION.pay = 50
FACTION.payTimer = 3600
FACTION_MINECRAFTER = FACTION.index
```

---

## **Key Variables Explained**

| **Variable**                                       | **Purpose**                                                                                             | **Type**                        | **Example**                                                                                                         |
|----------------------------------------------------|---------------------------------------------------------------------------------------------------------|---------------------------------|---------------------------------------------------------------------------------------------------------------------|
| `FACTION.name`                                     | The displayed name of your faction.                                                                     | `String`                        | `FACTION.name = "Minecrafters"`<br>*Sets the faction name to "Minecrafters."*                                       |
| `FACTION.desc`                                     | The description or lore of your faction.                                                                | `String`                        | `FACTION.desc = "Surviving and crafting in the blocky world."`<br>*Provides a description for the faction.*         |
| `FACTION.isDefault`                                | Marks the faction as default if set to `true`.                                                          | `Boolean`                          | `FACTION.isDefault = false`<br>*Sets the faction as not default.*                                                  |
| `FACTION.color` *(Optional)*                       | The color associated with the faction.                                                                  | `Color`                         | `FACTION.color = Color(0, 255, 0)`<br>*Sets the faction color to green.*                                           |
| `FACTION.models`                                   | Models available to faction members.                                                                    | `Table` of `Strings`             | `FACTION.models = {"minecraft_model_1.mdl", "minecraft_model_2.mdl", "minecraft_model_3.mdl"}`<br>*Assigns multiple models.* |
| `FACTION.weapons` *(Optional)*                     | Weapons available to faction members.                                                                   | `Table` of `Strings`             | `FACTION.weapons = {"stone_sword", "iron_pickaxe"}`<br>*Provides stone sword and iron pickaxe to faction members.*  |
| `FACTION.pay` *(Optional)*                         | Payment amount for members of this faction.                                                             | `Number`                        | `FACTION.pay = 50`<br>*Sets the pay rate to 50 units.*                                                              |
| `FACTION.payLimit` *(Optional)*                    | Maximum amount of pay a member can accumulate.                                                          | `Number`                        | `FACTION.payLimit = 1000`<br>*Limits the maximum pay a member can accumulate.*                                     |
| `FACTION.payTimer` *(Optional)*                    | Interval (in seconds) for issuing pay.                                                                  | `Number`                        | `FACTION.payTimer = 3600`<br>*Sets the pay interval to one hour.*                                                  |
| `FACTION.limit` *(Optional)*                       | Maximum number of players allowed in this faction.                                                      | `Number`                        | `FACTION.limit = 20`<br>*Limits the faction to 20 players.*                                                        |
| `FACTION.oneCharOnly` *(Optional)*                 | Restricts players to a single character in this faction.                                                | `Boolean`                          | `FACTION.oneCharOnly = true`<br>*Prevents creating multiple characters in the same faction.*                       |
| `FACTION.health` *(Optional)*                      | Default health for faction members.                                                                     | `Number`                        | `FACTION.health = 150`<br>*Sets the default health to 150.*                                                        |
| `FACTION.armor` *(Optional)*                       | Default armor for faction members.                                                                      | `Number`                        | `FACTION.armor = 25`<br>*Sets the default armor to 25.*                                                            |
| `FACTION.scale` *(Optional)*                       | Adjusts the player model’s size.                                                                        | `Number`                        | `FACTION.scale = 1.1`<br>*Increases the player model size by 10%.*                                                 |
| `FACTION.runSpeed` *(Optional)*                    | Default running speed for faction members.                                                              | `Number`                        | `FACTION.runSpeed = 250`<br>*Sets the running speed to 250 units.*                                                 |
| `FACTION.runSpeedMultiplier` *(Optional)*          | If `true`, multiplies `runSpeed` by the base speed; if `false`, sets it directly.                        | `Boolean`                          | `FACTION.runSpeedMultiplier = false`<br>*Sets the running speed directly.*                                         |
| `FACTION.walkSpeed` *(Optional)*                   | Default walking speed for faction members.                                                              | `Number`                        | `FACTION.walkSpeed = 200`<br>*Sets the walking speed to 200 units.*                                                |
| `FACTION.walkSpeedMultiplier` *(Optional)*         | If `true`, multiplies `walkSpeed` by the base speed; if `false`, sets it directly.                       | `Boolean`                          | `FACTION.walkSpeedMultiplier = true`<br>*Enables walk speed multiplication.*                                       |
| `FACTION.jumpPower` *(Optional)*                   | Default jump power for faction members.                                                                 | `Number`                        | `FACTION.jumpPower = 200`<br>*Sets the jump power to 200.*                                                         |
| `FACTION.jumpPowerMultiplier` *(Optional)*         | If `true`, multiplies `jumpPower` by the base jump power; if `false`, sets it directly.                  | `Boolean`                          | `FACTION.jumpPowerMultiplier = true`<br>*Enables jump power multiplication.*                                       |
| `FACTION.MemberToMemberAutoRecognition` *(Optional)* | Determines if members automatically recognize each other.                                              | `Boolean`                          | `FACTION.MemberToMemberAutoRecognition = true`<br>*Members automatically recognize each other.*                    |
| `FACTION.bloodcolor` *(Optional)*                  | Sets the blood color for faction members.                                                               | `Number` (Enum)                 | `FACTION.bloodcolor = BLOOD_COLOR_RED`<br>*Sets the blood color to red.*                                           |
| `FACTION.bodyGroups` *(Optional)*                  | Assigns bodygroup settings for faction members.                                                         | `Table`                         | `FACTION.bodyGroups = {[1] = 2, [2] = 1}`<br>*Sets specific bodygroups for the faction model.*                     |
| `FACTION.RecognizesGlobally` *(Optional)*          | If `true`, this faction recognizes all players globally.                                                | `Boolean`                          | `FACTION.RecognizesGlobally = false`<br>*Does not globally recognize all players.*                                 |
| `FACTION.index`                                     | A unique ID identifying the faction, used for reference and indexing.                                   | `Number`                        | `FACTION_MINECRAFTER = FACTION.index`<br>*Assigns a unique ID to the Minecrafter faction.*                         |

---

## **Detailed Descriptions**

Below are more in-depth explanations of each **FACTION** variable, closely matching the style and structure of the **CLASS** documentation.

---

### 1. `FACTION.name`
- **Purpose:**  
  The displayed name of your faction.

- **Type:**  
  `String`

- **Example Usage:**
  ```lua
  FACTION.name = "Minecrafters"
  ```
  *Sets the faction name to "Minecrafters."*

---

### 2. `FACTION.desc`
- **Purpose:**  
  The description or lore of your faction.

- **Type:**  
  `String`

- **Example Usage:**
  ```lua
  FACTION.desc = "Surviving and crafting in the blocky world."
  ```
  *Provides a description for the faction.*

---

### 3. `FACTION.isDefault`
- **Purpose:**  
  Marks the faction as default if set to `true`.

- **Type:**  
  `Boolean`

- **Example Usage:**
  ```lua
  FACTION.isDefault = false
  ```
  *Sets the faction as non-default.*

---

### 4. `FACTION.color` *(Optional)*
- **Purpose:**  
  The color associated with the faction.

- **Type:**  
  `Color`

- **Example Usage:**
  ```lua
  FACTION.color = Color(0, 255, 0)
  ```
  *Sets the faction color to green.*

---

### 5. `FACTION.models`
- **Purpose:**  
  Models available to faction members.

- **Type:**  
  `Table` of `Strings`

- **Example Usage:**
  ```lua
  FACTION.models = {"minecraft_model_1.mdl", "minecraft_model_2.mdl", "minecraft_model_3.mdl"}
  ```
  *Assigns multiple models to the faction.*

---

### 6. `FACTION.weapons` *(Optional)*
- **Purpose:**  
  Weapons available to faction members.

- **Type:**  
  `Table` of `Strings`

- **Example Usage:**
  ```lua
  FACTION.weapons = {"stone_sword", "iron_pickaxe"}
  ```
  *Assigns the stone sword and iron pickaxe to faction members.*

---

### 7. `FACTION.pay` *(Optional)*
- **Purpose:**  
  Payment amount for members of this faction.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION.pay = 50
  ```
  *Sets the pay rate to 50 units.*

---

### 8. `FACTION.payLimit` *(Optional)*
- **Purpose:**  
  Maximum amount of pay a member can accumulate.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION.payLimit = 1000
  ```
  *Limits the maximum pay a member can accumulate.*

---

### 9. `FACTION.payTimer` *(Optional)*
- **Purpose:**  
  Interval (in seconds) for issuing pay.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION.payTimer = 3600
  ```
  *Sets the pay interval to one hour.*

---

### 10. `FACTION.limit` *(Optional)*
- **Purpose:**  
  Maximum number of players allowed in this faction.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION.limit = 20
  ```
  *Limits the faction to 20 players.*

---

### 11. `FACTION.oneCharOnly` *(Optional)*
- **Purpose:**  
  Restricts players to a single character in this faction.

- **Type:**  
  `Boolean`

- **Example Usage:**
  ```lua
  FACTION.oneCharOnly = true
  ```
  *Prevents multiple characters under the same faction.*

---

### 12. `FACTION.health` *(Optional)*
- **Purpose:**  
  Default health for faction members.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION.health = 150
  ```
  *Sets the default health to 150.*

---

### 13. `FACTION.armor` *(Optional)*
- **Purpose:**  
  Default armor for faction members.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION.armor = 25
  ```
  *Sets the default armor to 25.*

---

### 14. `FACTION.scale` *(Optional)*
- **Purpose:**  
  Adjusts the player model’s size.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION.scale = 1.1
  ```
  *Increases the player model size by 10%.*

---

### 15. `FACTION.runSpeed` *(Optional)*
- **Purpose:**  
  Default running speed for faction members.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION.runSpeed = 250
  ```
  *Sets the running speed to 250 units.*

---

### 16. `FACTION.runSpeedMultiplier` *(Optional)*
- **Purpose:**  
  If `true`, multiplies `runSpeed` by the base speed; if `false`, sets it directly.

- **Type:**  
  `Boolean`

- **Example Usage:**
  ```lua
  FACTION.runSpeedMultiplier = false
  ```
  *Sets the running speed directly without multiplying.*

---

### 17. `FACTION.walkSpeed` *(Optional)*
- **Purpose:**  
  Default walking speed for faction members.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION.walkSpeed = 200
  ```
  *Sets the walking speed to 200 units.*

---

### 18. `FACTION.walkSpeedMultiplier` *(Optional)*
- **Purpose:**  
  If `true`, multiplies `walkSpeed` by the base speed; if `false`, sets it directly.

- **Type:**  
  `Boolean`

- **Example Usage:**
  ```lua
  FACTION.walkSpeedMultiplier = true
  ```
  *Enables walk speed multiplication.*

---

### 19. `FACTION.jumpPower` *(Optional)*
- **Purpose:**  
  Default jump power for faction members.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION.jumpPower = 200
  ```
  *Sets the jump power to 200.*

---

### 20. `FACTION.jumpPowerMultiplier` *(Optional)*
- **Purpose:**  
  If `true`, multiplies `jumpPower` by the base jump power; if `false`, sets it directly.

- **Type:**  
  `Boolean`

- **Example Usage:**
  ```lua
  FACTION.jumpPowerMultiplier = true
  ```
  *Enables jump power multiplication.*

---

### 21. `FACTION.MemberToMemberAutoRecognition` *(Optional)*
- **Purpose:**  
  Determines if members automatically recognize each other.

- **Type:**  
  `Boolean`

- **Example Usage:**
  ```lua
  FACTION.MemberToMemberAutoRecognition = true
  ```
  *Enables automatic recognition among faction members.*

---

### 22. `FACTION.bloodcolor` *(Optional)*
- **Purpose:**  
  Sets the blood color for faction members.

- **Type:**  
  `Number` (Enum)

- **Example Usage:**
  ```lua
  FACTION.bloodcolor = BLOOD_COLOR_RED
  ```
  *Sets the blood color to red.*

---

### 23. `FACTION.bodyGroups` *(Optional)*
- **Purpose:**  
  Assigns bodygroup settings for faction members.

- **Type:**  
  `Table`

- **Example Usage:**
  ```lua
  FACTION.bodyGroups = { [1] = 2, [2] = 1 }
  ```
  *Sets specific bodygroups for the faction model.*

---

### 24. `FACTION.RecognizesGlobally` *(Optional)*
- **Purpose:**  
  If `true`, this faction recognizes all players globally.

- **Type:**  
  `Boolean`

- **Example Usage:**
  ```lua
  FACTION.RecognizesGlobally = false
  ```
  *Does not globally recognize all players.*

---

### 25. `FACTION.ScoreboardHidden` *(Optional)*
- **Purpose:**  
  Determines whether this faction is displayed on the scoreboard. If set to `true`, the faction members will be hidden from the scoreboard.

- **Type:**  
  `Boolean`

- **Example Usage:**
  ```lua
  FACTION.ScoreboardHidden = false
  ```
---

### 26. `FACTION.index`
- **Purpose:**  
  A unique ID (faction index) identifying the faction.

- **Type:**  
  `Number`

- **Example Usage:**
  ```lua
  FACTION_MINECRAFTER = FACTION.index
  ```
  *Assigns a unique index to the “Minecrafters” faction.*

---
