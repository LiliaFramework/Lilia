# Hooks

This document describes the hooks available in the Enhanced Death module for managing hospital respawn and death functionality.

---

## HospitalDeathFlagged

**Purpose**

Called when a player's death is flagged for hospital respawn.

**Parameters**

* `client` (*Player*): The player whose death was flagged.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player dies
- The hospital system is enabled
- The death is flagged for hospital respawn

**Example Usage**

```lua
-- Track hospital death flagging
hook.Add("HospitalDeathFlagged", "TrackHospitalDeathFlagging", function(client)
    local char = client:getChar()
    if char then
        local hospitalDeaths = char:getData("hospital_deaths", 0)
        char:setData("hospital_deaths", hospitalDeaths + 1)
    end
    
    lia.log.add(client, "hospitalDeathFlagged")
end)

-- Apply hospital death flagging effects
hook.Add("HospitalDeathFlagged", "HospitalDeathFlaggingEffects", function(client)
    -- Play death sound
    client:EmitSound("vo/npc/male01/pain08.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 25), 1, 0)
    
    -- Notify player
    client:notify("You have been flagged for hospital respawn!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track hospital death flagging statistics
hook.Add("HospitalDeathFlagged", "TrackHospitalDeathFlaggingStats", function(client)
    local char = client:getChar()
    if char then
        -- Track flagging frequency
        local flaggingFrequency = char:getData("hospital_death_flagging_frequency", 0)
        char:setData("hospital_death_flagging_frequency", flaggingFrequency + 1)
        
        -- Track flagging patterns
        local flaggingPatterns = char:getData("hospital_death_flagging_patterns", {})
        table.insert(flaggingPatterns, {
            time = os.time()
        })
        char:setData("hospital_death_flagging_patterns", flaggingPatterns)
    end
end)
```

---

## HospitalMoneyLost

**Purpose**

Called when a player loses money due to hospital death.

**Parameters**

* `client` (*Player*): The player who lost money.
* `moneyLoss` (*number*): The amount of money lost.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player respawns at a hospital
- Money loss is enabled
- The money is deducted from the player's character

**Example Usage**

```lua
-- Track hospital money loss
hook.Add("HospitalMoneyLost", "TrackHospitalMoneyLoss", function(client, moneyLoss)
    local char = client:getChar()
    if char then
        local totalMoneyLost = char:getData("hospital_money_lost", 0)
        char:setData("hospital_money_lost", totalMoneyLost + moneyLoss)
    end
    
    lia.log.add(client, "hospitalMoneyLost", moneyLoss)
end)

-- Apply hospital money loss effects
hook.Add("HospitalMoneyLost", "HospitalMoneyLossEffects", function(client, moneyLoss)
    -- Play money loss sound
    client:EmitSound("ui/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("You lost " .. lia.currency.get(moneyLoss) .. " due to hospital fees!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track hospital money loss statistics
hook.Add("HospitalMoneyLost", "TrackHospitalMoneyLossStats", function(client, moneyLoss)
    local char = client:getChar()
    if char then
        -- Track money loss frequency
        local moneyLossFrequency = char:getData("hospital_money_loss_frequency", 0)
        char:setData("hospital_money_loss_frequency", moneyLossFrequency + 1)
        
        -- Track money loss patterns
        local moneyLossPatterns = char:getData("hospital_money_loss_patterns", {})
        table.insert(moneyLossPatterns, {
            amount = moneyLoss,
            time = os.time()
        })
        char:setData("hospital_money_loss_patterns", moneyLossPatterns)
    end
end)
```

---

## HospitalRespawned

**Purpose**

Called when a player respawns at a hospital.

**Parameters**

* `client` (*Player*): The player who respawned.
* `respawnLocation` (*Vector*): The location where the player respawned.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player respawns at a hospital
- The respawn location is set
- After the hospital death flag is cleared

**Example Usage**

```lua
-- Track hospital respawns
hook.Add("HospitalRespawned", "TrackHospitalRespawns", function(client, respawnLocation)
    local char = client:getChar()
    if char then
        local hospitalRespawns = char:getData("hospital_respawns", 0)
        char:setData("hospital_respawns", hospitalRespawns + 1)
    end
    
    lia.log.add(client, "hospitalRespawned", respawnLocation)
end)

-- Apply hospital respawn effects
hook.Add("HospitalRespawned", "HospitalRespawnEffects", function(client, respawnLocation)
    -- Play respawn sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("You have respawned at the hospital!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(respawnLocation)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track hospital respawn statistics
hook.Add("HospitalRespawned", "TrackHospitalRespawnStats", function(client, respawnLocation)
    local char = client:getChar()
    if char then
        -- Track respawn frequency
        local respawnFrequency = char:getData("hospital_respawn_frequency", 0)
        char:setData("hospital_respawn_frequency", respawnFrequency + 1)
        
        -- Track respawn patterns
        local respawnPatterns = char:getData("hospital_respawn_patterns", {})
        table.insert(respawnPatterns, {
            location = respawnLocation,
            time = os.time()
        })
        char:setData("hospital_respawn_patterns", respawnPatterns)
    end
end)
```
