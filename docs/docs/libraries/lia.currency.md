# Currency Library

This page covers money and currency related helpers.

---

## Overview

The currency library formats money amounts and converts between numeric and display representations. It stores the currency symbol and helps with cost calculations.

---

### lia.currency.get

    
**Description:**
Formats a numeric amount into a currency string using the defined symbol,
singular, and plural names. If the amount is exactly 1, it returns the singular
form; otherwise, it returns the plural form.
**Parameters:**
* amount (number) – The amount to format.
**Returns:**
* string – The formatted currency string.
**Realm:**
* Shared
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.currency.get
lia.currency.get(10)  -- e.g., "$10 dollars"
```

### lia.currency.spawn

    
**Description:**
Spawns a currency entity at the specified position with a given amount and optional angle.
Validates the position and ensures the amount is a non-negative number.
**Parameters:**
* pos (Vector) – The spawn position for the currency entity.
* amount (number) – The monetary value for the entity.
* angle (Angle, optional) – The orientation for the entity (defaults to Angle(0, 0, 0)).
**Returns:**
* Entity – The spawned currency entity if successful; nil otherwise.
**Realm:**
* Server
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.currency.spawn
lia.currency.spawn(Vector(0, 0, 0), 100)
```
