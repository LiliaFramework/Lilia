### `ProtectionModuleLoaded`

**Purpose**
`Runs when the protection module loads.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("ProtectionModuleLoaded", "Example", function(m)
    print("Protection loaded")
end)
```

---

### `ProtectionConfigLoaded`

**Purpose**
`Signals that configuration has been loaded for protection features.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("ProtectionConfigLoaded", "Example", function(m)
    print("Protection config loaded")
end)
```

---

### `ProtectionHooksAdded`

**Purpose**
`Called after protection hooks are bound.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("ProtectionHooksAdded", "Example", function(m)
    print("Hooks added")
end)
```

---

### `ProtectionChecksInitialized`

**Purpose**
`Runs once protection checks have been initialised.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("ProtectionChecksInitialized", "Example", function(m)
    print("Protection checks ready")
end)
```

---

### `ProtectionReady`

**Purpose**
`Final hook fired when the protection system is ready.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("ProtectionReady", "Example", function(m)
    print("Protection ready")
end)
```

---
