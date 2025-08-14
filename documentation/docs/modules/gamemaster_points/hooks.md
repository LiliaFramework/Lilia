# Hooks

Module-specific events raised by the Gamemaster Points module.

---

### `GamemasterPreAddPoint`

**Purpose**

`Called before a new teleport point is saved.`

**Parameters**

* `client` (`Player`): `Admin creating the point.`

* `name` (`string`): `Name chosen for the point.`

* `pos` (`Vector`): `World position to save.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterPreAddPoint", "LogPreAddPoint", function(client, name, pos)
    print(client, "is adding", name)
end)
```

---

### `GamemasterAddPoint`

**Purpose**

`Fires after a teleport point has been created.`

**Parameters**

* `client` (`Player`): `Admin who added the point.`

* `name` (`string`): `Point name.`

* `pos` (`Vector`): `Saved position.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterAddPoint", "NotifyAddPoint", function(client, name, pos)
    print(name .. " added at " .. tostring(pos))
end)
```

---

### `GamemasterPreRemovePoint`

**Purpose**

`Called before deleting a teleport point.`

**Parameters**

* `client` (`Player`): `Admin removing the point.`

* `name` (`string`): `Name typed by the admin.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterPreRemovePoint", "LogPreRemovePoint", function(client, name)
    print(client, "wants to remove", name)
end)
```

---

### `GamemasterRemovePoint`

**Purpose**

`Fires after a teleport point was removed.`

**Parameters**

* `client` (`Player`): `Admin that removed the point.`

* `name` (`string`): `Actual point name that was removed.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterRemovePoint", "NotifyRemovePoint", function(client, name)
    print(name .. " removed")
end)
```

---

### `GamemasterPreRenamePoint`

**Purpose**

`Called before a teleport point is renamed.`

**Parameters**

* `client` (`Player`): `Admin renaming the point.`

* `name` (`string`): `Current name.`

* `newName` (`string`): `Desired new name.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterPreRenamePoint", "LogPreRename", function(client, name, newName)
    print(client, "renaming", name, "to", newName)
end)
```

---

### `GamemasterRenamePoint`

**Purpose**

`Fires once a teleport point has been renamed.`

**Parameters**

* `client` (`Player`): `Admin who renamed the point.`

* `oldName` (`string`): `Previous name.`

* `newName` (`string`): `New name.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterRenamePoint", "NotifyRename", function(client, oldName, newName)
    print(oldName .. " is now " .. newName)
end)
```

---

### `GamemasterPreUpdateSound`

**Purpose**

`Called before a teleport point's sound effect changes.`

**Parameters**

* `client` (`Player`): `Admin editing the point.`

* `name` (`string`): `Point being updated.`

* `newSound` (`string`): `New sound path.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterPreUpdateSound", "CheckSound", function(client, name, newSound)
    if newSound == "" then return end
end)
```

---

### `GamemasterUpdateSound`

**Purpose**

`Fires after a teleport point's sound was changed.`

**Parameters**

* `client` (`Player`): `Admin who updated the sound.`

* `name` (`string`): `Point name.`

* `newSound` (`string`): `New sound path.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterUpdateSound", "NotifySound", function(client, name, newSound)
    print(name .. " now plays " .. newSound)
end)
```

---

### `GamemasterPreUpdateEffect`

**Purpose**

`Called before a teleport point's particle effect changes.`

**Parameters**

* `client` (`Player`): `Admin editing the point.`

* `name` (`string`): `Point being updated.`

* `newEffect` (`string`): `New particle effect name.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterPreUpdateEffect", "CheckEffect", function(client, name, newEffect)
    print("Changing effect for", name)
end)
```

---

### `GamemasterUpdateEffect`

**Purpose**

`Fires after a teleport point's particle effect was changed.`

**Parameters**

* `client` (`Player`): `Admin who updated the effect.`

* `name` (`string`): `Point name.`

* `newEffect` (`string`): `New particle effect.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterUpdateEffect", "NotifyEffect", function(client, name, newEffect)
    print(name .. " now uses effect " .. newEffect)
end)
```

---

### `GamemasterPreMoveToPoint`

**Purpose**

`Called just before a player teleports to a saved point.`

**Parameters**

* `client` (`Player`): `Player being moved.`

* `name` (`string`): `Name entered.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterPreMoveToPoint", "LogMoveRequest", function(client, name)
    print(client, "requested move to", name)
end)
```

---

### `GamemasterMoveToPoint`

**Purpose**

`Fires after a player has been teleported to a point.`

**Parameters**

* `client` (`Player`): `Player moved.`

* `name` (`string`): `Point name used.`

* `pos` (`Vector`): `Destination position.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("GamemasterMoveToPoint", "NotifyMove", function(client, name, pos)
    print(client, "arrived at", name)
end)
```

---

