# Hooks

Module-specific events raised by the Alcoholism module.

---

### `BACChanged`

**Purpose**

`Called whenever a player's Blood Alcohol Content (BAC) value is updated.`

**Parameters**

* `client` (`Player`): `The player whose BAC changed.`

* `newBac` (`number`): `The player's new BAC value.`

**Realm**

`Server`

**Returns**

`nil` — `This hook does not return anything.`

**Example**

```lua
hook.Add("BACChanged", "PrintBac", function(client, newBac)
    print(client:Name() .. " BAC is now " .. newBac .. "%")
end)
```

---

### `BACReset`

**Purpose**

`Runs when a player's BAC is reset to 0.`

**Parameters**

* `client` (`Player`): `The player whose BAC was reset.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BACReset", "HandleBacReset", function(client)
    -- Additional logic when the player sobers up
end)
```

---

### `BACIncreased`

**Purpose**

`Fires when a player's BAC is increased through consuming alcohol.`

**Parameters**

* `client` (`Player`): `The affected player.`

* `amount` (`number`): `Amount added to the BAC.`

* `newBac` (`number`): `The resulting BAC value.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BACIncreased", "NotifyBACIncrease", function(client, amount, newBac)
    client:ChatPrint("BAC increased by " .. amount .. " to " .. newBac .. "%")
end)
```

---

### `AlcoholConsumed`

**Purpose**

`Triggered when an alcohol item is used by a player.`

**Parameters**

* `client` (`Player`): `Player that consumed the item.`

* `item` (`Item`): `The alcohol item that was consumed.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("AlcoholConsumed", "LogDrink", function(client, item)
    print(client:Name() .. " drank " .. item.name)
end)
```

---

### `PreBACReset`

**Purpose**

`Runs right before a player's BAC value is cleared.`

**Parameters**

* `client` (`Player`): `The player about to be reset.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreBACReset", "LogBeforeReset", function(client)
    print(client:Name() .. " BAC resetting")
end)
```

---

### `PostBACReset`

**Purpose**

`Called after a player's BAC has been cleared.`

**Parameters**

* `client` (`Player`): `The player that was reset.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PostBACReset", "AfterReset", function(client)
    -- cleanup
end)
```

---

### `PreBACIncrease`

**Purpose**

`Invoked before a player's BAC value increases.`

**Parameters**

* `client` (`Player`): `The affected player.`

* `amount` (`number`): `Amount being added.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreBACIncrease", "CheckIncrease", function(client, amount)
    if amount > 50 then return false end
end)
```

---

### `BACThresholdReached`

**Purpose**

`Fires when a player's BAC crosses the drunk threshold.`

**Parameters**

* `client` (`Player`): `The player who crossed the threshold.`

* `newBac` (`number`): `Their new BAC value.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("BACThresholdReached", "AlertAdmins", function(client, bac)
    print(client:Name() .. " is drunk at " .. bac .. "%")
end)
```

---

### `PreBACDecrease`

**Purpose**

`Runs before the server lowers a player's BAC over time.`

**Parameters**

* `client` (`Player`): `Player whose BAC will drop.`

* `current` (`number`): `Their current BAC before drop.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreBACDecrease", "CheckDrop", function(client, current)
    -- You could modify decay here
end)
```

---

### `PostBACDecrease`

**Purpose**

`Runs after a player's BAC has decayed for the tick.`

**Parameters**

* `client` (`Player`): `Affected player.`

* `newBac` (`number`): `Their BAC after decay.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("PostBACDecrease", "NotifyDrop", function(client, newBac)
    print("BAC now", newBac)
end)
```

---


