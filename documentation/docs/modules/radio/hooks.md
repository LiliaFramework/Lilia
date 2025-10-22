# Hooks

This document describes the hooks available in the Radio module for managing radio communication functionality.

---

## CanHearRadio

**Purpose**

Called to determine if a player can hear radio communication.

**Parameters**

* `listener` (*Player*): The player who would hear the radio.
* `speaker` (*Player*): The player who is speaking on radio.
* `freq` (*string*): The radio frequency.
* `channel` (*number*): The radio channel.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player attempts to hear radio communication
- During radio chat processing
- When the hearing validation begins

**Example Usage**

```lua
-- Control radio hearing
hook.Add("CanHearRadio", "ControlRadioHearing", function(listener, speaker, freq, channel)
    local char = listener:getChar()
    if char then
        -- Check if radio hearing is disabled
        if char:getData("radio_hearing_disabled", false) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
        
        -- Check if player is in a vehicle
        if listener:InVehicle() then
            return false
        end
        
        -- Check if player is in water
        if listener:WaterLevel() >= 2 then
            return false
        end
        
        -- Check if player is handcuffed
        if listener:IsHandcuffed() then
            return false
        end
        
        -- Check cooldown
        local lastRadioHear = char:getData("last_radio_hear_time", 0)
        if os.time() - lastRadioHear < 1 then -- 1 second cooldown
            return false
        end
        
        -- Update last radio hear time
        char:setData("last_radio_hear_time", os.time())
    end
    
    return true
end)

-- Track radio hearing attempts
hook.Add("CanHearRadio", "TrackRadioHearingAttempts", function(listener, speaker, freq, channel)
    local char = listener:getChar()
    if char then
        local hearingAttempts = char:getData("radio_hearing_attempts", 0)
        char:setData("radio_hearing_attempts", hearingAttempts + 1)
    end
    
    lia.log.add(listener, "radioHearingAttempted", speaker, freq, channel)
end)

-- Apply radio hearing check effects
hook.Add("CanHearRadio", "RadioHearingCheckEffects", function(listener, speaker, freq, channel)
    local char = listener:getChar()
    if char then
        -- Check if radio hearing is disabled
        if char:getData("radio_hearing_disabled", false) then
            listener:notify("Radio hearing is disabled!")
        end
    end
end)
```

---

## CanUseRadio

**Purpose**

Called to determine if a player can use radio communication.

**Parameters**

* `speaker` (*Player*): The player attempting to use radio.
* `freq` (*string*): The radio frequency.
* `channel` (*number*): The radio channel.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player attempts to use radio communication
- During radio chat processing
- When the usage validation begins

**Example Usage**

```lua
-- Control radio usage
hook.Add("CanUseRadio", "ControlRadioUsage", function(speaker, freq, channel)
    local char = speaker:getChar()
    if char then
        -- Check if radio usage is disabled
        if char:getData("radio_usage_disabled", false) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
        
        -- Check if player is in a vehicle
        if speaker:InVehicle() then
            return false
        end
        
        -- Check if player is in water
        if speaker:WaterLevel() >= 2 then
            return false
        end
        
        -- Check if player is handcuffed
        if speaker:IsHandcuffed() then
            return false
        end
        
        -- Check cooldown
        local lastRadioUse = char:getData("last_radio_use_time", 0)
        if os.time() - lastRadioUse < 1 then -- 1 second cooldown
            return false
        end
        
        -- Update last radio use time
        char:setData("last_radio_use_time", os.time())
    end
    
    return true
end)

-- Track radio usage attempts
hook.Add("CanUseRadio", "TrackRadioUsageAttempts", function(speaker, freq, channel)
    local char = speaker:getChar()
    if char then
        local usageAttempts = char:getData("radio_usage_attempts", 0)
        char:setData("radio_usage_attempts", usageAttempts + 1)
    end
    
    lia.log.add(speaker, "radioUsageAttempted", freq, channel)
end)

-- Apply radio usage check effects
hook.Add("CanUseRadio", "RadioUsageCheckEffects", function(speaker, freq, channel)
    local char = speaker:getChar()
    if char then
        -- Check if radio usage is disabled
        if char:getData("radio_usage_disabled", false) then
            speaker:notify("Radio usage is disabled!")
        end
    end
end)
```

---

## OnRadioDisabled

**Purpose**

Called when a radio is disabled.

**Parameters**

* `client` (*Player*): The player whose radio was disabled.
* `item` (*Item*): The radio item that was disabled.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A radio is disabled
- During radio item processing
- When the radio is turned off

**Example Usage**

