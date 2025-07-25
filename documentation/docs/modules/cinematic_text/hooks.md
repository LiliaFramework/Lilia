# Hooks

Module-specific events raised by the Cinematic Text module.

---

### `CinematicDisplayStart`

**Purpose**

Called when a cinematic display begins on the client.

**Parameters**

* `text` (`string|nil`): Main splash text or `nil`.

* `bigText` (`string|nil`): Larger text shown beneath, or `nil`.

* `duration` (`number`): Display time before fading out.

* `blackBars` (`boolean`): Whether letterbox bars are drawn.

* `playMusic` (`boolean`): Whether background music should play.

* `color` (`Color`): Color applied to the text.

**Realm**

`Client`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("CinematicDisplayStart", "ExampleStart", function(text, bigText, duration, blackBars, playMusic, color)
    print("Cinematic started:", text)
end)
```

---

### `CinematicPanelCreated`

**Purpose**

Runs after the cinematic splash panel has been created.

**Parameters**

* `panel` (`Panel`): The newly created splash panel.

**Realm**

`Client`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("CinematicPanelCreated", "ModifyPanel", function(panel)
    panel:SetAlpha(200)
end)
```

---

### `CinematicDisplayEnded`

**Purpose**

Fires when the cinematic display has completely faded out.

**Parameters**

_None_

**Realm**

`Client`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("CinematicDisplayEnded", "NotifyEnd", function()
    print("Cinematic finished")
end)
```

---

### `CinematicMenuOpened`

**Purpose**

Triggered when a player opens the cinematic text menu.

**Parameters**

* `client` (`Player`): The player opening the menu.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("CinematicMenuOpened", "LogMenuOpen", function(client)
    print(client:Name() .. " opened the cinematic menu")
end)
```

---

### `CinematicTriggered`

**Purpose**

Called server-side when a player requests to trigger a cinematic display.

**Parameters**

* `client` (`Player`): The requesting player.

* `text` (`string`): Splash text.

* `bigText` (`string`): Large splash text.

* `duration` (`number`): How long the effect should last.

* `blackBars` (`boolean`): Whether to include black bars.

* `playMusic` (`boolean`): Whether to play music.

* `color` (`Color`): Text color.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("CinematicTriggered", "OnCinematicTrigger", function(client, text, bigText, duration, blackBars, playMusic, color)
    print(client:Name() .. " started a cinematic.")
end)
```

---

