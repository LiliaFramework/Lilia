# Hooks

Module-specific events raised by the Development Server module.

---

### `DevServerUnauthorized`

**Purpose**

`Fires when a player without developer access tries to join while development mode is enabled.`

**Parameters**

* `steamid64` (`string`): `SteamID64 of the player that attempted to join.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DevServerUnauthorized", "PrintUnauthorized", function(steamid64)
    print("Unauthorized dev join:", steamid64)
end)
```

---

### `DevServerAuthorized`

**Purpose**

`Runs when an allowed developer joins the server while dev mode is active.`

**Parameters**

* `steamid64` (`string`): `SteamID64 of the developer.`

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DevServerAuthorized", "LogAuthorized", function(steamid64)
    print("Developer authorized:", steamid64)
end)
```

---

### `DevServerModeActivated`

**Purpose**

`Called after modules initialize when development server mode is enabled.`

**Parameters**

*(None)*

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DevServerModeActivated", "AnnounceDevMode", function()
    print("Development server mode is active!")
end)
```

---

### `DevServerModeDeactivated`

**Purpose**

`Called after modules initialize when development server mode is disabled.`

**Parameters**

*(None)*

**Realm**

`Server`

**Returns**

`void` — `Nothing.`

**Example**

```lua
hook.Add("DevServerModeDeactivated", "AnnounceDevModeOff", function()
    print("Development server mode is not active.")
end)
```

---

