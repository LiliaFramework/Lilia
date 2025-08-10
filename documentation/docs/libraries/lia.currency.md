# Currency Library

This page covers money and currency related helpers.

---

## Overview

The currency library formats money amounts, spawns physical money entities, and exposes the configured currency names. The values are pulled from the configuration options `CurrencySymbol`, `CurrencySingularName`, and `CurrencyPluralName` defined in `gamemode/core/libraries/config.lua` (defaults: `""`, `"currencySingular"`, `"currencyPlural"`).

---

### lia.currency.symbol

**Purpose**

Currency symbol prefix retrieved from the `CurrencySymbol` config (empty string by default).

**Realm**

`Shared`

**Example Usage**

```lua
print(lia.currency.symbol)
```

---

### lia.currency.singular

**Purpose**

Localized singular currency name from the `CurrencySingularName` config (defaults to localization key `currencySingular`).

**Realm**

`Shared`

**Example Usage**

```lua
print(lia.currency.singular)
```

---

### lia.currency.plural

**Purpose**

Localized plural currency name from the `CurrencyPluralName` config (defaults to localization key `currencyPlural`).

**Realm**

`Shared`

**Example Usage**

```lua
print(lia.currency.plural)
```

---

### lia.currency.get

**Purpose**

Formats a numeric amount into a currency string using `lia.currency.symbol`, `lia.currency.singular`, and `lia.currency.plural`. The singular name is used only when the amount is exactly `1` (the output always shows `1` in this case); any other value, including negatives and fractions, uses the plural name.

**Parameters**

* `amount` (*number*): Amount to format. No rounding or validation is performed; the value is concatenated as-is.

**Realm**

`Shared`

**Returns**

* *string*: The formatted currency string.

**Example Usage**

```lua
lia.currency.symbol = "$"
lia.currency.singular = "dollar"
lia.currency.plural = "dollars"

print(lia.currency.get(1))  -- "$1 dollar"
print(lia.currency.get(10)) -- "$10 dollars"
print(lia.currency.get(0))  -- "$0 dollars"
print(lia.currency.get(1.5)) -- "$1.5 dollars"
print(lia.currency.get(-5)) -- "$-5 dollars"
```

---

### lia.currency.spawn

**Purpose**

Spawns a `lia_money` entity at the specified position with the given amount and optional angle. If `pos` is missing or `amount` is `nil` or negative, `lia.information` is called with a localized error and no entity is created.

**Parameters**

* `pos` (*Vector*): Spawn position for the currency entity.

* `amount` (*number*): Non-negative monetary value. The absolute value is rounded to the nearest whole number before assignment.

* `angle` (*Angle*): Orientation of the entity. Defaults to `angle_zero` (`Angle(0, 0, 0)`). *Optional*.

**Realm**

`Server`

**Returns**

* *Entity or nil*: The spawned currency entity if successful; `nil` otherwise.

**Example Usage**

```lua
local pos = client:GetEyeTrace().HitPos
local money = lia.currency.spawn(pos, 50) -- default angle

local ang = Angle(0, client:EyeAngles().y, 0)
local money2 = lia.currency.spawn(pos, 100, ang)
-- Invalid spawns: print errors and return nil
local failedAmount = lia.currency.spawn(pos, -25)
local failedPos = lia.currency.spawn(nil, 50)
```

---
