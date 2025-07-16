### `F1MenuModuleLoaded`

**Purpose**
`Triggered when the F1 menu module loads.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("F1MenuModuleLoaded", "Example", function(m)
    print("F1 menu loaded")
end)
```

---

### `F1MenuPanelsBuilt`

**Purpose**
`Fires after the F1 menu panels have been created.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("F1MenuPanelsBuilt", "Example", function(m)
    print("Panels built")
end)
```

---

### `F1MenuButtonsAdded`

**Purpose**
`Runs when default buttons are added to the F1 menu.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("F1MenuButtonsAdded", "Example", function(m)
    print("Buttons added")
end)
```

---

### `F1MenuTabsRegistered`

**Purpose**
`Called once F1 menu tabs have registered.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("F1MenuTabsRegistered", "Example", function(m)
    print("Tabs registered")
end)
```

---

### `F1MenuReady`

**Purpose**
`Final hook fired when the F1 menu is ready for use.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("F1MenuReady", "Example", function(m)
    print("F1 menu ready")
end)
```

---
