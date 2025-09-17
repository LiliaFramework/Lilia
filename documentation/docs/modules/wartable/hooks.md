# Hooks

This document describes the hooks available in the War Table module for managing interactive war table functionality.

---

## PostWarTableClear

**Purpose**

Called after a war table has been cleared.

**Parameters**

* `client` (*Player*): The player who cleared the table.
* `tableEnt` (*Entity*): The war table entity that was cleared.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A war table has been successfully cleared
- After `WarTableCleared` hook
- After the clear operation is complete

**Example Usage**

```lua
-- Track war table clear completion
hook.Add("PostWarTableClear", "TrackWarTableClear", function(client, tableEnt)
    local char = client:getChar()
    if char then
        local tableClears = char:getData("war_table_clears", 0)
        char:setData("war_table_clears", tableClears + 1)
    end
    lia.log.add(client, "warTableCleared", tableEnt:GetPos())
end)

-- Apply clear effects
hook.Add("PostWarTableClear", "WarTableClearEffects", function(client, tableEnt)
    client:EmitSound("buttons/button14.wav", 75, 100)
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.5, 0)
    client:notify("War table cleared!")
end)
```

---

## PostWarTableMapChange

**Purpose**

Called after a war table map has been changed.

**Parameters**

* `client` (*Player*): The player who changed the map.
* `tableEnt` (*Entity*): The war table entity.
* `text` (*string*): The new map URL or path.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A war table map has been successfully changed
- After `WarTableMapChanged` hook
- After the map change is broadcast

**Example Usage**

```lua
-- Track war table map changes
hook.Add("PostWarTableMapChange", "TrackWarTableMapChange", function(client, tableEnt, text)
    local char = client:getChar()
    if char then
        local mapChanges = char:getData("war_table_map_changes", 0)
        char:setData("war_table_map_changes", mapChanges + 1)
    end
    lia.log.add(client, "warTableMapChanged", text)
end)

-- Apply map change effects
hook.Add("PostWarTableMapChange", "WarTableMapChangeEffects", function(client, tableEnt, text)
    client:EmitSound("buttons/button15.wav", 75, 100)
    client:ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 10), 0.5, 0)
    client:notify("War table map changed!")
end)
```

---

## PostWarTableMarkerPlace

**Purpose**

Called after a marker has been placed on the war table.

**Parameters**

* `client` (*Player*): The player who placed the marker.
* `marker` (*Entity*): The marker entity that was placed.
* `tableEnt` (*Entity*): The war table entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A marker has been successfully placed on the war table
- After `WarTableMarkerPlaced` hook
- After the marker is created and configured

**Example Usage**

```lua
-- Track war table marker placement
hook.Add("PostWarTableMarkerPlace", "TrackWarTableMarkerPlace", function(client, marker, tableEnt)
    local char = client:getChar()
    if char then
        local markersPlaced = char:getData("war_table_markers_placed", 0)
        char:setData("war_table_markers_placed", markersPlaced + 1)
    end
    lia.log.add(client, "warTableMarkerPlaced", marker:GetPos())
end)

-- Apply marker placement effects
hook.Add("PostWarTableMarkerPlace", "WarTableMarkerPlaceEffects", function(client, marker, tableEnt)
    client:EmitSound("buttons/button16.wav", 75, 100)
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.5, 0)
    client:notify("Marker placed on war table!")
end)
```

---

## PostWarTableMarkerRemove

**Purpose**

Called after a marker has been removed from the war table.

**Parameters**

* `client` (*Player*): The player who removed the marker.
* `ent` (*Entity*): The marker entity that was removed.
* `tableEnt` (*Entity*): The war table entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A marker has been successfully removed from the war table
- After `WarTableMarkerRemoved` hook
- After the marker is destroyed

**Example Usage**

```lua
-- Track war table marker removal
hook.Add("PostWarTableMarkerRemove", "TrackWarTableMarkerRemove", function(client, ent, tableEnt)
    local char = client:getChar()
    if char then
        local markersRemoved = char:getData("war_table_markers_removed", 0)
        char:setData("war_table_markers_removed", markersRemoved + 1)
    end
    lia.log.add(client, "warTableMarkerRemoved", ent:GetPos())
end)

-- Apply marker removal effects
hook.Add("PostWarTableMarkerRemove", "WarTableMarkerRemoveEffects", function(client, ent, tableEnt)
    client:EmitSound("buttons/button17.wav", 75, 100)
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 10), 0.5, 0)
    client:notify("Marker removed from war table!")
end)
```

