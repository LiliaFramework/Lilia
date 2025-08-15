# Hooks

Module-specific events raised by the Raised Weapons module.

---

### `OverrideWeaponRaiseSpeed`

**Purpose**

`Allows modification of the delay before a weapon is raised or holstered.`

**Parameters**

* `player` (`Player`): `Player whose weapon is changing state.`

* `speed` (`number`): `Default raise speed in seconds.`

**Realm**

`Server`

**Returns**

`number` — `Return a new delay to override the default.`

**Example**

```lua
hook.Add("OverrideWeaponRaiseSpeed", "FastRaise", function(player, speed)
    if player:Team() == FACTION_POLICE then return 0.5 end
end)
```

---

### `WeaponRaiseScheduled`

**Purpose**

`Called when a weapon raise is scheduled after switching weapons.`

**Parameters**

* `player` (`Player`): `Player whose weapon will be raised.`

* `weapon` (`Weapon`): `Weapon that will be raised.`

* `delay` (`number`): `Time until the weapon is raised.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("WeaponRaiseScheduled", "NotifyRaise", function(player, weapon, delay)
    print("Weapon raise in", delay)
end)
```

---

### `WeaponHolsterCancelled`

**Purpose**

`Fires when a holster action is interrupted.`

**Parameters**

* `player` (`Player`): `Player who cancelled the holster.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("WeaponHolsterCancelled", "CancelNotice", function(player)
    print(player:Name(), "stopped holstering")
end)
```

---

### `WeaponHolsterScheduled`

**Purpose**

`Called when a player begins to holster their weapon.`

**Parameters**

* `player` (`Player`): `Player holstering the weapon.`

* `delay` (`number`): `Time until the weapon lowers.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("WeaponHolsterScheduled", "HolsterMsg", function(player, delay)
    print("Holster in", delay)
end)
```

---

### `ShouldWeaponBeRaised`

**Purpose**

`Override check determining if the active weapon counts as raised.`

**Parameters**

* `player` (`Player`): `Player being queried.`

* `weapon` (`Weapon`): `Active weapon instance.`

**Realm**

`Shared`

**Returns**

`boolean` — `Return true or false to override default behaviour.`

**Example**

```lua
hook.Add("ShouldWeaponBeRaised", "ForceAlwaysRaised", function(player, weapon)
    if weapon:GetClass() == "weapon_physgun" then return true end
end)
```

---

### `PlayerWeaponRaisedChanged`

**Purpose**

`Runs when a player's raised state changes.`

**Parameters**

* `player` (`Player`): `Player whose state changed.`

* `state` (`boolean`): `True if the weapon is now raised.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PlayerWeaponRaisedChanged", "UpdateHUD", function(player, state)
    print(player:Name(), "raised state is", state)
end)
```

---

### `OnWeaponRaised`

**Purpose**

`Called when a weapon has been successfully raised.`

**Parameters**

* `player` (`Player`): `Player that raised the weapon.`

* `weapon` (`Weapon`): `Weapon that was raised.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnWeaponRaised", "AlertRaised", function(player, weapon)
    print(player:Name(), "raised", weapon:GetClass())
end)
```

---

### `OnWeaponLowered`

**Purpose**

`Called when a weapon is completely lowered.`

**Parameters**

* `player` (`Player`): `Player that lowered the weapon.`

* `weapon` (`Weapon`): `Weapon that was lowered.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnWeaponLowered", "AlertLowered", function(player, weapon)
    print(player:Name(), "lowered", weapon:GetClass())
end)
```

---

