# Attribute Fields

This document describes all configurable `ATTRIBUTE` fields and hooks in the codebase. Use these to control each attribute’s display, limits, and behavior when applied to players.
Unspecified fields fall back to sensible defaults.

---

## Table of Contents

1. [Overview](#overview)  
2. [Field Summary](#field-summary)  
3. [Field Details](#field-details)  
   - [Basic Info](#basic-info)  
   - [Value Constraints](#value-constraints)  
   - [Setup Hook](#setup-hook)  

---

## Overview

Each attribute is defined on a global `ATTRIBUTE` table. You can configure its name, description, whether it receives a startup bonus, its maximum and starting values, and respond to setup events via a hook.

---

## Field Summary

| Field / Hook             | Type            | Description                                                  |
|--------------------------|-----------------|--------------------------------------------------------------|
| `name`                   | `string`        | Display name of the attribute.                               |
| `desc`                   | `string`        | Short description or lore of the attribute.                  |
| `noStartBonus`           | `boolean`       | If `true`, attribute cannot receive a bonus at game start.   |
| `maxValue`               | `number`        | Absolute maximum value the attribute can reach.             |
| `startingMax`            | `number`        | Maximum value the attribute can start with at character creation. |
| `OnSetup(client, value)` | `function`      | Hook executed when the attribute is applied to a player.     |

---

## Field Details

### Basic Info

#### `name`
**Type:** `string`  
**Description:** Specifies the display name of the attribute.  
**Example:**
```lua
ATTRIBUTE.name = "Strength"
````

#### `desc`

**Type:** `string`
**Description:** Provides a short description or lore for the attribute.
**Example:**

```lua
ATTRIBUTE.desc = "Strength Skill."
```

---

### Value Constraints

#### `noStartBonus`

**Type:** `boolean`
**Description:** Determines whether the attribute is eligible for a bonus at the start of the game.
**Example:**

```lua
ATTRIBUTE.noStartBonus = false
```

#### `maxValue`

**Type:** `number`
**Description:** Specifies the absolute upper limit the attribute can ever reach.
**Example:**

```lua
ATTRIBUTE.maxValue = 50
```

#### `startingMax`

**Type:** `number`
**Description:** Defines the maximum value the attribute can begin with when a character is created.
**Example:**

```lua
ATTRIBUTE.startingMax = 15
```

---

### Setup Hook

#### `OnSetup(client, value)`

**Type:** `function(client, number)`
**Description:** Called when the attribute is initialized on a player (e.g., at character load or creation). Use this hook to run custom logic, send notifications, apply effects, etc.

**Example:**

```lua
function ATTRIBUTE:OnSetup(client, value)
    if value > 5 then
        client:ChatPrint("You are very Strong!")
    end
end
```
