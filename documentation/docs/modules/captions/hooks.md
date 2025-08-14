# Hooks

Module-specific events raised by the Captions module.

---

### `SendCaptionCommand`

**Purpose**

`Triggered when an administrator uses the sendCaption command.`

**Parameters**

* `client` (`Player`): `The admin running the command.`

* `target` (`Player`): `Player who will receive the caption.`

* `text` (`string`): `Caption text.`

* `duration` (`number`): `How long the caption should display.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("SendCaptionCommand", "LogCaptionSend", function(client, target, text, duration)
    print(client:Name() .. " captioned " .. target:Name())
end)
```

---

### `BroadcastCaptionCommand`

**Purpose**

`Called when an administrator broadcasts a caption to all players.`

**Parameters**

* `client` (`Player`): `Admin issuing the command.`

* `text` (`string`): `Caption text.`

* `duration` (`number`): `Display time in seconds.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BroadcastCaptionCommand", "TrackCaptionBroadcast", function(client, text, duration)
    -- log broadcast here
end)
```

---

### `CaptionStarted`

**Purpose**

`Fires whenever a caption begins displaying.`

**Parameters**

**Server**

* `client` (`Player`): `The player receiving the caption.`
* `text` (`string`): `Caption text.`
* `duration` (`number`): `How long the caption should display.`

**Client**

* `text` (`string`): `Caption text.`
* `duration` (`number`): `How long the caption should display.`

**Realm**

`Client & Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("CaptionStarted", "HandleCaptionStart", function(a, b, duration)
    -- parameters depend on realm
end)
```

---

### `CaptionFinished`

**Purpose**

`Runs when an active caption ends.`

**Parameters**

**Server**

* `client` (`Player`): `The player whose caption ended.`

**Client**

* *(None)*

**Realm**

`Client & Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("CaptionFinished", "HandleCaptionEnd", function(client)
    -- cleanup logic here
end)
```

---

