# Hooks

This document describes the hooks available in the Compass module for managing compass markers and spotting functionality.

---

## CompassEntityMarkerAdded

**Purpose**

Called when an entity marker is added to the compass.

**Parameters**

* `player` (*Player*): The player who added the marker.
* `entity` (*Entity*): The entity being marked.
* `players` (*table*): Array of players who will see the marker.
* `time` (*number*): The duration the marker will be visible.
* `color` (*Color*): The color of the marker.
* `icon` (*string*): The icon material path for the marker.
* `name` (*string*): The name/label for the marker.
* `id` (*number*): The unique ID of the marker.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An entity marker is successfully added to the compass
- After the marker is sent to all target players
- After `PreCompassEntityMarkerAdded` hook

**Example Usage**

```lua
-- Track entity marker usage
hook.Add("CompassEntityMarkerAdded", "TrackEntityMarkers", function(player, entity, players, time, color, icon, name, id)
    local char = player:getChar()
    if char then
        local entityMarkers = char:getData("entity_markers_added", 0)
        char:setData("entity_markers_added", entityMarkers + 1)
        
        -- Track specific entity types
        local entityType = entity:GetClass()
        local entityCounts = char:getData("entity_marker_types", {})
        entityCounts[entityType] = (entityCounts[entityType] or 0) + 1
        char:setData("entity_marker_types", entityCounts)
    end
    
    lia.log.add(player, "entityMarkerAdded", entity:GetClass(), name)
end)

-- Apply entity marker effects
hook.Add("CompassEntityMarkerAdded", "EntityMarkerEffects", function(player, entity, players, time, color, icon, name, id)
    -- Notify players about the marker
    for _, ply in ipairs(players or {}) do
        if IsValid(ply) then
            ply:notify(player:Name() .. " marked " .. (name or entity:GetClass()) .. " on the compass!")
        end
    end
    
    -- Play sound effect
    player:EmitSound("buttons/button14.wav", 75, 100)
end)

-- Track marker statistics
hook.Add("CompassEntityMarkerAdded", "TrackMarkerStats", function(player, entity, players, time, color, icon, name, id)
    -- Track marker duration
    local avgDuration = player:getData("avg_marker_duration", 0)
    local totalMarkers = player:getData("total_markers", 0)
    local newAvg = (avgDuration * totalMarkers + time) / (totalMarkers + 1)
    player:setData("avg_marker_duration", newAvg)
    player:setData("total_markers", totalMarkers + 1)
end)
```

---

## CompassMarkerAdded

**Purpose**

Called when a position marker is added to the compass.

**Parameters**

* `player` (*Player*): The player who added the marker.
* `position` (*Vector*): The position being marked.
* `players` (*table*): Array of players who will see the marker.
* `time` (*number*): The duration the marker will be visible.
* `color` (*Color*): The color of the marker.
* `icon` (*string*): The icon material path for the marker.
* `name` (*string*): The name/label for the marker.
* `id` (*number*): The unique ID of the marker.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A position marker is successfully added to the compass
- After the marker is sent to all target players
- After `PreCompassMarkerAdded` hook

**Example Usage**

