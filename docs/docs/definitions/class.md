# Class Fields

This document describes all configurable `CLASS` fields in the codebase. Each field controls a specific aspect of how a class behaves, appears, or is granted to players. Unspecified fields will use sensible defaults.

---

## Overview

The global `CLASS` table defines per-class settings such as display name, lore, starting equipment, pay parameters, movement speeds, and visual appearance. Use these fields to fully customize each class’s behavior and presentation.

---

## Field Summary

| Field                 | Type           | Description                                                    |
|-----------------------|----------------|----------------------------------------------------------------|
| `name`                | `string`       | Displayed name of the class.                                   |
| `desc`                | `string`       | Description or lore of the class.                              |
| `isDefault`           | `boolean`      | Whether the class is available by default.                     |
| `isWhitelisted`       | `boolean`      | Whether the class requires whitelist to join.                  |
| `faction`             | `number`       | Linked faction index (e.g., `FACTION_CITIZEN`).                |
| `color`               | `Color`        | UI color associated with the class.                            |
| `weapons`             | `string[]`     | Weapons granted to members of this class.                      |
| `pay`                 | `number`       | Payment amount per interval.                                   |
| `payLimit`            | `number`       | Maximum accumulated pay.                                       |
| `payTimer`            | `number`       | Interval (seconds) between paychecks.                          |
| `limit`               | `number`       | Maximum number of players in this class.                       |
| `health`              | `number`       | Default starting health.                                       |
| `armor`               | `number`       | Default starting armor.                                        |
| `scale`               | `number`       | Player model scale multiplier.                                |
| `runSpeed`            | `number`       | Default running speed.                                         |
| `runSpeedMultiplier`  | `boolean`      | Multiply base speed instead of replacing it.                   |
| `walkSpeed`           | `number`       | Default walking speed.                                         |
| `walkSpeedMultiplier` | `boolean`      | Multiply base walk speed instead of replacing it.              |
| `jumpPower`           | `number`       | Default jump power.                                            |
| `jumpPowerMultiplier` | `boolean`      | Multiply base jump power instead of replacing it.              |
| `bloodcolor`          | `number`       | Blood color enumeration constant.                              |
| `bodyGroups`          | `table`        | Bodygroup index mapping applied on spawn.                      |
| `model`               | `string`       | Model path (or table of paths) used by this class.             |
| `index`               | `number`       | Unique team index assigned at registration.                    |

---

## Field Details

### Basic Info

#### `name`
**Type:** `string`  
**Description:** The displayed name of the class.  
**Example:**
```lua
CLASS.name = "Engineer"
````

#### `desc`

**Type:** `string`
**Description:** The description or lore of the class.
**Example:**

```lua
CLASS.desc = "Technicians who maintain equipment."
```

#### `index`

**Type:** `number`
**Description:** Unique numeric identifier (team index) for the class.
**Example:**

```lua
CLASS.index = CLASS_ENGINEER
```

---

### Affiliation & Availability

#### `isDefault`

**Type:** `boolean`
**Description:** Determines if the class is available to all players by default.
**Example:**

```lua
CLASS.isDefault = true
```

#### `isWhitelisted`

**Type:** `boolean`
**Description:** Indicates if the class requires a whitelist entry to be accessible.
**Example:**

```lua
CLASS.isWhitelisted = false
```

#### `faction`

**Type:** `number`
**Description:** Links this class to a specific faction index.
**Example:**

```lua
CLASS.faction = FACTION_CITIZEN
```

#### `color`

**Type:** `Color`
**Description:** UI color representing the class.
**Example:**

```lua
CLASS.color = Color(255, 0, 0)
```

---

### Equipment & Economy

#### `weapons`

**Type:** `string[]`
**Description:** Weapons granted to members of this class on spawn.
**Example:**

```lua
CLASS.weapons = {"weapon_pistol", "weapon_crowbar"}
```

#### `pay`

**Type:** `number`
**Description:** Payment amount issued per pay interval.
**Example:**

```lua
CLASS.pay = 50
```

#### `payLimit`

**Type:** `number`
**Description:** Maximum accumulated pay a player can hold.
**Example:**

```lua
CLASS.payLimit = 1000
```

#### `payTimer`

**Type:** `number`
**Description:** Interval in seconds between salary payouts.
**Example:**

```lua
CLASS.payTimer = 3600
```

#### `limit`

**Type:** `number`
**Description:** Maximum number of players allowed in this class simultaneously.
**Example:**

```lua
CLASS.limit = 10
```

---

### Movement & Stats

#### `health`

**Type:** `number`
**Description:** Default starting health for class members.
**Example:**

```lua
CLASS.health = 150
```

#### `armor`

**Type:** `number`
**Description:** Default starting armor.
**Example:**

```lua
CLASS.armor = 50
```

#### `scale`

**Type:** `number`
**Description:** Multiplier for player model size.
**Example:**

```lua
CLASS.scale = 1.2
```

#### `runSpeed`

**Type:** `number`
**Description:** Default running speed.
**Example:**

```lua
CLASS.runSpeed = 250
```

#### `runSpeedMultiplier`

**Type:** `boolean`
**Description:** Multiply base run speed instead of replacing it.
**Example:**

```lua
CLASS.runSpeedMultiplier = true
```

#### `walkSpeed`

**Type:** `number`
**Description:** Default walking speed.
**Example:**

```lua
CLASS.walkSpeed = 200
```

#### `walkSpeedMultiplier`

**Type:** `boolean`
**Description:** Multiply base walk speed instead of replacing it.
**Example:**

```lua
CLASS.walkSpeedMultiplier = false
```

#### `jumpPower`

**Type:** `number`
**Description:** Default jump power.
**Example:**

```lua
CLASS.jumpPower = 200
```

#### `jumpPowerMultiplier`

**Type:** `boolean`
**Description:** Multiply base jump power instead of replacing it.
**Example:**

```lua
CLASS.jumpPowerMultiplier = true
```

#### `bloodcolor`

**Type:** `number`
**Description:** Blood color enumeration constant for this class.
**Example:**

```lua
CLASS.bloodcolor = BLOOD_COLOR_RED
```

---

### Appearance & Identity

#### `bodyGroups`

**Type:** `table`
**Description:** Mapping of bodygroup indices to values applied on spawn.
**Example:**

```lua
CLASS.bodyGroups = { [1] = 2, [3] = 1 }
```

#### `model`

**Type:** `string` or `string[]`
**Description:** Model path (or list of paths) assigned to this class.
**Example:**

```lua
CLASS.model = "models/player/alyx.mdl"
```
