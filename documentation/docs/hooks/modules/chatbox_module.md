### `ChatboxModuleLoaded`

**Purpose**
`Runs when the Chatbox module loads.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("ChatboxModuleLoaded", "Example", function(m)
    print("Chatbox loaded")
end)
```

---

### `ChatboxFontsInitialized`

**Purpose**
`Signals that chatbox fonts are ready.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("ChatboxFontsInitialized", "Example", function(m)
    print("Fonts ready")
end)
```

---

### `ChatboxChannelsRegistered`

**Purpose**
`Fires after default chat channels are registered.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("ChatboxChannelsRegistered", "Example", function(m)
    print("Channels registered")
end)
```

---

### `ChatboxUIBuilt`

**Purpose**
`Called once the chatbox UI panels have been created.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("ChatboxUIBuilt", "Example", function(m)
    print("Chat UI built")
end)
```

---

### `ChatboxReady`

**Purpose**
`Final hook fired when the chatbox is ready for use.`

**Parameters**
* `module` (`table`): `The module table.`

**Realm**
`Shared`

**Returns**
`nil`

**Example**
```lua
hook.Add("ChatboxReady", "Example", function(m)
    print("Chatbox ready")
end)
```

---
