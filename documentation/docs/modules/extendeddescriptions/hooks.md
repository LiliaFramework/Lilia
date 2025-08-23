# Hooks

Module-specific events raised by the Extended Descriptions module.

---

### `ExtendedDescriptionOpened`

**Purpose**

Opens the detailed description panel for a player.

**Parameters**

* `ply` (`Player`): Player whose description is being viewed.

* `frame` (`Panel`): The panel containing the description.

* `text` (`string`): The description text.

* `url` (`string`): Reference image URL.

**Realm**

`Client`

**Returns**

`nil` — called for notification only

**Example**

```lua
hook.Add("ExtendedDescriptionOpened", "logDescriptionOpen", function(ply, frame, text, url)
    print(ply:Name() .. " opened their description")
end)
```

---

### `ExtendedDescriptionClosed`

**Purpose**

Fired when the detailed description panel is closed.

**Parameters**

* `ply` (`Player`): Player whose description was viewed.

* `text` (`string`): The description text.

* `url` (`string`): Reference image URL.

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("ExtendedDescriptionClosed", "logDescriptionClose", function(ply, text, url)
    print(ply:Name() .. " closed the description window")
end)
```

---

### `ExtendedDescriptionEditOpened`

**Purpose**

Fired when the admin edit window is opened.

**Parameters**

* `frame` (`Panel`): Panel allowing text entry.

* `steamName` (`string`): Steam name of the player being edited.

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("ExtendedDescriptionEditOpened", "editOpened", function(frame, name)
    frame:SetBackgroundColor(Color(30,30,30))
end)
```

---

### `ExtendedDescriptionEditClosed`

**Purpose**

Fired when the edit window is closed.

**Parameters**

* `steamName` (`string`): Steam name of the player being edited.

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("ExtendedDescriptionEditClosed", "editClosed", function(name)
    print(name .. " finished editing")
end)
```

---

### `ExtendedDescriptionEditSubmitted`

**Purpose**

Called when the admin submits new description text.

**Parameters**

* `steamName` (`string`): Steam name of the player being edited.

* `url` (`string`): Submitted reference image URL.

* `text` (`string`): Submitted description text.

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("ExtendedDescriptionEditSubmitted", "logEdit", function(name, url, text)
    print("Description submitted for" .. name)
end)
```

---

### `PreExtendedDescriptionUpdate`

**Purpose**

Runs on the server before a player's description data is changed.

**Parameters**

* `client` (`Player`): The player receiving the new description.

* `url` (`string`): Reference image URL.

* `text` (`string`): Description text.

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreExtendedDescriptionUpdate", "notifyAdmin", function(client, url, text)
    print(client:Name() .. " is updating their description")
end)
```

---

### `ExtendedDescriptionUpdated`

**Purpose**

Runs after the server stores a player's new description.

**Parameters**

* `client` (`Player`): Player whose description was updated.

* `url` (`string`): Reference image URL.

* `text` (`string`): Description text.

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("ExtendedDescriptionUpdated", "announceUpdate", function(client, url, text)
    client:ChatPrint("Your description was saved!")
end)
```

---

