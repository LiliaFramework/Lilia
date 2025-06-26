---

### **Example**

```lua
FACTION.name = "Minecrafters"
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `name`                                  | Display name shown for members of this faction. | `Unknown`    | `FACTION.name = "Minecrafters"` |

---

### **Detailed Descriptions**

#### 1. `name`

- **Purpose:**  
    Display name shown for members of this faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.name = "Minecrafters"
    ```

---

---

### **Example**

```lua
FACTION.desc = "Surviving and crafting in the blocky world."
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `desc`                                  | Lore or descriptive text about the faction. | `Unknown`    | `FACTION.desc = "Surviving and crafting in the blocky world."` |

---

### **Detailed Descriptions**

#### 1. `desc`

- **Purpose:**  
    Lore or descriptive text about the faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.desc = "Surviving and crafting in the blocky world."
    ```

---

---

### **Example**

```lua
FACTION.isDefault = false
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `isDefault`                                  | Set to true if players may select this faction without a whitelist. | `Unknown`    | `FACTION.isDefault = false` |

---

### **Detailed Descriptions**

#### 1. `isDefault`

- **Purpose:**  
    Set to true if players may select this faction without a whitelist.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.isDefault = false
    ```

---

---

### **Example**

```lua
FACTION.color = Color(255, 56, 252)
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `color`                                  | Color used to represent the faction in UI elements. | `Color`    | `FACTION.color = Color(255, 56, 252)` |

---

### **Detailed Descriptions**

#### 1. `color`

- **Purpose:**  
    Color used to represent the faction in UI elements.

- **Type:**  
    `Color`

- **Example Usage:
    ```lua
FACTION.color = Color(255, 56, 252)
    ```

---

---

### **Example**

```lua
FACTION.models = {"models/Humans/Group02/male_07.mdl"}
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `models`                                  | Table of player models available to faction members. | `Unknown`    | `FACTION.models = {"models/Humans/Group02/male_07.mdl"}` |

---

### **Detailed Descriptions**

#### 1. `models`

- **Purpose:**  
    Table of player models available to faction members.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.models = {"models/Humans/Group02/male_07.mdl"}
    ```

---

---

### **Example**

```lua
FACTION.uniqueID = "staff"
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `uniqueID`                                  | String identifier used internally to reference the faction. | `Unknown`    | `FACTION.uniqueID = "staff"` |

---

### **Detailed Descriptions**

#### 1. `uniqueID`

- **Purpose:**  
    String identifier used internally to reference the faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.uniqueID = "staff"
    ```

---

---

### **Example**

```lua
FACTION.weapons = {"weapon_physgun", "gmod_tool"}
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `weapons`                                  | Weapons automatically granted to players in this faction. | `Unknown`    | `FACTION.weapons = {"weapon_physgun", "gmod_tool"}` |

---

### **Detailed Descriptions**

#### 1. `weapons`

- **Purpose:**  
    Weapons automatically granted to players in this faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.weapons = {"weapon_physgun", "gmod_tool"}
    ```

---

---

### **Example**

```lua
FACTION.items = {"radio", "handcuffs"}
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `items`                                  | Table of item uniqueIDs automatically granted when a character is created. | `Unknown`    | `FACTION.items = {"radio", "handcuffs"}` |

---

### **Detailed Descriptions**

#### 1. `items`

- **Purpose:**  
    Table of item uniqueIDs automatically granted when a character is created.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.items = {"radio", "handcuffs"}
    ```

---

---

### **Example**

```lua
FACTION_STAFF = FACTION.index
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `index`                                  | Numeric identifier assigned during faction registration. | `Unknown`    | `FACTION_STAFF = FACTION.index` |

---

### **Detailed Descriptions**

#### 1. `index`

- **Purpose:**  
    Numeric identifier assigned during faction registration.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION_STAFF = FACTION.index
    ```

---

---

### **Example**

```lua
FACTION.pay = 50
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `pay`                                  | Payment amount for members of this faction. | `Unknown`    | `FACTION.pay = 50` |

---

### **Detailed Descriptions**

#### 1. `pay`

- **Purpose:**  
    Payment amount for members of this faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.pay = 50
    ```

---

---

### **Example**

```lua
FACTION.payLimit = 1000
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `payLimit`                                  | Maximum pay a member can accumulate. | `Unknown`    | `FACTION.payLimit = 1000` |

