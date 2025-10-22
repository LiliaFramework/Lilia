# Hooks

This document describes the hooks available in the Extended Descriptions module for managing detailed item descriptions and editing functionality.

---

## ExtendedDescriptionClosed

**Purpose**

Called when an extended description window is closed.

**Parameters**

* `player` (*Player*): The player who closed the description.
* `descText` (*string*): The description text that was displayed.
* `descURL` (*string*): The URL that was displayed.

**Realm**

Client.

**When Called**

This hook is triggered when:
- An extended description window is closed
- The player closes the description interface
- After `ExtendedDescriptionOpened` hook

**Example Usage**

```lua
-- Track extended description closures
hook.Add("ExtendedDescriptionClosed", "TrackExtendedDescriptionClosures", function(player, descText, descURL)
    local char = player:getChar()
    if char then
        local descriptionClosures = char:getData("extended_description_closures", 0)
        char:setData("extended_description_closures", descriptionClosures + 1)
    end
end)

-- Apply extended description closure effects
hook.Add("ExtendedDescriptionClosed", "ExtendedDescriptionClosureEffects", function(player, descText, descURL)
    -- Play closure sound
    player:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 5), 0.2, 0)
    
    -- Notify player
    player:notify("Extended description closed!")
end)

-- Track extended description closure statistics
hook.Add("ExtendedDescriptionClosed", "TrackExtendedDescriptionClosureStats", function(player, descText, descURL)
    local char = player:getChar()
    if char then
        -- Track closure frequency
        local closureFrequency = char:getData("extended_description_closure_frequency", 0)
        char:setData("extended_description_closure_frequency", closureFrequency + 1)
        
        -- Track closure patterns
        local closurePatterns = char:getData("extended_description_closure_patterns", {})
        table.insert(closurePatterns, {
            text = descText,
            url = descURL,
            time = os.time()
        })
        char:setData("extended_description_closure_patterns", closurePatterns)
    end
end)
```

---

## ExtendedDescriptionEditClosed

**Purpose**

Called when an extended description edit window is closed.

**Parameters**

* `steamName` (*string*): The Steam name of the player who closed the edit window.

**Realm**

Client.

**When Called**

This hook is triggered when:
- An extended description edit window is closed
- The player closes the edit interface
- After `ExtendedDescriptionEditOpened` hook

**Example Usage**

```lua
-- Track extended description edit closures
hook.Add("ExtendedDescriptionEditClosed", "TrackExtendedDescriptionEditClosures", function(steamName)
    local char = LocalPlayer():getChar()
    if char then
        local editClosures = char:getData("extended_description_edit_closures", 0)
        char:setData("extended_description_edit_closures", editClosures + 1)
    end
end)

-- Apply extended description edit closure effects
hook.Add("ExtendedDescriptionEditClosed", "ExtendedDescriptionEditClosureEffects", function(steamName)
    -- Play closure sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 5), 0.2, 0)
    
    -- Notify player
    LocalPlayer():notify("Extended description edit closed!")
end)

-- Track extended description edit closure statistics
hook.Add("ExtendedDescriptionEditClosed", "TrackExtendedDescriptionEditClosureStats", function(steamName)
    local char = LocalPlayer():getChar()
    if char then
        -- Track edit closure frequency
        local editClosureFrequency = char:getData("extended_description_edit_closure_frequency", 0)
        char:setData("extended_description_edit_closure_frequency", editClosureFrequency + 1)
        
        -- Track edit closure patterns
        local editClosurePatterns = char:getData("extended_description_edit_closure_patterns", {})
        table.insert(editClosurePatterns, {
            steamName = steamName,
            time = os.time()
        })
        char:setData("extended_description_edit_closure_patterns", editClosurePatterns)
    end
end)
```

---

## ExtendedDescriptionEditOpened

**Purpose**

Called when an extended description edit window is opened.

**Parameters**

* `frame` (*Panel*): The edit frame that was opened.
* `steamName` (*string*): The Steam name of the player who opened the edit window.

**Realm**

Client.

**When Called**

This hook is triggered when:
- An extended description edit window is opened
- The player opens the edit interface
- Before `ExtendedDescriptionEditClosed` hook

**Example Usage**

