# Hooks

Module-specific events raised by the Stun Gun module.

---

### `PlayerStunned`

**Purpose**

`Called when a player is successfully stunned by the stun gun.`

**Parameters**

* `target` (`Player`): `Player that was stunned.`

* `weapon` (`Entity`): `The stun gun that triggered the stun.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PlayerStunned", "LogStun", function(target, weapon)
    print(target:Name() .. " was stunned by " .. weapon:GetOwner():Name())
end)
```

---

### `PlayerStunCleared`

**Purpose**

`Fires after the stun effect ends and the player can move again.`

**Parameters**

* `target` (`Player`): `Player whose stun has ended.`

* `weapon` (`Entity`): `The stun gun involved.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PlayerStunCleared", "OnStunEnd", function(target)
    target:ChatPrint("You can move again.")
end)
```

---

### `PlayerOverStunned`

**Purpose**

`Triggered when a player is over-stunned and takes damage.`

**Parameters**

* `target` (`Player`): `Player that has been over-stunned.`

* `weapon` (`Entity`): `The stun gun that caused it.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PlayerOverStunned", "AlertOverStun", function(target)
    target:EmitSound("npc/roller/blade_in.wav")
end)
```

---

### `PlayerOverStunCleared`

**Purpose**

`Runs once an over-stun effect has finished.`

**Parameters**

* `target` (`Player`): `Player freed from over-stun.`

* `weapon` (`Entity`): `The stun gun responsible.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PlayerOverStunCleared", "OverStunEnd", function(target)
    target:ChatPrint("Over-stun ended.")
end)
```

---

### `StunGunReloaded`

**Purpose**

`Called after the stun gun finishes reloading.`

**Parameters**

* `owner` (`Player`): `Player who reloaded the weapon.`

* `weapon` (`Entity`): `The stun gun that was reloaded.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("StunGunReloaded", "RechargeNotice", function(owner)
    owner:ChatPrint("Taser reloaded")
end)
```

---

### `StunGunLaserToggled`

**Purpose**

`Fires whenever the laser sight on the stun gun is toggled.`

**Parameters**

* `owner` (`Player`): `Player toggling the laser.`

* `enabled` (`boolean`): `Whether the laser is now on.`

* `weapon` (`Entity`): `The stun gun.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("StunGunLaserToggled", "LaserSound", function(owner, enabled)
    owner:EmitSound(enabled and "buttons/button17.wav" or "buttons/button18.wav")
end)
```

---

### `StunGunFired`

**Purpose**

`Called when the stun gun fires and a target is shocked.`

**Parameters**

* `owner` (`Player`): `Player who fired the stun gun.`

* `target` (`Player`): `Player that was hit.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("StunGunFired", "BroadcastStun", function(owner, target)
    PrintMessage(HUD_PRINTTALK, owner:Name() .. " stunned " .. target:Name())
end)
```

---

### `StunGunTethered`

**Purpose**

`Runs when a rope tether is successfully attached to a target.`

**Parameters**

* `owner` (`Player`): `Player holding the stun gun.`

* `target` (`Player`): `Player that the rope attached to.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("StunGunTethered", "TetherMsg", function(owner, target)
    owner:ChatPrint("Tethered to " .. target:Name())
end)
```

---

