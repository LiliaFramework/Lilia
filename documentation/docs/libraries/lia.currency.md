# Currency Library

This page covers money and currency related helpers.

---

## Overview

The currency library formats money amounts, spawns physical money entities, and exposes the configured currency names. The symbol and name values come from the configuration options defined in `gamemode/core/libraries/config.lua`.

---

### lia.currency.get

**Purpose**

Formats a numeric amount into a currency string using `lia.currency.symbol`, `lia.currency.singular`, and `lia.currency.plural`.

**Parameters**

* `amount` (*number*): Amount to format.

**Realm**

`Shared`

**Returns**

* *string*: The formatted currency string.

**Example Usage**

```lua
lia.currency.symbol = "$"
lia.currency.singular = "dollar"
lia.currency.plural = "dollars"

print(lia.currency.get(10))
```

---

### lia.currency.spawn

**Purpose**

Creates a `lia_money` entity at the specified position with the given amount.

**Parameters**

* `pos` (*Vector*): Spawn position for the currency entity.

* `amount` (*number*): Monetary value for the entity.

* `angle` (*Angle*): Orientation of the entity. Optional.

**Realm**

`Server`

**Returns**

* *Entity*: The spawned currency entity if successful; `nil` otherwise.

**Example Usage**

```lua
local pos = client:GetEyeTrace().HitPos
local ang = Angle(0, client:EyeAngles().y, 0)

local money = lia.currency.spawn(pos, 100, ang)
```

---
