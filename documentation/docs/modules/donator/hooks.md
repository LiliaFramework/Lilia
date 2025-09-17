# Hooks

This document describes the hooks available in the Donator module for managing donor perks and benefits.

---

## DonatorAdditionalSlotsGiven

**Purpose**

Called when additional character slots are given to a donator.

**Parameters**

* `player` (*Player*): The player who received the additional slots.
* `addValue` (*number*): The number of additional slots given.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Additional character slots are given to a player
- The `GiveAdditionalCharSlots` function is called
- After `DonatorAdditionalSlotsSet` hook

**Example Usage**

```lua
-- Track additional slots given
hook.Add("DonatorAdditionalSlotsGiven", "TrackAdditionalSlotsGiven", function(player, addValue)
    local char = player:getChar()
    if char then
        local slotsGiven = char:getData("additional_slots_given", 0)
        char:setData("additional_slots_given", slotsGiven + addValue)
    end
    
    lia.log.add(player, "additionalSlotsGiven", addValue)
end)

-- Apply additional slots effects
hook.Add("DonatorAdditionalSlotsGiven", "AdditionalSlotsEffects", function(player, addValue)
    -- Play success sound
    player:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    player:notify("You received " .. addValue .. " additional character slots!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track additional slots statistics
hook.Add("DonatorAdditionalSlotsGiven", "TrackAdditionalSlotsStats", function(player, addValue)
    local char = player:getChar()
    if char then
        -- Track total slots given
        local totalSlotsGiven = char:getData("total_slots_given", 0)
        char:setData("total_slots_given", totalSlotsGiven + addValue)
        
        -- Track slots given patterns
        local slotsPatterns = char:getData("slots_given_patterns", {})
        table.insert(slotsPatterns, {
            amount = addValue,
            time = os.time()
        })
        char:setData("slots_given_patterns", slotsPatterns)
    end
end)
```

---

## DonatorAdditionalSlotsSet

**Purpose**

Called when additional character slots are set for a donator.

**Parameters**

* `player` (*Player*): The player whose slots are being set.
* `value` (*number*): The new number of additional slots.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Additional character slots are set for a player
- The `SetAdditionalCharSlots` function is called
- Before `DonatorAdditionalSlotsGiven` hook

**Example Usage**

```lua
-- Track additional slots set
hook.Add("DonatorAdditionalSlotsSet", "TrackAdditionalSlotsSet", function(player, value)
    local char = player:getChar()
    if char then
        local slotsSet = char:getData("additional_slots_set", 0)
        char:setData("additional_slots_set", slotsSet + 1)
    end
    
    lia.log.add(player, "additionalSlotsSet", value)
end)

-- Apply additional slots set effects
hook.Add("DonatorAdditionalSlotsSet", "AdditionalSlotsSetEffects", function(player, value)
    -- Play set sound
    player:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 10), 0.3, 0)
    
    -- Notify player
    player:notify("Your additional character slots have been set to " .. value .. "!")
end)

-- Track additional slots set statistics
hook.Add("DonatorAdditionalSlotsSet", "TrackAdditionalSlotsSetStats", function(player, value)
    local char = player:getChar()
    if char then
        -- Track slots set frequency
        local slotsSetFrequency = char:getData("slots_set_frequency", 0)
        char:setData("slots_set_frequency", slotsSetFrequency + 1)
        
        -- Track slots set patterns
        local slotsSetPatterns = char:getData("slots_set_patterns", {})
        table.insert(slotsSetPatterns, {
            value = value,
            time = os.time()
        })
        char:setData("slots_set_patterns", slotsSetPatterns)
    end
end)
```

---

## DonatorFlagsGiven

**Purpose**

Called when donator flags are given to a player.

**Parameters**

* `target` (*Player*): The player who received the flags.
* `flags` (*string*): The flags that were given.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Donator flags are given to a player
- The `lia_giveflags` command is executed
- After the flags are applied to the character

**Example Usage**

