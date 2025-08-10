# Hooks

Module-specific events raised by the Door Kick module.

---

### `DoorKickFailed`

**Purpose**

`Called when a player attempts to kick a door but the action fails.`

**Parameters**

* `client` (`Player`): `Player who tried to kick the door.`

* `door` (`Entity`): `Door entity involved in the attempt.`

* `reason` (`string`): `Why the kick failed (disabled, weak, cannotKick, tooClose, tooFar, or invalid).`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DoorKickFailed", "NotifyFail", function(client, door, reason)
    print(client:Nick() .. " failed to kick a door: " .. reason)
end)
```

---

### `DoorKickStarted`

**Purpose**

`Runs when the door kick animation begins.`

**Parameters**

* `client` (`Player`): `Player kicking the door.`

* `door` (`Entity`): `Door being kicked.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DoorKickStarted", "FreezePlayer", function(client, door)
    client:ChatPrint("Kicking door...")
end)
```

---

### `DoorKickedOpen`

**Purpose**

`Called when a door is successfully kicked open.`

**Parameters**

* `client` (`Player`): `Player who kicked the door.`

* `door` (`Entity`): `Door that was opened.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DoorKickedOpen", "LogDoorKick", function(client, door)
    print(client:Nick() .. " kicked open " .. tostring(door))
end)
```

---