---

## PostWarTableUsed

**Purpose**

Called after a war table has been used.

**Parameters**

* `activator` (*Player*): The player who used the war table.
* `tableEnt` (*Entity*): The war table entity that was used.
* `isSprinting` (*boolean*): Whether the player was sprinting when using the table.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A war table has been successfully used
- After `WarTableUsed` hook
- After the use operation is complete

**Example Usage**

```lua
-- Track war table usage
hook.Add("PostWarTableUsed", "TrackWarTableUsed", function(activator, tableEnt, isSprinting)
    local char = activator:getChar()
    if char then
        local tableUses = char:getData("war_table_uses", 0)
        char:setData("war_table_uses", tableUses + 1)
    end
    lia.log.add(activator, "warTableUsed", tableEnt:GetPos())
end)

-- Apply usage effects
hook.Add("PostWarTableUsed", "WarTableUsedEffects", function(activator, tableEnt, isSprinting)
    activator:EmitSound("buttons/button18.wav", 75, 100)
    activator:ScreenFade(SCREENFADE.IN, Color(255, 0, 255, 10), 0.5, 0)
    activator:notify("War table used!")
end)
```

---

## PreWarTableClear

**Purpose**

Called before a war table is cleared.

**Parameters**

* `client` (*Player*): The player who is clearing the table.
* `tableEnt` (*Entity*): The war table entity that will be cleared.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A war table is about to be cleared
- Before the clear operation begins
- Before `WarTableCleared` hook

**Example Usage**

```lua
-- Validate war table clear
hook.Add("PreWarTableClear", "ValidateWarTableClear", function(client, tableEnt)
    local char = client:getChar()
    if char then
        if char:getData("war_table_clear_disabled", false) then
            client:notify("War table clearing is disabled!")
            return false
        end
    end
end)

-- Track clear attempts
hook.Add("PreWarTableClear", "TrackWarTableClearAttempts", function(client, tableEnt)
    local char = client:getChar()
    if char then
        local clearAttempts = char:getData("war_table_clear_attempts", 0)
        char:setData("war_table_clear_attempts", clearAttempts + 1)
    end
end)
```

---

## PreWarTableMapChange

**Purpose**

Called before a war table map is changed.

**Parameters**

* `client` (*Player*): The player who is changing the map.
* `tableEnt` (*Entity*): The war table entity.
* `text` (*string*): The new map URL or path.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A war table map is about to be changed
- Before the map change operation begins
- Before `WarTableMapChanged` hook

**Example Usage**

```lua
-- Validate war table map change
hook.Add("PreWarTableMapChange", "ValidateWarTableMapChange", function(client, tableEnt, text)
    local char = client:getChar()
    if char then
        if char:getData("war_table_map_change_disabled", false) then
            client:notify("War table map changes are disabled!")
            return false
        end
    end
end)

-- Track map change attempts
hook.Add("PreWarTableMapChange", "TrackWarTableMapChangeAttempts", function(client, tableEnt, text)
    local char = client:getChar()
    if char then
        local mapChangeAttempts = char:getData("war_table_map_change_attempts", 0)
        char:setData("war_table_map_change_attempts", mapChangeAttempts + 1)
    end
end)
```

---

## PreWarTableMarkerPlace

**Purpose**

Called before a marker is placed on the war table.

**Parameters**

* `client` (*Player*): The player who is placing the marker.
* `pos` (*Vector*): The position where the marker will be placed.
* `bodygroups` (*table*): The bodygroup configuration for the marker.
* `tableEnt` (*Entity*): The war table entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A marker is about to be placed on the war table
- Before the marker creation begins
- Before `WarTableMarkerPlaced` hook

**Example Usage**

