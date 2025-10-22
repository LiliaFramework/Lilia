# Hooks

This document describes the hooks available in the Rumour module for managing anonymous rumour functionality.

---

## CanSendRumour

**Purpose**

Called to determine if a player can send a rumour.

**Parameters**

* `client` (*Player*): The player attempting to send the rumour.
* `rumourMessage` (*string*): The rumour message being sent.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player attempts to send a rumour
- Before `RumourValidationFailed` hook
- Before any rumour validation

**Example Usage**

```lua
-- Control rumour sending
hook.Add("CanSendRumour", "ControlRumourSending", function(client, rumourMessage)
    local char = client:getChar()
    if char then
        -- Check if rumour sending is disabled
        if char:getData("rumour_sending_disabled", false) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
        
        -- Check if player is in a vehicle
        if client:InVehicle() then
            return false
        end
        
        -- Check if player is in water
        if client:WaterLevel() >= 2 then
            return false
        end
        
        -- Check if player is handcuffed
        if client:IsHandcuffed() then
            return false
        end
        
        -- Check cooldown
        local lastRumour = char:getData("last_rumour_time", 0)
        if os.time() - lastRumour < 5 then -- 5 second cooldown
            return false
        end
        
        -- Update last rumour time
        char:setData("last_rumour_time", os.time())
    end
    
    return true
end)

-- Track rumour sending attempts
hook.Add("CanSendRumour", "TrackRumourSendingAttempts", function(client, rumourMessage)
    local char = client:getChar()
    if char then
        local sendingAttempts = char:getData("rumour_sending_attempts", 0)
        char:setData("rumour_sending_attempts", sendingAttempts + 1)
    end
end)

-- Apply rumour sending check effects
hook.Add("CanSendRumour", "RumourSendingCheckEffects", function(client, rumourMessage)
    local char = client:getChar()
    if char then
        -- Check if rumour sending is disabled
        if char:getData("rumour_sending_disabled", false) then
            client:notify("Rumour sending is disabled!")
        end
    end
end)
```

---

## PreRumourCommand

**Purpose**

Called before a rumour command is processed.

**Parameters**

* `client` (*Player*): The player executing the rumour command.
* `arguments` (*table*): The command arguments.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A rumour command is about to be processed
- Before any rumour validation
- Before `RumourFactionDisallowed` hook

**Example Usage**

```lua
-- Track rumour command attempts
hook.Add("PreRumourCommand", "TrackRumourCommandAttempts", function(client, arguments)
    local char = client:getChar()
    if char then
        local commandAttempts = char:getData("rumour_command_attempts", 0)
        char:setData("rumour_command_attempts", commandAttempts + 1)
    end
end)

-- Apply pre-rumour command effects
hook.Add("PreRumourCommand", "PreRumourCommandEffects", function(client, arguments)
    -- Play command sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Processing rumour command...")
end)

-- Track pre-rumour command statistics
hook.Add("PreRumourCommand", "TrackPreRumourCommandStats", function(client, arguments)
    local char = client:getChar()
    if char then
        -- Track command frequency
        local commandFrequency = char:getData("rumour_command_frequency", 0)
        char:setData("rumour_command_frequency", commandFrequency + 1)
        
        -- Track command patterns
        local commandPatterns = char:getData("rumour_command_patterns", {})
        table.insert(commandPatterns, {
            arguments = arguments,
            time = os.time()
        })
        char:setData("rumour_command_patterns", commandPatterns)
    end
end)
```

---

## RumourAttempt

**Purpose**

Called when a rumour attempt is made.

**Parameters**

* `client` (*Player*): The player attempting to send the rumour.
* `rumourMessage` (*string*): The rumour message being sent.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A rumour attempt is made
- After `CanSendRumour` hook
- Before `RumourRevealRoll` hook

**Example Usage**

```lua
-- Track rumour attempts
hook.Add("RumourAttempt", "TrackRumourAttempts", function(client, rumourMessage)
    local char = client:getChar()
    if char then
        local rumourAttempts = char:getData("rumour_attempts", 0)
        char:setData("rumour_attempts", rumourAttempts + 1)
    end
    
    lia.log.add(client, "rumourAttempt", rumourMessage)
end)

-- Apply rumour attempt effects
hook.Add("RumourAttempt", "RumourAttemptEffects", function(client, rumourMessage)
    -- Play attempt sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Rumour attempt made!")
end)

-- Track rumour attempt statistics
hook.Add("RumourAttempt", "TrackRumourAttemptStats", function(client, rumourMessage)
    local char = client:getChar()
    if char then
        -- Track attempt frequency
        local attemptFrequency = char:getData("rumour_attempt_frequency", 0)
        char:setData("rumour_attempt_frequency", attemptFrequency + 1)
        
        -- Track attempt patterns
        local attemptPatterns = char:getData("rumour_attempt_patterns", {})
        table.insert(attemptPatterns, {
            message = rumourMessage,
            time = os.time()
        })
        char:setData("rumour_attempt_patterns", attemptPatterns)
    end
end)
```

