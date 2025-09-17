# Hooks

This document describes the hooks available in the View Manipulation module for managing VManip animations and item interactions.

---

## PreVManipPickup

**Purpose**

Called before a VManip pickup animation is triggered for an item.

**Parameters**

* `client` (*Player*): The player who is picking up the item.
* `item` (*Item*): The item being picked up.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player interacts with an item that has VManip support
- Before the pickup animation is sent to the client
- Before `VManipPickup` hook

**Example Usage**

```lua
-- Track VManip pickup attempts
hook.Add("PreVManipPickup", "TrackVManipPickups", function(client, item)
    local char = client:getChar()
    if char then
        local vmanipPickups = char:getData("vmanip_pickups", 0)
        char:setData("vmanip_pickups", vmanipPickups + 1)
        
        -- Track item types
        local itemTypes = char:getData("vmanip_item_types", {})
        itemTypes[item.uniqueID] = (itemTypes[item.uniqueID] or 0) + 1
        char:setData("vmanip_item_types", itemTypes)
    end
    
    lia.log.add(client, "vmanipPickupAttempt", item.uniqueID)
end)

-- Apply pickup restrictions
hook.Add("PreVManipPickup", "ApplyPickupRestrictions", function(client, item)
    local char = client:getChar()
    if char then
        -- Check if VManip is disabled
        if char:getData("vmanip_disabled", false) then
            client:notify("VManip animations are disabled!")
            return false
        end
        
        -- Check pickup cooldown
        local lastPickup = char:getData("last_vmanip_pickup_time", 0)
        if os.time() - lastPickup < 2 then -- 2 second cooldown
            client:notify("Please wait before picking up another item!")
            return false
        end
        
        -- Check item restrictions
        if item.VManipDisabled then
            client:notify("This item cannot be picked up with VManip!")
            return false
        end
        
        -- Update last pickup time
        char:setData("last_vmanip_pickup_time", os.time())
    end
end)

-- Modify pickup behavior
hook.Add("PreVManipPickup", "ModifyPickupBehavior", function(client, item)
    local char = client:getChar()
    if char then
        -- Apply character-specific modifications
        local pickupStyle = char:getData("pickup_style", "normal")
        
        if pickupStyle == "aggressive" then
            -- Make pickup more aggressive
            item.VManipDisabled = false
        elseif pickupStyle == "careful" then
            -- Make pickup more careful
            item.VManipDisabled = true
        end
        
        -- Apply item-specific modifications
        if item.uniqueID == "weapon_*" then
            -- Special handling for weapons
            char:setData("weapon_pickup_count", char:getData("weapon_pickup_count", 0) + 1)
        elseif item.uniqueID == "food_*" then
            -- Special handling for food
            char:setData("food_pickup_count", char:getData("food_pickup_count", 0) + 1)
        end
    end
end)

-- Apply pickup effects
hook.Add("PreVManipPickup", "PickupEffects", function(client, item)
    -- Play pickup sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.5, 0)
    
    -- Notify client
    client:notify("Picking up " .. item.name .. " with VManip!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)
```

---

## VManipAnimationPlayed

**Purpose**

Called when a VManip animation has been played on the client.

**Parameters**

* `itemID` (*string*): The unique ID of the item that triggered the animation.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A VManip animation has been played
- After the animation is sent from the server
- After `VManipChooseAnim` hook

**Example Usage**

