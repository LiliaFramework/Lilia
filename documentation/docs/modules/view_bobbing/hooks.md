# Hooks

Module-specific events raised by the View Bobbing module.

---

### `ViewBobPunch`

**Purpose**

`Allows custom effects whenever the module applies a view punch.`

**Parameters**

* `client` (`Player`): `The local player receiving the view punch.`

* `angleX` (`number`): `Pitch component.`

* `angleY` (`number`): `Yaw component.`

* `angleZ` (`number`): `Roll component.`

**Realm**

`Client`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("ViewBobPunch", "ScreenShake", function(client, x, y, z)
    if x > 2 then
        util.ScreenShake(client:GetPos(), 5, 5, 0.25, 100)
    end
end)
```

---

### `ViewBobStep`

**Purpose**

`Called each time the player takes a step to allow overriding the step value.`

**Parameters**

* `client` (`Player`): `The stepping player.`

* `step` (`number`): `1 or -1 indicating step direction.`

**Realm**

`Client`

**Returns**

`number` — `New step value to use.`

**Example**

```lua
hook.Add("ViewBobStep", "InvertBob", function(client, step)
    if client:Crouching() then
        return -step
    end
end)
```

---

### `PreViewPunch`

**Purpose**

`Called just before the view punch is applied.`

**Parameters**

* `client` (`Player`): `Player receiving the view punch.`

* `angleX` (`number`): `Pitch component.`

* `angleY` (`number`): `Yaw component.`

* `angleZ` (`number`): `Roll component.`

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("PreViewPunch", "ClampPunch", function(client, x, y, z)
    return math.Clamp(x, -5, 5), y, z
end)
```

---

### `PostViewPunch`

**Purpose**

`Runs after the view punch effect has been triggered.`

**Parameters**

* `client` (`Player`): `Player that was punched.`

* `angleX` (`number`): `Pitch component.`

* `angleY` (`number`): `Yaw component.`

* `angleZ` (`number`): `Roll component.`

**Realm**

`Client`

**Returns**

`nil`

**Example**

```lua
hook.Add("PostViewPunch", "PostEffects", function(client)
    -- apply additional effects
end)
```

---

