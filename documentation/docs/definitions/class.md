# Class Fields

This document describes all configurable `CLASS` fields in the codebase. Each field controls a specific aspect of how a class behaves, appears, or is granted to players. Unspecified fields will use sensible defaults.

---

## Overview

The global `CLASS` table defines per-class settings such as display name, lore, starting equipment, pay parameters, movement speeds, and visual appearance. Use these fields to fully customize each class’s behavior and presentation.

---

## Field Summary

| Field | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"Unknown"` | Displayed name of the class. |
| `desc` | `string` | `"No Description"` | Description or lore of the class. |
| `isDefault` | `boolean` | `false` | Whether the class is available by default. |
| `isWhitelisted` | `boolean` | `false` | Whether the class requires whitelist to join. |
| `faction` | `number` | `required` | Linked faction index (e.g., `FACTION_CITIZEN`). |
| `color` | `Color` | `nil` | UI color associated with the class; falls back to faction color when unset. |
| `weapons` | `string` or `table` | `nil` | Weapons granted to members of this class. |
| `pay` | `number` | `0` | Payment amount per interval. |
| `payLimit` | `number` | `0` | Maximum accumulated pay. |
| `payTimer` | `number` | `3600` | Seconds between paychecks when not overridden. |
| `limit` | `number` | `0` | Maximum number of players in this class. |
| `health` | `number` | `nil` | Starting health override. |
| `armor` | `number` | `nil` | Starting armor override. |
| `scale` | `number` | `1` | Player model scale multiplier. |
| `runSpeed` | `number` | `nil` | Running speed or multiplier value. |
| `runSpeedMultiplier` | `boolean` | `false` | Multiply base speed instead of replacing it. |
| `walkSpeed` | `number` | `nil` | Walking speed or multiplier value. |
| `walkSpeedMultiplier` | `boolean` | `false` | Multiply base walk speed instead of replacing it. |
| `jumpPower` | `number` | `nil` | Jump power or multiplier value. |
| `jumpPowerMultiplier` | `boolean` | `false` | Multiply base jump power instead of replacing it. |
| `bloodcolor` | `number` | `0` | Blood color enumeration constant. |
| `bodyGroups` | `table` | `nil` | Bodygroup name → index mapping applied on spawn. |
| `logo` | `string` | `nil` | Material path for the class logo. |
| `scoreboardHidden` | `boolean` | `false` | Hide class headers and logos in the scoreboard. |
| `skin` | `number` | `0` | Player model skin index. |
| `subMaterials` | `table` | `nil` | Sub-material overrides for the model. |
| `model` | `string` or `table` | `nil` | Model path or list of paths used by this class. |
| `requirements` | `string` or `table` | `nil` | Informational requirements text shown to players. |
| `index` | `number` | `auto` | Unique team index assigned at registration. |
| `uniqueID` | `string` | `filename` | Optional identifier; defaults to the file name when omitted. |
| `commands` | `table` | `nil` | Command names members may always use. |
| `canInviteToFaction` | `boolean` | `false` | Allows members of this class to invite players to their faction. |
| `canInviteToClass` | `boolean` | `false` | Allows members of this class to invite others to their class. |
| `OnCanBe(client)` | `function` | `function(self, client) return true end` | Custom join check; return `false` to deny the client. |

---

## Field Details

### Basic Info

#### `name`

**Type:**

`string`

**Description:**

The displayed name of the class.

**Example Usage:**

```lua
CLASS.name = "Engineer"
```

---

#### `desc`

**Type:**

`string`

**Description:**

The description or lore of the class.

**Example Usage:**

```lua
CLASS.desc = "Technicians who maintain equipment."
```

---

#### `uniqueID`

**Type:**

`string`

**Description:**

Internal identifier used when referencing the class. If omitted, it defaults to the file name this class was loaded from.

**Example Usage:**

```lua
CLASS.uniqueID = "engineer"
```

---

#### `index`

**Type:**

`number`

**Description:**

Unique numeric identifier (team index) for the class.

**Example Usage:**

```lua
CLASS.index = CLASS_ENGINEER
```

---

### Affiliation & Availability

#### `isDefault`

**Type:**

`boolean`

**Description:**

Determines if the class is available to all players by default.

**Example Usage:**

```lua
CLASS.isDefault = true
```

---

#### `isWhitelisted`

**Type:**

`boolean`

**Description:**

Indicates if the class requires a whitelist entry to be accessible.

**Example Usage:**

```lua
CLASS.isWhitelisted = false
```

---

#### `faction`

**Type:**

`number`

**Description:**

Links this class to a specific faction index. This field is required; registration fails if the faction is missing or invalid.

**Example Usage:**

```lua
CLASS.faction = FACTION_CITIZEN
```

---

#### `color`

**Type:**

`Color`

**Description:**

UI color representing the class. When omitted, the faction’s color is used.

**Example Usage:**

```lua
CLASS.color = Color(255, 0, 0)
```

---

### Equipment & Economy

#### `weapons`

**Type:**

`string` or `table`

**Description:**

Weapons granted to members of this class on spawn. Supply a single weapon class or a table of weapon class strings.

**Example Usage:**

```lua
-- give two weapons
CLASS.weapons = {"weapon_pistol", "weapon_crowbar"}
-- or grant one weapon
CLASS.weapons = "weapon_pistol"
```

#### `pay`

**Type:**

`number`

**Description:**

Payment amount issued per pay interval.

**Example Usage:**

```lua
CLASS.pay = 50
```

---

#### `payLimit`

**Type:**

`number`

**Description:**

Maximum accumulated pay a player can hold.

**Example Usage:**

```lua
CLASS.payLimit = 1000
```

---

#### `payTimer`

**Type:**

`number`

**Description:**

How often salaries are paid to members of this class.

If omitted, the timer falls back to the faction's `payTimer` or

the global `SalaryInterval` configuration value (default `3600`).

**Example Usage:**

```lua
CLASS.payTimer = 3600
```

---

#### `limit`

**Type:**

`number`

**Description:**

Maximum number of players allowed in this class simultaneously.

**Example Usage:**

```lua
CLASS.limit = 10
```

---

### Movement & Stats

#### `health`

**Type:**

`number`

**Description:**

Overrides the player’s starting health when they spawn as this class. If omitted, health is unchanged.

**Example Usage:**

```lua
CLASS.health = 150
```

---

#### `armor`

**Type:**

`number`

**Description:**

Overrides the player’s starting armor. If omitted, armor remains unchanged.

**Example Usage:**

```lua
CLASS.armor = 50
```

---

#### `scale`

**Type:**

`number`

**Description:**

Multiplier for player model size.

**Example Usage:**

```lua
CLASS.scale = 1.2
```

---

#### `runSpeed`

**Type:**

`number`

**Description:**

Overrides or multiplies the player's running speed. Set a number to replace the speed or a multiplier when used with `runSpeedMultiplier`. If unset, the run speed is unchanged.

**Example Usage:**

```lua
-- explicit speed value
CLASS.runSpeed = 250
OR
-- 25% faster than the base run speed
CLASS.runSpeed = 1.25
CLASS.runSpeedMultiplier = true
```

---

#### `runSpeedMultiplier`

**Type:**

`boolean`

**Description:**

Multiply base run speed instead of replacing it.

**Example Usage:**

```lua
CLASS.runSpeedMultiplier = true
```

---

#### `walkSpeed`

**Type:**

`number`

**Description:**

Overrides or multiplies the player's walking speed. If unset, the walk speed is unchanged.

**Example Usage:**

```lua
CLASS.walkSpeed = 200
```

---

#### `walkSpeedMultiplier`

**Type:**

`boolean`

**Description:**

Multiply base walk speed instead of replacing it.

**Example Usage:**

```lua
CLASS.walkSpeedMultiplier = false
```

---

#### `jumpPower`

**Type:**

`number`

**Description:**

Overrides or multiplies the player's jump power. If unset, the jump power is unchanged.

**Example Usage:**

```lua
CLASS.jumpPower = 200
```

---

#### `jumpPowerMultiplier`

**Type:**

`boolean`

**Description:**

Multiply base jump power instead of replacing it.

**Example Usage:**

```lua
CLASS.jumpPowerMultiplier = true
```

---

#### `bloodcolor`

**Type:**

`number`

**Description:**

Blood color enumeration constant for this class.

**Example Usage:**

```lua
CLASS.bloodcolor = BLOOD_COLOR_RED
```

---

### Appearance & Identity

#### `bodyGroups`

**Type:**

`table`

**Description:**

Mapping of bodygroup names to index values applied when the player spawns. If omitted, bodygroups are not modified.

**Example Usage:**

```lua
CLASS.bodyGroups = {
    hands = 2, -- apply option 2 to the "hands" bodygroup
    torso = 0  -- index value 0 keeps the default option
}
```

---

#### `logo`

**Type:**

`string`

**Description:**

Path to the material used as this class's logo. When `nil`, no logo is displayed in the scoreboard or F1 menu.

**Example Usage:**

```lua
CLASS.logo = "materials/example/eng_logo.png"
```

---

#### `scoreboardHidden`

**Type:**

`boolean`

**Description:**

If `true`, this class will not display a header or logo on the scoreboard.

**Example Usage:**

```lua
CLASS.scoreboardHidden = true
```

---

#### `skin`

**Type:**

`number`

**Description:**

Model skin index to apply to members of this class.

**Example Usage:**

```lua
CLASS.skin = 2
```

---

#### `subMaterials`

**Type:**

`table`

**Description:**

List of material paths that replace the model's sub-materials. The first entry applies to sub-material `0`, the second to `1`, and so on. Leave `nil` for no overrides.

**Example Usage:**

```lua
CLASS.subMaterials = {
    "models/example/custom_cloth", -- sub-material 0
    "models/example/custom_armor" -- sub-material 1
}
```

---

#### `model`

**Type:**

`string` or `table`

**Description:**

Model path (or list of paths) assigned to this class. When omitted, the character's existing model is used.

**Example Usage:**

```lua
CLASS.model = "models/player/alyx.mdl"
```

---

#### `requirements`

**Type:**

`string` or `table`

**Description:**

Text displayed to the player describing what is needed to join this class. Accepts a string or list of strings. This field does not restrict access on its own.

**Example Usage:**

```lua
-- single requirement string
CLASS.requirements = "Flag V"
-- or list multiple requirements
CLASS.requirements = {"Flag V", "Engineering 25+"}
```

---

#### `commands`

**Type:**

`table`

**Description:**

Table of command names that members of this class may always use,

overriding standard command permissions. If omitted, no extra commands are granted.

**Example Usage:**

```lua
CLASS.commands = {
    plytransfer = true,
}
```

#### `canInviteToFaction`

**Type:**

`boolean`

**Description:**

Whether members of this class can invite players to join their faction.

**Example Usage:**

```lua
CLASS.canInviteToFaction = true
```

---

#### `canInviteToClass`

**Type:**

`boolean`

**Description:**

Whether members of this class can invite players to join this class.

**Example Usage:**

```lua
CLASS.canInviteToClass = true
```

---

#### `OnCanBe(client)`

**Type:**

`function`

**Description:**

Optional callback executed when a player attempts to join the class. `self` is the class table. Return `false` to block the player from joining.

**Example Usage:**

```lua
function CLASS:OnCanBe(client)
    return client:IsAdmin()