```lua
-- Track position marker usage
hook.Add("CompassMarkerAdded", "TrackPositionMarkers", function(player, position, players, time, color, icon, name, id)
    local char = player:getChar()
    if char then
        local positionMarkers = char:getData("position_markers_added", 0)
        char:setData("position_markers_added", positionMarkers + 1)
        
        -- Track marker locations
        local markerLocations = char:getData("marker_locations", {})
        table.insert(markerLocations, {
            pos = position,
            time = os.time(),
            name = name
        })
        char:setData("marker_locations", markerLocations)
    end
    
    lia.log.add(player, "positionMarkerAdded", position, name)
end)

-- Apply position marker effects
hook.Add("CompassMarkerAdded", "PositionMarkerEffects", function(player, position, players, time, color, icon, name, id)
    -- Notify players about the marker
    for _, ply in ipairs(players or {}) do
        if IsValid(ply) then
            ply:notify(player:Name() .. " marked " .. (name or "a location") .. " on the compass!")
        end
    end
    
    -- Play sound effect
    player:EmitSound("buttons/button15.wav", 75, 100)
    
    -- Create particle effect at marked location
    local effect = EffectData()
    effect:SetOrigin(position)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track marker patterns
hook.Add("CompassMarkerAdded", "TrackMarkerPatterns", function(player, position, players, time, color, icon, name, id)
    local char = player:getChar()
    if char then
        -- Track marker frequency
        local lastMarker = char:getData("last_marker_time", 0)
        local markerFrequency = char:getData("marker_frequency", 0)
        
        if os.time() - lastMarker < 60 then
            markerFrequency = markerFrequency + 1
        else
            markerFrequency = 1
        end
        
        char:setData("marker_frequency", markerFrequency)
        char:setData("last_marker_time", os.time())
        
        -- Flag for spam if too many markers
        if markerFrequency > 10 then
            char:setData("marker_spam_warning", true)
            player:notify("Please don't spam compass markers!")
        end
    end
end)
```

---

## CompassMarkerRemoved

**Purpose**

Called when a compass marker is removed.

**Parameters**

* `markerID` (*number*): The unique ID of the marker being removed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A marker is removed from the compass
- After the removal is broadcast to all players

**Example Usage**

```lua
-- Track marker removal
hook.Add("CompassMarkerRemoved", "TrackMarkerRemoval", function(markerID)
    lia.log.add(nil, "markerRemoved", markerID)
    
    -- Notify all players
    for _, ply in player.Iterator() do
        ply:notify("Compass marker " .. markerID .. " has been removed!")
    end
end)

-- Clean up marker data
hook.Add("CompassMarkerRemoved", "CleanupMarkerData", function(markerID)
    -- Remove marker from any tracking systems
    for _, ply in player.Iterator() do
        local char = ply:getChar()
        if char then
            local markerLocations = char:getData("marker_locations", {})
            for i = #markerLocations, 1, -1 do
                if markerLocations[i].id == markerID then
                    table.remove(markerLocations, i)
                end
            end
            char:setData("marker_locations", markerLocations)
        end
    end
end)

-- Apply removal effects
hook.Add("CompassMarkerRemoved", "MarkerRemovalEffects", function(markerID)
    -- Play removal sound
    for _, ply in player.Iterator() do
        ply:EmitSound("buttons/button16.wav", 75, 100)
    end
end)
```

---

## CompassSpotCommand

**Purpose**

Called when the compass spot command is executed.

**Parameters**

* `player` (*Player*): The player who executed the spot command.
* `trace` (*table*): The trace result from the spot command.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The `mcompass_spot` console command is executed
- Before the marker is added to the compass

**Example Usage**

```lua
-- Track spot command usage
hook.Add("CompassSpotCommand", "TrackSpotUsage", function(player, trace)
    local char = player:getChar()
    if char then
        local spotCommands = char:getData("spot_commands_used", 0)
        char:setData("spot_commands_used", spotCommands + 1)
        
        -- Track what was spotted
        if trace.Entity and IsValid(trace.Entity) then
            local entityType = trace.Entity:GetClass()
            local entitySpots = char:getData("entity_spots", {})
            entitySpots[entityType] = (entitySpots[entityType] or 0) + 1
            char:setData("entity_spots", entitySpots)
        else
            local locationSpots = char:getData("location_spots", 0)
            char:setData("location_spots", locationSpots + 1)
        end
    end
    
    lia.log.add(player, "compassSpotCommand", trace.HitPos)
end)

-- Apply spot restrictions
hook.Add("CompassSpotCommand", "ApplySpotRestrictions", function(player, trace)
    local char = player:getChar()
    if char then
        -- Check cooldown
        local lastSpot = char:getData("last_spot_time", 0)
        if os.time() - lastSpot < 5 then -- 5 second cooldown
            player:notify("Please wait before spotting again!")
            return false
        end
        
        -- Check spot limit
        local spotsToday = char:getData("spots_today", 0)
        if spotsToday >= 50 then
            player:notify("Daily spot limit reached!")
            return false
        end
        
        -- Update counters
        char:setData("last_spot_time", os.time())
        char:setData("spots_today", spotsToday + 1)
    end
end)

-- Apply spot effects
hook.Add("CompassSpotCommand", "SpotCommandEffects", function(player, trace)
    -- Play spot sound
    player:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.5, 0)
    
    -- Notify player
    if trace.Entity and IsValid(trace.Entity) then
        player:notify("Spotted " .. trace.Entity:GetClass() .. " on compass!")
    else
        player:notify("Spotted location on compass!")
    end
end)
```

