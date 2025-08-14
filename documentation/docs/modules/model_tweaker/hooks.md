# Hooks

Module-specific events raised by the Model Tweaker module.

---

### `WardrobeModelChangeRequested`

**Purpose**

`Fired when the client requests to change their model via the wardrobe.`

**Parameters**

* `client` (`Player`): `Player requesting the change.`

* `newModel` (`string`): `Model path the player selected.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("WardrobeModelChangeRequested", "CheckModel", function(client, newModel)
    print(client:Name(), "wants", newModel)
end)
```

---

### `PreWardrobeModelChange`

**Purpose**

`Called just before the player's model is updated.`

**Parameters**

* `client` (`Player`): `Player whose model will change.`

* `newModel` (`string`): `Model that will be applied.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PreWardrobeModelChange", "Permissions", function(client, newModel)
    -- verify permissions
end)
```

---

### `WardrobeModelChanged`

**Purpose**

`Runs after the player's model entity has been updated.`

**Parameters**

* `client` (`Player`): `Player that changed models.`

* `newModel` (`string`): `Model that was applied.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("WardrobeModelChanged", "Announce", function(client, newModel)
    print(client:Name(), "changed to", newModel)
end)
```

---

### `PostWardrobeModelChange`

**Purpose**

`Final hook after the model update is completed.`

**Parameters**

* `client` (`Player`): `Player whose model changed.`

* `newModel` (`string`): `Model used.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PostWardrobeModelChange", "Cleanup", function(client, newModel)
    -- optional cleanup
end)
```

---

### `WardrobeModelInvalid`

**Purpose**

`Invoked when the requested model is not allowed.`

**Parameters**

* `client` (`Player`): `Player that attempted the change.`

* `newModel` (`string`): `Disallowed model path.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("WardrobeModelInvalid", "Warn", function(client, newModel)
    print(newModel, "is not permitted")
end)
```

---

