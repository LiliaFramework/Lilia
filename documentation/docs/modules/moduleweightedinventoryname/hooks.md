# Hooks

Module-specific events raised by the Weighted Inventory module.

---

### `InventoryPrePlayerLoadedChar`

**Purpose**

`Runs before a character's inventory is initialised.`

**Parameters**

* `client` (`Player`): `The player whose character loaded.`

* `character` (`Character`): `Loaded character object.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("InventoryPrePlayerLoadedChar", "SetupInventory", function(client, char)
    print("Preparing inventory for", char:getName())
end)
```

---

### `GetDefaultInventoryMaxWeight`

**Purpose**

`Provides a base max weight for new inventories.`

**Parameters**

* `client` (`Player`): `Player owning the inventory.`

**Realm**

`Server`

**Returns**

`number|nil` — `Return a number to override the default weight.`

**Example**

```lua
hook.Add("GetDefaultInventoryMaxWeight", "SetByRank", function(client)
    if client:IsAdmin() then return 200 end
end)
```

---

### `InventoryPostPlayerLoadedChar`

**Purpose**

`Fires after a character's inventory is ready.`

**Parameters**

* `client` (`Player`): `The player.`

* `character` (`Character`): `Loaded character.`

* `inventory` (`Inventory`): `Inventory instance.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("InventoryPostPlayerLoadedChar", "AnnounceInv", function(client, char, inv)
    print("Inventory", inv:getID(), "loaded for", char:getName())
end)
```

---

### `CanPlayerViewInventory`

**Purpose**

`Determines if the local player may open the inventory menu.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`boolean|nil` — `Return false to block the panel.`

**Example**

```lua
hook.Add("CanPlayerViewInventory", "DisableDuringEvent", function()
    if IsEventRunning then return false end
end)
```

---

### `CanOpenBagPanel`

**Purpose**

`Called before a bag inventory panel is opened.`

**Parameters**

* `item` (`Item`): `The bag item about to be opened.`

**Realm**

`Client`

**Returns**

`boolean|nil` — `Return false to prevent opening.`

**Example**

```lua
hook.Add("CanOpenBagPanel", "CheckLock", function(item)
    return not item:getData("locked")
end)
```

---

### `PostDrawInventory`

**Purpose**

`Allows drawing over inventory panels.`

**Parameters**

* `inventoryPanel` (`Panel`): `Panel being drawn.`

* `parentPanel` (`Panel`): `Parent container panel.`

**Realm**

`Client`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("PostDrawInventory", "AddHints", function(panel, parent)
    draw.SimpleText("Drag items", "ChatFont", 0, 0, color_white)
end)
```

---

### `WeightInvGetMaxWeight`

**Purpose**

`Called when calculating an inventory's maximum weight.`

**Parameters**

* `inventory` (`WeightInv`): `The inventory object.`

* `baseMax` (`number`): `The weight before overrides.`

**Realm**

`Server`

**Returns**

`number|nil` — `Return a new maximum weight.`

**Example**

```lua
hook.Add("WeightInvGetMaxWeight", "BonusCapacity", function(inv, base)
    return base + 10
end)
```

---

### `PreWeightInvItemAdded`

**Purpose**

`Runs before an item is inserted into a WeightInv.`

**Parameters**

* `inventory` (`WeightInv`): `The inventory being modified.`

* `item` (`Item`): `Item about to be added.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("PreWeightInvItemAdded", "LogAdd", function(inv, item)
    print("Adding", item.name)
end)
```

---

### `WeightInvItemAdded`

**Purpose**

`Fires after an item has been added to a WeightInv.`

**Parameters**

* `inventory` (`WeightInv`): `The inventory modified.`

* `item` (`Item`): `Item that was inserted.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("WeightInvItemAdded", "PlaySound", function(inv, item)
    inv:getOwner():EmitSound("items/ammo_pickup.wav")
end)
```

---

### `PreWeightInvItemRemoved`

**Purpose**

`Called before an item is removed from a WeightInv.`

**Parameters**

* `inventory` (`WeightInv`): `Inventory being modified.`

* `item` (`Item`): `Item being removed.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("PreWeightInvItemRemoved", "CheckRemove", function(inv, item)
    if item:getData("important") then return false end
end)
```

---

### `WeightInvItemRemoved`

**Purpose**

`Fires after an item is removed from a WeightInv.`

**Parameters**

* `inventory` (`WeightInv`): `Inventory affected.`

* `item` (`Item`): `Item that was removed.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("WeightInvItemRemoved", "OnRemove", function(inv, item)
    print(item.name .. " removed")
end)
```

---

