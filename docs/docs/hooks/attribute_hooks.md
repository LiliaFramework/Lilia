# Attribute Hooks

This document lists hooks related to attribute setup and changes.

---

## Overview

Attributes can define their own hooks to react when a player's attribute is created or its value changes. Implement these functions on the `ATTRIBUTE` table to run custom logic. All hooks are optional; if a hook is omitted the default behavior is used.

---

### OnSetup

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
    -- Reward exceptionally high values with extra health.
    if value >= 10 then
        local bonus = (value - 9) * 5
        client:SetMaxHealth(client:GetMaxHealth() + bonus)
        client:SetHealth(client:GetMaxHealth())
        client:ChatPrint("You gained " .. bonus .. " max health from " .. self.name .. "!")
    else
        client:ChatPrint("You need more practice in " .. self.name .. ".")
    end
end
```

---

