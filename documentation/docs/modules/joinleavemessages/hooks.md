# Hooks

This document describes the hooks available in the Join Leave Messages module for managing player join and leave announcements.

---

## JoinLeaveMessageSent

**Purpose**

Called when a join or leave message is sent to players.

**Parameters**

* `client` (*Player*): The player who joined or left.
* `isJoin` (*boolean*): Whether this is a join message (true) or leave message (false).
* `message` (*string*): The message that was sent.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A join or leave message is sent to all players
- After `PreJoinLeaveMessageSent` hook
- After the message is displayed

**Example Usage**

```lua
-- Track join/leave messages
hook.Add("JoinLeaveMessageSent", "TrackJoinLeaveMessages", function(client, isJoin, message)
    local char = client:getChar()
    if char then
        local messageType = isJoin and "join" or "leave"
        local messageCount = char:getData("join_leave_messages_" .. messageType, 0)
        char:setData("join_leave_messages_" .. messageType, messageCount + 1)
    end
    
    lia.log.add(client, "joinLeaveMessageSent", isJoin, message)
end)

-- Apply join/leave message effects
hook.Add("JoinLeaveMessageSent", "JoinLeaveMessageEffects", function(client, isJoin, message)
    -- Play message sound
    client:EmitSound(isJoin and "buttons/button14.wav" or "buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, isJoin and Color(0, 255, 0, 15) or Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    local status = isJoin and "joined" or "left"
    client:notify("Player " .. status .. " message sent!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track join/leave message statistics
hook.Add("JoinLeaveMessageSent", "TrackJoinLeaveMessageStats", function(client, isJoin, message)
    local char = client:getChar()
    if char then
        -- Track message frequency
        local messageFrequency = char:getData("join_leave_message_frequency", 0)
        char:setData("join_leave_message_frequency", messageFrequency + 1)
        
        -- Track message patterns
        local messagePatterns = char:getData("join_leave_message_patterns", {})
        table.insert(messagePatterns, {
            isJoin = isJoin,
            message = message,
            time = os.time()
        })
        char:setData("join_leave_message_patterns", messagePatterns)
    end
end)
```

---

## PreJoinLeaveMessageSent

**Purpose**

Called before a join or leave message is sent to players.

**Parameters**

* `client` (*Player*): The player who joined or left.
* `isJoin` (*boolean*): Whether this is a join message (true) or leave message (false).
* `message` (*string*): The message that will be sent.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A join or leave message is about to be sent
- Before `JoinLeaveMessageSent` hook
- Before any message validation

**Example Usage**

```lua
-- Validate join/leave messages
hook.Add("PreJoinLeaveMessageSent", "ValidateJoinLeaveMessages", function(client, isJoin, message)
    local char = client:getChar()
    if char then
        -- Check if messages are disabled
        if char:getData("join_leave_messages_disabled", false) then
            client:notify("Join/leave messages are disabled!")
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            client:notify("Cannot send join/leave messages in this area!")
            return false
        end
        
        -- Check cooldown
        local lastMessage = char:getData("last_join_leave_message_time", 0)
        if os.time() - lastMessage < 1 then -- 1 second cooldown
            client:notify("Please wait before sending another message!")
            return false
        end
        
        -- Update last message time
        char:setData("last_join_leave_message_time", os.time())
    end
    
    return true
end)

-- Track join/leave message attempts
hook.Add("PreJoinLeaveMessageSent", "TrackJoinLeaveMessageAttempts", function(client, isJoin, message)
    local char = client:getChar()
    if char then
        local messageAttempts = char:getData("join_leave_message_attempts", 0)
        char:setData("join_leave_message_attempts", messageAttempts + 1)
    end
end)

-- Apply pre-message effects
hook.Add("PreJoinLeaveMessageSent", "PreJoinLeaveMessageEffects", function(client, isJoin, message)
    -- Play pre-message sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    local status = isJoin and "join" or "leave"
    client:notify("Sending " .. status .. " message...")
end)
```