end
```

---

## Complete Example

```lua
-- schema/classes/engineer.lua
CLASS.name = "Engineer"
CLASS.desc = "Technicians who maintain complex machinery."
CLASS.faction = FACTION_CITIZEN
CLASS.isDefault = true
CLASS.color = Color(150, 150, 255)
CLASS.weapons = {"weapon_pistol", "weapon_crowbar"}
CLASS.pay = 25
CLASS.payLimit = 250
CLASS.payTimer = 1800
CLASS.limit = 5
CLASS.health = 120
CLASS.armor = 25
CLASS.scale = 1
CLASS.runSpeed = 1.1
CLASS.runSpeedMultiplier = true
CLASS.walkSpeed = 1
CLASS.walkSpeedMultiplier = true
CLASS.jumpPower = 200
CLASS.jumpPowerMultiplier = false
CLASS.logo = "materials/example/eng_logo.png"
CLASS.scoreboardHidden = true
CLASS.skin = 0
CLASS.subMaterials = {
    "models/example/custom_cloth", -- sub-material 0
    "models/example/custom_armor" -- sub-material 1
}
CLASS.bodyGroups = {
    {id = 1, value = 1},
    {id = 2, value = 2}
}
CLASS.model = {
    "models/player/Group03/male_07.mdl",
    "models/player/Group03/female_02.mdl"
}
CLASS.requirements = "Flag V"
CLASS.isWhitelisted = false
CLASS.uniqueID = "engineer"
CLASS.index = CLASS_ENGINEER
CLASS.bloodcolor = BLOOD_COLOR_RED
CLASS.commands = {
    plytransfer = true
}
CLASS.canInviteToFaction = true
CLASS.canInviteToClass = true
function CLASS:OnCanBe(client)
    return client:IsAdmin()
end
```
