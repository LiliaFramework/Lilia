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
