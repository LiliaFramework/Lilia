# Hooks

This document describes the hooks available in the Load Messages module for managing faction-based load messages.

---

## LoadMessageMissing

**Purpose**

Called when a load message is missing for a player's faction.

**Parameters**

* `client` (*Player*): The player who loaded a character but has no faction message.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player loads a character
- No faction message is found for their team
- After `PreLoadMessage` hook would have been called

**Example Usage**

```lua
-- Track missing load messages
hook.Add("LoadMessageMissing", "TrackMissingLoadMessages", function(client)
    local char = client:getChar()
    if char then
        local missingMessages = char:getData("missing_load_messages", 0)
        char:setData("missing_load_messages", missingMessages + 1)
    end
    
    lia.log.add(client, "loadMessageMissing")
end)

-- Apply missing load message effects
hook.Add("LoadMessageMissing", "MissingLoadMessageEffects", function(client)
    -- Play missing message sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("No load message found for your faction!")
end)

-- Track missing load message statistics
hook.Add("LoadMessageMissing", "TrackMissingLoadMessageStats", function(client)
    local char = client:getChar()
    if char then
        -- Track missing frequency
        local missingFrequency = char:getData("load_message_missing_frequency", 0)
        char:setData("load_message_missing_frequency", missingFrequency + 1)
        
        -- Track missing patterns
        local missingPatterns = char:getData("load_message_missing_patterns", {})
        table.insert(missingPatterns, {
            faction = client:Team(),
            time = os.time()
        })
        char:setData("load_message_missing_patterns", missingPatterns)
    end
end)
```

---

## LoadMessageSent

**Purpose**

Called when a load message is sent to a player.

**Parameters**

* `client` (*Player*): The player who received the load message.
* `data` (*table*): The load message data containing the message content.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A load message is sent to a player
- After `PreLoadMessage` hook
- Before `PostLoadMessage` hook

**Example Usage**

```lua
-- Track load message sends
hook.Add("LoadMessageSent", "TrackLoadMessageSends", function(client, data)
    local char = client:getChar()
    if char then
        local messageSends = char:getData("load_message_sends", 0)
        char:setData("load_message_sends", messageSends + 1)
    end
    
    lia.log.add(client, "loadMessageSent", data)
end)

-- Apply load message send effects
hook.Add("LoadMessageSent", "LoadMessageSendEffects", function(client, data)
    -- Play send sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Load message sent!")
end)

-- Track load message send statistics
hook.Add("LoadMessageSent", "TrackLoadMessageSendStats", function(client, data)
    local char = client:getChar()
    if char then
        -- Track send frequency
        local sendFrequency = char:getData("load_message_send_frequency", 0)
        char:setData("load_message_send_frequency", sendFrequency + 1)
        
        -- Track send patterns
        local sendPatterns = char:getData("load_message_send_patterns", {})
        table.insert(sendPatterns, {
            data = data,
            time = os.time()
        })
        char:setData("load_message_send_patterns", sendPatterns)
    end
end)
```

---

## PostLoadMessage

**Purpose**

Called after a load message is processed.

**Parameters**

* `client` (*Player*): The player who received the load message.
* `data` (*table*): The load message data containing the message content.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A load message is fully processed
- After `LoadMessageSent` hook
- When the message display is complete

**Example Usage**

```lua
-- Track load message completion
hook.Add("PostLoadMessage", "TrackLoadMessageCompletion", function(client, data)
    local char = client:getChar()
    if char then
        local messageCompletions = char:getData("load_message_completions", 0)
        char:setData("load_message_completions", messageCompletions + 1)
    end
    
    lia.log.add(client, "loadMessageCompleted", data)
end)

-- Apply post load message effects
hook.Add("PostLoadMessage", "PostLoadMessageEffects", function(client, data)
    -- Play completion sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Load message processing complete!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track post load message statistics
hook.Add("PostLoadMessage", "TrackPostLoadMessageStats", function(client, data)
    local char = client:getChar()
    if char then
        -- Track completion frequency
        local completionFrequency = char:getData("load_message_completion_frequency", 0)
        char:setData("load_message_completion_frequency", completionFrequency + 1)
        
        -- Track completion patterns
        local completionPatterns = char:getData("load_message_completion_patterns", {})
        table.insert(completionPatterns, {
            data = data,
            time = os.time()
        })
        char:setData("load_message_completion_patterns", completionPatterns)
    end
end)
```

---

## PreLoadMessage

**Purpose**

Called before a load message is processed.

**Parameters**

* `client` (*Player*): The player who will receive the load message.
* `data` (*table*): The load message data containing the message content.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A load message is about to be processed
- Before `LoadMessageSent` hook
- When the message data is ready

**Example Usage**

```lua
-- Track load message preparation
hook.Add("PreLoadMessage", "TrackLoadMessagePreparation", function(client, data)
    local char = client:getChar()
    if char then
        local messagePreparations = char:getData("load_message_preparations", 0)
        char:setData("load_message_preparations", messagePreparations + 1)
    end
    
    lia.log.add(client, "loadMessagePrepared", data)
end)

-- Apply pre load message effects
hook.Add("PreLoadMessage", "PreLoadMessageEffects", function(client, data)
    -- Play preparation sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Preparing load message...")
end)

-- Track pre load message statistics
hook.Add("PreLoadMessage", "TrackPreLoadMessageStats", function(client, data)
    local char = client:getChar()
    if char then
        -- Track preparation frequency
        local preparationFrequency = char:getData("load_message_preparation_frequency", 0)
        char:setData("load_message_preparation_frequency", preparationFrequency + 1)
        
        -- Track preparation patterns
        local preparationPatterns = char:getData("load_message_preparation_patterns", {})
        table.insert(preparationPatterns, {
            data = data,
            time = os.time()
        })
        char:setData("load_message_preparation_patterns", preparationPatterns)
    end
end)
```