```lua
-- Track radio disabled
hook.Add("OnRadioDisabled", "TrackRadioDisabled", function(client, item)
    local char = client:getChar()
    if char then
        local radioDisabled = char:getData("radio_disabled", 0)
        char:setData("radio_disabled", radioDisabled + 1)
    end
    
    lia.log.add(client, "radioDisabled", item)
end)

-- Apply radio disabled effects
hook.Add("OnRadioDisabled", "RadioDisabledEffects", function(client, item)
    -- Play disabled sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Radio disabled!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track radio disabled statistics
hook.Add("OnRadioDisabled", "TrackRadioDisabledStats", function(client, item)
    local char = client:getChar()
    if char then
        -- Track disabled frequency
        local disabledFrequency = char:getData("radio_disabled_frequency", 0)
        char:setData("radio_disabled_frequency", disabledFrequency + 1)
        
        -- Track disabled patterns
        local disabledPatterns = char:getData("radio_disabled_patterns", {})
        table.insert(disabledPatterns, {
            item = item:getID(),
            time = os.time()
        })
        char:setData("radio_disabled_patterns", disabledPatterns)
    end
end)
```

---

## OnRadioEnabled

**Purpose**

Called when a radio is enabled.

**Parameters**

* `client` (*Player*): The player whose radio was enabled.
* `item` (*Item*): The radio item that was enabled.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A radio is enabled
- During radio item processing
- When the radio is turned on

**Example Usage**

```lua
-- Track radio enabled
hook.Add("OnRadioEnabled", "TrackRadioEnabled", function(client, item)
    local char = client:getChar()
    if char then
        local radioEnabled = char:getData("radio_enabled", 0)
        char:setData("radio_enabled", radioEnabled + 1)
    end
    
    lia.log.add(client, "radioEnabled", item)
end)

-- Apply radio enabled effects
hook.Add("OnRadioEnabled", "RadioEnabledEffects", function(client, item)
    -- Play enabled sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Radio enabled!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track radio enabled statistics
hook.Add("OnRadioEnabled", "TrackRadioEnabledStats", function(client, item)
    local char = client:getChar()
    if char then
        -- Track enabled frequency
        local enabledFrequency = char:getData("radio_enabled_frequency", 0)
        char:setData("radio_enabled_frequency", enabledFrequency + 1)
        
        -- Track enabled patterns
        local enabledPatterns = char:getData("radio_enabled_patterns", {})
        table.insert(enabledPatterns, {
            item = item:getID(),
            time = os.time()
        })
        char:setData("radio_enabled_patterns", enabledPatterns)
    end
end)
```

---

## OnRadioFrequencyChanged

**Purpose**

Called when a radio frequency is changed.

**Parameters**

* `client` (*Player*): The player whose radio frequency was changed.
* `item` (*Item*): The radio item whose frequency was changed.
* `freq` (*string*): The new frequency.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A radio frequency is changed
- During radio item processing
- When the frequency is updated

**Example Usage**

```lua
-- Track radio frequency changes
hook.Add("OnRadioFrequencyChanged", "TrackRadioFrequencyChanges", function(client, item, freq)
    local char = client:getChar()
    if char then
        local frequencyChanges = char:getData("radio_frequency_changes", 0)
        char:setData("radio_frequency_changes", frequencyChanges + 1)
    end
    
    lia.log.add(client, "radioFrequencyChanged", item, freq)
end)

-- Apply radio frequency change effects
hook.Add("OnRadioFrequencyChanged", "RadioFrequencyChangeEffects", function(client, item, freq)
    -- Play frequency change sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Radio frequency changed to: " .. freq .. "!")
end)

-- Track radio frequency change statistics
hook.Add("OnRadioFrequencyChanged", "TrackRadioFrequencyChangeStats", function(client, item, freq)
    local char = client:getChar()
    if char then
        -- Track frequency change frequency
        local frequencyChangeFrequency = char:getData("radio_frequency_change_frequency", 0)
        char:setData("radio_frequency_change_frequency", frequencyChangeFrequency + 1)
        
        -- Track frequency change patterns
        local frequencyChangePatterns = char:getData("radio_frequency_change_patterns", {})
        table.insert(frequencyChangePatterns, {
            item = item:getID(),
            freq = freq,
            time = os.time()
        })
        char:setData("radio_frequency_change_patterns", frequencyChangePatterns)
    end
end)
```

---

## OnRadioSabotaged

**Purpose**

Called when a radio is sabotaged.

**Parameters**

* `client` (*Player*): The player whose radio was sabotaged.
* `item` (*Item*): The radio item that was sabotaged.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A radio is sabotaged
- During radio item processing
- When the radio is damaged

**Example Usage**

```lua
-- Track radio sabotaged
hook.Add("OnRadioSabotaged", "TrackRadioSabotaged", function(client, item)
    local char = client:getChar()
    if char then
        local radioSabotaged = char:getData("radio_sabotaged", 0)
        char:setData("radio_sabotaged", radioSabotaged + 1)
    end
    
    lia.log.add(client, "radioSabotaged", item)
end)

-- Apply radio sabotaged effects
hook.Add("OnRadioSabotaged", "RadioSabotagedEffects", function(client, item)
    -- Play sabotaged sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Radio sabotaged!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track radio sabotaged statistics
hook.Add("OnRadioSabotaged", "TrackRadioSabotagedStats", function(client, item)
    local char = client:getChar()
    if char then
        -- Track sabotaged frequency
        local sabotagedFrequency = char:getData("radio_sabotaged_frequency", 0)
        char:setData("radio_sabotaged_frequency", sabotagedFrequency + 1)
        
        -- Track sabotaged patterns
        local sabotagedPatterns = char:getData("radio_sabotaged_patterns", {})
        table.insert(sabotagedPatterns, {
            item = item:getID(),
            time = os.time()
        })
        char:setData("radio_sabotaged_patterns", sabotagedPatterns)
    end
end)
```

