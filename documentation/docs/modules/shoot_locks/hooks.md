# Hooks

Module-specific events raised by the Shoot Locks module.

---

### `LockShotAttempt`

**Purpose**

`Called when a player damages a door with a bullet before any checks are made.`

**Parameters**

* `client` (`Player`): `The attacker attempting to breach the lock.`

* `door` (`Entity`): `The door being shot.`

* `dmgInfo` (`CTakeDamageInfo`): `Damage information for the shot.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("LockShotAttempt", "AlertSecurity", function(client, door)
    print(client:Name() .. " fired at " .. tostring(door))
end)
```

---

### `CanPlayerBustLock`

**Purpose**

`Determines if the player may break a door lock using their weapon.`

**Parameters**

* `client` (`Player`): `The player attempting the breach.`

* `door` (`Entity`): `Target door entity.`

**Realm**

`Server`

**Returns**

`boolean` — `Return false to prevent the breach.`

**Example**

```lua
hook.Add("CanPlayerBustLock", "OnlyShotguns", function(client, door)
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) or weapon:GetClass() ~= "weapon_shotgun" then
        return false
    end
end)
```

---

### `LockShotBreach`

**Purpose**

`Fired when a door's lock is successfully blown off.`

**Parameters**

* `client` (`Player`): `The player who breached the lock.`

* `door` (`Entity`): `Door that was breached.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("LockShotBreach", "PlayBreachSound", function(client, door)
    door:EmitSound("breach.wav")
end)
```

---

### `LockShotSuccess`

**Purpose**

`Called after the door has been forced open with a shot.`

**Parameters**

* `client` (`Player`): `The player who breached the door.`

* `door` (`Entity`): `The door that opened.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("LockShotSuccess", "RewardBuster", function(client, door)
    client:notify("Door breached!")
end)
```

---

### `LockShotFailed`

**Purpose**

`Runs when a bullet fails to break the door lock.`

**Parameters**

* `client` (`Player`): `The attacker.`

* `door` (`Entity`): `Door that resisted the breach.`

* `dmgInfo` (`CTakeDamageInfo`): `Damage information for the failed attempt.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("LockShotFailed", "BreachFailed", function(client, door)
    client:notify("The lock held strong.")
end)
```

---

