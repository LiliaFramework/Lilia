# Hooks

Module-specific events raised by the Load Messages module.

---

### `PreLoadMessage`

**Purpose**

`Called before a player's faction load message is shown.`

**Parameters**

* `client` (`Player`): `The player that loaded a character.`

* `data` (`table`): `Arguments passed to ClientAddText for this faction.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PreLoadMessage", "LogPreMessage", function(client, data)
    print(client:Name() .. " is about to see a load message")
end)
```

---

### `LoadMessageSent`

**Purpose**

`Runs right after the load message text has been sent to the client.`

**Parameters**

* `client` (`Player`): `Recipient of the message.`

* `data` (`table`): `Message arguments that were sent.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("LoadMessageSent", "NotifySend", function(client, data)
    -- additional processing
end)
```

---

### `PostLoadMessage`

**Purpose**

`Final hook after a faction load message is displayed.`

**Parameters**

* `client` (`Player`): `The player who saw the message.`

* `data` (`table`): `Message arguments that were displayed.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PostLoadMessage", "ClearTempData", function(client, data)
    -- cleanup work
end)
```

---

### `LoadMessageMissing`

**Purpose**

`Triggered when a faction has no configured load message.`

**Parameters**

* `client` (`Player`): `Player without a defined message.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("LoadMessageMissing", "FallbackMessage", function(client)
    client:ChatPrint("Welcome back!")
end)
```

---

