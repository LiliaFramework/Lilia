# Attribute Hooks

This document lists hooks related to attribute setup events.

---

## Overview

Attributes may define callback functions that run when a player's attribute table is being set up. These functions live on the `ATTRIBUTE` table of each attribute definition and are entirely optional. At the time of writing the only built‑in attribute hook is `OnSetup`, which is called whenever `lia.attribs.setup` runs.

---

### OnSetup

**Description:**

Invoked when `lia.attribs.setup(client)` initializes or refreshes a player's attributes. This occurs after a character spawns or whenever the function is executed manually. It does **not** run when attribute boosts are added or removed. Use it to apply any server‑side effects based on the attribute's current value.

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
    -- Give the player extra run speed based on this attribute.
    local base = lia.config.get("RunSpeed")
    client:SetRunSpeed(base + value * 5)
end
```

---

