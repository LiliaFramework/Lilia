# Hooks

Module-specific events raised by the Climb module.

---

### `PlayerClimbAttempt`

**Purpose**

Called when a player presses jump to attempt climbing a ledge.

**Parameters**

* `player` (`Player`): Player who is trying to climb.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("PlayerClimbAttempt", "MyAddonClimbAttempt", function(player)
    print(player:Name() .. " tried to climb")
end)
```

---

### `PlayerBeginClimb`

**Purpose**

Runs when the climb is successful and velocity is about to be applied.

**Parameters**

* `player` (`Player`): Player beginning to climb.

* `distance` (`number`): Height difference of the ledge.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("PlayerBeginClimb", "StartClimbEffects", function(player, distance)
    player:EmitSound("jump.wav")
end)
```

---

### `PlayerClimbed`

**Purpose**

Called right after the player has been launched upward to climb.

**Parameters**

* `player` (`Player`): Player who climbed.

* `distance` (`number`): The height of the climb.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("PlayerClimbed", "FinishClimb", function(player, distance)
    print(player:Name() .. " climbed " .. distance .. " units")
end)
```

---

### `PlayerFailedClimb`

**Purpose**

Executed when a climb attempt fails.

**Parameters**

* `player` (`Player`): Player whose attempt failed.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("PlayerFailedClimb", "ClimbFail", function(player)
    player:ChatPrint("You can't climb here.")
end)
```

---

