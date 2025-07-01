# Attribute Hooks

This document lists hooks related to attribute setup events.

---

## Overview

Attributes may define callback functions that run when their values are first initialized or when certain events occur, such as temporary boosts. These functions live on the `ATTRIBUTE` table of each attribute definition and are entirely optional.

---

### OnSetup

**Description:**

Called when the attribute is initialized for a player (for example during character creation or when loading a character). This hook also fires again when a temporary boost is applied so the attribute can refresh any effects.

**Parameters:**

* `client` (`Player`) – The player that owns the attribute.
* `value` (`number`) – The current value assigned to the attribute.

**Realm:**

* Server

**Example Usage:**

```lua
function ATTRIBUTE:OnSetup(client, value)
    -- Give an extra 5 max health for every point above 10.
    if value > 10 then
        local bonus = (value - 10) * 5
        client:SetMaxHealth(client:GetMaxHealth() + bonus)
    end
end
```

---