---

### **Detailed Descriptions**

#### 1. `payLimit`

- **Purpose:**  
    Maximum pay a member can accumulate.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.payLimit = 1000
    ```

---

---

### **Example**

```lua
FACTION.payTimer = 3600
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `payTimer`                                  | Interval in seconds between salary payouts. | `Unknown`    | `FACTION.payTimer = 3600` |

---

### **Detailed Descriptions**

#### 1. `payTimer`

- **Purpose:**  
    Interval in seconds between salary payouts.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.payTimer = 3600
    ```

---

---

### **Example**

```lua
FACTION.limit = 20
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `limit`                                  | Maximum number of players allowed in this faction. | `Unknown`    | `FACTION.limit = 20` |

---

### **Detailed Descriptions**

#### 1. `limit`

- **Purpose:**  
    Maximum number of players allowed in this faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.limit = 20
    ```

---

---

### **Example**

```lua
FACTION.oneCharOnly = true
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `oneCharOnly`                                  | If true, players may only create one character in this faction. | `Unknown`    | `FACTION.oneCharOnly = true` |

---

### **Detailed Descriptions**

#### 1. `oneCharOnly`

- **Purpose:**  
    If true, players may only create one character in this faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.oneCharOnly = true
    ```

---

---

### **Example**

```lua
FACTION.health = 150
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `health`                                  | Starting health for faction members. | `Unknown`    | `FACTION.health = 150` |

---

### **Detailed Descriptions**

#### 1. `health`

- **Purpose:**  
    Starting health for faction members.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.health = 150
    ```

---

---

### **Example**

```lua
FACTION.armor = 25
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `armor`                                  | Starting armor for faction members. | `Unknown`    | `FACTION.armor = 25` |

---

### **Detailed Descriptions**

#### 1. `armor`

- **Purpose:**  
    Starting armor for faction members.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.armor = 25
    ```

---

---

### **Example**

```lua
FACTION.scale = 1.1
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `scale`                                  | Player model scale multiplier for this faction. | `Unknown`    | `FACTION.scale = 1.1` |

---

### **Detailed Descriptions**

#### 1. `scale`

- **Purpose:**  
    Player model scale multiplier for this faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.scale = 1.1
    ```

---

---

### **Example**

```lua
FACTION.runSpeed = 250
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `runSpeed`                                  | Base running speed for members of this faction. | `Unknown`    | `FACTION.runSpeed = 250` |

---

### **Detailed Descriptions**

#### 1. `runSpeed`

- **Purpose:**  
    Base running speed for members of this faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.runSpeed = 250
    ```

---

---

### **Example**

```lua
FACTION.runSpeedMultiplier = false
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `runSpeedMultiplier`                                  | If true, runSpeed multiplies the base speed instead of replacing it. | `Unknown`    | `FACTION.runSpeedMultiplier = false` |

---

### **Detailed Descriptions**

#### 1. `runSpeedMultiplier`

- **Purpose:**  
    If true, runSpeed multiplies the base speed instead of replacing it.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.runSpeedMultiplier = false
    ```

---

---

### **Example**

```lua
FACTION.walkSpeed = 200
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `walkSpeed`                                  | Base walking speed for members of this faction. | `Unknown`    | `FACTION.walkSpeed = 200` |

---

### **Detailed Descriptions**

#### 1. `walkSpeed`

- **Purpose:**  
    Base walking speed for members of this faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.walkSpeed = 200
    ```

---

---

### **Example**

```lua
FACTION.walkSpeedMultiplier = true
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `walkSpeedMultiplier`                                  | If true, walkSpeed multiplies the base speed instead of replacing it. | `Unknown`    | `FACTION.walkSpeedMultiplier = true` |

---

### **Detailed Descriptions**

#### 1. `walkSpeedMultiplier`

- **Purpose:**  
    If true, walkSpeed multiplies the base speed instead of replacing it.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.walkSpeedMultiplier = true
    ```

---

---

### **Example**

```lua
FACTION.jumpPower = 200
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `jumpPower`                                  | Base jump power for members of this faction. | `Unknown`    | `FACTION.jumpPower = 200` |

---

### **Detailed Descriptions**