```lua
-- Track extended description edit openings
hook.Add("ExtendedDescriptionEditOpened", "TrackExtendedDescriptionEditOpenings", function(frame, steamName)
    local char = LocalPlayer():getChar()
    if char then
        local editOpenings = char:getData("extended_description_edit_openings", 0)
        char:setData("extended_description_edit_openings", editOpenings + 1)
    end
end)

-- Apply extended description edit opening effects
hook.Add("ExtendedDescriptionEditOpened", "ExtendedDescriptionEditOpeningEffects", function(frame, steamName)
    -- Play opening sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    LocalPlayer():notify("Extended description edit opened!")
end)

-- Track extended description edit opening statistics
hook.Add("ExtendedDescriptionEditOpened", "TrackExtendedDescriptionEditOpeningStats", function(frame, steamName)
    local char = LocalPlayer():getChar()
    if char then
        -- Track edit opening frequency
        local editOpeningFrequency = char:getData("extended_description_edit_opening_frequency", 0)
        char:setData("extended_description_edit_opening_frequency", editOpeningFrequency + 1)
        
        -- Track edit opening patterns
        local editOpeningPatterns = char:getData("extended_description_edit_opening_patterns", {})
        table.insert(editOpeningPatterns, {
            steamName = steamName,
            time = os.time()
        })
        char:setData("extended_description_edit_opening_patterns", editOpeningPatterns)
    end
end)
```

---

## ExtendedDescriptionEditSubmitted

**Purpose**

Called when an extended description edit is submitted.

**Parameters**

* `steamName` (*string*): The Steam name of the player who submitted the edit.
* `urlEntry` (*string*): The URL that was entered.
* `textEntry` (*string*): The text that was entered.

**Realm**

Client.

**When Called**

This hook is triggered when:
- An extended description edit is submitted
- The player saves their changes
- Before `ExtendedDescriptionEditClosed` hook

**Example Usage**

```lua
-- Track extended description edit submissions
hook.Add("ExtendedDescriptionEditSubmitted", "TrackExtendedDescriptionEditSubmissions", function(steamName, urlEntry, textEntry)
    local char = LocalPlayer():getChar()
    if char then
        local editSubmissions = char:getData("extended_description_edit_submissions", 0)
        char:setData("extended_description_edit_submissions", editSubmissions + 1)
    end
end)

-- Apply extended description edit submission effects
hook.Add("ExtendedDescriptionEditSubmitted", "ExtendedDescriptionEditSubmissionEffects", function(steamName, urlEntry, textEntry)
    -- Play submission sound
    LocalPlayer():EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.5, 0)
    
    -- Notify player
    LocalPlayer():notify("Extended description edit submitted!")
end)

-- Track extended description edit submission statistics
hook.Add("ExtendedDescriptionEditSubmitted", "TrackExtendedDescriptionEditSubmissionStats", function(steamName, urlEntry, textEntry)
    local char = LocalPlayer():getChar()
    if char then
        -- Track edit submission frequency
        local editSubmissionFrequency = char:getData("extended_description_edit_submission_frequency", 0)
        char:setData("extended_description_edit_submission_frequency", editSubmissionFrequency + 1)
        
        -- Track edit submission patterns
        local editSubmissionPatterns = char:getData("extended_description_edit_submission_patterns", {})
        table.insert(editSubmissionPatterns, {
            steamName = steamName,
            url = urlEntry,
            text = textEntry,
            time = os.time()
        })
        char:setData("extended_description_edit_submission_patterns", editSubmissionPatterns)
    end
end)
```

---

## ExtendedDescriptionOpened

**Purpose**

Called when an extended description window is opened.

**Parameters**

* `player` (*Player*): The player who opened the description.
* `frame` (*Panel*): The description frame that was opened.
* `descText` (*string*): The description text being displayed.
* `descURL` (*string*): The URL being displayed.

**Realm**

Client.

**When Called**

This hook is triggered when:
- An extended description window is opened
- The player opens the description interface
- Before `ExtendedDescriptionClosed` hook

**Example Usage**

