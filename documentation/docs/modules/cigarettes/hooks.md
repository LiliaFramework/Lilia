# Hooks

Module-specific events raised by the Cigarettes module.

---

### `PlayerInhaleSmoke`

**Purpose**

Fires each time a player inhales from a cigarette weapon.

**Parameters**

* `player` (`Player`): The smoking player.

* `cigID` (`number`): Identifier of the cigarette item.

* `puffs` (`number`): Total puffs taken so far.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("PlayerInhaleSmoke", "TrackInhale", function(player, cigID, puffs)
    print(player:Name() .. " inhaled", puffs, "times")
end)
```

---

### `PlayerStartSmoking`

**Purpose**

Called the first time a player inhales from a cigarette.

**Parameters**

* `player` (`Player`): The player who started smoking.

* `cigID` (`number`): Identifier of the cigarette item.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("PlayerStartSmoking", "SmokingBegin", function(player, cigID)
    print(player:Name() .. " started smoking")
end)
```

---

### `PlayerPuffSmoke`

**Purpose**

Occurs when a player releases smoke after holding a cigarette.

**Parameters**

* `player` (`Player`): The smoker.

* `cigID` (`number`): Identifier of the cigarette item.

* `puffs` (`number`): How many puffs were taken.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("PlayerPuffSmoke", "OnPuff", function(player, cigID, puffs)
    print(player:Name() .. " puffed after", puffs, "puffs")
end)
```

---

### `PlayerStopSmoking`

**Purpose**

Fires when the player stops smoking, either by releasing the attack key or after finishing a cigarette.

**Parameters**

* `player` (`Player`): The player who stopped smoking.

* `cigID` (`number`): Identifier of the cigarette item.

**Realm**

`Server`

**Returns**

`nil` — This hook does not return anything.

**Example**

```lua
hook.Add("PlayerStopSmoking", "SmokingEnd", function(player, cigID)
    print(player:Name() .. " stopped smoking")
end)
```

---

