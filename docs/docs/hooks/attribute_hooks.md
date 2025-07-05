# Attribute Hooks

This document lists hooks related to attribute setup events.

---

## Overview

Attributes may define callback functions that run when a player's attribute table is being set up. These functions live on the `ATTRIBUTE` table of each attribute definition.  At the moment the only built‑in hook is `OnSetup`, which is executed for each attribute whenever `lia.attribs.setup(client)` runs on the server.

---

### OnSetup

```lua
function ATTRIBUTE:OnSetup(client, value)
```

**Description:**

Called on the server whenever `lia.attribs.setup(client)` initializes or refreshes a player's attributes. This typically happens after a character spawns, or whenever the function is run manually. The hook does **not** fire when attribute boosts are added or removed. Use it to apply any server‑side effects based on the attribute's current value.

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
    -- Apply movement bonuses based on this attribute level.
    local baseRun = lia.config.get("RunSpeed")
    client:SetRunSpeed(baseRun + value * 5)

    -- Slightly increase jump height as well.
    local baseJump = client:GetJumpPower()
    client:SetJumpPower(baseJump + value * 2)
end
```

---

