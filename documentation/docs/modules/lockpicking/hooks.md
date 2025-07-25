# Hooks

Module-specific events raised by the Lockpicking module.

---

### `CanPlayerLockpick`

**Purpose**

`Determines if a player is allowed to start picking a door or vehicle.`

**Parameters**

* `client` (`Player`): `The player using the lockpick.`

* `target` (`Entity`): `Door or vehicle being lockpicked.`

**Realm**

`Server`

**Returns**

`boolean` — `Return false to disallow lockpicking.`

**Example**

```lua
hook.Add("CanPlayerLockpick", "DisallowPolice", function(client, target)
    if client:isCombine() then
        return false
    end
end)
```

---

### `LockpickStart`

**Purpose**

`Fired when a player begins a lockpick attempt.`

**Parameters**

* `client` (`Player`): `The player using the lockpick.`

* `target` (`Entity`): `Door or vehicle being lockpicked.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("LockpickStart", "AnnounceStart", function(client, target)
    print(client:Name() .. " started lockpicking " .. tostring(target))
end)
```

---

### `LockpickSuccess`

**Purpose**

`Runs when the lockpick completes successfully.`

**Parameters**

* `client` (`Player`): `The player who picked the lock.`

* `target` (`Entity`): `Door or vehicle that was unlocked.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("LockpickSuccess", "RewardPlayer", function(client, target)
    client:notify("Unlocked!")
end)
```

---

### `LockpickFinished`

**Purpose**

`Called when lockpicking ends for any reason.`

**Parameters**

* `client` (`Player`): `The player who used the lockpick.`

* `target` (`Entity`): `Door or vehicle that was targeted.`

* `success` (`boolean`): `True if the lock was opened.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("LockpickFinished", "LogFinish", function(client, target, success)
    if success then
        print(client:Name() .. " unlocked " .. tostring(target))
    end
end)
```

---

### `LockpickInterrupted`

**Purpose**

`Triggered when a lockpick attempt is cancelled before completion.`

**Parameters**

* `client` (`Player`): `The player who was lockpicking.`

* `target` (`Entity`): `Door or vehicle involved.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("LockpickInterrupted", "HandleAbort", function(client, target)
    client:notify("Lockpicking stopped")
end)
```

---

