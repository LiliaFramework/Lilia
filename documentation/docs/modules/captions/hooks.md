# Hooks

This document describes the hooks available in the Captions module for managing on-screen captions.

---

## CaptionStarted

**Purpose**

Called when a caption is started for a player.

**Parameters**

* `client` (*Player*): The player receiving the caption (Server only).
* `text` (*string*): The text content of the caption.
* `duration` (*number*): The duration in seconds the caption will be displayed.

**Realm**

Server and Client.

**When Called**

This hook is triggered when:
- A caption is started via `lia.caption.start()`
- A caption command is executed
- A broadcast caption is sent

**Example Usage**

```lua
-- Track caption starts
hook.Add("CaptionStarted", "TrackCaptionStarts", function(client, text, duration)
    if SERVER then
        print("Caption started for", client:Name(), ":", text, "for", duration, "seconds")
        
        -- Log to server console
        local char = client:getChar()
        if char then
            local captionStarts = char:getData("caption_starts", 0)
            char:setData("caption_starts", captionStarts + 1)
        end
    else
        print("Caption started:", text, "for", duration, "seconds")
    end
end)

-- Apply custom effects when caption starts
hook.Add("CaptionStarted", "CaptionStartEffects", function(client, text, duration)
    if SERVER then
        -- Play sound effect for the player
        client:EmitSound("buttons/button14.wav", 75, 100)
        
        -- Notify the player
        client:notify("Caption started: " .. text)
    else
        -- Apply screen effect
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 20), 0.5, 0)
    end
end)

-- Modify caption content
hook.Add("CaptionStarted", "ModifyCaptionContent", function(client, text, duration)
    if SERVER then
        -- Add timestamp to caption
        local timestamp = os.date("%H:%M:%S")
        local modifiedText = "[" .. timestamp .. "] " .. text
        
        -- Send modified caption
        lia.caption.start(client, modifiedText, duration)
        return true -- Prevent original caption
    end
end)
```

---

## CaptionFinished

**Purpose**

Called when a caption finishes for a player.

**Parameters**

* `client` (*Player*): The player whose caption finished (Server only).

**Realm**

Server and Client.

**When Called**

This hook is triggered when:
- A caption duration expires
- A caption is manually finished via `lia.caption.finish()`
- A new caption replaces an existing one

**Example Usage**

```lua
-- Track caption finishes
hook.Add("CaptionFinished", "TrackCaptionFinishes", function(client)
    if SERVER then
        print("Caption finished for", client:Name())
        
        -- Log to server console
        local char = client:getChar()
        if char then
            local captionFinishes = char:getData("caption_finishes", 0)
            char:setData("caption_finishes", captionFinishes + 1)
        end
    else
        print("Caption finished")
    end
end)

-- Apply custom effects when caption finishes
hook.Add("CaptionFinished", "CaptionFinishEffects", function(client)
    if SERVER then
        -- Play sound effect for the player
        client:EmitSound("buttons/button15.wav", 75, 100)
        
        -- Notify the player
        client:notify("Caption finished")
    else
        -- Apply screen effect
        LocalPlayer():ScreenFade(SCREENFADE.OUT, Color(255, 0, 0, 20), 0.5, 0)
    end
end)

-- Clean up caption data
hook.Add("CaptionFinished", "CleanupCaptionData", function(client)
    if SERVER then
        local char = client:getChar()
        if char then
            -- Clear caption-related data
            char:setData("current_caption", nil)
            char:setData("caption_start_time", nil)
        end
    end
end)
```

---

## SendCaptionCommand

**Purpose**

Called when the sendCaption command is executed.

**Parameters**

* `client` (*Player*): The player who executed the command.
* `target` (*Player*): The target player who will receive the caption.
* `text` (*string*): The text content of the caption.
* `duration` (*number*): The duration in seconds the caption will be displayed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The `sendCaption` command is executed
- Before the caption is sent to the target player

**Example Usage**

```lua
-- Track sendCaption command usage
hook.Add("SendCaptionCommand", "TrackSendCaptionUsage", function(client, target, text, duration)
    print(client:Name(), "sent caption to", target:Name(), ":", text)
    
    -- Log to server console
    local char = client:getChar()
    if char then
        local sendCaptions = char:getData("send_captions", 0)
        char:setData("send_captions", sendCaptions + 1)
    end
end)

-- Apply custom effects for sendCaption command
hook.Add("SendCaptionCommand", "SendCaptionEffects", function(client, target, text, duration)
    -- Play sound effect for both players
    client:EmitSound("buttons/button14.wav", 75, 100)
    target:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Notify both players
    client:notify("Caption sent to " .. target:Name())
    target:notify("Caption received from " .. client:Name())
end)

-- Modify sendCaption behavior
hook.Add("SendCaptionCommand", "ModifySendCaptionBehavior", function(client, target, text, duration)
    -- Check if target is in range
    local distance = client:GetPos():Distance(target:GetPos())
    if distance > 1000 then
        client:notify("Target is too far away!")
        return false -- Prevent caption from being sent
    end
    
    -- Add sender information to caption
    local modifiedText = "[" .. client:Name() .. "] " .. text
    lia.caption.start(target, modifiedText, duration)
    return true -- Prevent original caption
end)
```

---

## BroadcastCaptionCommand

**Purpose**

Called when the broadcastCaption command is executed.

**Parameters**

* `client` (*Player*): The player who executed the command.
* `text` (*string*): The text content of the caption.
* `duration` (*number*): The duration in seconds the caption will be displayed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The `broadcastCaption` command is executed
- Before the caption is sent to all players

**Example Usage**

```lua
-- Track broadcastCaption command usage
hook.Add("BroadcastCaptionCommand", "TrackBroadcastCaptionUsage", function(client, text, duration)
    print(client:Name(), "broadcasted caption:", text)
    
    -- Log to server console
    local char = client:getChar()
    if char then
        local broadcastCaptions = char:getData("broadcast_captions", 0)
        char:setData("broadcast_captions", broadcastCaptions + 1)
    end
end)

-- Apply custom effects for broadcastCaption command
hook.Add("BroadcastCaptionCommand", "BroadcastCaptionEffects", function(client, text, duration)
    -- Play sound effect for all players
    for _, ply in player.Iterator() do
        ply:EmitSound("buttons/button14.wav", 75, 100)
    end
    
    -- Notify all players
    for _, ply in player.Iterator() do
        ply:notify("Broadcast caption from " .. client:Name())
    end
end)

-- Modify broadcastCaption behavior
hook.Add("BroadcastCaptionCommand", "ModifyBroadcastCaptionBehavior", function(client, text, duration)
    -- Add sender information to caption
    local modifiedText = "[BROADCAST from " .. client:Name() .. "] " .. text
    
    -- Send to all players
    for _, ply in player.Iterator() do
        lia.caption.start(ply, modifiedText, duration)
    end
    
    return true -- Prevent original caption
end)

-- Log broadcast captions
hook.Add("BroadcastCaptionCommand", "LogBroadcastCaptions", function(client, text, duration)
    -- Log to server console
    print("BROADCAST CAPTION:", client:Name(), "->", text, "(" .. duration .. "s)")
    
    -- Log to file if needed
    file.Append("captions_log.txt", os.date() .. " - " .. client:Name() .. " - " .. text .. "\n")
end)
```
