# Hooks

Module-specific events raised by the Join Leave Messages module.

---

### `PreJoinLeaveMessageSent`

**Purpose**

`Called before a join or leave message is broadcast.`

**Parameters**

* `player` (`Player`): `Player that joined or left.`

* `joined` (`boolean`): `True if joining, false if leaving.`

* `message` (`string`): `The text that will be sent.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("PreJoinLeaveMessageSent", "FilterMessages", function(ply, joined, msg)
    if ply:IsBot() then return false end
end)
```

---

### `JoinLeaveMessageSent`

**Purpose**

`Fires after the join or leave message has been sent.`

**Parameters**

* `player` (`Player`): `The player in question.`

* `joined` (`boolean`): `Whether they joined (true) or left (false).`

* `message` (`string`): `Message that was sent.`

**Realm**

`Server`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("JoinLeaveMessageSent", "LogToConsole", function(ply, joined, msg)
    print(msg)
end)
```

---

