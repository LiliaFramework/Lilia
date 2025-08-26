# Hooks

Module-specific events raised by the Map Cleaner module.

---

### `PreItemCleanupWarning`

**Purpose**

`Sent one minute before world items are removed.`

**Parameters**

* None

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PreItemCleanupWarning", "MyNotify", function()
    print("Item cleanup in 60 seconds")
end)
```

---

### `PostItemCleanupWarning`

**Purpose**

`Runs after the warning for item cleanup has been broadcast.`

**Parameters**

* None

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PostItemCleanupWarning", "Log", function()
    -- do something
end)
```

---

### `PreMapCleanupWarning`

**Purpose**

`Sent one minute before the map cleanup process starts.`

**Parameters**

* None

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PreMapCleanupWarning", "Announce", function()
    print("Map cleanup in 60 seconds")
end)
```

---

### `PostMapCleanupWarning`

**Purpose**

`Triggered after the map cleanup warning has been shown.`

**Parameters**

* None

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PostMapCleanupWarning", "AfterWarn", function()
    -- custom code
end)
```

---

### `PreItemCleanup`

**Purpose**

`Called right before world items are removed.`

**Parameters**

* None

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PreItemCleanup", "Inform", function()
    print("Removing dropped items")
end)
```

---

### `ItemCleanupEntityRemoved`

**Purpose**

`Runs for each dropped entity that is deleted.`

**Parameters**

* `ent` (`Entity`): `The entity being removed.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("ItemCleanupEntityRemoved", "Track", function(ent)
    -- record removal
end)
```

---

### `PostItemCleanup`

**Purpose**

`Executed after all world items have been cleaned up.`

**Parameters**

* None

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PostItemCleanup", "Finish", function()
    print("Item cleanup complete")
end)
```

---

### `PreMapCleanup`

**Purpose**

`Called before map cleanup begins.`

**Parameters**

* None

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PreMapCleanup", "NotifyBegin", function()
    print("Starting map cleanup")
end)
```

---

### `MapCleanupEntityRemoved`

**Purpose**

`Runs for every entity removed during map cleanup.`

**Parameters**

* `ent` (`Entity`): `Entity being removed from the map.`

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("MapCleanupEntityRemoved", "Count", function(ent)
    -- custom tracking
end)
```

---

### `PostMapCleanup`

**Purpose**

`Fires after the map cleanup has finished.`

**Parameters**

* None

**Realm**

`Server`

**Returns**

`void` — `None`

**Example**

```lua
hook.Add("PostMapCleanup", "CleanupDone", function()
    print("Map cleanup completed")
end)
```

---

