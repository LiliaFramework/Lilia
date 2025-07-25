# Hooks

Module-specific events raised by the Realistic Damage module.

---

### `PreScaleDamage`

**Purpose**

`Runs before the damage scale for a hit is calculated.`

**Parameters**

* `hitgroup` (`number`): `Hit group that was damaged.`

* `damageInfo` (`CTakeDamageInfo`): `Damage information object.`

* `scale` (`number`): `Starting scale value.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PreScaleDamage", "DebugScale", function(hitgroup, dmg, scale)
    print("Scaling", scale)
end)
```

---

### `GetDamageScale`

**Purpose**

`Allows overriding of the final damage multiplier for a hit.`

**Parameters**

* `hitgroup` (`number`): `Hit group that was damaged.`

* `damageInfo` (`CTakeDamageInfo`): `Damage information object.`

* `scale` (`number`): `Current calculated scale.`

**Realm**

`Server`

**Returns**

`number` — `Return a new multiplier to apply.`

**Example**

```lua
hook.Add("GetDamageScale", "FriendlyFire", function(hitgroup, dmg, scale)
    return scale * 0.5
end)
```

---

### `PostScaleDamage`

**Purpose**

`Called after the damage scale has been applied to the info object.`

**Parameters**

* `hitgroup` (`number`): `Hit group that was damaged.`

* `damageInfo` (`CTakeDamageInfo`): `Damage information object.`

* `scale` (`number`): `Final scale that was used.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PostScaleDamage", "ReportScale", function(hitgroup, dmg, scale)
    print("Damage scaled by", scale)
end)
```

---

### `GetPlayerDeathSound`

**Purpose**

`Provides a sound file path to play when a player dies.`

**Parameters**

* `player` (`Player`): `Player that died.`

* `isFemale` (`boolean`): `True if the player uses female sounds.`

**Realm**

`Server`

**Returns**

`string` — `Sound path to play or nil for default.`

**Example**

```lua
hook.Add("GetPlayerDeathSound", "CustomDeath", function(ply, female)
    if female then return "custom/femaledie.wav" end
end)
```

---

### `ShouldPlayDeathSound`

**Purpose**

`Decides whether the chosen death sound should be emitted.`

**Parameters**

* `player` (`Player`): `Player that died.`

* `soundPath` (`string`): `Sound file chosen.`

**Realm**

`Server`

**Returns**

`boolean` — `Return false to cancel playing the sound.`

**Example**

```lua
hook.Add("ShouldPlayDeathSound", "MuteDeaths", function(ply, path)
    return not ply:IsSilent()
end)
```

---

### `OnDeathSoundPlayed`

**Purpose**

`Called after the death sound has been emitted.`

**Parameters**

* `player` (`Player`): `Player that died.`

* `soundPath` (`string`): `Sound that was played.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnDeathSoundPlayed", "DeathLogged", function(ply, path)
    print("Played death sound", path)
end)
```

---

### `ShouldPlayPainSound`

**Purpose**

`Determines if a player's pain sound should be played.`

**Parameters**

* `player` (`Player`): `Hurt player.`

* `soundPath` (`string`): `Sound that would play.`

**Realm**

`Server`

**Returns**

`boolean` — `Return false to stop the sound.`

**Example**

```lua
hook.Add("ShouldPlayPainSound", "NoPain", function(ply, path)
    return ply:Health() < 50
end)
```

---

### `OnPainSoundPlayed`

**Purpose**

`Runs after a pain sound has been emitted for a player.`

**Parameters**

* `player` (`Player`): `Hurt player.`

* `soundPath` (`string`): `Sound that was played.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnPainSoundPlayed", "LogPain", function(ply, path)
    print("Played pain sound", path)
end)
```

---

