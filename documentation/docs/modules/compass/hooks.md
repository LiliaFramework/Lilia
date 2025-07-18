# Hooks

Module-specific events raised by the Compass module.

---

### `mCompass_loadFonts`

**Purpose**

Runs when the compass needs to rebuild its fonts. Allows addons to create custom font sizes.

**Parameters**

* *(None)*

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("mCompass_loadFonts", "MyAddonFonts", function()
    surface.CreateFont("MyCompassFont", {font = "Exo", size = 24})
end)
```

---

### `PreCompassMarkerAdded`

**Purpose**

Fires before a new world position marker is added to the compass.

**Parameters**

* `ply` (`Player`): Player that created the marker.

* `pos` (`Vector`): World position for the marker.

* `players` (`table|nil`): Players that should receive the marker.

* `time` (`number`): Time when the marker should expire.

* `color` (`Color`): Marker color.

* `icon` (`string`): Material path for the marker icon.

* `name` (`string`): Optional marker label.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("PreCompassMarkerAdded", "LogMarkers", function(ply, pos)
    print(ply:Nick() .. " placed a marker at " .. tostring(pos))
end)
```

---

### `CompassMarkerAdded`

**Purpose**

Called after a marker has been successfully added.

**Parameters**

* `ply` (`Player`): Player that created the marker.

* `pos` (`Vector`): World position for the marker.

* `players` (`table|nil`): Players that received the marker.

* `time` (`number`): Expiration time.

* `color` (`Color`): Marker color.

* `icon` (`string`): Icon material.

* `name` (`string`): Marker label.

* `id` (`number`): Unique marker identifier.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CompassMarkerAdded", "TrackMarkerIDs", function(_, _, _, _, _, _, _, id)
    print("Marker id " .. id .. " created")
end)
```

---

### `PreCompassEntityMarkerAdded`

**Purpose**

Runs before a marker attached to an entity is added.

**Parameters**

* `ply` (`Player`): Player that created the marker.

* `ent` (`Entity`): Entity to track.

* `players` (`table|nil`): Players that should see the marker.

* `time` (`number`): Expiration time.

* `color` (`Color`): Marker color.

* `icon` (`string`): Icon material.

* `name` (`string`): Marker label.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("PreCompassEntityMarkerAdded", "ValidateMarker", function(ply, ent)
    if not ent:IsNPC() then return false end
end)
```

---

### `CompassEntityMarkerAdded`

**Purpose**

Called after an entity marker has been added.

**Parameters**

* `ply` (`Player`): Player that created the marker.

* `ent` (`Entity`): Entity being tracked.

* `players` (`table|nil`): Players that received the marker.

* `time` (`number`): Expiration time.

* `color` (`Color`): Marker color.

* `icon` (`string`): Icon material.

* `name` (`string`): Marker label.

* `id` (`number`): Unique marker identifier.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CompassEntityMarkerAdded", "NotifyMarker", function(ply, ent)
    print("Marker added for entity " .. tostring(ent))
end)
```

---

### `CompassMarkerRemoved`

**Purpose**

Fires when a marker is removed from the compass.

**Parameters**

* `id` (`number`): Identifier of the removed marker.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CompassMarkerRemoved", "MarkerRemoved", function(id)
    print("Marker " .. id .. " removed")
end)
```

---

### `CompassSpotCommand`

**Purpose**

Triggered when a player uses the `mcompass_spot` console command.

**Parameters**

* `ply` (`Player`): Player who ran the command.

* `tr` (`TraceResult`): Trace result used to determine the spot location.

**Realm**

`Server`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CompassSpotCommand", "HandleSpot", function(ply, tr)
    print(ply:Nick() .. " spotted at " .. tostring(tr.HitPos))
end)
```

---

