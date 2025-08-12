# Hooks

Module-specific events raised by the War Table module.

---

### `PreWarTableClear`

**Purpose**

Runs before the war table is cleared.

**Parameters**

* `client` (`Player`): Player clearing the table.

* `tableEnt` (`Entity`): War table entity being cleared.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PreWarTableClear", "Example_PreWarTableClear", function(client, tableEnt)
    -- custom logic before the table is wiped
end)
```

---

### `WarTableCleared`

**Purpose**

Fires after the war table has been cleared.

**Parameters**

* `client` (`Player`): Player that cleared the table.

* `tableEnt` (`Entity`): War table entity that was cleared.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("WarTableCleared", "Example_WarTableCleared", function(client, tableEnt)
    print(client:Name() .. " cleared " .. tostring(tableEnt))
end)
```

---

### `PostWarTableClear`

**Purpose**

Runs after `WarTableCleared` when the clear process has finished.

**Parameters**

* `client` (`Player`): Player that cleared the table.

* `tableEnt` (`Entity`): War table entity that was cleared.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PostWarTableClear", "Example_PostWarTableClear", function(client, tableEnt)
    -- perform cleanup
end)
```

---

### `PreWarTableMapChange`

**Purpose**

Called before a new map image is set on the war table.

**Parameters**

* `client` (`Player`): Player setting the map.

* `tableEnt` (`Entity`): War table entity being changed.

* `text` (`string`): Map image name or URL.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PreWarTableMapChange", "Example_PreWarTableMapChange", function(client, tableEnt, text)
    print("Changing map to", text)
end)
```

---

### `WarTableMapChanged`

**Purpose**

Fires once the war table's map image is updated.

**Parameters**

* `client` (`Player`): Player who changed the map.

* `tableEnt` (`Entity`): War table entity that was changed.

* `text` (`string`): New map image name or URL.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("WarTableMapChanged", "Example_WarTableMapChanged", function(client, tableEnt, text)
    -- map updated
end)
```

---

### `PostWarTableMapChange`

**Purpose**

Runs after `WarTableMapChanged` once the new map is fully set.

**Parameters**

* `client` (`Player`): Player who changed the map.

* `tableEnt` (`Entity`): War table entity that was changed.

* `text` (`string`): New map image name or URL.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PostWarTableMapChange", "Example_PostWarTableMapChange", function(client, tableEnt, text)
    -- post-update logic
end)
```

---

### `PreWarTableMarkerPlace`

**Purpose**

Triggered before a new marker entity is placed.

**Parameters**

* `client` (`Player`): Player placing the marker.

* `pos` (`Vector`): World position of the marker.

* `bodygroups` (`table`): Bodygroups for the marker model.

* `tableEnt` (`Entity`): War table entity receiving the marker.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PreWarTableMarkerPlace", "Example_PreWarTableMarkerPlace", function(client, pos, bodygroups, tableEnt)
    -- modify bodygroups here
end)
```

---

### `WarTableMarkerPlaced`

**Purpose**

Fires when a marker entity has been spawned on the table.

**Parameters**

* `client` (`Player`): Player who placed the marker.

* `marker` (`Entity`): Spawned marker entity.

* `tableEnt` (`Entity`): War table that holds the marker.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("WarTableMarkerPlaced", "Example_WarTableMarkerPlaced", function(client, marker, tableEnt)
    print("Marker", marker, "placed by", client)
end)
```

---

### `PostWarTableMarkerPlace`

**Purpose**

Runs after `WarTableMarkerPlaced` once the marker setup is done.

**Parameters**

* `client` (`Player`): Player who placed the marker.

* `marker` (`Entity`): Spawned marker entity.

* `tableEnt` (`Entity`): War table that holds the marker.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PostWarTableMarkerPlace", "Example_PostWarTableMarkerPlace", function(client, marker, tableEnt)
    -- further customization
end)
```

---

### `PreWarTableMarkerRemove`

**Purpose**

Called before a marker entity is removed from the table.

**Parameters**

* `client` (`Player`): Player removing the marker.

* `ent` (`Entity`): Marker entity to remove.

* `tableEnt` (`Entity`): War table containing the marker.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PreWarTableMarkerRemove", "Example_PreWarTableMarkerRemove", function(client, ent, tableEnt)
    -- decide if the marker can be removed
end)
```

---

### `WarTableMarkerRemoved`

**Purpose**

Fires after a marker entity has been removed from the table.

**Parameters**

* `client` (`Player`): Player who removed the marker.

* `ent` (`Entity`): Marker entity that was removed.

* `tableEnt` (`Entity`): War table that contained the marker.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("WarTableMarkerRemoved", "Example_WarTableMarkerRemoved", function(client, ent, tableEnt)
    print("Marker removed", ent)
end)
```

---

### `PostWarTableMarkerRemove`

**Purpose**

Runs after `WarTableMarkerRemoved` once cleanup is done.

**Parameters**

* `client` (`Player`): Player who removed the marker.

* `ent` (`Entity`): Marker entity that was removed.

* `tableEnt` (`Entity`): War table that contained the marker.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PostWarTableMarkerRemove", "Example_PostWarTableMarkerRemove", function(client, ent, tableEnt)
    -- post-removal tasks
end)
```

---

### `PreWarTableUsed`

**Purpose**

Called when a player begins interacting with the war table.

**Parameters**

* `activator` (`Player`): Player activating the table.

* `tableEnt` (`Entity`): War table being used.

* `sprinting` (`boolean`): Whether the player is sprinting while activating.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PreWarTableUsed", "Example_PreWarTableUsed", function(activator, tableEnt, sprinting)
    -- modify interaction
end)
```

---

### `WarTableUsed`

**Purpose**

Fires after the war table has been activated.

**Parameters**

* `activator` (`Player`): Player activating the table.

* `tableEnt` (`Entity`): War table being used.

* `sprinting` (`boolean`): Whether the player was sprinting.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("WarTableUsed", "Example_WarTableUsed", function(activator, tableEnt, sprinting)
    print(activator, "used", tableEnt)
end)
```

---

### `PostWarTableUsed`

**Purpose**

Runs after `WarTableUsed` when all usage logic has completed.

**Parameters**

* `activator` (`Player`): Player activating the table.

* `tableEnt` (`Entity`): War table being used.

* `sprinting` (`boolean`): Whether the player was sprinting.

**Realm**

`Server`

**Returns**

`None`

**Example**

```lua
hook.Add("PostWarTableUsed", "Example_PostWarTableUsed", function(activator, tableEnt, sprinting)
    -- final actions after use
end)
```

---

