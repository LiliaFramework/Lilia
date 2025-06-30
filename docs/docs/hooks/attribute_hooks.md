# Attribute Hooks

This document lists hooks related to attribute setup and changes.

---

## Overview

Attributes can define their own hooks to react when a player's attribute is created or its value changes. Implement these functions on the `ATTRIBUTE` table to run custom logic. All hooks are optional; if a hook is omitted the default behavior is used.

---

### OnSetup

```lua
function ATTRIBUTE:OnSetup(client, value)
```

**Description:**

Called when the attribute is initialized on a player (for example, during character load or creation). Use this hook to run custom logic, send notifications or apply effects.

**Parameters:**

* `client` (`Player`) – The player the attribute belongs to.
* `value` (`number`) – The value assigned to the attribute.

**Realm:**

* Server

**Example Usage:**

```lua
function ATTRIBUTE:OnSetup(client, value)
    if value > 5 then
        client:ChatPrint("You feel your strength surging!")
        client:SetHealth(client:Health() + value * 10)
    else
        client:ChatPrint("Your muscles ache from weakness...")
    end
end
```