---

## RumourFactionDisallowed

**Purpose**

Called when a rumour is disallowed due to faction restrictions.

**Parameters**

* `client` (*Player*): The player whose rumour was disallowed.
* `faction` (*table*): The faction that disallowed the rumour.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A rumour is disallowed due to faction restrictions
- After `PreRumourCommand` hook
- When the faction check fails

**Example Usage**

```lua
-- Track rumour faction disallowances
hook.Add("RumourFactionDisallowed", "TrackRumourFactionDisallowances", function(client, faction)
    local char = client:getChar()
    if char then
        local factionDisallowances = char:getData("rumour_faction_disallowances", 0)
        char:setData("rumour_faction_disallowances", factionDisallowances + 1)
    end
    
    lia.log.add(client, "rumourFactionDisallowed", faction)
end)

-- Apply rumour faction disallowance effects
hook.Add("RumourFactionDisallowed", "RumourFactionDisallowanceEffects", function(client, faction)
    -- Play disallowance sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Rumour disallowed by faction!")
end)

-- Track rumour faction disallowance statistics
hook.Add("RumourFactionDisallowed", "TrackRumourFactionDisallowanceStats", function(client, faction)
    local char = client:getChar()
    if char then
        -- Track disallowance frequency
        local disallowanceFrequency = char:getData("rumour_faction_disallowance_frequency", 0)
        char:setData("rumour_faction_disallowance_frequency", disallowanceFrequency + 1)
        
        -- Track disallowance patterns
        local disallowancePatterns = char:getData("rumour_faction_disallowance_patterns", {})
        table.insert(disallowancePatterns, {
            faction = faction,
            time = os.time()
        })
        char:setData("rumour_faction_disallowance_patterns", disallowancePatterns)
    end
end)
```

---

## RumourNoMessage

**Purpose**

Called when a rumour command is executed without a message.

**Parameters**

* `client` (*Player*): The player who executed the command without a message.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A rumour command is executed without a message
- After `PreRumourCommand` hook
- When the message validation fails

**Example Usage**

```lua
-- Track rumour no message attempts
hook.Add("RumourNoMessage", "TrackRumourNoMessageAttempts", function(client)
    local char = client:getChar()
    if char then
        local noMessageAttempts = char:getData("rumour_no_message_attempts", 0)
        char:setData("rumour_no_message_attempts", noMessageAttempts + 1)
    end
    
    lia.log.add(client, "rumourNoMessage")
end)

-- Apply rumour no message effects
hook.Add("RumourNoMessage", "RumourNoMessageEffects", function(client)
    -- Play no message sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("No rumour message provided!")
end)

-- Track rumour no message statistics
hook.Add("RumourNoMessage", "TrackRumourNoMessageStats", function(client)
    local char = client:getChar()
    if char then
        -- Track no message frequency
        local noMessageFrequency = char:getData("rumour_no_message_frequency", 0)
        char:setData("rumour_no_message_frequency", noMessageFrequency + 1)
        
        -- Track no message patterns
        local noMessagePatterns = char:getData("rumour_no_message_patterns", {})
        table.insert(noMessagePatterns, {
            time = os.time()
        })
        char:setData("rumour_no_message_patterns", noMessagePatterns)
    end
end)
```

---

## RumourRevealed

**Purpose**

Called when a rumour is revealed to police.

**Parameters**

* `client` (*Player*): The player whose rumour was revealed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A rumour is revealed to police
- After `RumourRevealRoll` hook
- When the reveal roll succeeds

**Example Usage**

```lua
-- Track rumour revelations
hook.Add("RumourRevealed", "TrackRumourRevelations", function(client)
    local char = client:getChar()
    if char then
        local rumourRevelations = char:getData("rumour_revelations", 0)
        char:setData("rumour_revelations", rumourRevelations + 1)
    end
    
    lia.log.add(client, "rumourRevealed")
end)

-- Apply rumour revelation effects
hook.Add("RumourRevealed", "RumourRevelationEffects", function(client)
    -- Play revelation sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Your rumour has been revealed to police!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track rumour revelation statistics
hook.Add("RumourRevealed", "TrackRumourRevelationStats", function(client)
    local char = client:getChar()
    if char then
        -- Track revelation frequency
        local revelationFrequency = char:getData("rumour_revelation_frequency", 0)
        char:setData("rumour_revelation_frequency", revelationFrequency + 1)
        
        -- Track revelation patterns
        local revelationPatterns = char:getData("rumour_revelation_patterns", {})
        table.insert(revelationPatterns, {
            time = os.time()
        })
        char:setData("rumour_revelation_patterns", revelationPatterns)
    end
end)
```

---

## RumourRevealRoll

**Purpose**

Called when a rumour reveal roll is made.

**Parameters**