```lua
-- Track donator flags given
hook.Add("DonatorFlagsGiven", "TrackDonatorFlagsGiven", function(target, flags)
    local char = target:getChar()
    if char then
        local flagsGiven = char:getData("donator_flags_given", 0)
        char:setData("donator_flags_given", flagsGiven + 1)
        
        -- Track specific flags
        local specificFlags = char:getData("donator_specific_flags", {})
        specificFlags[flags] = (specificFlags[flags] or 0) + 1
        char:setData("donator_specific_flags", specificFlags)
    end
    
    lia.log.add(target, "donatorFlagsGiven", flags)
end)

-- Apply donator flags effects
hook.Add("DonatorFlagsGiven", "DonatorFlagsEffects", function(target, flags)
    -- Play success sound
    target:EmitSound("buttons/button15.wav", 75, 100)
    
    -- Apply screen effect
    target:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    target:notify("You received donator flags: " .. flags .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(target:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track donator flags statistics
hook.Add("DonatorFlagsGiven", "TrackDonatorFlagsStats", function(target, flags)
    local char = target:getChar()
    if char then
        -- Track flags given frequency
        local flagsGivenFrequency = char:getData("donator_flags_given_frequency", 0)
        char:setData("donator_flags_given_frequency", flagsGivenFrequency + 1)
        
        -- Track flags given patterns
        local flagsPatterns = char:getData("donator_flags_patterns", {})
        table.insert(flagsPatterns, {
            flags = flags,
            time = os.time()
        })
        char:setData("donator_flags_patterns", flagsPatterns)
    end
end)
```

---

## DonatorFlagsGranted

**Purpose**

Called when donator flags are granted to a player based on their usergroup.

**Parameters**

* `client` (*Player*): The player who received the flags.
* `group` (*string*): The donator group that granted the flags.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player loads a character
- The player's usergroup matches a donator group
- After the flags are applied to the character

**Example Usage**

```lua
-- Track donator flags granted
hook.Add("DonatorFlagsGranted", "TrackDonatorFlagsGranted", function(client, group)
    local char = client:getChar()
    if char then
        local flagsGranted = char:getData("donator_flags_granted", 0)
        char:setData("donator_flags_granted", flagsGranted + 1)
        
        -- Track donator group
        char:setData("donator_group", group)
    end
    
    lia.log.add(client, "donatorFlagsGranted", group)
end)

-- Apply donator flags granted effects
hook.Add("DonatorFlagsGranted", "DonatorFlagsGrantedEffects", function(client, group)
    -- Play granted sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Donator flags granted for group: " .. group .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track donator flags granted statistics
hook.Add("DonatorFlagsGranted", "TrackDonatorFlagsGrantedStats", function(client, group)
    local char = client:getChar()
    if char then
        -- Track flags granted frequency
        local flagsGrantedFrequency = char:getData("donator_flags_granted_frequency", 0)
        char:setData("donator_flags_granted_frequency", flagsGrantedFrequency + 1)
        
        -- Track donator group patterns
        local groupPatterns = char:getData("donator_group_patterns", {})
        groupPatterns[group] = (groupPatterns[group] or 0) + 1
        char:setData("donator_group_patterns", groupPatterns)
    end
end)
```

---

## DonatorItemGiven

**Purpose**

Called when a donator item is given to a player.

**Parameters**

* `target` (*Player*): The player who received the item.
* `uniqueID` (*string*): The unique ID of the item that was given.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A donator item is given to a player
- The `lia_giveitem` command is executed
- After the item is added to the player's inventory

**Example Usage**

```lua
-- Track donator item given
hook.Add("DonatorItemGiven", "TrackDonatorItemGiven", function(target, uniqueID)
    local char = target:getChar()
    if char then
        local itemsGiven = char:getData("donator_items_given", 0)
        char:setData("donator_items_given", itemsGiven + 1)
        
        -- Track specific items
        local specificItems = char:getData("donator_specific_items", {})
        specificItems[uniqueID] = (specificItems[uniqueID] or 0) + 1
        char:setData("donator_specific_items", specificItems)
    end
    
    lia.log.add(target, "donatorItemGiven", uniqueID)
end)

-- Apply donator item effects
hook.Add("DonatorItemGiven", "DonatorItemEffects", function(target, uniqueID)
    -- Play success sound
    target:EmitSound("items/item_pickup.wav", 75, 100)
    
    -- Apply screen effect
    target:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    target:notify("You received a donator item: " .. uniqueID .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(target:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track donator item statistics
hook.Add("DonatorItemGiven", "TrackDonatorItemStats", function(target, uniqueID)
    local char = target:getChar()
    if char then
        -- Track items given frequency
        local itemsGivenFrequency = char:getData("donator_items_given_frequency", 0)
        char:setData("donator_items_given_frequency", itemsGivenFrequency + 1)
        
        -- Track items given patterns
        local itemsPatterns = char:getData("donator_items_patterns", {})
        table.insert(itemsPatterns, {
            item = uniqueID,
            time = os.time()
        })
        char:setData("donator_items_patterns", itemsPatterns)
    end
end)
```

