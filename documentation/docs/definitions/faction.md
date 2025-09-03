# Faction Fields

This document describes all the configurable `FACTION` fields available in the codebase, with their descriptions and example usages.

Unspecified fields will use sensible defaults.

---

## Overview

Each faction in the game is defined by a set of fields on the global `FACTION` table. These fields control everything from display name and lore, to starting weapons and player statistics. All fields are optional; unspecified fields will fall back to sensible defaults.

---

## Field Summary

| Field | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | `"Unknown"` | Display name shown to players. |
| `desc` | `string` | `"No Description"` | Lore or descriptive text. |
| `isDefault` | `boolean` | `true` | Whether the faction is available without whitelist. |
| `color` | `Color` | `Color(150,150,150)` | UI color representing the faction. |
| `models` | `table` | `DefaultModels` | Available player model paths. |
| `uniqueID` | `string` | `filename` | Internal string identifier. |
| `prefix` | `string`/`function` | `""` | Optional name prefix or function returning one. |
| `weapons` | `table` | `{}` | Automatically granted weapons. |
| `items` | `table` | `{}` | Automatically granted items. |
| `index` | `number` | `auto` | Numeric ID assigned at registration time. |
| `pay` | `number` | `0` | Payment amount per interval. |
| `payLimit` | `number` | `0` | Maximum accumulated pay. |
| `limit` | `number` | `0` | Maximum number of players in the faction. |
| `oneCharOnly` | `boolean` | `false` | Restrict players to one character only. |
| `health` | `number` | `0` | Starting health. |
| `armor` | `number` | `0` | Starting armor. |
| `scale` | `number` | `1` | Player model scale multiplier. |
| `runSpeed` | `number` | `0` | Base running speed. |
| `runSpeedMultiplier` | `boolean` | `false` | Multiply base speed instead of replacing it. |
| `walkSpeed` | `number` | `0` | Base walking speed. |
| `walkSpeedMultiplier` | `boolean` | `false` | Multiply base walk speed instead of replacing it. |
| `jumpPower` | `number` | `0` | Base jump power. |
| `jumpPowerMultiplier` | `boolean` | `false` | Multiply base jump power instead of replacing it. |
| `MemberToMemberAutoRecognition` | `boolean` | `false` | Auto-recognition among faction members. |
| `bloodcolor` | `number` | `0` | Blood color enum. |
| `bodyGroups` | `table` | `{}` | Bodygroup name→index mapping applied on spawn. |
| `NPCRelations` | `table` | `{}` | NPC class→disposition mapping on spawn/creation. |
| `RecognizesGlobally` | `boolean` | `false` | Global player recognition. |
| `isGloballyRecognized` | `boolean` | `false` | Everyone automatically recognizes this faction.
| `scoreboardHidden` | `boolean` | `false` | Hide members from the scoreboard. |
| `commands` | `table` | `{}` | Command names members may always use. |

---

## Field Details

### Basic Info

#### `name`

**Type:**

`string`

**Description:**

Display name shown for members of this faction.

**Example Usage:**

```lua
FACTION.name = "Minecrafters"
```

---

#### `desc`

**Type:**

`string`

**Description:**

Lore or descriptive text about the faction.

**Example Usage:**

```lua
FACTION.desc = "Surviving and crafting in the blocky world."
```

---

#### `isDefault`

**Type:**

`boolean`

**Description:**

Set to `true` if players may select this faction without a whitelist.

**Example Usage:**

```lua
FACTION.isDefault = false
```

---

#### `uniqueID`

**Type:**

`string`

**Description:**

Internal string identifier for referencing the faction.

**Example Usage:**

```lua
FACTION.uniqueID = "staff"
```

#### `prefix`

**Type:**

`string` or `function`

**Description:**

Optional prefix automatically prepended to new character names. If a function is

provided, it is called with the player creating the character and should return

the desired text. The result is inserted before the base name with a space and

trimmed; returning `nil` or an empty string results in no prefix being applied.

**Example Usage:**

```lua
FACTION.prefix = "[CIT]"
-- or
FACTION.prefix = function(client)
    return client:isVIP() and "[VIP]" or ""
end
```

---

#### `index`

**Type:**

`number`

**Description:**

Numeric identifier assigned during faction registration.

**Example Usage:**

```lua
FACTION_STAFF = FACTION.index
```

---

### Appearance & Models

#### `color`

**Type:**

`Color`

**Description:**

Color used in UI elements to represent the faction. Defaults to `Color(150, 150, 150)` if not specified.

**Example Usage:**

```lua
FACTION.color = Color(255, 56, 252)
```

---

#### `models`

**Type:**

`table`

**Description:**

Table of player model paths available to faction members.

**Example Usage:**

```lua
FACTION.models = {
    "models/Humans/Group02/male_07.mdl",
    "models/Humans/Group02/female_02.mdl"
}
```

---

#### `bodyGroups`

**Type:**

`table`

**Description:**

Mapping of bodygroup names to index values applied on spawn.

**Example Usage:**

```lua
FACTION.bodyGroups = {
    hands = 1,
    torso = 3
}
```

---

### Economy & Limits

#### `weapons`

**Type:**

`table`

**Description:**

Weapons automatically granted on spawn.

**Example Usage:**

