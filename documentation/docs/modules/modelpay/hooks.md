# Hooks

This document describes the hooks available in the Model Pay module for managing model-based payment functionality.

---

## CreateSalaryTimer

**Purpose**

Called when a salary timer is created for a player.

**Parameters**

* `client` (*Player*): The player for whom the salary timer is created.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A salary timer is created for a player
- When a player's model changes to an eligible model
- During model change processing

**Example Usage**

```lua
-- Track salary timer creation
hook.Add("CreateSalaryTimer", "TrackSalaryTimerCreation", function(client)
    local char = client:getChar()
    if char then
        local timerCreations = char:getData("salary_timer_creations", 0)
        char:setData("salary_timer_creations", timerCreations + 1)
    end
    
    lia.log.add(client, "salaryTimerCreated")
end)

-- Apply salary timer creation effects
hook.Add("CreateSalaryTimer", "SalaryTimerCreationEffects", function(client)
    -- Play creation sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Salary timer created!")
end)

-- Track salary timer creation statistics
hook.Add("CreateSalaryTimer", "TrackSalaryTimerCreationStats", function(client)
    local char = client:getChar()
    if char then
        -- Track creation frequency
        local creationFrequency = char:getData("salary_timer_creation_frequency", 0)
        char:setData("salary_timer_creation_frequency", creationFrequency + 1)
        
        -- Track creation patterns
        local creationPatterns = char:getData("salary_timer_creation_patterns", {})
        table.insert(creationPatterns, {
            time = os.time()
        })
        char:setData("salary_timer_creation_patterns", creationPatterns)
    end
end)
```

---

## ModelPayModelChecked

**Purpose**

Called when a player's model is checked for payment eligibility.

**Parameters**

* `client` (*Player*): The player whose model is being checked.
* `playerModel` (*string*): The player's model string.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's model is checked for payment eligibility
- During salary amount calculation
- When the model validation begins

**Example Usage**

```lua
-- Track model checks
hook.Add("ModelPayModelChecked", "TrackModelChecks", function(client, playerModel)
    local char = client:getChar()
    if char then
        local modelChecks = char:getData("model_checks", 0)
        char:setData("model_checks", modelChecks + 1)
    end
    
    lia.log.add(client, "modelChecked", playerModel)
end)

-- Apply model check effects
hook.Add("ModelPayModelChecked", "ModelCheckEffects", function(client, playerModel)
    -- Play check sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Model checked: " .. playerModel .. "!")
end)

-- Track model check statistics
hook.Add("ModelPayModelChecked", "TrackModelCheckStats", function(client, playerModel)
    local char = client:getChar()
    if char then
        -- Track check frequency
        local checkFrequency = char:getData("model_check_frequency", 0)
        char:setData("model_check_frequency", checkFrequency + 1)
        
        -- Track check patterns
        local checkPatterns = char:getData("model_check_patterns", {})
        table.insert(checkPatterns, {
            model = playerModel,
            time = os.time()
        })
        char:setData("model_check_patterns", checkPatterns)
    end
end)
```

---

## ModelPayModelEligible

**Purpose**

Called when a player's model is eligible for payment.

**Parameters**

* `client` (*Player*): The player whose model is eligible.
* `newModel` (*string*): The new model that is eligible.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's model is eligible for payment
- When a player changes to an eligible model
- During model change processing

**Example Usage**

```lua
-- Track model eligibility
hook.Add("ModelPayModelEligible", "TrackModelEligibility", function(client, newModel)
    local char = client:getChar()
    if char then
        local modelEligibility = char:getData("model_eligibility", 0)
        char:setData("model_eligibility", modelEligibility + 1)
    end
    
    lia.log.add(client, "modelEligible", newModel)
end)

-- Apply model eligibility effects
hook.Add("ModelPayModelEligible", "ModelEligibilityEffects", function(client, newModel)
    -- Play eligibility sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Model eligible for payment: " .. newModel .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track model eligibility statistics
hook.Add("ModelPayModelEligible", "TrackModelEligibilityStats", function(client, newModel)
    local char = client:getChar()
    if char then
        -- Track eligibility frequency
        local eligibilityFrequency = char:getData("model_eligibility_frequency", 0)
        char:setData("model_eligibility_frequency", eligibilityFrequency + 1)
        
        -- Track eligibility patterns
        local eligibilityPatterns = char:getData("model_eligibility_patterns", {})
        table.insert(eligibilityPatterns, {
            model = newModel,
            time = os.time()
        })
        char:setData("model_eligibility_patterns", eligibilityPatterns)
    end
end)
```

---

## ModelPayModelIneligible

**Purpose**

Called when a player's model is not eligible for payment.

**Parameters**

* `client` (*Player*): The player whose model is not eligible.
* `newModel` (*string*): The new model that is not eligible.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's model is not eligible for payment
- When a player changes to an ineligible model
- During model change processing

**Example Usage**

