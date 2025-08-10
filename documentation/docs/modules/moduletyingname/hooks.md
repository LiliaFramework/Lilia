# Hooks

Module-specific events raised by the Tying module.

---

### `PlayerStartUnTying`

**Purpose**

`Called when a player begins untying another player.`

**Parameters**

* `actor` (`Player`): `Player attempting to untie.`

* `target` (`Player`): `Player being untied.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PlayerStartUnTying", "NotifyStartUnTie", function(actor, target)
    actor:ChatPrint("You begin untying " .. target:Name())
end)
```

---

### `PlayerFinishUnTying`

**Purpose**

`Runs when the untying process successfully completes.`

**Parameters**

* `actor` (`Player`): `Player who untied the target.`

* `target` (`Player`): `Player that was untied.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PlayerFinishUnTying", "CelebrateUnTie", function(actor, target)
    actor:EmitSound("npc/roller/blade_in.wav")
end)
```

---

### `PlayerUnTieAborted`

**Purpose**

`Fires if the untying action is cancelled before completion.`

**Parameters**

* `actor` (`Player`): `Player who attempted the untying.`

* `target` (`Player`): `Player that remained tied.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PlayerUnTieAborted", "AbortNotice", function(actor, target)
    actor:ChatPrint("Untying failed.")
end)
```

---

### `PlayerStartHandcuff`

**Purpose**

`Called when a player first becomes handcuffed.`

**Parameters**

* `target` (`Player`): `Player being handcuffed.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PlayerStartHandcuff", "HandcuffSound", function(target)
    target:EmitSound("npc/metropolice/gear1.wav")
end)
```

---

### `PlayerHandcuffed`

**Purpose**

`Runs after the handcuff procedure finishes.`

**Parameters**

* `target` (`Player`): `Player that is now handcuffed.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PlayerHandcuffed", "RestrictChat", function(target)
    target:ChatPrint("You have been restrained.")
end)
```

---

### `ResetSubModuleCuffData`

**Purpose**

`Signals submodules to clear any cuff related data when cuffs are removed.`

**Parameters**

* `target` (`Player`): `Player whose cuff data should reset.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("ResetSubModuleCuffData", "ClearSearch", function(target)
    -- remove search permissions or other submodule data
end)
```

---

### `PlayerUnhandcuffed`

**Purpose**

`Fires after a player has been fully unhandcuffed.`

**Parameters**

* `target` (`Player`): `Player that is no longer restrained.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PlayerUnhandcuffed", "FreedomMsg", function(target)
    target:ChatPrint("You are free to go.")
end)
```

---

