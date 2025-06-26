# Faction Fields

This document describes all the configurable `FACTION` fields available in the codebase, with their descriptions and example usages.

---

## Table of Contents

1. [Overview](#overview)  
2. [Field Summary](#field-summary)  
3. [Field Details](#field-details)  
   - [Basic Info](#basic-info)  
   - [Appearance & Models](#appearance--models)  
   - [Economy & Limits](#economy--limits)  
   - [Movement & Stats](#movement--stats)  
   - [Recognition & Relations](#recognition--relations)  

---

## Overview

Each faction in the game is defined by a set of fields on the global `FACTION` table. These fields control everything from display name and lore, to starting weapons and player statistics. All fields are optional; unspecified fields will fall back to sensible defaults.

---

## Field Summary

| Field                       | Type         | Description                                            |
|-----------------------------|--------------|--------------------------------------------------------|
| `name`                      | `string`     | Display name shown to players.                         |
| `desc`                      | `string`     | Lore or descriptive text.                              |
| `isDefault`                 | `boolean`    | Whether the faction is available without whitelist.    |
| `color`                     | `Color`      | UI color representing the faction.                     |
| `models`                    | `string[]`   | Available player model paths.                          |
| `uniqueID`                  | `string`     | Internal string identifier.                            |
| `weapons`                   | `string[]`   | Automatically granted weapons.                         |
| `items`                     | `string[]`   | Automatically granted items.                           |
| `index`                     | `number`     | Numeric ID assigned at registration time.              |
| `pay`                       | `number`     | Payment amount per interval.                           |
| `payLimit`                  | `number`     | Maximum accumulated pay.                               |
| `payTimer`                  | `number`     | Interval (in seconds) between paychecks.               |
| `limit`                     | `number`     | Maximum number of players in the faction.              |
| `oneCharOnly`               | `boolean`    | Restrict players to one character only.                |
| `health`                    | `number`     | Starting health.                                       |
| `armor`                     | `number`     | Starting armor.                                        |
| `scale`                     | `number`     | Player model scale multiplier.                        |
| `runSpeed`                  | `number`     | Base running speed.                                    |
| `runSpeedMultiplier`        | `boolean`    | Multiply base speed instead of replacing it.           |
| `walkSpeed`                 | `number`     | Base walking speed.                                    |
| `walkSpeedMultiplier`       | `boolean`    | Multiply base walk speed instead of replacing it.      |
| `jumpPower`                 | `number`     | Base jump power.                                       |
| `jumpPowerMultiplier`       | `boolean`    | Multiply base jump power instead of replacing it.      |
| `MemberToMemberAutoRecognition` | `boolean` | Auto-recognition among faction members.                |
| `bloodcolor`                | `number`     | Blood color enum.                                      |
| `bodyGroups`                | `table`      | Bodygroup name→index mapping applied on spawn.         |
| `NPCRelations`              | `table`      | NPC class→disposition mapping on spawn/creation.       |
| `RecognizesGlobally`        | `boolean`    | Global player recognition.                             |
| `ScoreboardHidden`          | `boolean`    | Hide members from the scoreboard.                      |

---

## Field Details

### Basic Info

#### `name`
**Type:** `string`  
**Description:** Display name shown for members of this faction.  
**Example:**
```lua
FACTION.name = "Minecrafters"
````

#### `desc`

**Type:** `string`
**Description:** Lore or descriptive text about the faction.
**Example:**

```lua
FACTION.desc = "Surviving and crafting in the blocky world."
```

#### `isDefault`

**Type:** `boolean`
**Description:** Set to `true` if players may select this faction without a whitelist.
**Example:**

```lua
FACTION.isDefault = false
```

#### `uniqueID`

**Type:** `string`
**Description:** Internal string identifier for referencing the faction.
**Example:**

```lua
FACTION.uniqueID = "staff"
```

#### `index`

**Type:** `number`
**Description:** Numeric identifier assigned during faction registration.
**Example:**

```lua
FACTION_STAFF = FACTION.index
```

---

### Appearance & Models

#### `color`

**Type:** `Color`
**Description:** Color used in UI elements to represent the faction.
**Example:**

```lua
FACTION.color = Color(255, 56, 252)
```

#### `models`

**Type:** `string[]`
**Description:** Table of player model paths available to faction members.
**Example:**

```lua
FACTION.models = {
    "models/Humans/Group02/male_07.mdl",
    "models/Humans/Group02/female_02.mdl"
}
```

#### `bodyGroups`

**Type:** `table`
**Description:** Mapping of bodygroup names to index values applied on spawn.
**Example:**

```lua
FACTION.bodyGroups = {
    hands = 1,
    torso = 3
}
```

---

### Economy & Limits

#### `weapons`

**Type:** `string[]`
**Description:** Weapons automatically granted on spawn.
**Example:**

```lua
FACTION.weapons = {"weapon_physgun", "gmod_tool"}
```

#### `items`

**Type:** `string[]`
**Description:** Item uniqueIDs automatically granted on character creation.
**Example:**

```lua
FACTION.items = {"radio", "handcuffs"}
```

#### `pay`

**Type:** `number`
**Description:** Payment amount for members each interval.
**Example:**

```lua
FACTION.pay = 50
```

#### `payLimit`

**Type:** `number`
**Description:** Maximum pay a member can accumulate.
**Example:**

```lua
FACTION.payLimit = 1000
```

#### `payTimer`

**Type:** `number`
**Description:** Interval in seconds between salary payouts.
**Example:**

```lua
FACTION.payTimer = 3600
```

#### `limit`

**Type:** `number`
**Description:** Maximum number of players allowed in this faction.
**Example:**

```lua
FACTION.limit = 20
```

#### `oneCharOnly`

**Type:** `boolean`
**Description:** If `true`, players may only create one character in this faction.
**Example:**

```lua
FACTION.oneCharOnly = true
```

---

### Movement & Stats

#### `health`

**Type:** `number`
**Description:** Starting health for faction members.
**Example:**

```lua
FACTION.health = 150
```

#### `armor`

**Type:** `number`
**Description:** Starting armor for faction members.
**Example:**

```lua
FACTION.armor = 25
```

#### `scale`

**Type:** `number`
**Description:** Player model scale multiplier.
**Example:**

```lua
FACTION.scale = 1.1
```

#### `runSpeed`

**Type:** `number`
**Description:** Base running speed.
**Example:**

```lua
FACTION.runSpeed = 250
```

#### `runSpeedMultiplier`

**Type:** `boolean`
**Description:** If `true`, multiplies the base speed rather than replacing it.
**Example:**

```lua
FACTION.runSpeedMultiplier = false
```

#### `walkSpeed`

**Type:** `number`
**Description:** Base walking speed.
**Example:**

```lua
FACTION.walkSpeed = 200
```

#### `walkSpeedMultiplier`

**Type:** `boolean`
**Description:** If `true`, multiplies the base walk speed rather than replacing it.
**Example:**

```lua
FACTION.walkSpeedMultiplier = true
```

#### `jumpPower`

**Type:** `number`
**Description:** Base jump power.
**Example:**

```lua
FACTION.jumpPower = 200
```

#### `jumpPowerMultiplier`

**Type:** `boolean`
**Description:** If `true`, multiplies the base jump power rather than replacing it.
**Example:**

```lua
FACTION.jumpPowerMultiplier = true
```

---

### Recognition & Relations

#### `MemberToMemberAutoRecognition`

**Type:** `boolean`
**Description:** Whether faction members automatically recognize each other on sight.
**Example:**

```lua
FACTION.MemberToMemberAutoRecognition = true
```

#### `RecognizesGlobally`

**Type:** `boolean`
**Description:** If `true`, members recognize all players globally, regardless of faction.
**Example:**

```lua
FACTION.RecognizesGlobally = false
```

#### `NPCRelations`

**Type:** `table`
**Description:** Mapping of NPC class names to disposition constants (`D_HT`, `D_LI`, etc.). NPCs are updated on spawn/creation.
**Example:**

```lua
FACTION.NPCRelations = {
    ["npc_combine_s"] = D_HT,
    ["npc_citizen"]     = D_LI
}
```

#### `bloodcolor`

**Type:** `number`
**Description:** Blood color enumeration constant for faction members.
**Example:**

```lua
FACTION.bloodcolor = BLOOD_COLOR_RED
```

#### `ScoreboardHidden`

**Type:** `boolean`
**Description:** If `true`, members of this faction are hidden from the scoreboard.
**Example:**

```lua
FACTION.ScoreboardHidden = false
```

```