```lua
-- Track extended description openings
hook.Add("ExtendedDescriptionOpened", "TrackExtendedDescriptionOpenings", function(player, frame, descText, descURL)
    local char = player:getChar()
    if char then
        local descriptionOpenings = char:getData("extended_description_openings", 0)
        char:setData("extended_description_openings", descriptionOpenings + 1)
    end
end)

-- Apply extended description opening effects
hook.Add("ExtendedDescriptionOpened", "ExtendedDescriptionOpeningEffects", function(player, frame, descText, descURL)
    -- Play opening sound
    player:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    player:notify("Extended description opened!")
end)

-- Track extended description opening statistics
hook.Add("ExtendedDescriptionOpened", "TrackExtendedDescriptionOpeningStats", function(player, frame, descText, descURL)
    local char = player:getChar()
    if char then
        -- Track opening frequency
        local openingFrequency = char:getData("extended_description_opening_frequency", 0)
        char:setData("extended_description_opening_frequency", openingFrequency + 1)
        
        -- Track opening patterns
        local openingPatterns = char:getData("extended_description_opening_patterns", {})
        table.insert(openingPatterns, {
            text = descText,
            url = descURL,
            time = os.time()
        })
        char:setData("extended_description_opening_patterns", openingPatterns)
    end
end)
```

---

## ExtendedDescriptionUpdated

**Purpose**

Called when an extended description is updated.

**Parameters**

* `client` (*Player*): The player whose description was updated.
* `textEntryURL` (*string*): The URL that was updated.
* `text` (*string*): The text that was updated.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An extended description is updated
- The description data is saved to the character
- After `PreExtendedDescriptionUpdate` hook

**Example Usage**

```lua
-- Track extended description updates
hook.Add("ExtendedDescriptionUpdated", "TrackExtendedDescriptionUpdates", function(client, textEntryURL, text)
    local char = client:getChar()
    if char then
        local descriptionUpdates = char:getData("extended_description_updates", 0)
        char:setData("extended_description_updates", descriptionUpdates + 1)
    end
    
    lia.log.add(client, "extendedDescriptionUpdated", textEntryURL, text)
end)

-- Apply extended description update effects
hook.Add("ExtendedDescriptionUpdated", "ExtendedDescriptionUpdateEffects", function(client, textEntryURL, text)
    -- Play update sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.5, 0)
    
    -- Notify player
    client:notify("Extended description updated!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track extended description update statistics
hook.Add("ExtendedDescriptionUpdated", "TrackExtendedDescriptionUpdateStats", function(client, textEntryURL, text)
    local char = client:getChar()
    if char then
        -- Track update frequency
        local updateFrequency = char:getData("extended_description_update_frequency", 0)
        char:setData("extended_description_update_frequency", updateFrequency + 1)
        
        -- Track update patterns
        local updatePatterns = char:getData("extended_description_update_patterns", {})
        table.insert(updatePatterns, {
            url = textEntryURL,
            text = text,
            time = os.time()
        })
        char:setData("extended_description_update_patterns", updatePatterns)
    end
end)
```

---

## PreExtendedDescriptionUpdate

**Purpose**

Called before an extended description is updated.

**Parameters**

* `client` (*Player*): The player whose description is about to be updated.
* `textEntryURL` (*string*): The URL that will be updated.
* `text` (*string*): The text that will be updated.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An extended description is about to be updated
- Before the description data is saved
- Before `ExtendedDescriptionUpdated` hook

**Example Usage**

```lua
-- Validate extended description update
hook.Add("PreExtendedDescriptionUpdate", "ValidateExtendedDescriptionUpdate", function(client, textEntryURL, text)
    local char = client:getChar()
    if char then
        -- Check if description updates are disabled
        if char:getData("extended_description_updates_disabled", false) then
            client:notify("Extended description updates are disabled!")
            return false
        end
        
        -- Check update cooldown
        local lastUpdate = char:getData("last_extended_description_update_time", 0)
        if os.time() - lastUpdate < 5 then -- 5 second cooldown
            client:notify("Please wait before updating your description again!")
            return false
        end
        
        -- Update last update time
        char:setData("last_extended_description_update_time", os.time())
    end
end)

-- Track extended description update attempts
hook.Add("PreExtendedDescriptionUpdate", "TrackExtendedDescriptionUpdateAttempts", function(client, textEntryURL, text)
    local char = client:getChar()
    if char then
        local updateAttempts = char:getData("extended_description_update_attempts", 0)
        char:setData("extended_description_update_attempts", updateAttempts + 1)
    end
end)

-- Apply pre-update effects
hook.Add("PreExtendedDescriptionUpdate", "PreExtendedDescriptionUpdateEffects", function(client, textEntryURL, text)
    -- Play pre-update sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Updating extended description...")
end)
```
