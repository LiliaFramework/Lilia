# Hooks

Module-specific events raised by the Realistic View module.

---

### `ShouldUseRealisticView`

**Purpose**

`Called before the module alters the player's camera. Returning false prevents the realistic view from being used.`

**Parameters**

* `client` (`Player`): `The player whose view is being calculated.`

**Realm**

`Client`

**Returns**

`boolean` — `Return false to cancel the realistic view.`

**Example**

```lua
hook.Add("ShouldUseRealisticView", "BlockInVehicle", function(client)
    if client:InVehicle() then
        return false
    end
end)
```

---

### `RealisticViewUpdated`

**Purpose**

`Fired after the view table has been built. Allows modification of the values.`

**Parameters**

* `client` (`Player`): `The player whose view is being updated.`

* `view` (`table`): `Table containing origin and angles that may be changed.`

**Realm**

`Client`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("RealisticViewUpdated", "LowerFOV", function(client, view)
    view.fov = 80
end)
```

---

### `RealisticViewCalcView`

**Purpose**

`Final hook before the adjusted view is returned.`

**Parameters**

* `client` (`Player`): `The player whose view is being calculated.`

* `view` (`table`): `Table that can be modified.`

**Realm**

`Client`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("RealisticViewCalcView", "AddRoll", function(client, view)
    view.angles.r = view.angles.r + 5
end)
```

---

