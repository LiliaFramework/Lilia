# Hooks

This document describes the hooks available in the Cinematic Text module for managing cinematic splash text overlays and displays.

---

## CinematicDisplayEnded

**Purpose**

Called when a cinematic text display has finished and is being removed.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The cinematic text display timer expires
- The display fades out completely
- The splash text panel is removed

**Example Usage**

```lua
-- Clean up after cinematic display
hook.Add("CinematicDisplayEnded", "CleanupCinematicDisplay", function()
    -- Stop any background music
    if IsValid(cinematicMusic) then
        cinematicMusic:Stop()
    end
    
    -- Clear screen effects
    LocalPlayer():ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 0), 0.5, 0)
    
    -- Reset HUD elements
    if IsValid(cinematicHUD) then
        cinematicHUD:Remove()
    end
end)

-- Track display completion
hook.Add("CinematicDisplayEnded", "TrackDisplayCompletion", function()
    local char = LocalPlayer():getChar()
    if char then
        local displaysWatched = char:getData("cinematic_displays_watched", 0)
        char:setData("cinematic_displays_watched", displaysWatched + 1)
    end
end)

-- Notify when display ends
hook.Add("CinematicDisplayEnded", "NotifyDisplayEnd", function()
    LocalPlayer():notify("Cinematic display ended!")
end)
```

---

## CinematicDisplayStart

**Purpose**

Called when a cinematic text display starts showing.

**Parameters**

* `text` (*string*): The main text content (can be nil).
* `bigText` (*string*): The large text content (can be nil).
* `duration` (*number*): The duration in seconds the display will show.
* `blackBars` (*boolean*): Whether black bars should be drawn.
* `music` (*boolean*): Whether background music should play.
* `color` (*Color*): The color of the text.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A cinematic display is received from the server
- Before the splash text panel is created
- Before any visual effects are applied

**Example Usage**

```lua
-- Apply custom effects when display starts
hook.Add("CinematicDisplayStart", "CustomDisplayEffects", function(text, bigText, duration, blackBars, music, color)
    -- Apply screen darkening
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 50), 1, 0)
    
    -- Create custom HUD overlay
    local overlay = vgui.Create("DPanel")
    overlay:SetSize(ScrW(), ScrH())
    overlay:SetPos(0, 0)
    overlay.Paint = function(self, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
    end
    overlay:MakePopup()
    
    -- Store reference for cleanup
    cinematicHUD = overlay
end)

-- Track display statistics
hook.Add("CinematicDisplayStart", "TrackDisplayStats", function(text, bigText, duration, blackBars, music, color)
    local char = LocalPlayer():getChar()
    if char then
        local totalDuration = char:getData("total_cinematic_duration", 0)
        char:setData("total_cinematic_duration", totalDuration + duration)
        
        -- Track display preferences
        if blackBars then
            char:setData("black_bars_displays", char:getData("black_bars_displays", 0) + 1)
        end
        if music then
            char:setData("music_displays", char:getData("music_displays", 0) + 1)
        end
    end
end)

-- Apply custom music
hook.Add("CinematicDisplayStart", "CustomMusic", function(text, bigText, duration, blackBars, music, color)
    if music then
        -- Play custom music based on text content
        local musicFile = "music/stingers/industrial_suspense2.wav"
        
        if text and string.find(string.lower(text), "warning") then
            musicFile = "music/stingers/warning.wav"
        elseif text and string.find(string.lower(text), "victory") then
            musicFile = "music/stingers/victory.wav"
        end
        
        cinematicMusic = CreateSound(LocalPlayer(), musicFile)
        cinematicMusic:PlayEx(0, 100)
        cinematicMusic:ChangeVolume(1, 2)
    end
end)
```

---

## CinematicMenuOpened

**Purpose**

Called when the cinematic text menu is opened.

**Parameters**

* `client` (*Player*): The client who opened the menu.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The `cinematicmenu` command is executed
- Before the menu network message is sent to the client

**Example Usage**

```lua
-- Track menu usage
hook.Add("CinematicMenuOpened", "TrackMenuUsage", function(client)
    local char = client:getChar()
    if char then
        local menuUses = char:getData("cinematic_menu_uses", 0)
        char:setData("cinematic_menu_uses", menuUses + 1)
    end
    
    lia.log.add(client, "cinematicMenuOpened")
end)

-- Apply restrictions
hook.Add("CinematicMenuOpened", "ApplyMenuRestrictions", function(client)
    -- Check cooldown
    local lastUse = client:getData("last_cinematic_menu", 0)
    if os.time() - lastUse < 60 then -- 1 minute cooldown
        client:notify("Please wait before opening the cinematic menu again!")
        return false
    end
    
    -- Set last use time
    client:setData("last_cinematic_menu", os.time())
end)

-- Notify administrators
hook.Add("CinematicMenuOpened", "NotifyAdmins", function(client)
    for _, admin in player.Iterator() do
        if admin:IsAdmin() then
            admin:notify(client:Name() .. " opened the cinematic menu")
        end
    end
end)
```

