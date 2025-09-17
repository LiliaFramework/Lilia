# Hooks

This document describes the hooks available in the Corpse ID module for managing corpse identification functionality.

---

## CorpseCreated

**Purpose**

Called when a corpse is created for a player.

**Parameters**

* `client` (*Player*): The player whose corpse was created.
* `corpse` (*Entity*): The ragdoll corpse entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player dies and a ragdoll is created
- The corpse is set up with player information
- Before the corpse becomes available for identification

**Example Usage**

```lua
-- Track corpse creation
hook.Add("CorpseCreated", "TrackCorpseCreation", function(client, corpse)
    local char = client:getChar()
    if char then
        local corpsesCreated = char:getData("corpses_created", 0)
        char:setData("corpses_created", corpsesCreated + 1)
        
        -- Track death location
        char:setData("last_death_location", client:GetPos())
        char:setData("last_death_time", os.time())
    end
    
    lia.log.add(client, "corpseCreated", client:GetPos())
end)

-- Apply corpse effects
hook.Add("CorpseCreated", "CorpseCreationEffects", function(client, corpse)
    -- Play death sound
    client:EmitSound("vo/npc/male01/pain08.wav", 75, 100)
    
    -- Create death particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Set corpse properties
    corpse:setNetVar("ShowCorpseMessage", true)
    corpse:setNetVar("player", client)
    corpse:setNetVar("death_time", os.time())
end)

-- Notify nearby players
hook.Add("CorpseCreated", "NotifyNearbyPlayers", function(client, corpse)
    for _, ply in player.Iterator() do
        if ply ~= client and ply:GetPos():Distance(client:GetPos()) < 500 then
            ply:notify(client:Name() .. " has died nearby!")
        end
    end
end)

-- Track death statistics
hook.Add("CorpseCreated", "TrackDeathStats", function(client, corpse)
    local char = client:getChar()
    if char then
        local deaths = char:getData("total_deaths", 0)
        char:setData("total_deaths", deaths + 1)
        
        -- Track death causes
        local deathCause = client:GetNWString("LastDamageType", "unknown")
        local deathCauses = char:getData("death_causes", {})
        deathCauses[deathCause] = (deathCauses[deathCause] or 0) + 1
        char:setData("death_causes", deathCauses)
    end
end)
```

---

## CorpseIdentified

**Purpose**

Called when a corpse has been successfully identified.

**Parameters**

* `client` (*Player*): The player who identified the corpse.
* `targetPlayer` (*Player*): The player whose corpse was identified.
* `corpse` (*Entity*): The ragdoll corpse entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player completes the identification process
- After the identification time has elapsed
- After `CorpseIdentifyStarted` hook

**Example Usage**

```lua
-- Track corpse identifications
hook.Add("CorpseIdentified", "TrackCorpseIdentifications", function(client, targetPlayer, corpse)
    local char = client:getChar()
    if char then
        local identifications = char:getData("corpse_identifications", 0)
        char:setData("corpse_identifications", identifications + 1)
        
        -- Track identification targets
        local targetIdentifications = char:getData("target_identifications", {})
        targetIdentifications[targetPlayer:SteamID()] = (targetIdentifications[targetPlayer:SteamID()] or 0) + 1
        char:setData("target_identifications", targetIdentifications)
    end
    
    lia.log.add(client, "corpseIdentified", targetPlayer:Name())
end)

-- Apply identification effects
hook.Add("CorpseIdentified", "IdentificationEffects", function(client, targetPlayer, corpse)
    -- Play identification sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 1, 0)
    
    -- Notify client
    client:notify("Successfully identified " .. targetPlayer:Name() .. "'s corpse!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(corpse:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Award identification achievements
hook.Add("CorpseIdentified", "IdentificationAchievements", function(client, targetPlayer, corpse)
    local char = client:getChar()
    if char then
        local identifications = char:getData("corpse_identifications", 0)
        
        if identifications == 1 then
            client:notify("Achievement: First Identification!")
        elseif identifications == 10 then
            client:notify("Achievement: Corpse Detective!")
        elseif identifications == 50 then
            client:notify("Achievement: Master Investigator!")
        end
        
        -- Check for specific target achievements
        local targetIdentifications = char:getData("target_identifications", {})
        local targetCount = targetIdentifications[targetPlayer:SteamID()] or 0
        
        if targetCount == 1 then
            client:notify("Achievement: First time identifying " .. targetPlayer:Name() .. "!")
        end
    end
end)

-- Track identification patterns
hook.Add("CorpseIdentified", "TrackIdentificationPatterns", function(client, targetPlayer, corpse)
    local char = client:getChar()
    if char then
        -- Track identification frequency
        local lastIdentification = char:getData("last_identification_time", 0)
        char:setData("last_identification_time", os.time())
        
        -- Track identification speed
        local identificationStart = char:getData("identification_start_time", 0)
        if identificationStart > 0 then
            local identificationTime = os.time() - identificationStart
            char:setData("avg_identification_time", char:getData("avg_identification_time", 0) + identificationTime)
        end
    end
end)
```

