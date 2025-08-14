# Hooks

Module-specific events raised by the Instant Kill module.

---

### `ShouldInstantKill`

**Purpose**

`Called before processing a headshot to determine if instant kill should occur.`

**Parameters**

* `client` (`Player`): `Victim receiving the hit.`

* `dmgInfo` (`CTakeDamageInfo`): `Damage information object.`

**Realm**

`Server`

**Returns**

`boolean` — `return false to ignore the instant kill.`

**Example**

```lua
hook.Add("ShouldInstantKill", "ProtectNPCs", function(client, dmgInfo)
    if client:IsNPC() then return false end
end)
```

---

### `PlayerPreInstantKill`

**Purpose**

`Invoked before a headshot damage override is applied.`

**Parameters**

* `client` (`Player`): `Victim receiving the hit.`

* `dmgInfo` (`CTakeDamageInfo`): `Damage information object.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("PlayerPreInstantKill", "PrepareKill", function(client, dmgInfo)
    -- modify dmgInfo here
end)
```

---

### `PlayerInstantKilled`

**Purpose**

`Fires once the instant-kill damage has been set.`

**Parameters**

* `client` (`Player`): `Victim that will die.`

* `dmgInfo` (`CTakeDamageInfo`): `Modified damage information.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("PlayerInstantKilled", "OnKill", function(client, dmgInfo)
    print(client:Nick() .. " was instantly killed")
end)
```

---

