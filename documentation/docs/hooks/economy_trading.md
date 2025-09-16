# Economy & Trading

This page documents the hooks for economic systems, trading mechanics, vendor management, and financial operations in the Lilia framework.

---

## Overview

The economy and trading system forms the backbone of Lilia's economic simulation, providing comprehensive hooks for managing financial transactions, vendor interactions, item trading, and economic balance. These hooks enable developers to create sophisticated economic systems that drive player engagement and create meaningful progression mechanics.

The economy and trading system in Lilia is built around a flexible architecture that supports multiple economic models, dynamic pricing, and extensive customization capabilities. The system handles everything from basic item transactions to complex vendor management and economic balancing, ensuring that all economic activities are properly tracked and managed.

**Vendor Management System** hooks provide comprehensive control over vendor entities, including vendor creation, configuration, inventory management, and interaction mechanics. These hooks enable developers to create diverse vendor types with custom behaviors, pricing models, and interaction patterns.

**Trading and Transaction Hooks** manage all aspects of item and currency trading, including transaction validation, price calculation, and trade completion. These hooks enable complex trading systems with custom restrictions, dynamic pricing, and sophisticated transaction logging.

**Economic Balance and Pricing** hooks allow developers to implement dynamic pricing systems, economic balancing mechanisms, and market simulation features. These hooks enable realistic economic systems that respond to player actions and market conditions.

**Item Transfer and Inventory Management** hooks handle the movement of items between inventories, including transfer validation, ownership checks, and inventory synchronization. These hooks enable complex item management systems with custom transfer rules and inventory restrictions.

**Financial Operations** hooks manage currency systems, salary distribution, and financial transactions. These hooks enable developers to implement custom currency systems, economic rewards, and financial progression mechanics.

**Door and Property Management** hooks handle property ownership, door purchasing, and property-related economic activities. These hooks enable complex property systems with ownership mechanics, property values, and economic implications.

**Recognition and Social Systems** hooks manage character recognition, social interactions, and reputation systems that affect economic activities. These hooks enable social-economic systems where relationships and reputation impact trading opportunities.

**Salary and Employment Systems** hooks handle player employment, salary distribution, and job-related economic activities. These hooks enable complex employment systems with custom salary calculations, job requirements, and economic progression.

**Economic Monitoring and Analytics** hooks provide tools for monitoring economic activity, tracking transactions, and analyzing economic trends. These hooks enable developers to implement economic analytics and monitoring systems.

**Custom Economic Models** hooks allow developers to implement custom economic systems, including alternative currencies, barter systems, and unique economic mechanics that go beyond traditional trading.

**Security and Anti-Exploit** hooks provide mechanisms for preventing economic exploits, validating transactions, and ensuring economic system integrity. These hooks help maintain fair and balanced economic systems.

**Integration and Compatibility** hooks facilitate integration between the economic system and other framework components, ensuring that economic activities are properly synchronized and that all systems work together seamlessly.
~
---

### CanPerformVendorEdit

**Purpose**

Determines if a player can modify a vendor's settings.

**When Called**

This hook is triggered when:
- A player attempts to edit vendor settings
- Before vendor modification interface is shown
- When vendor edit permissions are being validated
- During vendor configuration access checks

**Parameters**

* `client` (*Player*): Player attempting the edit.
* `vendor` (*Entity*): Vendor entity targeted.

**Returns**

- boolean: False to disallow editing.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to control who can edit vendor settings.
-- Vendors are entities that allow players to buy and sell items.
-- This hook allows you to implement custom permission systems for vendor editing.

