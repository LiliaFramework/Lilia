# Hooks

Module-specific events raised by the Flashlight module.

---

### `PrePlayerToggleFlashlight`

**Purpose**

Called when a player attempts to toggle their flashlight before any checks are run.

Returning `false` prevents the toggle.

**Parameters**

* `player` (`Player`): Player toggling the flashlight.

* `state` (`boolean`): `true` if enabling, `false` if disabling.

**Realm**

`Server`

**Returns**

`boolean` — return `false` to deny the action.

**Example**

```lua
hook.Add("PrePlayerToggleFlashlight", "RestrictInDarkRP", function(client, state)
    if client:isArrested() then return false end
end)
```

---

### `CanPlayerToggleFlashlight`

**Purpose**

Runs after the pre-hook to determine if the player is allowed to toggle their flashlight.

Returning `false` also prevents the toggle.

**Parameters**

* `player` (`Player`): Player toggling the flashlight.

* `state` (`boolean`): Desired flashlight state.

**Realm**

`Server`

**Returns**

`boolean` — return `false` to deny the action.

**Example**

```lua
hook.Add("CanPlayerToggleFlashlight", "CheckBattery", function(client, state)
    return client:hasItem("flashlight")
end)
```

---

### `PlayerToggleFlashlight`

**Purpose**

Fired once a player's flashlight has been toggled successfully.

**Parameters**

* `player` (`Player`): Player whose flashlight state changed.

* `state` (`boolean`): `true` if now on, `false` if off.

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PlayerToggleFlashlight", "Announce", function(client, state)
    local word = state and "on" or "off"
    print(client:Name() .. " turned their flashlight " .. word)
end)
```

---