```lua
-- Track VManip animation playback
hook.Add("VManipAnimationPlayed", "TrackVManipAnimations", function(itemID)
    local char = LocalPlayer():getChar()
    if char then
        local animationsPlayed = char:getData("vmanip_animations_played", 0)
        char:setData("vmanip_animations_played", animationsPlayed + 1)
        
        -- Track specific item animations
        local itemAnimations = char:getData("vmanip_item_animations", {})
        itemAnimations[itemID] = (itemAnimations[itemID] or 0) + 1
        char:setData("vmanip_item_animations", itemAnimations)
    end
end)

-- Apply animation effects
hook.Add("VManipAnimationPlayed", "AnimationEffects", function(itemID)
    -- Play animation sound
    LocalPlayer():EmitSound("buttons/button15.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.5, 0)
    
    -- Notify player
    LocalPlayer():notify("VManip animation played for " .. itemID .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(LocalPlayer():GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track animation statistics
hook.Add("VManipAnimationPlayed", "TrackAnimationStats", function(itemID)
    local char = LocalPlayer():getChar()
    if char then
        -- Track animation frequency
        local animationFrequency = char:getData("vmanip_animation_frequency", 0)
        char:setData("vmanip_animation_frequency", animationFrequency + 1)
        
        -- Track animation patterns
        local animationPatterns = char:getData("vmanip_animation_patterns", {})
        table.insert(animationPatterns, {
            item = itemID,
            time = os.time()
        })
        char:setData("vmanip_animation_patterns", animationPatterns)
        
        -- Track animation duration
        local animationDuration = char:getData("total_vmanip_animation_duration", 0)
        char:setData("total_vmanip_animation_duration", animationDuration + 2) -- Default 2 second duration
    end
end)

-- Apply animation restrictions
hook.Add("VManipAnimationPlayed", "ApplyAnimationRestrictions", function(itemID)
    local char = LocalPlayer():getChar()
    if char then
        -- Check if animations are disabled
        if char:getData("vmanip_animations_disabled", false) then
            LocalPlayer():notify("VManip animations are disabled!")
            return false
        end
        
        -- Check animation cooldown
        local lastAnimation = char:getData("last_vmanip_animation_time", 0)
        if os.time() - lastAnimation < 1 then -- 1 second cooldown
            LocalPlayer():notify("Please wait before playing another animation!")
            return false
        end
        
        -- Update last animation time
        char:setData("last_vmanip_animation_time", os.time())
    end
end)
```

---

## VManipChooseAnim

**Purpose**

Called when choosing which VManip animation to play for an item.

**Parameters**

* `itemID` (*string*): The unique ID of the item requesting an animation.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A VManip animation is about to be played
- Before the animation is selected
- Before `VManipAnimationPlayed` hook

**Example Usage**

```lua
-- Customize animation selection
hook.Add("VManipChooseAnim", "CustomizeAnimationSelection", function(itemID)
    local char = LocalPlayer():getChar()
    if char then
        -- Apply character-specific animation preferences
        local animationStyle = char:getData("animation_style", "normal")
        
        if animationStyle == "aggressive" then
            -- Choose more aggressive animations
            if itemID == "weapon_*" then
                return "interactaggressive"
            elseif itemID == "food_*" then
                return "interactquick"
            end
        elseif animationStyle == "careful" then
            -- Choose more careful animations
            if itemID == "weapon_*" then
                return "interactcareful"
            elseif itemID == "food_*" then
                return "interactslow"
            end
        elseif animationStyle == "dramatic" then
            -- Choose more dramatic animations
            if itemID == "weapon_*" then
                return "interactdramatic"
            elseif itemID == "food_*" then
                return "interacttheatrical"
            end
        end
        
        -- Apply item-specific animations
        if itemID == "weapon_pistol" then
            return "interactpistol"
        elseif itemID == "weapon_rifle" then
            return "interactrifle"
        elseif itemID == "food_bread" then
            return "interactbread"
        elseif itemID == "food_water" then
            return "interactwater"
        end
    end
    
    -- Return default animation
    return "interactslower"
end)

-- Track animation selection
hook.Add("VManipChooseAnim", "TrackAnimationSelection", function(itemID)
    local char = LocalPlayer():getChar()
    if char then
        local animationSelections = char:getData("vmanip_animation_selections", 0)
        char:setData("vmanip_animation_selections", animationSelections + 1)
        
        -- Track item-specific selections
        local itemSelections = char:getData("vmanip_item_selections", {})
        itemSelections[itemID] = (itemSelections[itemID] or 0) + 1
        char:setData("vmanip_item_selections", itemSelections)
    end
end)

-- Apply animation selection effects
hook.Add("VManipChooseAnim", "AnimationSelectionEffects", function(itemID)
    -- Play selection sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 5), 0.3, 0)
    
    -- Notify player
    LocalPlayer():notify("Choosing VManip animation for " .. itemID .. "!")
end)

-- Apply animation selection restrictions
hook.Add("VManipChooseAnim", "ApplyAnimationSelectionRestrictions", function(itemID)
    local char = LocalPlayer():getChar()
    if char then
        -- Check if animation selection is disabled
        if char:getData("vmanip_animation_selection_disabled", false) then
            LocalPlayer():notify("VManip animation selection is disabled!")
            return "interactdisabled"
        end
        
        -- Check selection cooldown
        local lastSelection = char:getData("last_animation_selection_time", 0)
        if os.time() - lastSelection < 0.5 then -- 0.5 second cooldown
            return "interactcooldown"
        end
        
        -- Update last selection time
        char:setData("last_animation_selection_time", os.time())
    end
end)
```