-- Allow only admins to edit vendors.
hook.Add("CanPerformVendorEdit", "AdminVendorEdit", function(client)
    return client:IsAdmin()
end)
```

---

### CanPickupMoney

**Purpose**

Called when a player attempts to pick up a money entity.

**When Called**

This hook is triggered when:
- A player attempts to pick up a dropped money entity
- Before money pickup is processed
- When money collection permissions are being validated
- During money pickup interaction checks

**Parameters**

* `client` (*Player*): Player attempting to pick up the money.
- `moneyEntity` (`Entity`): The money entity.

**Returns**

- boolean: False to disallow pickup.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to control when players can pick up money entities.
-- Money entities are dropped when players die or when money is spawned in the world.
-- This hook allows you to implement custom restrictions based on player state or conditions.

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

**When Called**

This hook is triggered when:
- A player attempts to access a vendor menu
- Before vendor interface is displayed
- When vendor access permissions are being validated
- During vendor interaction checks

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

**When Called**

This hook is triggered when:
- A player attempts to trade with a vendor
- Before a vendor transaction is processed
- When trade permissions are being validated
- During vendor trade authorization checks

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
-- This example demonstrates how to control vendor trading permissions and restrictions.
-- Vendor trading allows players to buy and sell items with NPCs or other players.
-- This hook allows you to implement custom trading rules and restrictions.

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

**When Called**

This hook is triggered when:
- Money is being dropped as an entity
- Before the money entity model is determined
- During money entity creation
- When money visual representation is being set

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

**When Called**

This hook is triggered when:
- An item has been successfully transferred between inventories
- After item movement is completed
- When inventory contents have been updated
- Following successful item relocation

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

**When Called**

This hook is triggered when:
- A vendor transaction has been completed
- After items or money have been exchanged
- When vendor trade is finalized
- Following successful vendor interaction

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

**When Called**

This hook is triggered when:
- A vendor menu interface is opened
- After vendor access is granted
- When vendor UI is being displayed
- During vendor menu initialization

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

**When Called**

This hook is triggered when:
- A player has successfully picked up a money entity
- After money has been added to player's inventory
- When money pickup is completed
- Following successful money collection

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

**When Called**

This hook is triggered when:
- A client requests to move an item between inventories
- Before item transfer is processed
- When transfer permissions are being validated
- During item movement authorization checks

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

**When Called**

This hook is triggered when:
- A player successfully accesses a vendor
- After vendor access permissions are validated
- When vendor interaction begins
- During successful vendor opening

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

**When Called**

This hook is triggered when:
- The server receives an item transfer request
- Before item movement is processed
- When transfer validation is needed
- During item relocation request handling

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

**Example Usage**

```lua
hook.Add("HandleItemTransferRequest", "CustomTransfer", function(client, itemID, x, y, inventoryID)
    -- Custom transfer logic
    return lia.inventory.get(inventoryID):add(itemID, x, y)
end)
```

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
-- This example demonstrates how to control vendor trading permissions and restrictions.
-- Vendor trading allows players to buy and sell items with NPCs or other players.
-- This hook allows you to implement custom trading rules and restrictions.

-- Block selling stolen goods.
hook.Add("CanPlayerTradeWithVendor", "DisallowStolenItems", function(client, vendor, itemType, selling)
    if lia.stolen[itemType] then
        return false, "Stolen items"
    end
end)
```

---

### OnCharTradeVendor

**Purpose**

Called after a character buys from or sells to a vendor.

**When Called**

This hook is triggered when:
- A vendor transaction has been completed
- After items or money have been exchanged
- When vendor trade is finalized
- Following successful vendor interaction

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

**When Called**

This hook is triggered when:
- A vendor menu interface is opened
- After vendor access is granted
- When vendor UI is being displayed
- During vendor menu initialization

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

**When Called**

This hook is triggered when:
- A player has successfully picked up a money entity
- After money has been added to player's inventory
- When money pickup is completed
- Following successful money collection

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

### PlayerAccessVendor

**Purpose**

Occurs when a player successfully opens a vendor.

**When Called**

This hook is triggered when:
- A player successfully accesses a vendor
- After vendor access permissions are validated
- When vendor interaction begins
- During successful vendor opening

**Parameters**

* `client` (*Player*): Player accessing the vendor.
- `vendor` (`Entity`): Vendor entity opened.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

---

### OnRequestItemTransfer

**Purpose**

Fired when a client requests an item transfer between inventories.

**When Called**

This hook is triggered when:
- A client requests to move an item between inventories
- Before item transfer is processed
- When transfer permissions are being validated
- During item movement authorization checks

**Parameters**

- `client` (`Player`): Requesting player.
- `item` (`Item`): Item to transfer.
- `fromInvId` (`number`): Source inventory ID.
- `toInvId` (`number`): Destination inventory ID.

**Returns**

- boolean: False to deny

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to handle item transfer requests.
-- Item transfers occur when players move items between inventories.
-- This hook allows you to validate or block transfer requests.

