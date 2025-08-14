# Hooks

Module-specific events raised by the Auto Restarter module.

---

### `AutoRestartScheduled`

**Purpose**

`Called when the next automatic restart time is calculated.`

**Parameters**

* `timestamp` (`number`): `Unix time of the upcoming restart.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("AutoRestartScheduled", "NotifyRestart", function(timestamp)
    print("Next restart at " .. os.date("%X", timestamp))
end)
```

---

### `AutoRestart`

**Purpose**

`Fires right before the map is reloaded for the automatic restart.`

**Parameters**

* `timestamp` (`number`): `Time when the restart triggered.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("AutoRestart", "SaveBeforeRestart", function(timestamp)
    -- save data here
end)
```

---

### `AutoRestartStarted`

**Purpose**

`Runs when the restart command is issued.`

**Parameters**

* `map` (`string`): `Map that will be loaded.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("AutoRestartStarted", "AnnounceRestart", function(map)
    print("Changing level to " .. map)
end)
```

---

### `AutoRestartCountdown`

**Purpose**

`Called periodically during the final quarter of the restart interval.`

**Parameters**

* `remaining` (`number`): `Seconds remaining until restart.`

**Realm**

`Server`

**Returns**

`nil`

**Example**

```lua
hook.Add("AutoRestartCountdown", "DisplayTimer", function(remaining)
    print(remaining .. " seconds until restart")
end)
```

