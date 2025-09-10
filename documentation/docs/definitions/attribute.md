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
| `name`         | `string`  | `"Unknown"` | Human-readable title of the attribute. |
| `desc`         | `string`  | `"No Description"`  | Brief description or lore text. |
| `startingMax`  | `number`  | `30`    | Maximum base value at character creation, before any startup bonus points are applied. |
| `noStartBonus` | `boolean` | `false` | If `true`, players cannot allocate any of the creation startup bonus points to this attribute. |
| `maxValue`     | `number`  | `30`    | Absolute upper limit an attribute can ever reach. |
| `min`          | `number`  | `0`     | Minimum value for display purposes in character information panels. |
| `max`          | `number`  | `100`   | Maximum value for display purposes in character information panels. |

---

## Field Details

#### `name`

Human readable title shown in menus. When the attribute is loaded,

`lia.attribs.loadFromDir` automatically defaults this to the translated

string "Unknown" if no name is provided.

```lua
ATTRIBUTE.name = "Strength"
```

---

#### `desc`

Concise description or lore text for the attribute. Defaults to the

translation "No Description" when omitted.

```lua
ATTRIBUTE.desc = "Determines physical power and carrying capacity."
```

---

#### `startingMax`

Cap on the attribute’s base value during character creation. The

configuration variable `MaxStartingAttributes` (default `30`) provides

the fallback value when this field is not defined.

```lua
ATTRIBUTE.startingMax = 15
```

---

#### `noStartBonus`

If set to `true`, players cannot allocate any of their initial creation

bonus points to this attribute. The attribute can still increase later

through normal gameplay or boosts.

```lua
ATTRIBUTE.noStartBonus = false
```

---

#### `maxValue`

Absolute ceiling an attribute can ever reach. Defaults to the

`MaxAttributePoints` configuration value (30) when unspecified.

```lua
ATTRIBUTE.maxValue = 50
```

---

#### `min`

Minimum value used for display purposes in character information panels.

This field controls the lower bound shown in progress bars and other UI elements.

```lua
ATTRIBUTE.min = 0
```

---

#### `max`

Maximum value used for display purposes in character information panels.

This field controls the upper bound shown in progress bars and other UI elements.

```lua
ATTRIBUTE.max = 100
```

### Full Attribute Example

```lua
-- agility.lua
ATTRIBUTE.name = "Agility"
ATTRIBUTE.desc = "Improves your reflexes and overall movement speed."
ATTRIBUTE.startingMax = 20
ATTRIBUTE.noStartBonus = false
ATTRIBUTE.maxValue = 50
ATTRIBUTE.min = 0
ATTRIBUTE.max = 100
```
