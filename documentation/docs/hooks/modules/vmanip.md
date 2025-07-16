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
