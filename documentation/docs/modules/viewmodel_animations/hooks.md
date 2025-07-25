# Hooks

Module-specific events raised by the Viewmodel Animations module.

---

### `PreVManipPickup`

**Purpose**

`Runs before the pickup animation message is sent to the client.`

**Parameters**

* `client` (`Player`): `Player picking up the item.`

* `item` (`Item`): `Item that is being picked up.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("PreVManipPickup", "BlockCertainItems", function(client, item)
    if item.uniqueID == "restricted" then
        return false
    end
end)
```

---

### `VManipPickup`

**Purpose**

`Called after the pickup animation network message is sent.`

**Parameters**

* `client` (`Player`): `Player that picked up the item.`

* `item` (`Item`): `Item that was picked up.`

**Realm**

`Server`

**Returns**

`nil` — `Return value is ignored.`

**Example**

```lua
hook.Add("VManipPickup", "PlaySound", function(client, item)
    client:EmitSound("items/ammo_pickup.wav")
end)
```

---

### `VManipChooseAnim`

**Purpose**

`Allows overriding which animation is played for a picked up item.`

**Parameters**

* `itemID` (`string`): `Unique ID of the item being picked up.`

**Realm**

`Client`

**Returns**

`string|nil` — `Return the animation name or nil for the default.`

**Example**

```lua
hook.Add("VManipChooseAnim", "UseFastAnim", function(itemID)
    if itemID == "apple" then
        return "interactfast"
    end
end)
```

---

### `VManipAnimationPlayed`

**Purpose**

`Notifies that a viewmodel animation has begun playing.`

**Parameters**

* `itemID` (`string`): `Unique ID of the related item.`

**Realm**

`Client`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("VManipAnimationPlayed", "DebugAnim", function(itemID)
    print("Animation started for", itemID)
end)
```

---

