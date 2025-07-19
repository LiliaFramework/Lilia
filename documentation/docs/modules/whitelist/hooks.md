# Hooks

Module-specific events raised by the Whitelist module.

---

### `PreWhitelistCheck`

**Purpose**

Runs before a player's SteamID is compared against the whitelist.

**Parameters**

* `steamID64` (`string`): SteamID64 of the connecting player.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PreWhitelistCheck", "Example_PreWhitelistCheck", function(steamID64)
    print("Checking whitelist for", steamID64)
end)
```

---

### `PlayerBlacklisted`

**Purpose**

Fires when a connecting player's SteamID is listed in the blacklist.

**Parameters**

* `steamID64` (`string`): SteamID64 of the blacklisted player.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PlayerBlacklisted", "Example_PlayerBlacklisted", function(steamID64)
    -- log or notify staff
end)
```

---

### `PlayerNotWhitelisted`

**Purpose**

Called when whitelist mode is enabled and a player is not on the list.

**Parameters**

* `steamID64` (`string`): SteamID64 of the rejected player.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PlayerNotWhitelisted", "Example_PlayerNotWhitelisted", function(steamID64)
    print(steamID64 .. " attempted to join without access")
end)
```

---

### `PlayerWhitelisted`

**Purpose**

Fires when a player passes the whitelist check.

**Parameters**

* `steamID64` (`string`): SteamID64 of the approved player.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PlayerWhitelisted", "Example_PlayerWhitelisted", function(steamID64)
    -- success actions
end)
```

---

### `PostWhitelistCheck`

**Purpose**

Runs after a player's whitelist status has been determined.

**Parameters**

* `steamID64` (`string`): SteamID64 that was checked.

* `allowed` (`boolean`): Whether the player is permitted to join.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PostWhitelistCheck", "Example_PostWhitelistCheck", function(steamID64, allowed)
    if allowed then
        print(steamID64 .. " is whitelisted")
    else
        print(steamID64 .. " is not whitelisted")
    end
end)
```

---

