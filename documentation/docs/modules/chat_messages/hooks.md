# Hooks

Module-specific events raised by the Chat Messages module.

---

### `ChatMessagesTimerStarted`

**Purpose**

`Runs when the repeating chat message timer is created.`

**Parameters**

* `interval` (`number`): `Number of seconds between messages.`

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("ChatMessagesTimerStarted", "DisplayInterval", function(interval)
    print("Chat messages will appear every " .. interval .. " seconds")
end)
```

---

### `ChatMessageSent`

**Purpose**

`Called each time an automated chat message is displayed.`

**Parameters**

* `index` (`number`): `Index of the message in the rotation.`

* `text` (`string`): `The text that was sent.`

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("ChatMessageSent", "ReactToMessage", function(index, text)
    chat.AddText(Color(0,255,0), "[Log]", color_white, " Message " .. index .. ": " .. text)
end)
```

---