---

## CorpseIdentifyBegin

**Purpose**

Called when a player begins the corpse identification process.

**Parameters**

* `client` (*Player*): The player who is beginning identification.
* `entity` (*Entity*): The ragdoll corpse entity being identified.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player chooses to identify a corpse
- Before the identification timer starts
- After the identification question is answered positively

**Example Usage**

```lua
-- Track identification attempts
hook.Add("CorpseIdentifyBegin", "TrackIdentificationAttempts", function(client, entity)
    local char = client:getChar()
    if char then
        local identificationAttempts = char:getData("identification_attempts", 0)
        char:setData("identification_attempts", identificationAttempts + 1)
        
        -- Set identification start time
        char:setData("identification_start_time", os.time())
    end
    
    lia.log.add(client, "corpseIdentifyBegin", entity:GetPos())
end)

-- Apply identification start effects
hook.Add("CorpseIdentifyBegin", "IdentificationStartEffects", function(client, entity)
    -- Play start sound
    client:EmitSound("buttons/button15.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.5, 0)
    
    -- Notify client
    client:notify("Beginning corpse identification...")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(entity:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Apply identification restrictions
hook.Add("CorpseIdentifyBegin", "ApplyIdentificationRestrictions", function(client, entity)
    local char = client:getChar()
    if char then
        -- Check cooldown
        local lastIdentification = char:getData("last_identification_time", 0)
        if os.time() - lastIdentification < 10 then -- 10 second cooldown
            client:notify("Please wait before identifying another corpse!")
            return false
        end
        
        -- Check if already identifying
        if char:getData("currently_identifying", false) then
            client:notify("You are already identifying a corpse!")
            return false
        end
        
        -- Set identification status
        char:setData("currently_identifying", true)
        char:setData("identification_target", entity:EntIndex())
    end
end)

-- Track identification statistics
hook.Add("CorpseIdentifyBegin", "TrackIdentificationStats", function(client, entity)
    local char = client:getChar()
    if char then
        -- Track identification locations
        local identificationLocations = char:getData("identification_locations", {})
        table.insert(identificationLocations, {
            pos = entity:GetPos(),
            time = os.time()
        })
        char:setData("identification_locations", identificationLocations)
        
        -- Track identification targets
        local targetPlayer = entity:getNetVar("player")
        if IsValid(targetPlayer) then
            local targetIdentifications = char:getData("target_identification_attempts", {})
            targetIdentifications[targetPlayer:SteamID()] = (targetIdentifications[targetPlayer:SteamID()] or 0) + 1
            char:setData("target_identification_attempts", targetIdentifications)
        end
    end
end)
```

---

## CorpseIdentifyDeclined

**Purpose**

Called when a player declines to identify a corpse.

**Parameters**

* `client` (*Player*): The player who declined identification.
* `entity` (*Entity*): The ragdoll corpse entity that was declined.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player chooses not to identify a corpse
- After the identification question is answered negatively

**Example Usage**

