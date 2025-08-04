# Hooks

Module-specific events raised by the Model Pay module.

---

### `ModelPayModelChecked`

**Purpose**

`Triggered when a player's model is compared against the pay table.`

**Parameters**

* `client` (`Player`): `The player being evaluated.`

* `model` (`string`): `Model path used for the check.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("ModelPayModelChecked", "PrintModel", function(client, model)
    print(client:Name(), "has model", model)
end)
```

---

### `ModelPayModelMatched`

**Purpose**

`Called when a player's model matches an entry in the pay table.`

**Parameters**

* `client` (`Player`): `Matching player.`

* `model` (`string`): `Matched model path.`

* `pay` (`number`): `Salary amount found for the model.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("ModelPayModelMatched", "Debug", function(client, model, pay)
    print(model, "pays", pay)
end)
```

---

### `ModelPaySalaryDetermined`

**Purpose**

`Fires after the salary for a player has been decided.`

**Parameters**

* `client` (`Player`): `Player receiving wages.`

* `pay` (`number`): `Amount calculated for the player.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("ModelPaySalaryDetermined", "RecordPay", function(client, pay)
    -- log wages
end)
```

---

### `ModelPayModelNotMatched`

**Purpose**

`Runs when the player's model has no entry in the pay table.`

**Parameters**

* `client` (`Player`): `Player with an unmatched model.`

* `model` (`string`): `Model path that did not match.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("ModelPayModelNotMatched", "DefaultPay", function(client, model)
    -- maybe set a default pay here
end)
```

---

### `CreateSalaryTimer`

**Purpose**

`A request to start the salary timer for a player.`

**Parameters**

* `client` (`Player`): `Player eligible for pay.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("CreateSalaryTimer", "CustomTimer", function(client)
    -- create timer
end)
```

---

### `ModelPayModelEligible`

**Purpose**

`Called when a player's changed model is eligible for pay.`

**Parameters**

* `client` (`Player`): `Player who changed models.`

* `model` (`string`): `New eligible model.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("ModelPayModelEligible", "StartSalary", function(client, model)
    -- handle eligibility
end)
```

---

### `ModelPayModelIneligible`

**Purpose**

`Runs when a player's new model does not qualify for pay.`

**Parameters**

* `client` (`Player`): `Player who changed models.`

* `model` (`string`): `Model that is not paid.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("ModelPayModelIneligible", "StopSalary", function(client, model)
    -- cleanup
end)
```

---

