# Hooks

Module-specific events raised by the Loyalism module.

---

### `PreUpdatePartyTiers`

**Purpose**

`Called before the module recalculates all player loyalty tiers.`

**Parameters**

* None

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PreUpdatePartyTiers", "Announce", function()
    print("Updating loyalty tiers")
end)
```

---

### `PartyTierApplying`

**Purpose**

`Runs for each player before their loyalty tier value is stored.`

**Parameters**

* `client` (`Player`): `Player being updated.`

* `tier` (`number`): `Tier value being applied.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PartyTierApplying", "DebugTier", function(client, tier)
    print(client:Name(), "set to tier", tier)
end)
```

---

### `PartyTierUpdated`

**Purpose**

`Fires after a player's tier data has been stored.`

**Parameters**

* `client` (`Player`): `Player whose tier was updated.`

* `tier` (`number`): `Tier value stored.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PartyTierUpdated", "Notify", function(client, tier)
    -- reward logic
end)
```

---

### `PartyTierNoCharacter`

**Purpose**

`Called during the update when a player lacks an active character.`

**Parameters**

* `client` (`Player`): `The player without a character.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PartyTierNoCharacter", "Skip", function(client)
    print(client:SteamName(), "has no character")
end)
```

---

### `PostUpdatePartyTiers`

**Purpose**

`Runs once all players have been processed.`

**Parameters**

* None

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PostUpdatePartyTiers", "Done", function()
    print("Tiers updated")
end)
```

---


