# Hooks

Module-specific events raised by the Free Look module.

---

### `ShouldUseFreelook`

**Purpose**

Determines if the freelook controls should be processed for a player.

**Parameters**

* `player` (`Player`): Player to check.

**Realm**

`Client`

**Returns**

`boolean` — return `false` to block freelook for this frame.

**Example**

```lua
hook.Add("ShouldUseFreelook", "DisableWhenFrozen", function(pl)
    if pl:IsFrozen() then return false end
end)
```

---

### `PreFreelookToggle`

**Purpose**

Called when the freelook bind is pressed before the mode is toggled. Returning `false` stops the state change.

**Parameters**

* `state` (`boolean`): `true` when enabling freelook, `false` when disabling.

**Realm**

`Client`

**Returns**

`boolean` — return `false` to cancel toggling.

**Example**

```lua
hook.Add("PreFreelookToggle", "BlockDuringCutscene", function(state)
    if IsInCutscene() then return false end
end)
```

---

### `FreelookToggled`

**Purpose**

Runs after freelook has been turned on or off.

**Parameters**

* `state` (`boolean`): Current freelook state after the change.

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("FreelookToggled", "Notify", function(state)
    print("Freelook state:", state)
end)
```

---

