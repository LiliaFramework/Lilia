### `RecognitionModuleLoaded`

**Purpose**
`Runs when the recognition module loads.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("RecognitionModuleLoaded", "Example", function(m)
    print("Recognition loaded")
end)
```

---

### `RecognitionDataLoaded`

**Purpose**
`Signals that recognition tables have been populated.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("RecognitionDataLoaded", "Example", function(m)
    print("Data loaded")
end)
```

---

### `RecognitionHooksAdded`

**Purpose**
`Fires once recognition hooks have been registered.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("RecognitionHooksAdded", "Example", function(m)
    print("Hooks added")
end)
```

---

### `RecognitionRulesSetup`

**Purpose**
`Called after recognition rules are established.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("RecognitionRulesSetup", "Example", function(m)
    print("Rules set up")
end)
```

---

### `RecognitionReady`

**Purpose**
`Final hook fired when recognition features are ready.`

**Parameters**
* `module` (`table`): `Module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("RecognitionReady", "Example", function(m)
    print("Recognition ready")
end)
```

---
