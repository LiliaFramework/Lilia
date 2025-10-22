# Hooks

This document describes the hooks available in the Model Tweaker module for managing wardrobe model change functionality.

---

## PostWardrobeModelChange

**Purpose**

Called after a wardrobe model change is complete.

**Parameters**

* `client` (*Player*): The player whose model was changed.
* `newModel` (*string*): The new model that was set.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A wardrobe model change is complete
- After `WardrobeModelChanged` hook
- When the model change process is finished

**Example Usage**

```lua
-- Track wardrobe model change completion
hook.Add("PostWardrobeModelChange", "TrackWardrobeModelChangeCompletion", function(client, newModel)
    local char = client:getChar()
    if char then
        local changeCompletions = char:getData("wardrobe_model_change_completions", 0)
        char:setData("wardrobe_model_change_completions", changeCompletions + 1)
    end
    
    lia.log.add(client, "wardrobeModelChangeCompleted", newModel)
end)

-- Apply post wardrobe model change effects
hook.Add("PostWardrobeModelChange", "PostWardrobeModelChangeEffects", function(client, newModel)
    -- Play completion sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Wardrobe model change completed: " .. newModel .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track post wardrobe model change statistics
hook.Add("PostWardrobeModelChange", "TrackPostWardrobeModelChangeStats", function(client, newModel)
    local char = client:getChar()
    if char then
        -- Track completion frequency
        local completionFrequency = char:getData("wardrobe_model_change_completion_frequency", 0)
        char:setData("wardrobe_model_change_completion_frequency", completionFrequency + 1)
        
        -- Track completion patterns
        local completionPatterns = char:getData("wardrobe_model_change_completion_patterns", {})
        table.insert(completionPatterns, {
            model = newModel,
            time = os.time()
        })
        char:setData("wardrobe_model_change_completion_patterns", completionPatterns)
    end
end)
```

---

## PreWardrobeModelChange

**Purpose**

Called before a wardrobe model change begins.

**Parameters**

* `client` (*Player*): The player whose model will be changed.
* `newModel` (*string*): The new model that will be set.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A wardrobe model change is about to begin
- Before `WardrobeModelChanged` hook
- When the model change process starts

**Example Usage**

```lua
-- Track wardrobe model change preparation
hook.Add("PreWardrobeModelChange", "TrackWardrobeModelChangePreparation", function(client, newModel)
    local char = client:getChar()
    if char then
        local changePreparations = char:getData("wardrobe_model_change_preparations", 0)
        char:setData("wardrobe_model_change_preparations", changePreparations + 1)
    end
    
    lia.log.add(client, "wardrobeModelChangePrepared", newModel)
end)

-- Apply pre wardrobe model change effects
hook.Add("PreWardrobeModelChange", "PreWardrobeModelChangeEffects", function(client, newModel)
    -- Play preparation sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Preparing wardrobe model change: " .. newModel .. "!")
end)

-- Track pre wardrobe model change statistics
hook.Add("PreWardrobeModelChange", "TrackPreWardrobeModelChangeStats", function(client, newModel)
    local char = client:getChar()
    if char then
        -- Track preparation frequency
        local preparationFrequency = char:getData("wardrobe_model_change_preparation_frequency", 0)
        char:setData("wardrobe_model_change_preparation_frequency", preparationFrequency + 1)
        
        -- Track preparation patterns
        local preparationPatterns = char:getData("wardrobe_model_change_preparation_patterns", {})
        table.insert(preparationPatterns, {
            model = newModel,
            time = os.time()
        })
        char:setData("wardrobe_model_change_preparation_patterns", preparationPatterns)
    end
end)
```

---

## WardrobeModelChanged

**Purpose**

Called when a wardrobe model is successfully changed.

**Parameters**

* `client` (*Player*): The player whose model was changed.
* `newModel` (*string*): The new model that was set.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A wardrobe model is successfully changed
- After `PreWardrobeModelChange` hook
- Before `PostWardrobeModelChange` hook

**Example Usage**

