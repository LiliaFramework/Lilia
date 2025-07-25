# Hooks

Module-specific events raised by the First Person Effects module.

---

### `ShouldUseFirstPersonEffects`

**Purpose**

Determines whether first-person motion effects should run for a player.

**Parameters**

* `player` (`Player`): Player whose view is being calculated.

**Realm**

`Client`

**Returns**

`boolean` — return `false` to disable the effects.

**Example**

```lua
hook.Add("ShouldUseFirstPersonEffects", "DisableForSpectators", function(pl)
    if pl:IsFlagSet(FL_NOTARGET) then return false end
end)
```

---

### `PreFirstPersonEffects`

**Purpose**

Called right before view bobbing calculations occur.

**Parameters**

* `player` (`Player`): Player whose view is being processed.

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreFirstPersonEffects", "ResetValues", function(pl)
    -- adjust module variables here
end)
```

---

### `PostFirstPersonEffects`

**Purpose**

Runs after the target view offsets have been calculated.

**Parameters**

* `player` (`Player`): Player being processed.

* `position` (`Vector`): Current position offset.

* `angles` (`Angle`): Current angle offset.

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("PostFirstPersonEffects", "Debug", function(pl, pos, ang)
    -- visualize the calculated offsets
end)
```

---

### `FirstPersonEffectsUpdated`

**Purpose**

Notifies that the first-person effect values have been applied for this frame.

**Parameters**

* `player` (`Player`): Player being processed.

* `position` (`Vector`): Applied position offset.

* `angles` (`Angle`): Applied angle offset.

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("FirstPersonEffectsUpdated", "StoreOffsets", function(pl, pos, ang)
    MyAddon.LastOffset = pos
end)
```

---

