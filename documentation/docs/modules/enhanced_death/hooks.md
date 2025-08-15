# Hooks

Module-specific events raised by the Enhanced Death module.

---

### `HospitalRespawned`

**Purpose**

`Runs after a player is respawned at a hospital location.`

**Parameters**

* `client` (`Player`): `The player being respawned.`

* `position` (`Vector`): `The location they were moved to.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("HospitalRespawned", "NotifyRespawn", function(client, pos)
    print(client:Nick() .. " respawned at hospital: " .. tostring(pos))
end)
```

---

### `HospitalMoneyLost`

**Purpose**

`Called when a hospital respawn removes money from a player.`

**Parameters**

* `client` (`Player`): `The player that lost money.`

* `amount` (`number`): `Amount of currency taken.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("HospitalMoneyLost", "LogLoss", function(client, amount)
    print(client:Nick() .. " lost " .. amount .. " credits at the hospital")
end)
```

---

### `HospitalDeathFlagged`

**Purpose**

`Fires when a player's death sets them to respawn at a hospital.`

**Parameters**

* `client` (`Player`): `The player that died.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("HospitalDeathFlagged", "AnnounceFlag", function(client)
    print(client:Nick() .. " will respawn at the hospital")
end)
```

---

