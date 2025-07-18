# Hooks

Module-specific events raised by the Cards module.

---

### `CardsCommandUsed`

**Purpose**

`Fires when a player uses the /cards command.`

**Parameters**

* `client` (`Player`): `Player who executed the command.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("CardsCommandUsed", "TrackCardCommand", function(client)
    print(client:Name() .. " opened a card deck")
end)
```

---

### `CardDrawn`

**Purpose**

`Called after a random card is drawn from the player's deck.`

**Parameters**

* `client` (`Player`): `Player that drew the card.`

* `card` (`string`): `Name of the card that was drawn.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("CardDrawn", "AnnounceCard", function(client, card)
    lia.chat.send(client, "me", "drew " .. card)
end)
```

---