```lua
-- Validate war table marker placement
hook.Add("PreWarTableMarkerPlace", "ValidateWarTableMarkerPlace", function(client, pos, bodygroups, tableEnt)
    local char = client:getChar()
    if char then
        if char:getData("war_table_marker_placement_disabled", false) then
            client:notify("War table marker placement is disabled!")
            return false
        end
    end
end)

-- Track marker placement attempts
hook.Add("PreWarTableMarkerPlace", "TrackWarTableMarkerPlaceAttempts", function(client, pos, bodygroups, tableEnt)
    local char = client:getChar()
    if char then
        local markerPlaceAttempts = char:getData("war_table_marker_place_attempts", 0)
        char:setData("war_table_marker_place_attempts", markerPlaceAttempts + 1)
    end
end)
```

---

## PreWarTableMarkerRemove

**Purpose**

Called before a marker is removed from the war table.

**Parameters**

* `client` (*Player*): The player who is removing the marker.
* `ent` (*Entity*): The marker entity that will be removed.
* `tableEnt` (*Entity*): The war table entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A marker is about to be removed from the war table
- Before the marker destruction begins
- Before `WarTableMarkerRemoved` hook

**Example Usage**

```lua
-- Validate war table marker removal
hook.Add("PreWarTableMarkerRemove", "ValidateWarTableMarkerRemove", function(client, ent, tableEnt)
    local char = client:getChar()
    if char then
        if char:getData("war_table_marker_removal_disabled", false) then
            client:notify("War table marker removal is disabled!")
            return false
        end
    end
end)

-- Track marker removal attempts
hook.Add("PreWarTableMarkerRemove", "TrackWarTableMarkerRemoveAttempts", function(client, ent, tableEnt)
    local char = client:getChar()
    if char then
        local markerRemoveAttempts = char:getData("war_table_marker_remove_attempts", 0)
        char:setData("war_table_marker_remove_attempts", markerRemoveAttempts + 1)
    end
end)
```

---

## PreWarTableUsed

**Purpose**

Called before a war table is used.

**Parameters**

* `activator` (*Player*): The player who is using the war table.
* `tableEnt` (*Entity*): The war table entity that will be used.
* `isSprinting` (*boolean*): Whether the player is sprinting.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A war table is about to be used
- Before the use operation begins
- Before `WarTableUsed` hook

**Example Usage**

```lua
-- Validate war table usage
hook.Add("PreWarTableUsed", "ValidateWarTableUsed", function(activator, tableEnt, isSprinting)
    local char = activator:getChar()
    if char then
        if char:getData("war_table_usage_disabled", false) then
            activator:notify("War table usage is disabled!")
            return false
        end
    end
end)

-- Track usage attempts
hook.Add("PreWarTableUsed", "TrackWarTableUsedAttempts", function(activator, tableEnt, isSprinting)
    local char = activator:getChar()
    if char then
        local usageAttempts = char:getData("war_table_usage_attempts", 0)
        char:setData("war_table_usage_attempts", usageAttempts + 1)
    end
end)
```

---

## WarTableCleared

**Purpose**

Called when a war table has been cleared.

**Parameters**

* `client` (*Player*): The player who cleared the table.
* `tableEnt` (*Entity*): The war table entity that was cleared.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A war table has been cleared
- After `PreWarTableClear` hook
- Before `PostWarTableClear` hook

**Example Usage**

```lua
-- Track war table clear
hook.Add("WarTableCleared", "TrackWarTableCleared", function(client, tableEnt)
    local char = client:getChar()
    if char then
        local tableClears = char:getData("war_table_clears", 0)
        char:setData("war_table_clears", tableClears + 1)
    end
    lia.log.add(client, "warTableCleared", tableEnt:GetPos())
end)

-- Apply clear effects
hook.Add("WarTableCleared", "WarTableClearedEffects", function(client, tableEnt)
    client:EmitSound("buttons/button14.wav", 75, 100)
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.5, 0)
    client:notify("War table cleared!")
end)
```

---

## WarTableMapChanged

**Purpose**

Called when a war table map has been changed.

**Parameters**

* `client` (*Player*): The player who changed the map.
* `tableEnt` (*Entity*): The war table entity.
* `text` (*string*): The new map URL or path.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A war table map has been changed
- After `PreWarTableMapChange` hook
- Before `PostWarTableMapChange` hook