---

## DonatorMoneyGiven

**Purpose**

Called when donator money is given to a player.

**Parameters**

* `target` (*Player*): The player who received the money.
* `amount` (*number*): The amount of money that was given.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Donator money is given to a player
- The `lia_givemoney` command is executed
- After the money is added to the player's character

**Example Usage**

```lua
-- Track donator money given
hook.Add("DonatorMoneyGiven", "TrackDonatorMoneyGiven", function(target, amount)
    local char = target:getChar()
    if char then
        local moneyGiven = char:getData("donator_money_given", 0)
        char:setData("donator_money_given", moneyGiven + amount)
    end
    
    lia.log.add(target, "donatorMoneyGiven", amount)
end)

-- Apply donator money effects
hook.Add("DonatorMoneyGiven", "DonatorMoneyEffects", function(target, amount)
    -- Play success sound
    target:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    target:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    target:notify("You received donator money: " .. lia.currency.get(amount) .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(target:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track donator money statistics
hook.Add("DonatorMoneyGiven", "TrackDonatorMoneyStats", function(target, amount)
    local char = target:getChar()
    if char then
        -- Track money given frequency
        local moneyGivenFrequency = char:getData("donator_money_given_frequency", 0)
        char:setData("donator_money_given_frequency", moneyGivenFrequency + 1)
        
        -- Track money given patterns
        local moneyPatterns = char:getData("donator_money_patterns", {})
        table.insert(moneyPatterns, {
            amount = amount,
            time = os.time()
        })
        char:setData("donator_money_patterns", moneyPatterns)
    end
end)
```

---

## DonatorSlotsAdded

**Purpose**

Called when character slots are added to a donator.

**Parameters**

* `player` (*Player*): The player who received the slots.
* `current` (*number*): The current number of slots after addition.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Character slots are added to a player
- The `AddOverrideCharSlots` function is called
- After the slots are updated

**Example Usage**

```lua
-- Track donator slots added
hook.Add("DonatorSlotsAdded", "TrackDonatorSlotsAdded", function(player, current)
    local char = player:getChar()
    if char then
        local slotsAdded = char:getData("donator_slots_added", 0)
        char:setData("donator_slots_added", slotsAdded + 1)
    end
    
    lia.log.add(player, "donatorSlotsAdded", current)
end)

-- Apply donator slots added effects
hook.Add("DonatorSlotsAdded", "DonatorSlotsAddedEffects", function(player, current)
    -- Play success sound
    player:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    player:notify("Character slots added! Total: " .. current .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track donator slots added statistics
hook.Add("DonatorSlotsAdded", "TrackDonatorSlotsAddedStats", function(player, current)
    local char = player:getChar()
    if char then
        -- Track slots added frequency
        local slotsAddedFrequency = char:getData("donator_slots_added_frequency", 0)
        char:setData("donator_slots_added_frequency", slotsAddedFrequency + 1)
        
        -- Track slots added patterns
        local slotsPatterns = char:getData("donator_slots_added_patterns", {})
        table.insert(slotsPatterns, {
            current = current,
            time = os.time()
        })
        char:setData("donator_slots_added_patterns", slotsPatterns)
    end
end)
```

---

## DonatorSlotsSet

**Purpose**

Called when character slots are set for a donator.

**Parameters**

* `player` (*Player*): The player whose slots are being set.
* `value` (*number*): The new number of character slots.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Character slots are set for a player
- The `OverrideCharSlots` function is called
- After the slots are updated

**Example Usage**