hook.Add("OnRequestItemTransfer", "ValidateTransfer", function(client, item, fromInvId, toInvId)
    -- Block transfers for locked items
    if item:getData("locked") then
        return false
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

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to track item transfers between inventories.
-- Item transfers occur when items are moved from one inventory to another.
-- This hook allows you to log or respond to completed transfers.

hook.Add("ItemTransfered", "LogTransfer", function(item, oldInv, newInv)
    if IsValid(item) then
        print("Item", item:getName(), "transferred between inventories")
    end
end)
```

---

### VendorClassUpdated

**Purpose**

Called when a vendor's class is updated.

**When Called**

This hook is triggered when:
- A vendor's class type is modified
- When vendor configuration is updated
- After vendor class changes are applied
- During vendor customization operations

**Parameters**

* `vendor` (*Entity*): Vendor entity.
* `class` (*string*): New class.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("VendorClassUpdated", "ClassUpdateLog", function(vendor, class)
    print("Vendor class updated to:", class)
end)
```

---

### VendorEdited

**Purpose**

Fires when a vendor is edited.

**When Called**

This hook is triggered when:
- A vendor's properties or settings are modified
- When vendor configuration changes
- After vendor updates are applied
- During vendor customization operations

**Parameters**

* `vendor` (*Entity*): Vendor that was edited.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("VendorEdited", "EditLog", function(vendor)
    print("Vendor edited:", vendor:GetClass())
end)
```

---

### VendorExited

**Purpose**

Called when a player exits a vendor menu.

**When Called**

This hook is triggered when:
- A player closes or exits a vendor menu
- When vendor interaction ends
- After vendor menu is closed
- During vendor session termination

**Parameters**

* `vendor` (*Entity*): Vendor that was exited.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("VendorExited", "ExitLog", function(vendor)
    print("Exited vendor menu")
end)
```

---

### VendorFactionUpdated

**Purpose**

Fires when a vendor's faction restriction is updated.

**When Called**

This hook is triggered when:
- A vendor's faction access restrictions are modified
- When vendor permissions are updated
- After faction restrictions are applied
- During vendor access configuration

**Parameters**

* `vendor` (*Entity*): Vendor entity.
* `faction` (*string*): New faction restriction.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("VendorFactionUpdated", "FactionUpdateLog", function(vendor, faction)
    print("Vendor faction updated to:", faction)
end)
```

---

### VendorItemMaxStockUpdated

**Purpose**

Called when a vendor item's max stock is updated.

**When Called**

This hook is triggered when:
- A vendor item's maximum stock limit is modified
- When vendor inventory limits are updated
- After stock configuration changes
- During vendor item management

**Parameters**

* `vendor` (*Entity*): Vendor entity.
* `itemType` (*string*): Item type.
* `maxStock` (*number*): New max stock.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("VendorItemMaxStockUpdated", "StockUpdateLog", function(vendor, itemType, maxStock)
    print("Vendor item max stock updated:", itemType, maxStock)
end)
```

---

### VendorItemModeUpdated

**Purpose**

Fires when a vendor item's mode is updated.

**When Called**

This hook is triggered when:
- A vendor item's trading mode is modified
- When item availability settings are updated
- After item mode configuration changes
- During vendor item customization

**Parameters**

* `vendor` (*Entity*): Vendor entity.
* `itemType` (*string*): Item type.
* `mode` (*number*): New mode.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("VendorItemModeUpdated", "ModeUpdateLog", function(vendor, itemType, mode)
    print("Vendor item mode updated:", itemType, mode)
end)
```

---

### VendorItemPriceUpdated

**Purpose**

Called when a vendor item's price is updated.

**When Called**

This hook is triggered when:
- A vendor item's price is modified
- When item pricing is updated
- After price configuration changes
- During vendor economic adjustments

**Parameters**

* `vendor` (*Entity*): Vendor entity.
* `itemType` (*string*): Item type.
* `price` (*number*): New price.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("VendorItemPriceUpdated", "PriceUpdateLog", function(vendor, itemType, price)
    print("Vendor item price updated:", itemType, price)
end)
```

---

### VendorItemStockUpdated

**Purpose**

Fires when a vendor item's stock is updated.

**When Called**

This hook is triggered when:
- A vendor item's current stock is modified
- When inventory quantities are updated
- After stock level changes
- During vendor restocking operations

**Parameters**

* `vendor` (*Entity*): Vendor entity.
* `itemType` (*string*): Item type.
* `stock` (*number*): New stock.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("VendorItemStockUpdated", "StockUpdateLog", function(vendor, itemType, stock)
    print("Vendor item stock updated:", itemType, stock)
end)
```

---

### VendorOpened

**Purpose**

Called when a vendor is opened.

**When Called**

This hook is triggered when:
- A vendor interface is opened
- When vendor interaction begins
- After vendor access is initiated
- During vendor session start

**Parameters**

* `vendor` (*Entity*): Vendor that was opened.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("VendorOpened", "OpenLog", function(vendor)
    print("Vendor opened:", vendor:GetClass())
end)
```

---

### VendorSynchronized

**Purpose**

Fires when vendor data is synchronized.

**When Called**

This hook is triggered when:
- Vendor data is synchronized between client and server
- When vendor information is updated
- After vendor data changes are propagated
- During vendor state synchronization

**Parameters**

* `vendor` (*Entity*): Vendor that was synchronized.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("VendorSynchronized", "SyncLog", function(vendor)
    print("Vendor synchronized")
end)
```

---

### VendorTradeEvent

**Purpose**

Called during vendor trade events.

**When Called**

This hook is triggered when:
- A vendor trade transaction is occurring
- During vendor trading operations
- When trade events are processed
- Throughout vendor transaction handling

**Parameters**

* `vendor` (*Entity*): Vendor involved in trade.
* `client` (*Player*): Player trading.
* `itemType` (*string*): Item type being traded.
* `isSelling` (*boolean*): True if selling to vendor.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("VendorTradeEvent", "TradeLog", function(vendor, client, itemType, isSelling)
    print(client:Nick(), isSelling and "sold" or "bought", itemType)
end)
```

---

### getItemDropModel

**Purpose**

Allows overriding the model used when an item is dropped on the ground.

**When Called**

This hook is triggered when:
- An item is being dropped on the ground
- Before the item entity model is determined
- During item drop processing
- When item visual representation is being set

**Parameters**

* `item` (*table*): Item being dropped.

**Returns**

* `model` (*string*): Model path to use for the dropped item.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("getItemDropModel", "CustomDropModel", function(item)
    if item.uniqueID == "special_item" then
        return "models/special_model.mdl"
    end
end)
```

---

### getPriceOverride

**Purpose**

Allows overriding the price of items in vendors.

**When Called**

This hook is triggered when:
- Vendor item pricing is being calculated
- Before item prices are displayed
- During vendor price determination
- When custom pricing logic is needed

**Parameters**

* `item` (*table*): Item to get price for.
* `vendor` (*Entity*): Vendor selling the item.

**Returns**

* `price` (*number*): Custom price for the item.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("getPriceOverride", "CustomPricing", function(item, vendor)
    if item.uniqueID == "premium_item" then
        return 1000
    end
end)
```

---

### isCharFakeRecognized

**Purpose**

Determines if a character is fake recognized (for roleplay purposes).

**When Called**

This hook is triggered when:
- Character recognition status is being checked
- During roleplay recognition validation
- When fake recognition mechanics are evaluated
- Before recognition display is determined

**Parameters**

* `character` (*Character*): Character to check.
* `target` (*Character*): Target character.

**Returns**

- boolean: True if fake recognized

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("isCharFakeRecognized", "FakeRecognition", function(character, target)
    return character:getFaction() == target:getFaction()
end)
```

---

### isCharRecognized

**Purpose**

Checks if one character recognizes another.

**When Called**

This hook is triggered when:
- Character recognition status is being evaluated
- During character interaction checks
- When recognition mechanics are processed
- Before character identification is determined

**Parameters**

* `character` (*Character*): Character doing the recognizing.
* `target` (*Character*): Character being recognized.

**Returns**

- boolean: True if recognized

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("isCharRecognized", "RecognitionCheck", function(character, target)
    -- Custom recognition logic
    return true
end)
```

---

### isRecognizedChatType

**Purpose**

Determines if a chat type requires recognition.

**When Called**

This hook is triggered when:
- Chat message recognition requirements are checked
- During chat processing validation
- When recognition-based chat is evaluated
- Before chat visibility is determined

**Parameters**

* `chatType` (*string*): Chat type to check.

**Returns**

- boolean: True if recognition required

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("isRecognizedChatType", "ChatRecognition", function(chatType)
    return chatType == "whisper" or chatType == "radio"
end)
```

---

### CanPlayerEarnSalary

**Purpose**

Checks if a player can earn salary.

**When Called**

This hook is triggered when:
- Player salary eligibility is being checked
- Before salary distribution occurs
- During salary payment validation
- When salary permissions are evaluated

**Parameters**

* `client` (*Player*): Player attempting to earn salary.

**Returns**

- boolean: False to prevent salary

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerEarnSalary", "NoSalary", function(ply)
    if ply:getChar():getClass() == "unemployed" then
        return false
    end
end)
```

---

### GetSalaryAmount

**Purpose**

Returns the salary amount for a player.

**When Called**

This hook is triggered when:
- Player salary amount is being calculated
- During salary payment processing
- When salary distribution occurs
- Before salary is awarded to players

**Parameters**

* `client` (*Player*): Player to get salary for.

**Returns**

* `amount` (*number*): Salary amount.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("GetSalaryAmount", "CustomSalary", function(client)
    local char = client:getChar()
    return char:getData("salary", 100)
end)
```

---

### GetSalaryLimit

**Purpose**

Returns the salary limit for a player.

**When Called**

This hook is triggered when:
- Player salary limits are being determined
- During salary cap validation
- When salary restrictions are checked
- Before salary payment limits are applied

**Parameters**

* `client` (*Player*): Player to get salary limit for.

**Returns**

* `limit` (*number*): Salary limit.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("GetSalaryLimit", "CustomLimit", function(client)
    return 1000
end)
```

---

### OnSalaryGive

**Purpose**

Called when salary is given to a player.

**When Called**

This hook is triggered when:
- A player receives their salary payment
- After salary is distributed to players
- When salary transactions are completed
- During periodic salary payments

**Parameters**

* `client` (*Player*): Player receiving salary.
* `amount` (*number*): Salary amount.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnSalaryGive", "SalaryLog", function(client, amount)
    print(client:Nick(), "received salary:", amount)
end)
```

---

### OnPlayerPurchaseDoor

**Purpose**

Called when a player purchases a door.

**When Called**

This hook is triggered when:
- A player successfully purchases a door
- After door ownership is transferred
- When door purchase transaction is completed
- Following successful property acquisition

**Parameters**

* `client` (*Player*): Player who purchased the door.
* `door` (*Entity*): Door that was purchased.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnPlayerPurchaseDoor", "LogPurchase", function(client, door)
    print(client:Nick(), "purchased door")
end)
```