#### 1. `jumpPower`

- **Purpose:**  
    Base jump power for members of this faction.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.jumpPower = 200
    ```

---

---

### **Example**

```lua
FACTION.jumpPowerMultiplier = true
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `jumpPowerMultiplier`                                  | If true, jumpPower multiplies the base jump power instead of replacing it. | `Unknown`    | `FACTION.jumpPowerMultiplier = true` |

---

### **Detailed Descriptions**

#### 1. `jumpPowerMultiplier`

- **Purpose:**  
    If true, jumpPower multiplies the base jump power instead of replacing it.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.jumpPowerMultiplier = true
    ```

---

---

### **Example**

```lua
FACTION.MemberToMemberAutoRecognition = true
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `MemberToMemberAutoRecognition`                                  | Whether members automatically recognize each other. | `Unknown`    | `FACTION.MemberToMemberAutoRecognition = true` |

---

### **Detailed Descriptions**

#### 1. `MemberToMemberAutoRecognition`

- **Purpose:**  
    Whether members automatically recognize each other.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.MemberToMemberAutoRecognition = true
    ```

---

---

### **Example**

```lua
FACTION.bloodcolor = BLOOD_COLOR_RED
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `bloodcolor`                                  | Blood color enumeration for faction members. | `Unknown`    | `FACTION.bloodcolor = BLOOD_COLOR_RED` |

---

### **Detailed Descriptions**

#### 1. `bloodcolor`

- **Purpose:**  
    Blood color enumeration for faction members.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.bloodcolor = BLOOD_COLOR_RED
    ```

---

---

### **Example**

```lua
FACTION.bodyGroups = {
hands = 1,
torso = 3
}
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `bodyGroups`                                  | Table mapping bodygroup names to the index value each should use.
These are applied whenever a faction member spawns. | `Unknown`    | `FACTION.bodyGroups = {
hands = 1,
torso = 3
}` |

---

### **Detailed Descriptions**

#### 1. `bodyGroups`

- **Purpose:**  
    Table mapping bodygroup names to the index value each should use.
These are applied whenever a faction member spawns.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.bodyGroups = {
hands = 1,
torso = 3
}
    ```

---

---

### **Example**

```lua
FACTION.NPCRelations = {
["npc_combine_s"] = D_HT,
["npc_citizen"] = D_LI
}
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `NPCRelations`                                  | Table mapping NPC class names to disposition constants such as
D_HT (hate) or D_LI (like). Each NPC is updated with these
relationships when the player spawns or the NPC is created. | `Unknown`    | `FACTION.NPCRelations = {
["npc_combine_s"] = D_HT,
["npc_citizen"] = D_LI
}` |

---

### **Detailed Descriptions**

#### 1. `NPCRelations`

- **Purpose:**  
    Table mapping NPC class names to disposition constants such as
D_HT (hate) or D_LI (like). Each NPC is updated with these
relationships when the player spawns or the NPC is created.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.NPCRelations = {
["npc_combine_s"] = D_HT,
["npc_citizen"] = D_LI
}
    ```

---

---

### **Example**

```lua
FACTION.RecognizesGlobally = false
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `RecognizesGlobally`                                  | If true, members of this faction recognize all players globally. | `Unknown`    | `FACTION.RecognizesGlobally = false` |

---

### **Detailed Descriptions**

#### 1. `RecognizesGlobally`

- **Purpose:**  
    If true, members of this faction recognize all players globally.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.RecognizesGlobally = false
    ```

---

---

### **Example**

```lua
FACTION.ScoreboardHidden = false
```

---

### **Key Variables Explained**

| **Variable**                                 | **Purpose**                                                                                                     | **Type**   | **Example**                           |
|----------------------------------------------|-----------------------------------------------------------------------------------------------------------------|------------|---------------------------------------|
| `ScoreboardHidden`                                  | If true, members of this faction are hidden from the scoreboard. | `Unknown`    | `FACTION.ScoreboardHidden = false` |

---

### **Detailed Descriptions**

#### 1. `ScoreboardHidden`

- **Purpose:**  
    If true, members of this faction are hidden from the scoreboard.

- **Type:**  
    `Unknown`

- **Example Usage:
    ```lua
FACTION.ScoreboardHidden = false
    ```

---

