# Hooks

Module-specific events raised by the Community Commands module.

---

### `CommunityURLOpened`

**Purpose**

Triggered client-side when a community URL is about to be opened.

**Parameters**

* `commandName` (`string`): The chat command used.

* `url` (`string`): The URL that will be opened.

* `openIngame` (`boolean`): True if the page is opened in an in-game panel.

**Realm**

`Client`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("CommunityURLOpened", "NotifyURLOpen", function(commandName, url, openIngame)
    print("Opening", url)
end)
```

---

### `CommunityURLRequest`

**Purpose**

Runs server-side when a player issues a community command.

**Parameters**

* `client` (`Player`): The player requesting the URL.

* `command` (`string`): The command name used.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("CommunityURLRequest", "LogRequest", function(client, command)
    print(client:Name() .. " requested URL for " .. command)
end)
```

---