---

## VManipPickup

**Purpose**

Called when a VManip pickup animation is triggered for an item.

**Parameters**

* `client` (*Player*): The player who is picking up the item.
* `item` (*Item*): The item being picked up.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A VManip pickup animation is triggered
- After `PreVManipPickup` hook
- After the animation is sent to the client

**Example Usage**

```lua
-- Track VManip pickup completion
hook.Add("VManipPickup", "TrackVManipPickupCompletion", function(client, item)
    local char = client:getChar()
    if char then
        local vmanipPickupsCompleted = char:getData("vmanip_pickups_completed", 0)
        char:setData("vmanip_pickups_completed", vmanipPickupsCompleted + 1)
        
        -- Track pickup success rate
        local pickupAttempts = char:getData("vmanip_pickup_attempts", 0)
        local pickupSuccesses = char:getData("vmanip_pickup_successes", 0)
        char:setData("vmanip_pickup_successes", pickupSuccesses + 1)
        
        local successRate = pickupSuccesses / pickupAttempts
        char:setData("vmanip_pickup_success_rate", successRate)
    end
    
    lia.log.add(client, "vmanipPickupCompleted", item.uniqueID)
end)

-- Apply pickup completion effects
hook.Add("VManipPickup", "PickupCompletionEffects", function(client, item)
    -- Play completion sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify client
    client:notify("Successfully picked up " .. item.name .. " with VManip!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track pickup statistics
hook.Add("VManipPickup", "TrackPickupStats", function(client, item)
    local char = client:getChar()
    if char then
        -- Track pickup frequency
        local pickupFrequency = char:getData("vmanip_pickup_frequency", 0)
        char:setData("vmanip_pickup_frequency", pickupFrequency + 1)
        
        -- Track pickup patterns
        local pickupPatterns = char:getData("vmanip_pickup_patterns", {})
        table.insert(pickupPatterns, {
            item = item.uniqueID,
            time = os.time()
        })
        char:setData("vmanip_pickup_patterns", pickupPatterns)
        
        -- Track pickup duration
        local pickupDuration = char:getData("total_vmanip_pickup_duration", 0)
        char:setData("total_vmanip_pickup_duration", pickupDuration + 2) -- Default 2 second duration
    end
end)

-- Award pickup achievements
hook.Add("VManipPickup", "PickupAchievements", function(client, item)
    local char = client:getChar()
    if char then
        local totalPickups = char:getData("vmanip_pickups_completed", 0)
        
        if totalPickups == 1 then
            client:notify("Achievement: First VManip Pickup!")
        elseif totalPickups == 10 then
            client:notify("Achievement: VManip Enthusiast!")
        elseif totalPickups == 50 then
            client:notify("Achievement: VManip Master!")
        end
        
        -- Check for specific item achievements
        local itemPickups = char:getData("vmanip_item_pickups", {})
        itemPickups[item.uniqueID] = (itemPickups[item.uniqueID] or 0) + 1
        char:setData("vmanip_item_pickups", itemPickups)
        
        if itemPickups[item.uniqueID] == 1 then
            client:notify("Achievement: First time picking up " .. item.name .. " with VManip!")
        end
    end
end)
```