```lua
-- Track identification declines
hook.Add("CorpseIdentifyDeclined", "TrackIdentificationDeclines", function(client, entity)
    local char = client:getChar()
    if char then
        local identificationDeclines = char:getData("identification_declines", 0)
        char:setData("identification_declines", identificationDeclines + 1)
    end
    
    lia.log.add(client, "corpseIdentifyDeclined", entity:GetPos())
end)

-- Apply decline effects
hook.Add("CorpseIdentifyDeclined", "IdentificationDeclineEffects", function(client, entity)
    -- Play decline sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 5), 0.5, 0)
    
    -- Notify client
    client:notify("Corpse identification declined.")
end)

-- Track decline patterns
hook.Add("CorpseIdentifyDeclined", "TrackDeclinePatterns", function(client, entity)
    local char = client:getChar()
    if char then
        -- Track decline frequency
        local lastDecline = char:getData("last_decline_time", 0)
        char:setData("last_decline_time", os.time())
        
        -- Track decline reasons
        local declineReasons = char:getData("decline_reasons", {})
        local reason = "unknown"
        
        -- Determine decline reason based on context
        if entity:GetPos():Distance(client:GetPos()) > 200 then
            reason = "too_far"
        elseif client:getChar():getData("injured", false) then
            reason = "injured"
        elseif client:getChar():getData("busy", false) then
            reason = "busy"
        end
        
        declineReasons[reason] = (declineReasons[reason] or 0) + 1
        char:setData("decline_reasons", declineReasons)
    end
end)

-- Apply decline restrictions
hook.Add("CorpseIdentifyDeclined", "ApplyDeclineRestrictions", function(client, entity)
    local char = client:getChar()
    if char then
        -- Check decline cooldown
        local lastDecline = char:getData("last_decline_time", 0)
        if os.time() - lastDecline < 5 then -- 5 second cooldown
            client:notify("Please wait before declining another identification!")
            return false
        end
        
        -- Track decline frequency
        local declineCount = char:getData("recent_declines", 0)
        char:setData("recent_declines", declineCount + 1)
        
        -- Reset decline count after 1 minute
        timer.Simple(60, function()
            if IsValid(client) and client:getChar() then
                client:getChar():setData("recent_declines", 0)
            end
        end)
    end
end)
```

---

## CorpseIdentifyStarted

**Purpose**

Called when the corpse identification process starts (timer begins).

**Parameters**

* `client` (*Player*): The player who is identifying the corpse.
* `targetPlayer` (*Player*): The player whose corpse is being identified.
* `corpse` (*Entity*): The ragdoll corpse entity.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The identification timer starts
- After `CorpseIdentifyBegin` hook
- Before the identification process begins

**Example Usage**

```lua
-- Track identification start
hook.Add("CorpseIdentifyStarted", "TrackIdentificationStart", function(client, targetPlayer, corpse)
    local char = client:getChar()
    if char then
        char:setData("identification_start_time", os.time())
        char:setData("identification_target", targetPlayer:SteamID())
    end
    
    lia.log.add(client, "corpseIdentifyStarted", targetPlayer:Name())
end)

-- Apply identification start effects
hook.Add("CorpseIdentifyStarted", "IdentificationStartEffects", function(client, targetPlayer, corpse)
    -- Play start sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 255, 10), 1, 0)
    
    -- Notify client
    client:notify("Identifying " .. targetPlayer:Name() .. "'s corpse...")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(corpse:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track identification statistics
hook.Add("CorpseIdentifyStarted", "TrackIdentificationStats", function(client, targetPlayer, corpse)
    local char = client:getChar()
    if char then
        -- Track identification targets
        local targetIdentifications = char:getData("target_identification_starts", {})
        targetIdentifications[targetPlayer:SteamID()] = (targetIdentifications[targetPlayer:SteamID()] or 0) + 1
        char:setData("target_identification_starts", targetIdentifications)
        
        -- Track identification locations
        local identificationLocations = char:getData("identification_start_locations", {})
        table.insert(identificationLocations, {
            pos = corpse:GetPos(),
            target = targetPlayer:Name(),
            time = os.time()
        })
        char:setData("identification_start_locations", identificationLocations)
    end
end)

-- Apply identification restrictions
hook.Add("CorpseIdentifyStarted", "ApplyIdentificationRestrictions", function(client, targetPlayer, corpse)
    local char = client:getChar()
    if char then
        -- Check if already identifying
        if char:getData("currently_identifying", false) then
            client:notify("You are already identifying a corpse!")
            return false
        end
        
        -- Set identification status
        char:setData("currently_identifying", true)
        char:setData("identification_target", targetPlayer:SteamID())
        
        -- Check identification limits
        local identificationsToday = char:getData("identifications_today", 0)
        if identificationsToday >= 20 then
            client:notify("Daily identification limit reached!")
            return false
        end
    end
end)

-- Notify target player
hook.Add("CorpseIdentifyStarted", "NotifyTargetPlayer", function(client, targetPlayer, corpse)
    -- Notify target player if they're online
    if IsValid(targetPlayer) then
        targetPlayer:notify(client:Name() .. " is identifying your corpse!")
    end
    
    -- Notify nearby players
    for _, ply in player.Iterator() do
        if ply ~= client and ply:GetPos():Distance(corpse:GetPos()) < 300 then
            ply:notify(client:Name() .. " is identifying " .. targetPlayer:Name() .. "'s corpse!")
        end
    end
end)
```
