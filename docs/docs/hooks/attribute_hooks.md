# Attribute Hooks

This document lists hooks related to attribute setup events.

---

## Overview

Attributes may define callback functions that run when a player's attribute table is being set up. These functions live on the `ATTRIBUTE` table of each attribute definition.  At the moment the only built‑in hook is `OnSetup`, which is executed for each attribute whenever `lia.attribs.setup(client)` runs on the server.

---

### OnSetup

**Purpose**

Called whenever `lia.attribs.setup` initializes or refreshes this attribute for a player.

**Parameters**

* `client` (*Player*): the player that owns the attribute.
* `value` (*number*): current attribute value including temporary boosts.

**Realm**

`Server`

**Returns**

* `nil`: none.

**Example**
```lua
function ATTRIBUTE:OnSetup(client, value)
    -- Apply movement bonuses based on this attribute level.
    client:SetRunSpeed(lia.config.get("RunSpeed") + value * 5)
    client:SetJumpPower(client:GetJumpPower() + value * 2)

    -- Expand the character's carry weight by one kilogram per point.
    local char = client:getChar()
    if char then
        char:setData("maxCarry", 15 + value)
    end
end
```

---

