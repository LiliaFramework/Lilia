## Economy & Trading

---

### CanPerformVendorEdit

**Purpose**

Determines if a player can modify a vendor's settings.

**Parameters**

* `client` (*Player*): Player attempting the edit.
* `vendor` (*Entity*): Vendor entity targeted.

**Returns**

- boolean: False to disallow editing.

**Realm**

**Shared**

**Example Usage**

```lua
-- Allow only admins to edit vendors.
hook.Add("CanPerformVendorEdit", "AdminVendorEdit", function(client)
    return client:IsAdmin()
end)
```

---

### CanPickupMoney

**Purpose**

Called when a player attempts to pick up a money entity.

**Parameters**

* `client` (*Player*): Player attempting to pick up the money.
- `moneyEntity` (`Entity`): The money entity.

**Returns**

- boolean: False to disallow pickup.

**Realm**

**Shared**

**Example Usage**

```lua
-- Prevent money pickup while handcuffed.
hook.Add("CanPickupMoney", "BlockWhileCuffed", function(client)
    if client:isHandcuffed() then
        return false
    end
end)
```

---

### CanPlayerAccessVendor

**Purpose**

Checks if a player is permitted to open a vendor menu.

**Parameters**

* `client` (*Player*): Player requesting access.
* `vendor` (*Entity*): Vendor entity.

**Returns**

- boolean: False to deny access.

**Realm**

**Server**

---

### CanPlayerTradeWithVendor

**Purpose**

Checks whether a vendor trade is allowed.

**Parameters**

* `client` (*Player*): Player attempting the trade.
- `vendor` (`Entity`): Vendor entity involved.
- `itemType` (`string`): Item identifier.
- `selling` (`boolean`): True if the player is selling to the vendor.

**Returns**

- boolean, string: False and reason to deny trade

**Realm**

**Server**

**Example Usage**

```lua
-- Block selling stolen goods.
hook.Add("CanPlayerTradeWithVendor", "DisallowStolenItems", function(client, vendor, itemType, selling)
    if lia.stolen[itemType] then
        return false, "Stolen items"
    end
end)
```

---

### GetMoneyModel

**Purpose**

Allows overriding the entity model used for dropped money.

**Parameters**

- `amount` (`number`): Money amount being dropped.

**Returns**

- string: Model path to use

**Realm**

**Shared**

**Example Usage**

```lua
-- Use a golden model for large sums.
hook.Add("GetMoneyModel", "GoldMoneyModel", function(amount)
    if amount > 5000 then
        return "models/props_lab/box01a.mdl"
    end
end)
```

---

### ItemTransfered

**Purpose**

Called after an item is moved between inventories.

**Parameters**

- `item` (`Item`): Item moved.
- `oldInv` (`Inventory`|nil): Source inventory.
- `newInv` (`Inventory`|nil): Destination inventory.

**Returns**

* `nil` (*nil*): This function does not return a value.

---

### OnCharTradeVendor

**Purpose**

Called after a character buys from or sells to a vendor.

**Parameters**

* `client` (*Player*): Player completing the trade.
- `vendor` (`Entity`): Vendor entity involved.
- `item` (`Item|nil`): Item traded, if any.
- `selling` (`boolean`): True if selling to the vendor.
* `character` (*Character*): Player's character.
- `itemType` (`string|nil`): Item identifier when item is nil.
- `failed` (`boolean|nil`): True if the trade failed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log vendor transactions to the console.
hook.Add("OnCharTradeVendor", "LogVendorTrade", function(client, vendor, item, selling)
    print(client:Nick(), selling and "sold" or "bought", item and item:getName() or "unknown")
end)
```

---

### OnOpenVendorMenu

**Purpose**

Called when the vendor dialog panel is opened.

**Parameters**

* `panel` (*Panel*): The vendor menu panel.
- `vendor` (`Entity`): The vendor entity.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Automatically switch to the buy tab.
hook.Add("OnOpenVendorMenu", "DefaultBuyTab", function(panel, vendor)
    panel:openTab("Buy")
end)
```

---

### OnPickupMoney

**Purpose**

Called after a player picks up a money entity.

**Parameters**

* `client` (*Player*): The player picking up the money.
- `moneyEntity` (`Entity`): The money entity collected.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Reward an achievement for looting money.
hook.Add("OnPickupMoney", "MoneyAchievement", function(client, ent)
    client:addProgress("rich", ent:getAmount())
end)
```

---

### OnRequestItemTransfer

**Purpose**

Fired when a client requests an item transfer between inventories.

**Parameters**

- `client` (`Player`): Requesting player.
- `item` (`Item`): Item to transfer.
- `fromInvId` (`number`): Source inventory ID.
- `toInvId` (`number`): Destination inventory ID.

**Returns**

- boolean: False to deny

**Realm**

**Server**

---

### PlayerAccessVendor

**Purpose**

Occurs when a player successfully opens a vendor.

**Parameters**

* `client` (*Player*): Player accessing the vendor.
- `vendor` (`Entity`): Vendor entity opened.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

---

### HandleItemTransferRequest

**Purpose**

Called when the server receives a request to move an item to another inventory. Add-ons may validate the request, change the destination or return nil to block it.

**Parameters**

* `client` (*Player*): Requesting player.
* `itemID` (*number*): Item identifier.
* `x` (*number*): X grid position.
* `y` (*number*): Y grid position.
* `inventoryID` (*number* | *string*): Target inventory identifier.

**Returns**

- DPromise|nil: Promise for the transfer or nil to block.

**Realm**

**Server**