---

## mCompass_loadFonts

**Purpose**

Called when compass fonts need to be loaded or reloaded.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Compass settings are updated
- Fonts need to be regenerated
- The compass style changes

**Example Usage**

```lua
-- Add custom fonts to compass
hook.Add("mCompass_loadFonts", "AddCustomFonts", function()
    -- Create custom compass font
    surface.CreateFont("CustomCompassFont", {
        font = "Arial",
        size = 24,
        antialias = true,
        weight = 800
    })
    
    -- Create custom marker font
    surface.CreateFont("CustomMarkerFont", {
        font = "Arial",
        size = 18,
        antialias = true,
        weight = 600
    })
end)

-- Track font loading
hook.Add("mCompass_loadFonts", "TrackFontLoading", function()
    print("Compass fonts loaded/reloded")
end)

-- Apply custom font styling
hook.Add("mCompass_loadFonts", "CustomFontStyling", function()
    -- Override default font behavior
    local originalCreateFont = surface.CreateFont
    surface.CreateFont = function(name, data)
        if string.find(name, "exo_compass") then
            data.weight = data.weight or 800
            data.antialias = true
            data.outline = true
        end
        return originalCreateFont(name, data)
    end
end)
```

---

## PopulateToolMenu

**Purpose**

Called when the tool menu is being populated (for compass settings).

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The spawn menu is opened
- The tool menu is being populated
- Compass settings need to be added to the menu

**Example Usage**

```lua
-- Add custom compass settings to tool menu
hook.Add("PopulateToolMenu", "CustomCompassSettings", function()
    spawnmenu.AddToolMenuOption("Options", "mCompass", "CustomSettings", "Custom Settings", "", "", function(panel)
        panel:ClearControls()
        
        -- Add custom settings
        local customLabel = vgui.Create("DLabel", panel)
        customLabel:SetText("Custom Compass Settings")
        customLabel:SetTextColor(Color(50, 50, 50))
        customLabel:Dock(TOP)
        panel:AddItem(customLabel)
        
        -- Add custom checkbox
        local customCheckbox = vgui.Create("DCheckBoxLabel", panel)
        customCheckbox:SetText("Enable Custom Effects")
        customCheckbox:SetTextColor(Color(50, 50, 50))
        customCheckbox:SetValue(false)
        customCheckbox:Dock(TOP)
        panel:AddItem(customCheckbox)
    end)
end)

-- Track tool menu usage
hook.Add("PopulateToolMenu", "TrackToolMenuUsage", function()
    local char = LocalPlayer():getChar()
    if char then
        local toolMenuUses = char:getData("tool_menu_uses", 0)
        char:setData("tool_menu_uses", toolMenuUses + 1)
    end
end)
```

---

## PreCompassEntityMarkerAdded

**Purpose**

Called before an entity marker is added to the compass.

**Parameters**

* `player` (*Player*): The player who is adding the marker.
* `entity` (*Entity*): The entity being marked.
* `players` (*table*): Array of players who will see the marker.
* `time` (*number*): The duration the marker will be visible.
* `color` (*Color*): The color of the marker.
* `icon` (*string*): The icon material path for the marker.
* `name` (*string*): The name/label for the marker.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An entity marker is about to be added
- Before any validation or processing
- Before `CompassEntityMarkerAdded` hook

**Example Usage**

