# Hooks

Module-specific events raised by the Instant Kill module.

---

### `ShouldInstantKill`

**Purpose**

`Called before processing a headshot to determine if instant kill should occur.`

**Parameters**

* `player` (`Player`): `Victim receiving the hit.`

* `damageInfo` (`CTakeDamageInfo`): `Damage information object.`

**Realm**

`Server`

**Returns**

`boolean` — `return false to ignore the instant kill.`

**Example**

```lua
hook.Add("ShouldInstantKill", "ProtectNPCs", function(ply, dmginfo)
    if ply:IsNPC() then return false end
end)
```

---

### `PlayerPreInstantKill`

**Purpose**

`Invoked before a headshot damage override is applied.`

**Parameters**

* `player` (`Player`): `Victim receiving the hit.`

* `damageInfo` (`CTakeDamageInfo`): `Damage information object.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("PlayerPreInstantKill", "PrepareKill", function(ply, dmginfo)
    -- modify damageInfo here
end)
```

---

### `PlayerInstantKilled`

**Purpose**

`Fires once the instant-kill damage has been set.`

**Parameters**

* `player` (`Player`): `Victim that will die.`

* `damageInfo` (`CTakeDamageInfo`): `Modified damage information.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("PlayerInstantKilled", "OnKill", function(ply, dmginfo)
    print(ply:Nick() .. " was instantly killed")
end)
```

---

