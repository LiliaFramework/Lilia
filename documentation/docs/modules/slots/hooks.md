# Hooks

Module-specific events raised by the Slot Machine module.

---

### `SlotMachineUse`

**Purpose**

`Runs when a player interacts with the slot machine before paying.`

**Parameters**

* `machine` (`Entity`): `The slot machine entity.`

* `client` (`Player`): `The player who used the machine.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("SlotMachineUse", "CheckVIP", function(machine, client)
    if not client:isVIP() then
        print("Only VIPs can play.")
    end
end)
```

---

### `SlotMachineStart`

**Purpose**

`Fired once the player has paid and the wheels begin to spin.`

**Parameters**

* `machine` (`Entity`): `The slot machine entity.`

* `client` (`Player`): `Player who started the spin.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("SlotMachineStart", "AnnounceSpin", function(machine, client)
    client:EmitSound("slots_spin.wav")
end)
```

---

### `SlotMachinePayout`

**Purpose**

`Called when the player wins money from the machine.`

**Parameters**

* `machine` (`Entity`): `The slot machine entity.`

* `client` (`Player`): `Player who won.`

* `amount` (`number`): `Amount of money awarded.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("SlotMachinePayout", "LogWin", function(machine, client, amount)
    print(client:Name() .. " won " .. amount .. "T")
end)
```

---

### `SlotMachineEnd`

**Purpose**

`Runs after the spin is finished regardless of the result.`

**Parameters**

* `machine` (`Entity`): `The slot machine entity.`

* `client` (`Player`): `Player who played.`

* `amount` (`number`): `Money paid out (0 if nothing).`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("SlotMachineEnd", "ReadyAgain", function(machine, client)
    machine.IsPlaying = true
end)
```

---

