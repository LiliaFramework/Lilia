### `InteractionMenuModuleLoaded`

**Purpose**
`Runs when the interaction menu module loads.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("InteractionMenuModuleLoaded", "Example", function(m)
    print("Interaction menu loaded")
end)
```

---

### `InteractionMenuEntriesAdded`

**Purpose**
`Fires after default entries have been added to the menu.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("InteractionMenuEntriesAdded", "Example", function(m)
    print("Entries added")
end)
```

---

### `InteractionMenuPanelsCreated`

**Purpose**
`Called once the menu panels are constructed.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("InteractionMenuPanelsCreated", "Example", function(m)
    print("Panels created")
end)
```

---

### `InteractionMenuKeybindSet`

**Purpose**
`Signals that the menu keybind has been assigned.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("InteractionMenuKeybindSet", "Example", function(m)
    print("Keybind ready")
end)
```

---

### `InteractionMenuReady`

**Purpose**
`Final hook run when the interaction menu is ready.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("InteractionMenuReady", "Example", function(m)
    print("Interaction menu ready")
end)
```

---
