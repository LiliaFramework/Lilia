# Attribute Fields

> This entry describes all configurable `ATTRIBUTE` fields in the codebase. Use these to control each attribute’s display, limits, and behavior when applied to players. Unspecified fields fall back to sensible defaults.

---

## Overview

Each attribute is registered on the global `ATTRIBUTE` table. You can customize:

* **Display**: The `name` and `desc` that players see in-game.
* **Startup bonus**: Whether this attribute can receive points from the pool allocated during character creation.
* **Value limits**: The hard cap (`maxValue`) and the creation-time base cap (`startingMax`).

---

## Field Summary

| Field          | Type      | Default | Description                                                                                    |
| -------------- | --------- | ------- | ---------------------------------------------------------------------------------------------- |
| `name`         | `string`  | —       | Human-readable title of the attribute.                                                         |
| `desc`         | `string`  | —       | Brief description or lore text.                                                                |
| `startingMax`  | `number`  | `0`     | Maximum base value at character creation, before any startup bonus points are applied.         |
| `noStartBonus` | `boolean` | `false` | If `true`, players cannot allocate any of the creation startup bonus points to this attribute. |
| `maxValue`     | `number`  | `30`    | Absolute upper limit an attribute can ever reach.                                              |

---

## Field Details

#### `name`

Specify the human-readable title for the attribute.

```lua
ATTRIBUTE.name = "Strength"
```

#### `desc`

Provide a concise description for the attribute.

```lua
ATTRIBUTE.desc = "Determines physical power and carrying capacity."
```

#### `startingMax`

Defines the cap on the attribute’s base value at character creation.

```lua
ATTRIBUTE.startingMax = 15
```

#### `noStartBonus`

Controls whether this attribute is eligible for the startup bonus—the pool of points players assign when creating a character.
If set to `true`, players cannot allocate any of their initial creation points to this attribute.

```lua
ATTRIBUTE.noStartBonus = false
```

#### `maxValue`

Sets the hard cap for this attribute.

```lua
ATTRIBUTE.maxValue = 50
```

---