---

## CinematicPanelCreated

**Purpose**

Called when the cinematic splash text panel is created.

**Parameters**

* `panel` (*Panel*): The cinematic splash text panel.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The splash text panel is created
- Before any visual effects are applied
- After `CinematicDisplayStart` hook

**Example Usage**

```lua
-- Customize the panel appearance
hook.Add("CinematicPanelCreated", "CustomizePanel", function(panel)
    -- Add custom styling
    panel:SetBackgroundColor(Color(0, 0, 0, 0))
    
    -- Add custom border
    panel.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    -- Store reference for later use
    currentCinematicPanel = panel
end)

-- Add custom effects to the panel
hook.Add("CinematicPanelCreated", "AddPanelEffects", function(panel)
    -- Add particle effect
    local effect = EffectData()
    effect:SetOrigin(panel:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Add sound effect
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
end)

-- Track panel creation
hook.Add("CinematicPanelCreated", "TrackPanelCreation", function(panel)
    local char = LocalPlayer():getChar()
    if char then
        local panelsCreated = char:getData("cinematic_panels_created", 0)
        char:setData("cinematic_panels_created", panelsCreated + 1)
    end
end)
```

---

## CinematicTriggered

**Purpose**

Called when a cinematic display is triggered by a player.

**Parameters**

* `client` (*Player*): The player who triggered the cinematic.
* `text` (*string*): The main text content.
* `bigText` (*string*): The large text content.
* `duration` (*number*): The duration in seconds.
* `blackBars` (*boolean*): Whether black bars should be drawn.
* `music` (*boolean*): Whether background music should play.
* `color` (*Color*): The color of the text.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player sends a cinematic display request
- Before the display is broadcast to all clients
- After permission checks pass

**Example Usage**

```lua
-- Log cinematic triggers
hook.Add("CinematicTriggered", "LogCinematicTriggers", function(client, text, bigText, duration, blackBars, music, color)
    lia.log.add(client, "cinematicTriggered", text, bigText, duration)
    
    -- Log to external system
    local data = {
        sender = client:SteamID(),
        sender_name = client:Name(),
        text = text,
        big_text = bigText,
        duration = duration,
        black_bars = blackBars,
        music = music,
        color = {r = color.r, g = color.g, b = color.b, a = color.a},
        timestamp = os.time()
    }
    
    http.Post("https://your-logging-service.com/cinematic-triggers", data, function(response)
        print("Cinematic trigger logged to external system")
    end)
end)

-- Track cinematic usage statistics
hook.Add("CinematicTriggered", "TrackCinematicStats", function(client, text, bigText, duration, blackBars, music, color)
    local char = client:getChar()
    if char then
        local triggers = char:getData("cinematic_triggers", 0)
        char:setData("cinematic_triggers", triggers + 1)
        
        -- Track total duration
        local totalDuration = char:getData("total_cinematic_duration_created", 0)
        char:setData("total_cinematic_duration_created", totalDuration + duration)
        
        -- Track preferences
        if blackBars then
            char:setData("black_bars_triggers", char:getData("black_bars_triggers", 0) + 1)
        end
        if music then
            char:setData("music_triggers", char:getData("music_triggers", 0) + 1)
        end
    end
end)

-- Apply content filtering
hook.Add("CinematicTriggered", "FilterCinematicContent", function(client, text, bigText, duration, blackBars, music, color)
    -- Check for inappropriate content
    local filteredWords = {"spam", "scam", "hack"}
    
    local fullText = (text or "") .. " " .. (bigText or "")
    for _, word in ipairs(filteredWords) do
        if string.find(string.lower(fullText), word) then
            client:notify("Your cinematic text contains inappropriate content!")
            return false
        end
    end
    
    -- Check duration limits
    if duration > 30 then
        client:notify("Cinematic duration too long! Maximum 30 seconds allowed.")
        return false
    end
    
    -- Check for empty content
    if not text and not bigText then
        client:notify("Cinematic text cannot be empty!")
        return false
    end
end)

-- Notify administrators of cinematic triggers
hook.Add("CinematicTriggered", "NotifyAdmins", function(client, text, bigText, duration, blackBars, music, color)
    for _, admin in player.Iterator() do
        if admin:IsAdmin() then
            local message = client:Name() .. " triggered cinematic: "
            if text then message = message .. text end
            if bigText then message = message .. " (Big: " .. bigText .. ")" end
            admin:notify(message)
        end
    end
end)

-- Award achievements
hook.Add("CinematicTriggered", "CinematicAchievements", function(client, text, bigText, duration, blackBars, music, color)
    local char = client:getChar()
    if char then
        local triggers = char:getData("cinematic_triggers", 0)
        
        if triggers == 1 then
            client:notify("Achievement: First Cinematic!")
        elseif triggers == 10 then
            client:notify("Achievement: Cinematic Director!")
        elseif triggers == 50 then
            client:notify("Achievement: Master of Drama!")
        end
    end
end)
```