**Example Usage**

```lua
-- Track war table map change
hook.Add("WarTableMapChanged", "TrackWarTableMapChanged", function(client, tableEnt, text)
    local char = client:getChar()
    if char then
        local mapChanges = char:getData("war_table_map_changes", 0)
        char:setData("war_table_map_changes", mapChanges + 1)
    end
    lia.log.add(client, "warTableMapChanged", text)
end)

-- Apply map change effects
hook.Add("WarTableMapChanged", "WarTableMapChangedEffects", function(client, tableEnt, text)
    client:EmitSound("buttons/button15.wav", 75, 100)
    client:ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 10), 0.5, 0)
    client:notify("War table map changed!")
end)
```

---

## WarTableMarkerPlaced

**Purpose**

Called when a marker has been placed on the war table.

**Parameters**

* `client` (*Player*): The player who placed the marker.
* `marker` (*Entity*): The marker entity that was placed.
* `tableEnt` (*Entity*): The war table entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A marker has been placed on the war table
- After `PreWarTableMarkerPlace` hook
- Before `PostWarTableMarkerPlace` hook

**Example Usage**

```lua
-- Track war table marker placement
hook.Add("WarTableMarkerPlaced", "TrackWarTableMarkerPlaced", function(client, marker, tableEnt)
    local char = client:getChar()
    if char then
        local markersPlaced = char:getData("war_table_markers_placed", 0)
        char:setData("war_table_markers_placed", markersPlaced + 1)
    end
    lia.log.add(client, "warTableMarkerPlaced", marker:GetPos())
end)

-- Apply marker placement effects
hook.Add("WarTableMarkerPlaced", "WarTableMarkerPlacedEffects", function(client, marker, tableEnt)
    client:EmitSound("buttons/button16.wav", 75, 100)
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.5, 0)
    client:notify("Marker placed on war table!")
end)
```

---

## WarTableMarkerRemoved

**Purpose**

Called when a marker has been removed from the war table.

**Parameters**

* `client` (*Player*): The player who removed the marker.
* `ent` (*Entity*): The marker entity that was removed.
* `tableEnt` (*Entity*): The war table entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A marker has been removed from the war table
- After `PreWarTableMarkerRemove` hook
- Before `PostWarTableMarkerRemove` hook

**Example Usage**

```lua
-- Track war table marker removal
hook.Add("WarTableMarkerRemoved", "TrackWarTableMarkerRemoved", function(client, ent, tableEnt)
    local char = client:getChar()
    if char then
        local markersRemoved = char:getData("war_table_markers_removed", 0)
        char:setData("war_table_markers_removed", markersRemoved + 1)
    end
    lia.log.add(client, "warTableMarkerRemoved", ent:GetPos())
end)

-- Apply marker removal effects
hook.Add("WarTableMarkerRemoved", "WarTableMarkerRemovedEffects", function(client, ent, tableEnt)
    client:EmitSound("buttons/button17.wav", 75, 100)
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 10), 0.5, 0)
    client:notify("Marker removed from war table!")
end)
```

---

## WarTableUsed

**Purpose**

Called when a war table has been used.

**Parameters**

* `activator` (*Player*): The player who used the war table.
* `tableEnt` (*Entity*): The war table entity that was used.
* `isSprinting` (*boolean*): Whether the player was sprinting.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A war table has been used
- After `PreWarTableUsed` hook
- Before `PostWarTableUsed` hook

**Example Usage**

```lua
-- Track war table usage
hook.Add("WarTableUsed", "TrackWarTableUsed", function(activator, tableEnt, isSprinting)
    local char = activator:getChar()
    if char then
        local tableUses = char:getData("war_table_uses", 0)
        char:setData("war_table_uses", tableUses + 1)
    end
    lia.log.add(activator, "warTableUsed", tableEnt:GetPos())
end)

-- Apply usage effects
hook.Add("WarTableUsed", "WarTableUsedEffects", function(activator, tableEnt, isSprinting)
    activator:EmitSound("buttons/button18.wav", 75, 100)
    activator:ScreenFade(SCREENFADE.IN, Color(255, 0, 255, 10), 0.5, 0)
    activator:notify("War table used!")
end)
```
