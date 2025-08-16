# Hooks

Module-specific events raised by the Heavy Weapon Slowdown module.

---

### `OverrideSlowWeaponSpeed`

**Purpose**

`Override the slow walk speed for a specific weapon before it is applied.`

**Parameters**

* `client` (`Player`): `The player who is moving.`

* `weapon` (`Weapon`): `The weapon affecting the player's speed.`

* `speed` (`number`): `The base slowdown speed configured for the weapon.`

**Realm**

`Server`

**Returns**

`number` — `New speed to apply. Return nil to use the base speed.`

**Example**

```lua
hook.Add("OverrideSlowWeaponSpeed", "MyHeavyWeaponOverride", function(client, weapon, speed)
    if weapon:GetClass() == "my_heavy_weapon" then
        return speed * 1.1
    end
end)
```

---

### `ApplyWeaponSlowdown`

**Purpose**

`Called right before the player's movement speed is set.`

**Parameters**

* `client` (`Player`): `The player being slowed.`

* `weapon` (`Weapon`): `The active weapon.`

* `moveData` (`CMoveData`): `The move data being modified.`

* `speed` (`number`): `The slowdown speed that will be applied.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("ApplyWeaponSlowdown", "ExtraSlow", function(client, weapon, moveData, speed)
    if weapon:GetClass() == "my_heavy_weapon" then
        moveData:SetMaxSpeed(speed * 0.9)
    end
end)
```

---

### `PostApplyWeaponSlowdown`

**Purpose**

`Runs after the slowdown speed has been applied to the player.`

**Parameters**

* `client` (`Player`): `The affected player.`

* `weapon` (`Weapon`): `The active weapon.`

* `moveData` (`CMoveData`): `The move data that was modified.`

* `speed` (`number`): `The final speed that was applied.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PostApplyWeaponSlowdown", "NotifySlowdown", function(client, weapon, moveData, speed)
    if speed < client:GetRunSpeed() then
        client:ChatPrint("You are slowed down by " .. weapon:GetPrintName())
    end
end)
```

---