```lua
-- Validate entity marker addition
hook.Add("PreCompassEntityMarkerAdded", "ValidateEntityMarker", function(player, entity, players, time, color, icon, name)
    -- Check if entity is valid
    if not IsValid(entity) then
        player:notify("Invalid entity for marking!")
        return false
    end
    
    -- Check if entity can be marked
    if entity:GetClass() == "prop_physics" and entity:GetPhysicsObject():IsAsleep() then
        player:notify("Cannot mark sleeping physics objects!")
        return false
    end
    
    -- Check marker limits
    local char = player:getChar()
    if char then
        local activeMarkers = char:getData("active_markers", 0)
        if activeMarkers >= 10 then
            player:notify("Too many active markers! Remove some first.")
            return false
        end
    end
end)

-- Modify entity marker properties
hook.Add("PreCompassEntityMarkerAdded", "ModifyEntityMarker", function(player, entity, players, time, color, icon, name)
    -- Modify marker duration based on entity type
    if entity:GetClass() == "npc_*" then
        time = time * 1.5 -- NPCs stay marked longer
    elseif entity:GetClass() == "prop_*" then
        time = time * 0.5 -- Props stay marked shorter
    end
    
    -- Modify color based on entity type
    if entity:IsPlayer() then
        color = Color(255, 0, 0) -- Red for players
    elseif entity:IsNPC() then
        color = Color(255, 255, 0) -- Yellow for NPCs
    end
    
    -- Modify name based on entity
    if not name or name == "" then
        if entity:IsPlayer() then
            name = entity:Name()
        else
            name = entity:GetClass()
        end
    end
end)

-- Track entity marker attempts
hook.Add("PreCompassEntityMarkerAdded", "TrackEntityMarkerAttempts", function(player, entity, players, time, color, icon, name)
    lia.log.add(player, "entityMarkerAttempt", entity:GetClass(), name)
end)
```

---

## PreCompassMarkerAdded

**Purpose**

Called before a position marker is added to the compass.

**Parameters**

* `player` (*Player*): The player who is adding the marker.
* `position` (*Vector*): The position being marked.
* `players` (*table*): Array of players who will see the marker.
* `time` (*number*): The duration the marker will be visible.
* `color` (*Color*): The color of the marker.
* `icon` (*string*): The icon material path for the marker.
* `name` (*string*): The name/label for the marker.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A position marker is about to be added
- Before any validation or processing
- Before `CompassMarkerAdded` hook

**Example Usage**

```lua
-- Validate position marker addition
hook.Add("PreCompassMarkerAdded", "ValidatePositionMarker", function(player, position, players, time, color, icon, name)
    -- Check if position is valid
    if not position or position == Vector(0, 0, 0) then
        player:notify("Invalid position for marking!")
        return false
    end
    
    -- Check distance from player
    local distance = player:GetPos():Distance(position)
    if distance > 1000 then
        player:notify("Cannot mark locations that are too far away!")
        return false
    end
    
    -- Check marker limits
    local char = player:getChar()
    if char then
        local activeMarkers = char:getData("active_markers", 0)
        if activeMarkers >= 10 then
            player:notify("Too many active markers! Remove some first.")
            return false
        end
    end
end)

-- Modify position marker properties
hook.Add("PreCompassMarkerAdded", "ModifyPositionMarker", function(player, position, players, time, color, icon, name)
    -- Modify marker duration based on location
    local distance = player:GetPos():Distance(position)
    if distance > 500 then
        time = time * 1.2 -- Longer duration for distant markers
    end
    
    -- Modify color based on location type
    local trace = util.TraceLine({
        start = position,
        endpos = position + Vector(0, 0, -1000),
        filter = player
    })
    
    if trace.Hit and trace.HitWorld then
        color = Color(0, 255, 0) -- Green for ground markers
    else
        color = Color(0, 0, 255) -- Blue for air markers
    end
    
    -- Modify name based on location
    if not name or name == "" then
        name = "Location (" .. math.Round(distance) .. " units away)"
    end
end)

-- Track position marker attempts
hook.Add("PreCompassMarkerAdded", "TrackPositionMarkerAttempts", function(player, position, players, time, color, icon, name)
    lia.log.add(player, "positionMarkerAttempt", position, name)
end)
```
