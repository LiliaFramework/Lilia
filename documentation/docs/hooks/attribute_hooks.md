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

## Additional Attribute-Related Hooks

The following hooks are related to the attribute system but are not defined on individual attributes:

### OnCharAttribUpdated

**Purpose**

Fired when a character attribute value is changed through `setAttrib` or `updateAttrib`.

**Parameters**

* `client` (`Player`): The player that owns the character.
* `character` (`Character`): The character whose attribute was updated.
* `key` (`string`): The attribute identifier that was changed.
* `value` (`number`): The new attribute value.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
hook.Add("OnCharAttribUpdated", "NotifyAttributeChange", function(client, character, key, value)
    client:notifyLocalized("attributeChanged", key, value)
end)
```

---

### OnCharAttribBoosted

**Purpose**

Fired when an attribute boost is added or removed from a character.

**Parameters**

* `client` (`Player`): The player that owns the character.
* `character` (`Character`): The character whose attribute was boosted.
* `attribID` (`string`): The attribute identifier that was boosted.
* `boostID` (`string`): The unique boost identifier.
* `amount` (`number|boolean`): The boost amount added, or `true` when removed.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
hook.Add("OnCharAttribBoosted", "NotifyBoostChange", function(client, character, attribID, boostID, amount)
    if amount ~= true then
        client:notifyLocalized("attributeBoosted", attribID, amount)
    else
        client:notifyLocalized("attributeBoostRemoved", attribID)
    end
end)
```

---

### AdjustStaminaOffset

**Purpose**

Allows modification of stamina regeneration/drain rates before they are applied.

**Parameters**

* `client` (`Player`): The player whose stamina is being calculated.
* `offset` (`number`): The current stamina offset value.

**Realm**

`Shared`

**Returns**

* `number?`: Return a modified offset value, or `nil` to use the original.

**Example Usage**

```lua
hook.Add("AdjustStaminaOffset", "ModifyStamina", function(client, offset)
    local char = client:getChar()
    if char and char:getAttrib("endurance", 0) > 20 then
        return offset * 1.5 -- 50% faster stamina regen for high endurance
    end
end)
```

---

### PlayerStaminaLost

**Purpose**

Fired when a player's stamina reaches zero and they become out of breath.

**Parameters**

* `client` (`Player`): The player who lost stamina.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
hook.Add("PlayerStaminaLost", "StaminaEffects", function(client)
    client:EmitSound("player/breathe1.wav", 35, 100)
    -- Apply visual effects for being out of breath
end)
```

---

### PlayerStaminaGained

**Purpose**

Fired when a player's stamina recovers above 50% and they are no longer out of breath.

**Parameters**

* `client` (`Player`): The player who gained stamina.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
hook.Add("PlayerStaminaGained", "StaminaRecovery", function(client)
    client:StopSound("player/breathe1.wav")
    -- Remove visual effects for being out of breath
end)
```

---