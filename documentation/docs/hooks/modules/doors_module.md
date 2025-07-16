### `DoorsModuleLoaded`

**Purpose**
`Runs when the Doors module loads.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("DoorsModuleLoaded", "Example", function(m)
    print("Doors module loaded")
end)
```

---

### `DoorsDataLoaded`

**Purpose**
`Signals that door data has been loaded from disk.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("DoorsDataLoaded", "Example", function(m)
    print("Door data ready")
end)
```

---

### `DoorsKeysRegistered`

**Purpose**
`Fires after door key entities are registered.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("DoorsKeysRegistered", "Example", function(m)
    print("Keys registered")
end)
```

---

### `DoorsLocksInitialized`

**Purpose**
`Called once door locking logic has initialized.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("DoorsLocksInitialized", "Example", function(m)
    print("Locks ready")
end)
```

---

### `DoorsReady`

**Purpose**
`Final hook fired when door features are ready.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("DoorsReady", "Example", function(m)
    print("Door system ready")
end)
```

---