* `client` (*Player*): The player whose rumour is being rolled.
* `revealChance` (*number*): The chance of revelation.
* `revealMath` (*boolean*): Whether the roll succeeded.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A rumour reveal roll is made
- After `RumourAttempt` hook
- Before `RumourRevealed` hook

**Example Usage**

```lua
-- Track rumour reveal rolls
hook.Add("RumourRevealRoll", "TrackRumourRevealRolls", function(client, revealChance, revealMath)
    local char = client:getChar()
    if char then
        local revealRolls = char:getData("rumour_reveal_rolls", 0)
        char:setData("rumour_reveal_rolls", revealRolls + 1)
    end
    
    lia.log.add(client, "rumourRevealRoll", revealChance, revealMath)
end)

-- Apply rumour reveal roll effects
hook.Add("RumourRevealRoll", "RumourRevealRollEffects", function(client, revealChance, revealMath)
    -- Play roll sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    local result = revealMath and "succeeded" or "failed"
    client:notify("Rumour reveal roll " .. result .. "!")
end)

-- Track rumour reveal roll statistics
hook.Add("RumourRevealRoll", "TrackRumourRevealRollStats", function(client, revealChance, revealMath)
    local char = client:getChar()
    if char then
        -- Track roll frequency
        local rollFrequency = char:getData("rumour_reveal_roll_frequency", 0)
        char:setData("rumour_reveal_roll_frequency", rollFrequency + 1)
        
        -- Track roll patterns
        local rollPatterns = char:getData("rumour_reveal_roll_patterns", {})
        table.insert(rollPatterns, {
            chance = revealChance,
            success = revealMath,
            time = os.time()
        })
        char:setData("rumour_reveal_roll_patterns", rollPatterns)
    end
end)
```

---

## RumourSent

**Purpose**

Called when a rumour is sent.

**Parameters**

* `client` (*Player*): The player who sent the rumour.
* `rumourMessage` (*string*): The rumour message that was sent.
* `revealMath` (*boolean*): Whether the rumour was revealed to police.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A rumour is successfully sent
- After `RumourRevealed` hook
- When the rumour is delivered to players

**Example Usage**

```lua
-- Track rumour sends
hook.Add("RumourSent", "TrackRumourSends", function(client, rumourMessage, revealMath)
    local char = client:getChar()
    if char then
        local rumourSends = char:getData("rumour_sends", 0)
        char:setData("rumour_sends", rumourSends + 1)
    end
    
    lia.log.add(client, "rumourSent", rumourMessage, revealMath)
end)

-- Apply rumour send effects
hook.Add("RumourSent", "RumourSendEffects", function(client, rumourMessage, revealMath)
    -- Play send sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    local status = revealMath and "revealed" or "hidden"
    client:notify("Rumour sent! Status: " .. status .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track rumour send statistics
hook.Add("RumourSent", "TrackRumourSendStats", function(client, rumourMessage, revealMath)
    local char = client:getChar()
    if char then
        -- Track send frequency
        local sendFrequency = char:getData("rumour_send_frequency", 0)
        char:setData("rumour_send_frequency", sendFrequency + 1)
        
        -- Track send patterns
        local sendPatterns = char:getData("rumour_send_patterns", {})
        table.insert(sendPatterns, {
            message = rumourMessage,
            revealed = revealMath,
            time = os.time()
        })
        char:setData("rumour_send_patterns", sendPatterns)
    end
end)
```

---

## RumourValidationFailed

**Purpose**

Called when rumour validation fails.

**Parameters**

* `client` (*Player*): The player whose rumour validation failed.
* `rumourMessage` (*string*): The rumour message that failed validation.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Rumour validation fails
- After `CanSendRumour` hook
- When the rumour is rejected

**Example Usage**

```lua
-- Track rumour validation failures
hook.Add("RumourValidationFailed", "TrackRumourValidationFailures", function(client, rumourMessage)
    local char = client:getChar()
    if char then
        local validationFailures = char:getData("rumour_validation_failures", 0)
        char:setData("rumour_validation_failures", validationFailures + 1)
    end
    
    lia.log.add(client, "rumourValidationFailed", rumourMessage)
end)

-- Apply rumour validation failure effects
hook.Add("RumourValidationFailed", "RumourValidationFailureEffects", function(client, rumourMessage)
    -- Play failure sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Rumour validation failed!")
end)

-- Track rumour validation failure statistics
hook.Add("RumourValidationFailed", "TrackRumourValidationFailureStats", function(client, rumourMessage)
    local char = client:getChar()
    if char then
        -- Track failure frequency
        local failureFrequency = char:getData("rumour_validation_failure_frequency", 0)
        char:setData("rumour_validation_failure_frequency", failureFrequency + 1)
        
        -- Track failure patterns
        local failurePatterns = char:getData("rumour_validation_failure_patterns", {})
        table.insert(failurePatterns, {
            message = rumourMessage,
            time = os.time()
        })
        char:setData("rumour_validation_failure_patterns", failurePatterns)
    end
end)
```
