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