---

### DoorPriceSet

**Purpose**

Called when a door's price is set.

**When Called**

This hook is triggered when:
- A door's purchase price is being set
- When door pricing is configured
- After door value is determined
- During door property setup

**Parameters**

* `entity` (*Entity*): Door entity.
* `price` (*number*): New price.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("DoorPriceSet", "PriceLog", function(entity, price)
    print("Door", entity, "price set to", price)
end)
```

---

### DoorTitleSet

**Purpose**

Fires when a door's title is set.

**When Called**

This hook is triggered when:
- A door's display title is being set
- When door naming is configured
- After door identification is updated
- During door property customization

**Parameters**

* `entity` (*Entity*): Door entity.
* `title` (*string*): New title.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("DoorTitleSet", "TitleLog", function(entity, title)
    print("Door", entity, "title set to", title)
end)
```

---

### GetVendorSaleScale

**Purpose**

Returns the sale scale for vendors.

**When Called**

This hook is triggered when:
- Vendor sale pricing scale is being calculated
- During vendor price adjustments
- When sale multipliers are determined
- Before vendor transaction pricing is applied

**Parameters**

* `vendor` (*Entity*): Vendor entity.

**Returns**

* `scale` (*number*): Sale scale.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("GetVendorSaleScale", "CustomScale", function(vendor)
    return vendor:getNetVar("saleScale", 1.0)
end)
```

---

### OnVendorEdited

**Purpose**

Called when a vendor is edited.

**When Called**

This hook is triggered when:
- A vendor is edited or modified
- When vendor properties are updated
- After vendor configuration changes
- During vendor customization operations

**Parameters**

* `vendor` (*Entity*): Vendor that was edited.
* `client` (*Player*): Player who edited the vendor.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnVendorEdited", "VendorEditLog", function(vendor, client)
    print("Vendor edited by", client:Nick())
end)
```