---

## PlayerFinishRadio

**Purpose**

Called when a player finishes using radio.

**Parameters**

* `listener` (*Player*): The player who finished using radio.
* `freq` (*string*): The radio frequency.
* `channel` (*number*): The radio channel.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player finishes using radio
- After radio communication ends
- When the radio session is complete

**Example Usage**

```lua
-- Track player finish radio
hook.Add("PlayerFinishRadio", "TrackPlayerFinishRadio", function(listener, freq, channel)
    local char = listener:getChar()
    if char then
        local finishRadio = char:getData("finish_radio", 0)
        char:setData("finish_radio", finishRadio + 1)
    end
    
    lia.log.add(listener, "playerFinishRadio", freq, channel)
end)

-- Apply player finish radio effects
hook.Add("PlayerFinishRadio", "PlayerFinishRadioEffects", function(listener, freq, channel)
    -- Play finish sound
    listener:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    listener:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    listener:notify("Radio session finished!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(listener:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track player finish radio statistics
hook.Add("PlayerFinishRadio", "TrackPlayerFinishRadioStats", function(listener, freq, channel)
    local char = listener:getChar()
    if char then
        -- Track finish frequency
        local finishFrequency = char:getData("finish_radio_frequency", 0)
        char:setData("finish_radio_frequency", finishFrequency + 1)
        
        -- Track finish patterns
        local finishPatterns = char:getData("finish_radio_patterns", {})
        table.insert(finishPatterns, {
            freq = freq,
            channel = channel,
            time = os.time()
        })
        char:setData("finish_radio_patterns", finishPatterns)
    end
end)
```

---

## PlayerStartRadio

**Purpose**

Called when a player starts using radio.

**Parameters**

* `speaker` (*Player*): The player who started using radio.
* `freq` (*string*): The radio frequency.
* `channel` (*number*): The radio channel.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player starts using radio
- Before radio communication begins
- When the radio session starts

**Example Usage**

```lua
-- Track player start radio
hook.Add("PlayerStartRadio", "TrackPlayerStartRadio", function(speaker, freq, channel)
    local char = speaker:getChar()
    if char then
        local startRadio = char:getData("start_radio", 0)
        char:setData("start_radio", startRadio + 1)
    end
    
    lia.log.add(speaker, "playerStartRadio", freq, channel)
end)

-- Apply player start radio effects
hook.Add("PlayerStartRadio", "PlayerStartRadioEffects", function(speaker, freq, channel)
    -- Play start sound
    speaker:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    speaker:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    speaker:notify("Radio session started!")
end)

-- Track player start radio statistics
hook.Add("PlayerStartRadio", "TrackPlayerStartRadioStats", function(speaker, freq, channel)
    local char = speaker:getChar()
    if char then
        -- Track start frequency
        local startFrequency = char:getData("start_radio_frequency", 0)
        char:setData("start_radio_frequency", startFrequency + 1)
        
        -- Track start patterns
        local startPatterns = char:getData("start_radio_patterns", {})
        table.insert(startPatterns, {
            freq = freq,
            channel = channel,
            time = os.time()
        })
        char:setData("start_radio_patterns", startPatterns)
    end
end)
```

---

## ShouldRadioBeep

**Purpose**

Called to determine if a radio should beep.

**Parameters**

* `listener` (*Player*): The player who would hear the beep.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A radio beep is about to be played
- During radio communication
- When the beep validation begins

**Example Usage**

```lua
-- Control radio beep
hook.Add("ShouldRadioBeep", "ControlRadioBeep", function(listener)
    local char = listener:getChar()
    if char then
        -- Check if radio beep is disabled
        if char:getData("radio_beep_disabled", false) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
        
        -- Check if player is in a vehicle
        if listener:InVehicle() then
            return false
        end
        
        -- Check if player is in water
        if listener:WaterLevel() >= 2 then
            return false
        end
        
        -- Check cooldown
        local lastRadioBeep = char:getData("last_radio_beep_time", 0)
        if os.time() - lastRadioBeep < 0.5 then -- 0.5 second cooldown
            return false
        end
        
        -- Update last radio beep time
        char:setData("last_radio_beep_time", os.time())
    end
    
    return true
end)

-- Track radio beep checks
hook.Add("ShouldRadioBeep", "TrackRadioBeepChecks", function(listener)
    local char = listener:getChar()
    if char then
        local beepChecks = char:getData("radio_beep_checks", 0)
        char:setData("radio_beep_checks", beepChecks + 1)
    end
    
    lia.log.add(listener, "radioBeepChecked")
end)

-- Apply radio beep check effects
hook.Add("ShouldRadioBeep", "RadioBeepCheckEffects", function(listener)
    local char = listener:getChar()
    if char then
        -- Check if radio beep is disabled
        if char:getData("radio_beep_disabled", false) then
            listener:notify("Radio beep is disabled!")
        end
    end
end)
```
