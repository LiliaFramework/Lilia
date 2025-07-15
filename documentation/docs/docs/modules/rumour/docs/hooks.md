### `CanSendRumour`

**Purpose**
`Called before a rumour is sent to check if the player is allowed to spread it.`

**Parameters**

* `client` (`Player`): `The player attempting to spread a rumour.`
* `text` (`string`): `The rumour text.`

**Realm**
`Server`

**Returns**
`boolean` — `Return false to block the rumour.`

**Example**

```lua
hook.Add("CanSendRumour", "BlockShortRumours", function(client, text)
    if #text < 10 then
        return false
    end
end)
```

---

### `RumourAttempt`

**Purpose**
`Fired when a player begins to spread a rumour after passing checks.`

**Parameters**

* `client` (`Player`): `The player attempting to spread a rumour.`
* `text` (`string`): `The rumour text.`

**Realm**
`Server`

**Returns**
`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("RumourAttempt", "LogRumourAttempt", function(client, text)
    print(client:Name() .. " attempted to rumour: " .. text)
end)
```

---

### `RumourSent`

**Purpose**
`Called after a rumour message has been broadcast to other players.`

**Parameters**

* `client` (`Player`): `The player who spread the rumour.`
* `text` (`string`): `The rumour text.`
* `revealed` (`boolean`): `Whether the player's identity was revealed.`

**Realm**
`Server`

**Returns**
`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("RumourSent", "NotifyReveal", function(client, text, revealed)
    if revealed then
        client:notify("You were identified!")
    end
end)
```
