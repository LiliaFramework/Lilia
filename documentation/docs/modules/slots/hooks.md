# Hooks

This document describes the hooks available in the Slots module for managing slot machine functionality.

---

## SlotMachineEnd

**Purpose**

Called when a slot machine game ends.

**Parameters**

* `machine` (*Entity*): The slot machine entity.
* `client` (*Player*): The player who played the machine.
* `payout` (*number*): The payout amount (0 if no win).

**Realm**

Server.

**When Called**

This hook is triggered when:
- A slot machine game ends
- After `SlotMachinePayout` hook
- When the game is complete

**Example Usage**

```lua
-- Track slot machine game endings
hook.Add("SlotMachineEnd", "TrackSlotMachineGameEndings", function(machine, client, payout)
    local char = client:getChar()
    if char then
        local gameEndings = char:getData("slot_machine_game_endings", 0)
        char:setData("slot_machine_game_endings", gameEndings + 1)
        
        -- Track payout patterns
        local payoutPatterns = char:getData("slot_machine_payout_patterns", {})
        payoutPatterns[payout] = (payoutPatterns[payout] or 0) + 1
        char:setData("slot_machine_payout_patterns", payoutPatterns)
    end
    
    lia.log.add(client, "slotMachineGameEnded", machine, payout)
end)

-- Apply slot machine game ending effects
hook.Add("SlotMachineEnd", "SlotMachineGameEndingEffects", function(machine, client, payout)
    -- Play ending sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    local status = payout > 0 and "won" or "lost"
    client:notify("Slot machine game ended! You " .. status .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(machine:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track slot machine game ending statistics
hook.Add("SlotMachineEnd", "TrackSlotMachineGameEndingStats", function(machine, client, payout)
    local char = client:getChar()
    if char then
        -- Track ending frequency
        local endingFrequency = char:getData("slot_machine_ending_frequency", 0)
        char:setData("slot_machine_ending_frequency", endingFrequency + 1)
        
        -- Track ending patterns
        local endingPatterns = char:getData("slot_machine_ending_patterns", {})
        table.insert(endingPatterns, {
            payout = payout,
            time = os.time()
        })
        char:setData("slot_machine_ending_patterns", endingPatterns)
    end
end)
```

---

## SlotMachinePayout

**Purpose**

Called when a slot machine pays out to a player.

**Parameters**

* `machine` (*Entity*): The slot machine entity.
* `client` (*Player*): The player who won the payout.
* `payout` (*number*): The payout amount.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A slot machine pays out to a player
- After `SlotMachineStart` hook
- Before `SlotMachineEnd` hook

**Example Usage**

```lua
-- Track slot machine payouts
hook.Add("SlotMachinePayout", "TrackSlotMachinePayouts", function(machine, client, payout)
    local char = client:getChar()
    if char then
        local payouts = char:getData("slot_machine_payouts", 0)
        char:setData("slot_machine_payouts", payouts + 1)
        
        -- Track total winnings
        local totalWinnings = char:getData("slot_machine_total_winnings", 0)
        char:setData("slot_machine_total_winnings", totalWinnings + payout)
    end
    
    lia.log.add(client, "slotMachinePayout", machine, payout)
end)

-- Apply slot machine payout effects
hook.Add("SlotMachinePayout", "SlotMachinePayoutEffects", function(machine, client, payout)
    -- Play payout sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Slot machine payout: " .. payout .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(machine:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track slot machine payout statistics
hook.Add("SlotMachinePayout", "TrackSlotMachinePayoutStats", function(machine, client, payout)
    local char = client:getChar()
    if char then
        -- Track payout frequency
        local payoutFrequency = char:getData("slot_machine_payout_frequency", 0)
        char:setData("slot_machine_payout_frequency", payoutFrequency + 1)
        
        -- Track payout patterns
        local payoutPatterns = char:getData("slot_machine_payout_patterns", {})
        table.insert(payoutPatterns, {
            payout = payout,
            time = os.time()
        })
        char:setData("slot_machine_payout_patterns", payoutPatterns)
    end
end)
```

---

## SlotMachineStart

**Purpose**

Called when a slot machine game starts.

**Parameters**

* `machine` (*Entity*): The slot machine entity.
* `client` (*Player*): The player who started the game.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A slot machine game starts
- After `SlotMachineUse` hook
- When the game begins

**Example Usage**

```lua
-- Track slot machine game starts
hook.Add("SlotMachineStart", "TrackSlotMachineGameStarts", function(machine, client)
    local char = client:getChar()
    if char then
        local gameStarts = char:getData("slot_machine_game_starts", 0)
        char:setData("slot_machine_game_starts", gameStarts + 1)
    end
    
    lia.log.add(client, "slotMachineGameStarted", machine)
end)

-- Apply slot machine game start effects
hook.Add("SlotMachineStart", "SlotMachineGameStartEffects", function(machine, client)
    -- Play start sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Slot machine game started!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(machine:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track slot machine game start statistics
hook.Add("SlotMachineStart", "TrackSlotMachineGameStartStats", function(machine, client)
    local char = client:getChar()
    if char then
        -- Track start frequency
        local startFrequency = char:getData("slot_machine_start_frequency", 0)
        char:setData("slot_machine_start_frequency", startFrequency + 1)
        
        -- Track start patterns
        local startPatterns = char:getData("slot_machine_start_patterns", {})
        table.insert(startPatterns, {
            time = os.time()
        })
        char:setData("slot_machine_start_patterns", startPatterns)
    end
end)
```

---

## SlotMachineUse

**Purpose**

Called when a player uses a slot machine.

**Parameters**

* `machine` (*Entity*): The slot machine entity.
* `client` (*Player*): The player using the machine.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player uses a slot machine
- Before `SlotMachineStart` hook
- When the use interaction begins

**Example Usage**

```lua
-- Track slot machine usage
hook.Add("SlotMachineUse", "TrackSlotMachineUsage", function(machine, client)
    local char = client:getChar()
    if char then
        local machineUsage = char:getData("slot_machine_usage", 0)
        char:setData("slot_machine_usage", machineUsage + 1)
    end
    
    lia.log.add(client, "slotMachineUsed", machine)
end)

-- Apply slot machine usage effects
hook.Add("SlotMachineUse", "SlotMachineUsageEffects", function(machine, client)
    -- Play usage sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Using slot machine...")
end)

-- Track slot machine usage statistics
hook.Add("SlotMachineUse", "TrackSlotMachineUsageStats", function(machine, client)
    local char = client:getChar()
    if char then
        -- Track usage frequency
        local usageFrequency = char:getData("slot_machine_usage_frequency", 0)
        char:setData("slot_machine_usage_frequency", usageFrequency + 1)
        
        -- Track usage patterns
        local usagePatterns = char:getData("slot_machine_usage_patterns", {})
        table.insert(usagePatterns, {
            time = os.time()
        })
        char:setData("slot_machine_usage_patterns", usagePatterns)
    end
end)
```
