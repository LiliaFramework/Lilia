# Hooks

Module-specific events raised by the Anonymous Rumors module.

---

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

---

### `PreRumourCommand`

**Purpose**

`Runs when a player executes the rumour command before processing.`

**Parameters**

* `client` (`Player`): `The player using the command.`

* `arguments` (`table`): `Raw command arguments.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreRumourCommand", "CapLength", function(client, args)
    if #args[1] > 200 then return false end
end)
```

---

### `RumourFactionDisallowed`

**Purpose**

`Triggered when a player's faction is not allowed to spread rumours.`

**Parameters**

* `client` (`Player`): `The player denied.`

* `faction` (`table`|`nil`): `Their faction data.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("RumourFactionDisallowed", "NotifyDenied", function(client)
    client:notify("Rumours restricted for your faction")
end)
```

---

### `RumourNoMessage`

**Purpose**

`Called when the command is used with no message text.`

**Parameters**

* `client` (`Player`): `The player who tried.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("RumourNoMessage", "HintUsage", function(c)
    c:ChatPrint("Usage: /rumour <text>")
end)
```

---

### `RumourValidationFailed`

**Purpose**

`Fires when another hook blocks the rumour from sending.`

**Parameters**

* `client` (`Player`): `The player whose rumour was denied.`

* `text` (`string`): `Rumour text attempted.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("RumourValidationFailed", "LogDeniedRumour", function(client, text)
    print(client:Name() .. " had rumour blocked: " .. text)
end)
```

---

### `RumourRevealRoll`

**Purpose**

`Runs after the random reveal chance is determined.`

**Parameters**

* `client` (`Player`): `The rumour source.`

* `chance` (`number`): `Configured reveal probability.`

* `revealed` (`boolean`): `Result of the roll.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("RumourRevealRoll", "DebugRoll", function(client, chance, revealed)
    print("Reveal roll:", chance, revealed)
end)
```

---

### `RumourRevealed`

**Purpose**

`Triggered if the player's identity is revealed during a rumour.`

**Parameters**

* `client` (`Player`): `The identified player.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("RumourRevealed", "Embarrass", function(client)
    client:ChatPrint("Your rumour was traced back to you!")
end)
```

---