```lua
-- Track wardrobe model changes
hook.Add("WardrobeModelChanged", "TrackWardrobeModelChanges", function(client, newModel)
    local char = client:getChar()
    if char then
        local modelChanges = char:getData("wardrobe_model_changes", 0)
        char:setData("wardrobe_model_changes", modelChanges + 1)
    end
    
    lia.log.add(client, "wardrobeModelChanged", newModel)
end)

-- Apply wardrobe model change effects
hook.Add("WardrobeModelChanged", "WardrobeModelChangeEffects", function(client, newModel)
    -- Play change sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Wardrobe model changed to: " .. newModel .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track wardrobe model change statistics
hook.Add("WardrobeModelChanged", "TrackWardrobeModelChangeStats", function(client, newModel)
    local char = client:getChar()
    if char then
        -- Track change frequency
        local changeFrequency = char:getData("wardrobe_model_change_frequency", 0)
        char:setData("wardrobe_model_change_frequency", changeFrequency + 1)
        
        -- Track change patterns
        local changePatterns = char:getData("wardrobe_model_change_patterns", {})
        table.insert(changePatterns, {
            model = newModel,
            time = os.time()
        })
        char:setData("wardrobe_model_change_patterns", changePatterns)
    end
end)
```

---

## WardrobeModelChangeRequested

**Purpose**

Called when a wardrobe model change is requested.

**Parameters**

* `client` (*Player*): The player requesting the model change.
* `newModel` (*string*): The new model being requested.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A wardrobe model change is requested
- Before any validation
- When the request is received

**Example Usage**

```lua
-- Track wardrobe model change requests
hook.Add("WardrobeModelChangeRequested", "TrackWardrobeModelChangeRequests", function(client, newModel)
    local char = client:getChar()
    if char then
        local changeRequests = char:getData("wardrobe_model_change_requests", 0)
        char:setData("wardrobe_model_change_requests", changeRequests + 1)
    end
    
    lia.log.add(client, "wardrobeModelChangeRequested", newModel)
end)

-- Apply wardrobe model change request effects
hook.Add("WardrobeModelChangeRequested", "WardrobeModelChangeRequestEffects", function(client, newModel)
    -- Play request sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Wardrobe model change requested: " .. newModel .. "!")
end)

-- Track wardrobe model change request statistics
hook.Add("WardrobeModelChangeRequested", "TrackWardrobeModelChangeRequestStats", function(client, newModel)
    local char = client:getChar()
    if char then
        -- Track request frequency
        local requestFrequency = char:getData("wardrobe_model_change_request_frequency", 0)
        char:setData("wardrobe_model_change_request_frequency", requestFrequency + 1)
        
        -- Track request patterns
        local requestPatterns = char:getData("wardrobe_model_change_request_patterns", {})
        table.insert(requestPatterns, {
            model = newModel,
            time = os.time()
        })
        char:setData("wardrobe_model_change_request_patterns", requestPatterns)
    end
end)
```

---

## WardrobeModelInvalid

**Purpose**

Called when a wardrobe model change request is invalid.

**Parameters**

* `client` (*Player*): The player whose model change request was invalid.
* `newModel` (*string*): The invalid model that was requested.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A wardrobe model change request is invalid
- When the model validation fails
- When the request is rejected

**Example Usage**

```lua
-- Track wardrobe model invalid requests
hook.Add("WardrobeModelInvalid", "TrackWardrobeModelInvalidRequests", function(client, newModel)
    local char = client:getChar()
    if char then
        local invalidRequests = char:getData("wardrobe_model_invalid_requests", 0)
        char:setData("wardrobe_model_invalid_requests", invalidRequests + 1)
    end
    
    lia.log.add(client, "wardrobeModelInvalid", newModel)
end)

-- Apply wardrobe model invalid effects
hook.Add("WardrobeModelInvalid", "WardrobeModelInvalidEffects", function(client, newModel)
    -- Play invalid sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Invalid wardrobe model: " .. newModel .. "!")
end)

-- Track wardrobe model invalid statistics
hook.Add("WardrobeModelInvalid", "TrackWardrobeModelInvalidStats", function(client, newModel)
    local char = client:getChar()
    if char then
        -- Track invalid frequency
        local invalidFrequency = char:getData("wardrobe_model_invalid_frequency", 0)
        char:setData("wardrobe_model_invalid_frequency", invalidFrequency + 1)
        
        -- Track invalid patterns
        local invalidPatterns = char:getData("wardrobe_model_invalid_patterns", {})
        table.insert(invalidPatterns, {
            model = newModel,
            time = os.time()
        })
        char:setData("wardrobe_model_invalid_patterns", invalidPatterns)
    end
end)
```
