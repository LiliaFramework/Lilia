### `AttributesModuleLoaded`

**Purpose**
`Fires when the Attributes module has loaded.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("AttributesModuleLoaded", "Example", function(mod)
    print("Attributes loaded")
end)
```

---

### `AttributesDataInitialized`

**Purpose**
`Signals that attribute data has been initialized.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("AttributesDataInitialized", "Example", function(m)
    print("Attributes data ready")
end)
```

---

### `AttributesBoostsReady`

**Purpose**
`Runs after default attribute boosts are registered.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("AttributesBoostsReady", "Example", function(m)
    print("Boosts ready")
end)
```

---

### `AttributesEventsBound`

**Purpose**
`Called once attribute related events have been bound.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("AttributesEventsBound", "Example", function(m)
    print("Attribute events bound")
end)
```

---

### `AttributesFinished`

**Purpose**
`Final hook fired after attributes finish initializing.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("AttributesFinished", "Example", function(m)
    print("Attributes module ready")
end)
```

---
