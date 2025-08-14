# Hooks

Module-specific events raised by the Damage Numbers module.

---

### `RefreshFonts`

**Purpose**

Rebuilds fonts when the damage number font configuration changes.

**Parameters**

* *(None)*

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("RefreshFonts", "DamageNumberFonts", function()
    surface.CreateFont("DamageFont", {font = lia.config.get("DamageFont"), size = 24})
end)
```

---

### `DamageNumbersSent`

**Purpose**

Server-side notification that damage numbers were sent to the attacker and victim.

**Parameters**

* `attacker` (`Player`): The player who dealt damage.

* `target` (`Player`): Player that was hit.

* `damage` (`number`): Amount of damage dealt.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("DamageNumbersSent", "PrintDamage", function(attacker, target, dmg)
    print(attacker:Name() .. " hit " .. target:Name() .. " for " .. dmg)
end)
```

---

### `DamageNumberAdded`

**Purpose**

Called on the client when a floating damage number is created.

**Parameters**

* `target` (`Entity`): Entity the number belongs to.

* `damage` (`number`): Damage amount shown.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("DamageNumberAdded", "ColorNumbers", function(ent, dmg)
    if ent == LocalPlayer() then return end
end)
```

---

### `DamageNumberExpired`

**Purpose**

Fires when a floating damage number fades out and is removed.

**Parameters**

* `target` (`Entity`): Entity the number belonged to.

* `damage` (`number`): Damage value that was shown.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("DamageNumberExpired", "OnExpire", function(ent, dmg)
    print("Damage number " .. dmg .. " expired")
end)
```

---

