### `AdministrationModuleLoaded`

**Purpose**
`Fires when the Administration Utilities module has loaded.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil` — `Nothing.`

**Example**
```lua
hook.Add("AdministrationModuleLoaded", "LogAdminLoad", function(module)
    print("Administration utilities loaded")
end)
```

---

### `AdministrationDataInitialized`

**Purpose**
`Signals that administration data structures have initialized.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("AdministrationDataInitialized", "NotifyAdminData", function(mod)
    print("Admin data ready")
end)
```

---

### `AdministrationPermissionsLoaded`

**Purpose**
`Runs after default administration permissions are registered.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("AdministrationPermissionsLoaded", "Example", function(mod)
    print("Permissions registered")
end)
```

---

### `AdministrationCommandsReady`

**Purpose**
`Indicates that administration commands have been set up.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("AdministrationCommandsReady", "Example", function(mod)
    print("Admin commands loaded")
end)
```

---

### `AdministrationFinished`

**Purpose**
`Final hook fired after administration initialization completes.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("AdministrationFinished", "Example", function(mod)
    print("Administration module ready")
end)
```

---
