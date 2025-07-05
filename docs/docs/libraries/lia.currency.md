# Currency Library

This page covers money and currency related helpers.

---

## Overview

The currency library formats money amounts, spawns physical money entities, and exposes the configured currency names. The symbol and name values come from the configuration options defined in `gamemode/core/libraries/config.lua`.

### Fields

* **lia.currency.symbol** (string) – Prefix used when displaying money amounts.
* **lia.currency.singular** (string) – Singular form of the currency name.
* **lia.currency.plural** (string) – Plural form of the currency name.

---

### lia.currency.get

**Description:**

Formats a numeric amount into a currency string using `lia.currency.symbol`,
`lia.currency.singular`, and `lia.currency.plural`. If the amount equals `1`
the singular name is used, otherwise the plural form is shown.

**Parameters:**

* amount (number) – The amount to format.


**Realm:**

* Shared


**Returns:**

* string – The formatted currency string.


**Example Usage:**

```lua
-- Customize how money is displayed
lia.currency.symbol = "$" -- usually configured via lia.config
lia.currency.singular = "dollar"
lia.currency.plural = "dollars"
print(lia.currency.get(10)) -- "$10 dollars"
```

---

### lia.currency.spawn

**Description:**

Creates a `lia_money` entity at the specified position with the given amount.
The position must be valid and the amount non-negative. An optional angle can
be provided to control the entity's orientation.

**Parameters:**

* pos (Vector) – The spawn position for the currency entity.


* amount (number) – The monetary value for the entity.


* angle (Angle, optional) – The orientation for the entity (defaults to Angle(0, 0, 0)).


**Realm:**

* Server


**Returns:**

* Entity – The spawned currency entity if successful; nil otherwise.


**Example Usage:**

```lua
-- Spawn 100 dollars in front of the player
local pos = client:GetEyeTrace().HitPos
local ang = Angle(0, client:EyeAngles().y, 0)
local money = lia.currency.spawn(pos, 100, ang)
if IsValid(money) then
    print("Spawned", lia.currency.get(money:getAmount()))
end
```
