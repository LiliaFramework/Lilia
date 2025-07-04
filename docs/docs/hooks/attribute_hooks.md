# Attribute Hooks

This document lists hooks related to attribute setup events.

---

## Overview

Attributes may define callback functions that run when their values are first initialized or when certain events occur, such as temporary boosts. These functions live on the `ATTRIBUTE` table of each attribute definition and are entirely optional. At the time of writing the only built‑in attribute hook is `OnSetup`.

---

### OnSetup

**Description:**

Called whenever the attribute is (re)initialized for a player—during character creation, when loading a character, and when attribute boosts are added or removed. Use it to apply any server‑side effects based on the attribute's current value.

**Parameters:**

* `client` (`Player`) – The player that owns the attribute.
* `value` (`number`) – The attribute's value returned by `character:getAttrib`, including temporary boosts.

**Realm:**

* Server

**Returns:**

* None

**Example Usage:**

```lua
function ATTRIBUTE:OnSetup(client, value)
    -- Example: scale max health directly with the attribute.
    local base = 100
    client:SetMaxHealth(base + value)
    client:SetHealth(client:GetMaxHealth())
end
```

---

