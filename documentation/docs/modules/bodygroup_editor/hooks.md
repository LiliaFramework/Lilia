# Hooks

Module-specific events raised by the Bodygroup Editor module.

---

### `BodygrouperClosetAddUser`

**Purpose**

`Fires when a player begins using a bodygrouper closet.`

**Parameters**

* `closet` (`Entity`): `The bodygrouper closet entity.`

* `user` (`Player`): `Player entering the closet.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperClosetAddUser", "LogClosetUser", function(closet, user)
    print(user:Name() .. " is using closet " .. tostring(closet))
end)
```

---

### `BodygrouperClosetRemoveUser`

**Purpose**

`Called when a player stops using a bodygrouper closet.`

**Parameters**

* `closet` (`Entity`): `The closet entity.`

* `user` (`Player`): `Player leaving the closet.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperClosetRemoveUser", "OnClosetLeave", function(closet, user)
    print(user:Name() .. " left closet " .. tostring(closet))
end)
```

---

### `BodygrouperClosetOpened`

**Purpose**

`Runs after a closet is opened and the open sound plays.`

**Parameters**

* `closet` (`Entity`): `The closet that opened.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperClosetOpened", "PlayOpenEffects", function(closet)
    -- custom effects here
end)
```

---

### `BodygrouperClosetClosed`

**Purpose**

`Runs after a closet has closed and the closing sound is played.`

**Parameters**

* `closet` (`Entity`): `The closet that closed.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperClosetClosed", "PlayCloseEffects", function(closet)
    -- custom effects here
end)
```

---

### `BodygrouperMenuOpened`

**Purpose**

`Called when the client opens the bodygrouper menu.`

**Parameters**

* `menu` (`Panel`): `The VGUI panel for the menu.`

* `target` (`Entity`): `Entity whose bodygroups are being edited.`

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperMenuOpened", "InitMenu", function(menu, target)
    -- do something with the menu
end)
```

---

### `BodygrouperMenuClosed`

**Purpose**

`Called when the bodygrouper menu is closed on the client.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperMenuClosed", "RemoveHighlights", function()
    -- cleanup here
end)
```

---

### `BodygrouperMenuClosedServer`

**Purpose**

`Runs server‑side when a player closes the bodygrouper menu.`

**Parameters**

* `client` (`Player`): `Player that closed the menu.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperMenuClosedServer", "TrackUsage", function(client)
    print(client:Name() .. " closed the bodygrouper menu")
end)
```

---

### `PreBodygroupApply`

**Purpose**

`Called before new skin or bodygroup values are applied to a target.`

**Parameters**

* `client` (`Player`): `Player applying the changes.`

* `target` (`Entity`): `Entity receiving the new appearance.`

* `skin` (`number`): `Skin index that will be set.`

* `groups` (`table`): `Bodygroup values keyed by group id.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreBodygroupApply", "ValidateChanges", function(client, target, skin, groups)
    -- validation before applying
end)
```

---

### `PostBodygroupApply`

**Purpose**

`Fires after bodygroup and skin values have been applied.`

**Parameters**

* `client` (`Player`): `Player that made the change.`

* `target` (`Entity`): `Entity that was modified.`

* `skin` (`number`): `Skin index that was set.`

* `groups` (`table`): `Applied bodygroup values.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PostBodygroupApply", "AnnounceChanges", function(client, target, skin, groups)
    print(target:Name() .. " updated appearance")
end)
```

---

### `PreBodygrouperMenuOpen`

**Purpose**

`Runs server-side before the bodygrouper menu is opened for a player.`

**Parameters**

* `client` (`Player`): `Player requesting the menu.`

* `target` (`Entity`): `Entity whose bodygroups will be edited.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreBodygrouperMenuOpen", "LogOpen", function(c, t)
    print(c:Name() .. " is viewing " .. t:Name())
end)
```

---

### `BodygrouperApplyAttempt`

**Purpose**

`Called when the server receives a request to apply bodygroup changes.`

**Parameters**

* `client` (`Player`): `Player applying changes.`

* `target` (`Entity`): `Target entity.`

* `skin` (`number`): `Requested skin index.`

* `groups` (`table`): `Requested bodygroup values.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperApplyAttempt", "LogAttempt", function(c, t, skn)
    print(c:Name(), "attempting bodygroup edit on", t)
end)
```

---

### `BodygrouperInvalidSkin`

**Purpose**

`Runs when a player selects a skin index the target does not support.`

**Parameters**

* `client` (`Player`): `Player who made the request.`

* `target` (`Entity`): `Target entity.`

* `skin` (`number`): `Invalid skin index.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperInvalidSkin", "Warn", function(c, t, skn)
    print("Invalid skin", skn)
end)
```

---

### `BodygrouperInvalidGroup`

**Purpose**

`Called when a bodygroup value exceeds the entity's allowed range.`

**Parameters**

* `client` (`Player`): `Player making the request.`

* `target` (`Entity`): `Target entity.`

* `index` (`number`): `Bodygroup index.`

* `value` (`number`): `Invalid value provided.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperInvalidGroup", "Debug", function(c, t, idx, val)
    print("Invalid group", idx, val)
end)
```

---

### `BodygrouperValidated`

**Purpose**

`Fires after validation passes but before changes apply.`

**Parameters**

* `client` (`Player`): `Player applying changes.`

* `target` (`Entity`): `Target entity.`

* `skin` (`number`): `Skin index to set.`

* `groups` (`table`): `Bodygroup values.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BodygrouperValidated", "Notify", function(c, t)
    print("Validated bodygroup edit for", c:Name())
end)
```

---

