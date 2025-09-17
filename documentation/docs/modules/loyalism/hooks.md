# Hooks

This document describes the hooks available in the Loyalism module for managing loyalty tier system functionality.

---

## PartyTierApplying

**Purpose**

Called when a party tier is being applied to a player.

**Parameters**

* `player` (*Player*): The player whose tier is being applied.
* `tier` (*number*): The tier number being applied.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A party tier is being applied to a player
- After `PreUpdatePartyTiers` hook
- Before `PartyTierUpdated` hook

**Example Usage**

```lua
-- Track party tier applications
hook.Add("PartyTierApplying", "TrackPartyTierApplications", function(player, tier)
    local char = player:getChar()
    if char then
        local tierApplications = char:getData("party_tier_applications", 0)
        char:setData("party_tier_applications", tierApplications + 1)
    end
    
    lia.log.add(player, "partyTierApplying", tier)
end)

-- Apply party tier application effects
hook.Add("PartyTierApplying", "PartyTierApplicationEffects", function(player, tier)
    -- Play application sound
    player:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    player:notify("Applying party tier: " .. tier .. "!")
end)

-- Track party tier application statistics
hook.Add("PartyTierApplying", "TrackPartyTierApplicationStats", function(player, tier)
    local char = player:getChar()
    if char then
        -- Track application frequency
        local applicationFrequency = char:getData("party_tier_application_frequency", 0)
        char:setData("party_tier_application_frequency", applicationFrequency + 1)
        
        -- Track application patterns
        local applicationPatterns = char:getData("party_tier_application_patterns", {})
        table.insert(applicationPatterns, {
            tier = tier,
            time = os.time()
        })
        char:setData("party_tier_application_patterns", applicationPatterns)
    end
end)
```

---

## PartyTierNoCharacter

**Purpose**

Called when a player has no character during party tier update.

**Parameters**

* `player` (*Player*): The player who has no character.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player has no character during party tier update
- After `PreUpdatePartyTiers` hook
- When the character check fails

**Example Usage**

```lua
-- Track party tier no character cases
hook.Add("PartyTierNoCharacter", "TrackPartyTierNoCharacter", function(player)
    local noCharacterCases = player:getData("party_tier_no_character_cases", 0)
    player:setData("party_tier_no_character_cases", noCharacterCases + 1)
    
    lia.log.add(player, "partyTierNoCharacter")
end)

-- Apply party tier no character effects
hook.Add("PartyTierNoCharacter", "PartyTierNoCharacterEffects", function(player)
    -- Play no character sound
    player:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 10), 0.3, 0)
    
    -- Notify player
    player:notify("No character found for party tier update!")
end)

-- Track party tier no character statistics
hook.Add("PartyTierNoCharacter", "TrackPartyTierNoCharacterStats", function(player)
    -- Track no character frequency
    local noCharacterFrequency = player:getData("party_tier_no_character_frequency", 0)
    player:setData("party_tier_no_character_frequency", noCharacterFrequency + 1)
    
    -- Track no character patterns
    local noCharacterPatterns = player:getData("party_tier_no_character_patterns", {})
    table.insert(noCharacterPatterns, {
        time = os.time()
    })
    player:setData("party_tier_no_character_patterns", noCharacterPatterns)
end)
```

---

## PartyTierUpdated

**Purpose**

Called when a party tier is updated for a player.

**Parameters**

* `player` (*Player*): The player whose tier was updated.
* `tier` (*number*): The tier number that was set.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A party tier is updated for a player
- After `PartyTierApplying` hook
- When the tier is successfully set

**Example Usage**

```lua
-- Track party tier updates
hook.Add("PartyTierUpdated", "TrackPartyTierUpdates", function(player, tier)
    local char = player:getChar()
    if char then
        local tierUpdates = char:getData("party_tier_updates", 0)
        char:setData("party_tier_updates", tierUpdates + 1)
    end
    
    lia.log.add(player, "partyTierUpdated", tier)
end)

-- Apply party tier update effects
hook.Add("PartyTierUpdated", "PartyTierUpdateEffects", function(player, tier)
    -- Play update sound
    player:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    player:notify("Party tier updated to: " .. tier .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track party tier update statistics
hook.Add("PartyTierUpdated", "TrackPartyTierUpdateStats", function(player, tier)
    local char = player:getChar()
    if char then
        -- Track update frequency
        local updateFrequency = char:getData("party_tier_update_frequency", 0)
        char:setData("party_tier_update_frequency", updateFrequency + 1)
        
        -- Track update patterns
        local updatePatterns = char:getData("party_tier_update_patterns", {})
        table.insert(updatePatterns, {
            tier = tier,
            time = os.time()
        })
        char:setData("party_tier_update_patterns", updatePatterns)
    end
end)
```

---

## PostUpdatePartyTiers

**Purpose**

Called after all party tiers have been updated.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- All party tiers have been updated
- After `PartyTierUpdated` hook for all players
- When the update cycle is complete

**Example Usage**

```lua
-- Track party tier update completion
hook.Add("PostUpdatePartyTiers", "TrackPartyTierUpdateCompletion", function()
    -- Track completion
    local completions = lia.data.get("party_tier_update_completions", 0)
    lia.data.set("party_tier_update_completions", completions + 1)
    
    lia.log.add(nil, "partyTierUpdateCompleted")
end)

-- Apply post update party tiers effects
hook.Add("PostUpdatePartyTiers", "PostUpdatePartyTiersEffects", function()
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Party tier update cycle completed!")
    end
end)

-- Track post update party tiers statistics
hook.Add("PostUpdatePartyTiers", "TrackPostUpdatePartyTiersStats", function()
    -- Track completion frequency
    local completionFrequency = lia.data.get("party_tier_update_completion_frequency", 0)
    lia.data.set("party_tier_update_completion_frequency", completionFrequency + 1)
    
    -- Track completion patterns
    local completionPatterns = lia.data.get("party_tier_update_completion_patterns", {})
    table.insert(completionPatterns, {
        time = os.time()
    })
    lia.data.set("party_tier_update_completion_patterns", completionPatterns)
end)
```

---

## PreUpdatePartyTiers

**Purpose**

Called before party tiers are updated.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Party tiers are about to be updated
- Before `PartyTierApplying` hook
- When the update cycle begins

**Example Usage**

```lua
-- Track party tier update preparation
hook.Add("PreUpdatePartyTiers", "TrackPartyTierUpdatePreparation", function()
    -- Track preparation
    local preparations = lia.data.get("party_tier_update_preparations", 0)
    lia.data.set("party_tier_update_preparations", preparations + 1)
    
    lia.log.add(nil, "partyTierUpdatePrepared")
end)

-- Apply pre update party tiers effects
hook.Add("PreUpdatePartyTiers", "PreUpdatePartyTiersEffects", function()
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Preparing party tier update...")
    end
end)

-- Track pre update party tiers statistics
hook.Add("PreUpdatePartyTiers", "TrackPreUpdatePartyTiersStats", function()
    -- Track preparation frequency
    local preparationFrequency = lia.data.get("party_tier_update_preparation_frequency", 0)
    lia.data.set("party_tier_update_preparation_frequency", preparationFrequency + 1)
    
    -- Track preparation patterns
    local preparationPatterns = lia.data.get("party_tier_update_preparation_patterns", {})
    table.insert(preparationPatterns, {
        time = os.time()
    })
    lia.data.set("party_tier_update_preparation_patterns", preparationPatterns)
end)
```
