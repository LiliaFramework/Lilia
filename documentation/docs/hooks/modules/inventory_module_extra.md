### `InventoryModuleLoaded`

**Purpose**
`Runs when the inventory module loads.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("InventoryModuleLoaded", "Example", function(m)
    print("Inventory module loaded")
end)
```

---

### `InventoryRulesAdded`

**Purpose**
`Signals that default inventory rules have been inserted.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("InventoryRulesAdded", "Example", function(m)
    print("Rules added")
end)
```

---

### `InventoryPanelsBuilt`

**Purpose**
`Fires after inventory UI panels are created.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("InventoryPanelsBuilt", "Example", function(m)
    print("Inventory panels built")
end)
```

---

### `InventoryNetworkingSetUp`

**Purpose**
`Runs once network messages for inventories are registered.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("InventoryNetworkingSetUp", "Example", function(m)
    print("Inventory networking ready")
end)
```

---

### `InventoryReady`

**Purpose**
`Final hook indicating the inventory system is ready.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("InventoryReady", "Example", function(m)
    print("Inventory ready")
end)
```

---
