# Captions Module Libraries

This document describes the library functions available in the Captions module for managing on-screen captions.

---

## lia.caption.start

**Purpose**

Starts displaying a caption on screen for a player.

**Parameters**

* `client` (*Player*): The player to display the caption to (Server only).
* `text` (*string*): The text content to display in the caption.
* `duration` (*number*): The duration in seconds to display the caption.

**Realm**

Server and Client.

**Returns**

*None*

**When to Use**

Use this function when you want to display a caption to a player. On the server, you can specify which player receives the caption. On the client, it displays the caption to the local player.

**Example Usage**

```lua
-- Server-side usage
if SERVER then
    -- Send caption to specific player
    lia.caption.start(client, "Welcome to the server!", 5)
    
    -- Send caption to all players
    for _, ply in player.Iterator() do
        lia.caption.start(ply, "Server announcement!", 10)
    end
end

-- Client-side usage
if CLIENT then
    -- Display caption to local player
    lia.caption.start("This is a local caption", 3)
    
    -- Display caption with custom duration
    lia.caption.start("Custom duration caption", 7.5)
end

-- Advanced usage with character data
local char = client:getChar()
if char then
    local captionText = "Character: " .. char:getName()
    lia.caption.start(client, captionText, 5)
end

-- Conditional caption display
if client:getData("admin_status", false) then
    lia.caption.start(client, "Admin caption", 5)
else
    lia.caption.start(client, "Regular player caption", 5)
end
```

**Notes**

- On the server, the function sends a network message to the client to display the caption.
- On the client, the function directly calls the game's caption system.
- The duration is automatically calculated if not provided (text length * 0.1 seconds).
- Captions will automatically clear when a new caption is started.

---

## lia.caption.finish

**Purpose**

Finishes/clears the currently displayed caption.

**Parameters**

* `client` (*Player*): The player whose caption should be finished (Server only).

**Realm**

Server and Client.

**Returns**

*None*

**When to Use**

Use this function when you want to immediately clear a caption before its duration expires, or when you need to ensure no caption is displayed.

**Example Usage**

```lua
-- Server-side usage
if SERVER then
    -- Finish caption for specific player
    lia.caption.finish(client)
    
    -- Finish captions for all players
    for _, ply in player.Iterator() do
        lia.caption.finish(ply)
    end
end

-- Client-side usage
if CLIENT then
    -- Finish caption for local player
    lia.caption.finish()
end

-- Advanced usage with conditions
local char = client:getChar()
if char then
    -- Finish caption if player is in a specific area
    if char:getData("in_caption_restricted_area", false) then
        lia.caption.finish(client)
    end
end

-- Finish caption after a delay
timer.Simple(3, function()
    lia.caption.finish(client)
end)

-- Finish caption when player moves
hook.Add("PlayerMove", "FinishCaptionOnMove", function(client, mv)
    if client:GetVelocity():Length() > 100 then
        lia.caption.finish(client)
    end
end)
```

**Notes**

- On the server, the function sends a network message to the client to clear the caption.
- On the client, the function directly calls the game's caption system to clear the caption.
- This function is useful for clearing captions when certain conditions are met.
- It's safe to call this function even if no caption is currently displayed.

---

## Usage Examples

### Complete Caption System

```lua
-- Server-side caption management
local function sendCaptionToPlayer(client, text, duration)
    if not IsValid(client) then return end
    
    -- Start the caption
    lia.caption.start(client, text, duration)
    
    -- Set up automatic finish
    timer.Simple(duration, function()
        if IsValid(client) then
            lia.caption.finish(client)
        end
    end)
end

-- Client-side caption management
local function displayLocalCaption(text, duration)
    -- Start the caption
    lia.caption.start(text, duration)
    
    -- Set up automatic finish
    timer.Simple(duration, function()
        lia.caption.finish()
    end)
end
```

### Caption with Custom Effects

```lua
-- Server-side with effects
local function sendCaptionWithEffects(client, text, duration)
    lia.caption.start(client, text, duration)
    
    -- Play sound effect
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Notify player
    client:notify("Caption displayed: " .. text)
end

-- Client-side with effects
local function displayCaptionWithEffects(text, duration)
    lia.caption.start(text, duration)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 20), 0.5, 0)
end
```

### Caption Management System

```lua
-- Track active captions
local activeCaptions = {}

-- Start caption with tracking
local function startTrackedCaption(client, text, duration)
    if SERVER then
        lia.caption.start(client, text, duration)
        activeCaptions[client] = {
            text = text,
            startTime = CurTime(),
            duration = duration
        }
    end
end

-- Finish caption with tracking
local function finishTrackedCaption(client)
    if SERVER then
        lia.caption.finish(client)
        activeCaptions[client] = nil
    end
end

-- Check if player has active caption
local function hasActiveCaption(client)
    return activeCaptions[client] ~= nil
end
```
