# Hooks

Module-specific events raised by the Broadcasts module.

---

### `PreClassBroadcastSend`

**Purpose**

`Called right before a class broadcast is sent.`

**Parameters**

* `client` (`Player`): `Player issuing the command.`

* `message` (`string`): `The broadcast text.`

* `classes` (`table`): `List of class names selected for the broadcast.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreClassBroadcastSend", "ModifyClassBroadcast", function(client, message, classes)
    table.insert(classes, "ExtraClass")
end)
```

---

### `ClassBroadcastSent`

**Purpose**

`Runs after a class broadcast has been delivered to players.`

**Parameters**

* `client` (`Player`): `The broadcaster.`

* `message` (`string`): `Message that was sent.`

* `classes` (`table`): `List of class names the message was sent to.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("ClassBroadcastSent", "LogClassBroadcast", function(client, message, classes)
    PrintTable(classes)
end)
```

---

### `PreFactionBroadcastSend`

**Purpose**

`Called before a faction broadcast is sent.`

**Parameters**

* `client` (`Player`): `Player issuing the command.`

* `message` (`string`): `Broadcast text.`

* `factions` (`table`): `Names of factions selected.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreFactionBroadcastSend", "EditFactionBroadcast", function(client, message, factions)
    -- alter message or factions here
end)
```

---

### `FactionBroadcastSent`

**Purpose**

`Runs after a faction broadcast has been delivered.`

**Parameters**

* `client` (`Player`): `The broadcaster.`

* `message` (`string`): `Message that was sent.`

* `factions` (`table`): `Faction names that received the message.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("FactionBroadcastSent", "LogFactionBroadcast", function(client, message, factions)
    print(table.concat(factions, ", "))
end)
```

---

### `ClassBroadcastMenuOpened`

**Purpose**

`Fires when the class broadcast selection menu is presented.`

**Parameters**

* `client` (`Player`): `Player opening the menu.`

* `options` (`table`): `List of class option strings.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("ClassBroadcastMenuOpened", "ModifyOptions", function(client, opts)
    table.sort(opts)
end)
```

---

### `ClassBroadcastMenuClosed`

**Purpose**

`Runs after the player has finished selecting classes.`

**Parameters**

* `client` (`Player`): `The selecting player.`

* `selection` (`table`): `Strings chosen from the list.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("ClassBroadcastMenuClosed", "LogSelection", function(client, selection)
    PrintTable(selection)
end)
```

---

### `ClassBroadcastLogged`

**Purpose**

`Called after a class broadcast has been logged.`

**Parameters**

* `client` (`Player`): `The broadcaster.`

* `message` (`string`): `Broadcast text.`

* `classes` (`table`): `Class names sent to.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("ClassBroadcastLogged", "NotifyAdmins", function(client, msg)
    print("Logged class BC", msg)
end)
```

---

### `FactionBroadcastMenuOpened`

**Purpose**

`Fires when the faction broadcast selection menu appears.`

**Parameters**

* `client` (`Player`): `Opening player.`

* `options` (`table`): `List of faction option strings.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("FactionBroadcastMenuOpened", "SortFactions", function(client, opts)
    table.sort(opts)
end)
```

---

### `FactionBroadcastMenuClosed`

**Purpose**

`Runs after faction options have been chosen.`

**Parameters**

* `client` (`Player`): `Selecting player.`

* `selection` (`table`): `Chosen faction strings.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("FactionBroadcastMenuClosed", "LogFactionSel", function(c, sel)
    PrintTable(sel)
end)
```

---

### `FactionBroadcastLogged`

**Purpose**

`Called after a faction broadcast entry is logged.`

**Parameters**

* `client` (`Player`): `The broadcaster.`

* `message` (`string`): `Broadcast text.`

* `factions` (`table`): `Faction names.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("FactionBroadcastLogged", "NotifyLog", function(client, msg)
    print("Logged faction BC", msg)
end)
```

---