```lua
-- Track donator slots set
hook.Add("DonatorSlotsSet", "TrackDonatorSlotsSet", function(player, value)
    local char = player:getChar()
    if char then
        local slotsSet = char:getData("donator_slots_set", 0)
        char:setData("donator_slots_set", slotsSet + 1)
    end
    
    lia.log.add(player, "donatorSlotsSet", value)
end)

-- Apply donator slots set effects
hook.Add("DonatorSlotsSet", "DonatorSlotsSetEffects", function(player, value)
    -- Play set sound
    player:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 15), 0.5, 0)
    
    -- Notify player
    player:notify("Character slots set to: " .. value .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track donator slots set statistics
hook.Add("DonatorSlotsSet", "TrackDonatorSlotsSetStats", function(player, value)
    local char = player:getChar()
    if char then
        -- Track slots set frequency
        local slotsSetFrequency = char:getData("donator_slots_set_frequency", 0)
        char:setData("donator_slots_set_frequency", slotsSetFrequency + 1)
        
        -- Track slots set patterns
        local slotsPatterns = char:getData("donator_slots_set_patterns", {})
        table.insert(slotsPatterns, {
            value = value,
            time = os.time()
        })
        char:setData("donator_slots_set_patterns", slotsPatterns)
    end
end)
```

---

## DonatorSlotsSubtracted

**Purpose**

Called when character slots are subtracted from a donator.

**Parameters**

* `player` (*Player*): The player who lost the slots.
* `current` (*number*): The current number of slots after subtraction.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Character slots are subtracted from a player
- The `SubtractOverrideCharSlots` function is called
- After the slots are updated

**Example Usage**

```lua
-- Track donator slots subtracted
hook.Add("DonatorSlotsSubtracted", "TrackDonatorSlotsSubtracted", function(player, current)
    local char = player:getChar()
    if char then
        local slotsSubtracted = char:getData("donator_slots_subtracted", 0)
        char:setData("donator_slots_subtracted", slotsSubtracted + 1)
    end
    
    lia.log.add(player, "donatorSlotsSubtracted", current)
end)

-- Apply donator slots subtracted effects
hook.Add("DonatorSlotsSubtracted", "DonatorSlotsSubtractedEffects", function(player, current)
    -- Play subtraction sound
    player:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    player:notify("Character slots subtracted! Total: " .. current .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track donator slots subtracted statistics
hook.Add("DonatorSlotsSubtracted", "TrackDonatorSlotsSubtractedStats", function(player, current)
    local char = player:getChar()
    if char then
        -- Track slots subtracted frequency
        local slotsSubtractedFrequency = char:getData("donator_slots_subtracted_frequency", 0)
        char:setData("donator_slots_subtracted_frequency", slotsSubtractedFrequency + 1)
        
        -- Track slots subtracted patterns
        local slotsPatterns = char:getData("donator_slots_subtracted_patterns", {})
        table.insert(slotsPatterns, {
            current = current,
            time = os.time()
        })
        char:setData("donator_slots_subtracted_patterns", slotsPatterns)
    end
end)
```

---

## DonatorSpawn

**Purpose**

Called when a donator spawns with override slots.

**Parameters**

* `client` (*Player*): The player who spawned.
* `currentSlots` (*number*): The current number of override slots.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A donator player spawns
- The player has override slots set
- After the player spawn process

**Example Usage**

```lua
-- Track donator spawn
hook.Add("DonatorSpawn", "TrackDonatorSpawn", function(client, currentSlots)
    local char = client:getChar()
    if char then
        local donatorSpawns = char:getData("donator_spawns", 0)
        char:setData("donator_spawns", donatorSpawns + 1)
    end
    
    lia.log.add(client, "donatorSpawn", currentSlots)
end)

-- Apply donator spawn effects
hook.Add("DonatorSpawn", "DonatorSpawnEffects", function(client, currentSlots)
    -- Play spawn sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Welcome back, donator! Override slots: " .. currentSlots .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track donator spawn statistics
hook.Add("DonatorSpawn", "TrackDonatorSpawnStats", function(client, currentSlots)
    local char = client:getChar()
    if char then
        -- Track spawn frequency
        local spawnFrequency = char:getData("donator_spawn_frequency", 0)
        char:setData("donator_spawn_frequency", spawnFrequency + 1)
        
        -- Track spawn patterns
        local spawnPatterns = char:getData("donator_spawn_patterns", {})
        table.insert(spawnPatterns, {
            slots = currentSlots,
            time = os.time()
        })
        char:setData("donator_spawn_patterns", spawnPatterns)
    end
end)
```
