# Attribute Hooks

Attributes may define callbacks that run when a player's attribute table is set up.

These functions live on each attribute’s `ATTRIBUTE` table.

---

### OnSetup

**Purpose**

Called whenever `lia.attribs.setup` initializes or refreshes this attribute for a player.

**Parameters**

* `client` (`Player`): The player that owns the attribute.

* `value` (`number`): Current attribute value including temporary boosts.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

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