```lua
FACTION.weapons = {"weapon_physgun", "gmod_tool"}
```

---

#### `items`

**Type:**

`table`

**Description:**

Item uniqueIDs automatically granted on character creation.

**Example Usage:**

```lua
FACTION.items = {"radio", "handcuffs"}
```

---

#### `pay`

**Type:**

`number`

**Description:**

Payment amount for members each interval.

**Example Usage:**

```lua
FACTION.pay = 50
```

---

#### `payLimit`

**Type:**

`number`

**Description:**

Maximum pay a member can accumulate.

**Example Usage:**

```lua
FACTION.payLimit = 1000
```

---

#### `limit`

**Type:**

`number`

**Description:**

Maximum number of players allowed in this faction.

**Example Usage:**

```lua
FACTION.limit = 20
```

---

#### `oneCharOnly`

**Type:**

`boolean`

**Description:**

If `true`, players may only create one character in this faction.

**Example Usage:**

```lua
FACTION.oneCharOnly = true
```

---

### Movement & Stats

#### `health`

**Type:**

`number`

**Description:**

Starting health for faction members.

**Example Usage:**

```lua
FACTION.health = 150
```

---

#### `armor`

**Type:**

`number`

**Description:**

Starting armor for faction members.

**Example Usage:**

```lua
FACTION.armor = 25
```

---

#### `scale`

**Type:**

`number`

**Description:**

Player model scale multiplier.

**Example Usage:**

```lua
FACTION.scale = 1.1
```

---

#### `runSpeed`

**Type:**

`number`

**Description:**

Base running speed.

**Example Usage:**

```lua
FACTION.runSpeed = 250
```

---

#### `runSpeedMultiplier`

**Type:**

`boolean`

**Description:**

If `true`, multiplies the base speed rather than replacing it.

**Example Usage:**

```lua
FACTION.runSpeedMultiplier = false
```

---

#### `walkSpeed`

**Type:**

`number`

**Description:**

Base walking speed.

**Example Usage:**

```lua
FACTION.walkSpeed = 200
```

---

#### `walkSpeedMultiplier`

**Type:**

`boolean`

**Description:**

If `true`, multiplies the base walk speed rather than replacing it.

**Example Usage:**

```lua
FACTION.walkSpeedMultiplier = true
```

---

#### `jumpPower`

**Type:**

`number`

**Description:**

Base jump power.

**Example Usage:**

```lua
FACTION.jumpPower = 200
```

---

#### `jumpPowerMultiplier`

**Type:**

`boolean`

**Description:**

If `true`, multiplies the base jump power rather than replacing it.

**Example Usage:**

```lua
FACTION.jumpPowerMultiplier = true
```

---

### Recognition & Relations

#### `MemberToMemberAutoRecognition`

**Type:**

`boolean`

**Description:**

Whether faction members automatically recognize each other on sight.

**Example Usage:**

```lua
FACTION.MemberToMemberAutoRecognition = true
```

---

#### `RecognizesGlobally`

**Type:**

`boolean`

**Description:**

If `true`, members recognize all players globally, regardless of faction.

**Example Usage:**

```lua
FACTION.RecognizesGlobally = false
```

#### `isGloballyRecognized`

**Type:**

`boolean`

**Description:**

If set to `true`, all players will automatically recognize members of this faction.

**Example Usage:**

```lua
FACTION.isGloballyRecognized = true
```

---

#### `NPCRelations`

**Type:**

`table`

**Description:**

Mapping of NPC class names to disposition constants (`D_HT`, `D_LI`, etc.). NPCs are updated on spawn/creation.

**Example Usage:**

```lua
FACTION.NPCRelations = {
    ["npc_combine_s"] = D_HT,
    ["npc_citizen"]     = D_LI
}
```

---

#### `bloodcolor`

**Type:**

`number`

**Description:**

Blood color enumeration constant for faction members.

**Example Usage:**

```lua
FACTION.bloodcolor = BLOOD_COLOR_RED
```

---

#### `scoreboardHidden`

**Type:**

`boolean`

**Description:**

If `true`, members of this faction are hidden from the scoreboard.

**Example Usage:**

```lua
FACTION.scoreboardHidden = false
```

---

#### `commands`

**Type:**

`table`

**Description:**

Table of command names that members of this faction may always use,

even if they normally lack the required privilege.

**Example Usage:**

```lua
FACTION.commands = {
    plytransfer = true,
}
```

## Example Faction Definition

The snippet below shows a minimal faction script using many of the fields described above.

```lua
FACTION.name = "Citizens"
FACTION.desc = "Everyday city dwellers."
FACTION.color = Color(75, 150, 50)
FACTION.isDefault = true
FACTION.models = {
    "models/Humans/Group01/male_01.mdl",
    "models/Humans/Group01/female_01.mdl"
}
FACTION.prefix = "[CIT]"
FACTION.weapons = {"radio"}
FACTION.items = {"water"}
FACTION.pay = 20
FACTION.health = 100
FACTION.armor = 0
FACTION.runSpeed = 200
FACTION.walkSpeed = 100
FACTION.jumpPower = 160
FACTION.bodyGroups = {hands = 1}
FACTION.NPCRelations = {
    ["npc_metropolice"] = D_HT
}

FACTION_CITIZEN = FACTION.index
```

---
