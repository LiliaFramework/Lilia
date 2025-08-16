# Hooks

Module-specific events raised by the Advertisements module.

---

### `AdvertSent`

**Purpose**

`Fires after a player successfully sends an advertisement message.`

**Parameters**

* `client` (`Player`): `Player who posted the advert.`

* `message` (`string`): `Text that was advertised.`

**Realm**

`Server`

**Returns**

`nil` — `This hook does not return anything.`

**Example**

```lua
hook.Add("AdvertSent", "LogAdvert", function(client, message)
    print(client:Nick() .. " advertised: " .. message)
end)
```

---

