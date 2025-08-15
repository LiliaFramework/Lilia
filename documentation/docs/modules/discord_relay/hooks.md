# Hooks

Module-specific events raised by the Discord Relay module.

---

### `DiscordRelaySend`

**Purpose**

`Called just before a log line is posted to the configured Discord webhook.`
Return values are ignored; the log string cannot be modified from this hook.

**Parameters**

* `logString` (`string`): `The text that will be sent to Discord.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DiscordRelaySend", "PrintLog", function(logString)
    print("Sending to Discord:", logString)
end)
```

---

### `DiscordRelayed`

**Purpose**

`Runs after a log line has been successfully sent through the webhook.`

**Parameters**

* `logString` (`string`): `The text that was sent to Discord.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DiscordRelayed", "PrintRelayed", function(logString)
    print("Relayed to Discord:", logString)
end)
```

---

### `DiscordRelayUnavailable`

**Purpose**

`Fires when the CHTTP binary module is missing and relaying cannot be performed.`

**Parameters**

*(None)*

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DiscordRelayUnavailable", "NotifyMissing", function()
    print("Discord relay module unavailable.")
end)
```

---

