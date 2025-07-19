# Hooks

Module-specific events raised by the Donator Perks module.

---

### `DonatorFlagsGranted`

**Purpose**

`Triggered after a donator group's flags are granted to a character when they join.`

**Parameters**

* `client` (`Player`): `The player that received the flags.`

* `group` (`string`): `The flag string defined for their user group.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DonatorFlagsGranted", "WelcomeDonator", function(client, group)
    print(client:Nick() .. " was granted " .. group)
end)
```

---

### `DonatorSpawn`

**Purpose**

`Runs when a player spawns and has additional character slots.`

**Parameters**

* `client` (`Player`): `The spawning player.`

* `slots` (`number`): `Number of override character slots.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DonatorSpawn", "AnnounceSlots", function(client, slots)
    print(client:Nick() .. " has " .. slots .. " character slots")
end)
```

---

### `DonatorSlotsAdded`

**Purpose**

`Called when a player's override character slot count is increased.`

**Parameters**

* `player` (`Player`): `The affected player.`

* `count` (`number`): `Their new total slot count.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DonatorSlotsAdded", "LogSlotsAdded", function(player, count)
    print(player:Nick() .. " now has " .. count .. " slots")
end)
```

---

### `DonatorSlotsSubtracted`

**Purpose**

`Called when a player's override character slot count is decreased.`

**Parameters**

* `player` (`Player`): `The affected player.`

* `count` (`number`): `Their new total slot count.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DonatorSlotsSubtracted", "LogSlotsSub", function(player, count)
    print(player:Nick() .. " now has " .. count .. " slots")
end)
```

---

### `DonatorSlotsSet`

**Purpose**

`Runs when a player's override slot value is set to a specific number.`

**Parameters**

* `player` (`Player`): `The affected player.`

* `value` (`number`): `New slot count.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DonatorSlotsSet", "LogSlotsSet", function(player, value)
    print("Slots for " .. player:Nick() .. " set to " .. value)
end)
```

---

### `DonatorMoneyGiven`

**Purpose**

`Fires after the console command grants money to a player.`

**Parameters**

* `target` (`Player`): `Player receiving the money.`

* `amount` (`number`): `Amount of money given.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DonatorMoneyGiven", "LogMoney", function(target, amount)
    print(target:Nick() .. " received " .. amount .. " credits")
end)
```

---

### `DonatorFlagsGiven`

**Purpose**

`Fires after flags are granted via the console command.`

**Parameters**

* `target` (`Player`): `Player receiving the flags.`

* `flags` (`string`): `Flag string given.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DonatorFlagsGiven", "LogFlags", function(target, flags)
    print(target:Nick() .. " was given flags " .. flags)
end)
```

---

### `DonatorItemGiven`

**Purpose**

`Fires after an item is granted via the console command.`

**Parameters**

* `target` (`Player`): `Player receiving the item.`

* `uniqueID` (`string`): `Unique ID of the item added.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DonatorItemGiven", "LogItemGiven", function(target, uniqueID)
    print(target:Nick() .. " received item " .. uniqueID)
end)
```

---

### `DonatorAdditionalSlotsSet`

**Purpose**

`Called when a player's additional character slot value is set.`

**Parameters**

* `player` (`Player`): `The player being modified.`

* `value` (`number`): `New additional slot amount.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DonatorAdditionalSlotsSet", "TrackAddSlotsSet", function(player, value)
    print(player:Nick() .. " additional slots set to " .. value)
end)
```

---

### `DonatorAdditionalSlotsGiven`

**Purpose**

`Called when a player is granted more additional character slots.`

**Parameters**

* `player` (`Player`): `The player receiving slots.`

* `amount` (`number`): `Number of additional slots given.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DonatorAdditionalSlotsGiven", "TrackAddSlots", function(player, amount)
    print(player:Nick() .. " gained " .. amount .. " additional slots")
end)
```

---

