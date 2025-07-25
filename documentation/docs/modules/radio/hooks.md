# Hooks

Module-specific events raised by the Radio module.

---

### `AddSection`

**Purpose**

`Allows other modules to add a new section to the radio information window.`

**Parameters**

* `title` (`string`): `Displayed section title.`

* `color` (`Color`): `Header color for the section.`

* `order` (`number`): `Order value used for sorting.`

**Realm**

`Client`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("AddSection", "AddRadioStats", function(title, color, order)
    print("Adding radio UI section", title)
end)
```

---


### `ShouldRadioBeep`

**Purpose**

`Determines whether a beep should play when radio chatter ends.`

**Parameters**

* `listener` (`Player`): `Player that would hear the beep.`

**Realm**

`Server`

**Returns**

`boolean` — `Return false to suppress the beep sound.`

**Example**

```lua
hook.Add("ShouldRadioBeep", "SilentRadios", function(listener)
    return listener:GetMoveType() == MOVETYPE_NOCLIP
end)
```

---

### `PlayerFinishRadio`

**Purpose**

`Runs after a player's radio transmission finishes.`

**Parameters**

* `listener` (`Player`): `Player hearing the beep.`

* `frequency` (`string`): `Frequency that was used.`

* `channel` (`number`): `Channel index.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PlayerFinishRadio", "LogFinish", function(listener, freq, channel)
    print(listener:Name(), "finished talking on", freq)
end)
```

---

### `CanHearRadio`

**Purpose**

`Checks if a listener should hear a given radio message.`

**Parameters**

* `listener` (`Player`): `Potential recipient.`

* `speaker` (`Player`): `Player sending the message.`

* `frequency` (`string`): `Radio frequency.`

* `channel` (`number`): `Channel index.`

**Realm**

`Server`

**Returns**

`boolean` — `Return false to block reception.`

**Example**

```lua
hook.Add("CanHearRadio", "FactionRestriction", function(listener, speaker, freq)
    return listener:Team() == speaker:Team()
end)
```

---

### `CanUseRadio`

**Purpose**

`Determines if a player can start transmitting on a radio.`

**Parameters**

* `speaker` (`Player`): `Player attempting to talk.`

* `frequency` (`string`): `Radio frequency.`

* `channel` (`number`): `Channel index.`

**Realm**

`Server`

**Returns**

`boolean` — `Return false to prevent talking.`

**Example**

```lua
hook.Add("CanUseRadio", "CheckJammed", function(speaker, freq, channel)
    if speaker:isJammed() then return false end
end)
```

---

### `PlayerStartRadio`

**Purpose**

`Called once a player begins transmitting over the radio.`

**Parameters**

* `speaker` (`Player`): `Player that started talking.`

* `frequency` (`string`): `Radio frequency used.`

* `channel` (`number`): `Channel index.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PlayerStartRadio", "AnnounceStart", function(speaker, freq, channel)
    print(speaker:Name(), "started radio on", freq)
end)
```

---

### `OnRadioSabotaged`

**Purpose**

`Triggered when a handheld radio is sabotaged and destroyed.`

**Parameters**

* `client` (`Player`): `Player who sabotaged the radio.`

* `item` (`Item`): `Radio item that was removed.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnRadioSabotaged", "AlertSabotage", function(client, item)
    print(client:Name(), "broke a radio")
end)
```

---

### `OnRadioEnabled`

**Purpose**

`Runs when a player enables their radio item.`

**Parameters**

* `client` (`Player`): `Owner of the radio.`

* `item` (`Item`): `Radio item being enabled.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnRadioEnabled", "RadioTurnedOn", function(client, item)
    print(client:Name(), "turned on a radio")
end)
```

---

### `OnRadioDisabled`

**Purpose**

`Runs when a player disables their radio item.`

**Parameters**

* `client` (`Player`): `Owner of the radio.`

* `item` (`Item`): `Radio item being disabled.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnRadioDisabled", "RadioTurnedOff", function(client, item)
    print(client:Name(), "turned off a radio")
end)
```

---

### `OnRadioFrequencyChanged`

**Purpose**

`Runs when a radio's frequency is adjusted through the UI.`

**Parameters**

* `client` (`Player`): `Player changing the frequency.`

* `item` (`Item`): `Radio item being modified.`

* `frequency` (`string`): `New frequency string.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnRadioFrequencyChanged", "LogFreqChange", function(client, item, freq)
    print(client:Name(), "set frequency to", freq)
end)
```

---

### `RefreshFonts`

**Purpose**

`Invoked client side after the radio font configuration changes.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("RefreshFonts", "ReloadRadioFonts", function()
    print("Updating radio fonts")
end)
```

---

