# Hooks

Module-specific events raised by the Word Filter module.

---

### `PreFilterCheck`

**Purpose**

Runs before a player's chat message is scanned for blocked words.

**Parameters**

* `ply` (`Player`): Player sending the message.

* `text` (`string`): Raw chat text.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PreFilterCheck", "Example_PreFilterCheck", function(ply, text)
    print(ply:Name() .. " said: " .. text)
end)
```

---

### `FilteredWordUsed`

**Purpose**

Called when a blocked word is detected in a chat message.

**Parameters**

* `ply` (`Player`): Player who sent the message.

* `word` (`string`): The banned word that was found.

* `text` (`string`): Original chat text.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("FilteredWordUsed", "Example_FilteredWordUsed", function(ply, word, text)
    ply:notify("Inappropriate language detected")
end)
```

---

### `PostFilterCheck`

**Purpose**

Fires after the filter check completes.

**Parameters**

* `ply` (`Player`): Player who sent the message.

* `text` (`string`): Original chat text.

* `passed` (`boolean`): Whether the message was allowed.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PostFilterCheck", "Example_PostFilterCheck", function(ply, text, passed)
    if passed then
        print("Allowed message from", ply)
    end
end)
```


---

### `FilterCheckFailed`

**Purpose**

`Called when a player's message is blocked for containing a banned word.`

**Parameters**

* `ply` (`Player`): `The offending player.`

* `text` (`string`): `Original chat text.`

* `word` (`string`): `The banned word found.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("FilterCheckFailed", "LogFailure", function(ply, text, bad)
    print(ply:Name() .. " used disallowed word " .. bad)
end)
```

---

### `FilterCheckPassed`

**Purpose**

`Runs when a player's chat message passes the filter.`

**Parameters**

* `ply` (`Player`): `Player whose message was allowed.`

* `text` (`string`): `Their original message.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("FilterCheckPassed", "LogPass", function(ply, text)
    print("Allowed chat:", text)
end)
```

---

### `WordAddedToFilter`

**Purpose**

`Fires after a new word is added to the blacklist.`

**Parameters**

* `word` (`string`): `The word that was inserted.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("WordAddedToFilter", "Announce", function(word)
    print("Added banned word:", word)
end)
```

---

### `WordRemovedFromFilter`

**Purpose**

`Called after a word is removed from the blacklist.`

**Parameters**

* `word` (`string`): `The word removed.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("WordRemovedFromFilter", "AnnounceRemove", function(word)
    print("Removed banned word:", word)
end)
```

---

