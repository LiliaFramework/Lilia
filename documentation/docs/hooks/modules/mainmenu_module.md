### `MainMenuModuleLoaded`

**Purpose**
`Runs when the main menu module loads.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("MainMenuModuleLoaded", "Example", function(m)
    print("Main menu module loaded")
end)
```

---

### `MainMenuCharListSynced`

**Purpose**
`Fires after the character list has been synchronised.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("MainMenuCharListSynced", "Example", function(m)
    print("Char list synced")
end)
```

---

### `MainMenuPanelsCreated`

**Purpose**
`Called when main menu panels are built.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("MainMenuPanelsCreated", "Example", function(m)
    print("Panels created")
end)
```

---

### `MainMenuButtonsAdded`

**Purpose**
`Runs when buttons are added to the main menu.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("MainMenuButtonsAdded", "Example", function(m)
    print("Buttons added")
end)
```

---

### `MainMenuReady`

**Purpose**
`Final hook triggered when the main menu is ready.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("MainMenuReady", "Example", function(m)
    print("Main menu ready")
end)
```

---
