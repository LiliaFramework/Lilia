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