```lua
-- Track model ineligibility
hook.Add("ModelPayModelIneligible", "TrackModelIneligibility", function(client, newModel)
    local char = client:getChar()
    if char then
        local modelIneligibility = char:getData("model_ineligibility", 0)
        char:setData("model_ineligibility", modelIneligibility + 1)
    end
    
    lia.log.add(client, "modelIneligible", newModel)
end)

-- Apply model ineligibility effects
hook.Add("ModelPayModelIneligible", "ModelIneligibilityEffects", function(client, newModel)
    -- Play ineligibility sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Model not eligible for payment: " .. newModel .. "!")
end)

-- Track model ineligibility statistics
hook.Add("ModelPayModelIneligible", "TrackModelIneligibilityStats", function(client, newModel)
    local char = client:getChar()
    if char then
        -- Track ineligibility frequency
        local ineligibilityFrequency = char:getData("model_ineligibility_frequency", 0)
        char:setData("model_ineligibility_frequency", ineligibilityFrequency + 1)
        
        -- Track ineligibility patterns
        local ineligibilityPatterns = char:getData("model_ineligibility_patterns", {})
        table.insert(ineligibilityPatterns, {
            model = newModel,
            time = os.time()
        })
        char:setData("model_ineligibility_patterns", ineligibilityPatterns)
    end
end)
```

---

## ModelPayModelMatched

**Purpose**

Called when a player's model matches a payment model.

**Parameters**

* `client` (*Player*): The player whose model matched.
* `model` (*string*): The model that matched.
* `pay` (*number*): The payment amount.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's model matches a payment model
- During salary amount calculation
- When a match is found

**Example Usage**

```lua
-- Track model matches
hook.Add("ModelPayModelMatched", "TrackModelMatches", function(client, model, pay)
    local char = client:getChar()
    if char then
        local modelMatches = char:getData("model_matches", 0)
        char:setData("model_matches", modelMatches + 1)
    end
    
    lia.log.add(client, "modelMatched", model, pay)
end)

-- Apply model match effects
hook.Add("ModelPayModelMatched", "ModelMatchEffects", function(client, model, pay)
    -- Play match sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Model matched! Payment: " .. pay .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track model match statistics
hook.Add("ModelPayModelMatched", "TrackModelMatchStats", function(client, model, pay)
    local char = client:getChar()
    if char then
        -- Track match frequency
        local matchFrequency = char:getData("model_match_frequency", 0)
        char:setData("model_match_frequency", matchFrequency + 1)
        
        -- Track match patterns
        local matchPatterns = char:getData("model_match_patterns", {})
        table.insert(matchPatterns, {
            model = model,
            pay = pay,
            time = os.time()
        })
        char:setData("model_match_patterns", matchPatterns)
    end
end)
```

---

## ModelPayModelNotMatched

**Purpose**

Called when a player's model does not match any payment model.

**Parameters**

* `client` (*Player*): The player whose model did not match.
* `playerModel` (*string*): The player's model string.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's model does not match any payment model
- During salary amount calculation
- When no match is found

**Example Usage**

```lua
-- Track model non-matches
hook.Add("ModelPayModelNotMatched", "TrackModelNonMatches", function(client, playerModel)
    local char = client:getChar()
    if char then
        local modelNonMatches = char:getData("model_non_matches", 0)
        char:setData("model_non_matches", modelNonMatches + 1)
    end
    
    lia.log.add(client, "modelNotMatched", playerModel)
end)

-- Apply model non-match effects
hook.Add("ModelPayModelNotMatched", "ModelNonMatchEffects", function(client, playerModel)
    -- Play non-match sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Model not matched: " .. playerModel .. "!")
end)

-- Track model non-match statistics
hook.Add("ModelPayModelNotMatched", "TrackModelNonMatchStats", function(client, playerModel)
    local char = client:getChar()
    if char then
        -- Track non-match frequency
        local nonMatchFrequency = char:getData("model_non_match_frequency", 0)
        char:setData("model_non_match_frequency", nonMatchFrequency + 1)
        
        -- Track non-match patterns
        local nonMatchPatterns = char:getData("model_non_match_patterns", {})
        table.insert(nonMatchPatterns, {
            model = playerModel,
            time = os.time()
        })
        char:setData("model_non_match_patterns", nonMatchPatterns)
    end
end)
```

---

## ModelPaySalaryDetermined

**Purpose**

Called when a salary amount is determined for a player.

**Parameters**

* `client` (*Player*): The player for whom the salary is determined.
* `pay` (*number*): The determined salary amount.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A salary amount is determined for a player
- After model matching or non-matching
- When the salary calculation is complete

**Example Usage**

```lua
-- Track salary determination
hook.Add("ModelPaySalaryDetermined", "TrackSalaryDetermination", function(client, pay)
    local char = client:getChar()
    if char then
        local salaryDeterminations = char:getData("salary_determinations", 0)
        char:setData("salary_determinations", salaryDeterminations + 1)
    end
    
    lia.log.add(client, "salaryDetermined", pay)
end)

-- Apply salary determination effects
hook.Add("ModelPaySalaryDetermined", "SalaryDeterminationEffects", function(client, pay)
    -- Play determination sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Salary determined: " .. pay .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track salary determination statistics
hook.Add("ModelPaySalaryDetermined", "TrackSalaryDeterminationStats", function(client, pay)
    local char = client:getChar()
    if char then
        -- Track determination frequency
        local determinationFrequency = char:getData("salary_determination_frequency", 0)
        char:setData("salary_determination_frequency", determinationFrequency + 1)
        
        -- Track determination patterns
        local determinationPatterns = char:getData("salary_determination_patterns", {})
        table.insert(determinationPatterns, {
            pay = pay,
            time = os.time()
        })
        char:setData("salary_determination_patterns", determinationPatterns)
    end
end)
```
