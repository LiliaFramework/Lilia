# Hooks

This document describes the hooks available in the HUD Extras module for managing additional HUD elements and effects.

---

## AdjustBlurAmount

**Purpose**

Called to adjust the blur amount for HUD effects.

**Parameters**

* `blurGoal` (*number*): The current blur goal value.

**Realm**

Client.

**When Called**

This hook is triggered when:
- HUD blur effects are being calculated
- Before the blur is applied to the screen
- During the blur rendering process

**Example Usage**

```lua
-- Adjust blur amount based on player state
hook.Add("AdjustBlurAmount", "AdjustBlurBasedOnPlayerState", function(blurGoal)
    local char = LocalPlayer():getChar()
    if char then
        -- Increase blur if player is injured
        if LocalPlayer():Health() < 50 then
            return blurGoal + 20
        end
        
        -- Increase blur if player is drunk
        if char:getData("drunk", false) then
            return blurGoal + 30
        end
        
        -- Increase blur if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return blurGoal + 10
        end
    end
    
    return blurGoal
end)

-- Track blur adjustments
hook.Add("AdjustBlurAmount", "TrackBlurAdjustments", function(blurGoal)
    local char = LocalPlayer():getChar()
    if char then
        local blurAdjustments = char:getData("blur_adjustments", 0)
        char:setData("blur_adjustments", blurAdjustments + 1)
    end
end)

-- Apply blur adjustment effects
hook.Add("AdjustBlurAmount", "BlurAdjustmentEffects", function(blurGoal)
    -- Play blur adjustment sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
end)
```

---

## HUDExtrasPostDrawBlur

**Purpose**

Called after blur effects are drawn on the HUD.

**Parameters**

* `blurValue` (*number*): The blur value that was applied.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Blur effects have been drawn on the HUD
- After `HUDExtrasPreDrawBlur` hook
- When blur rendering is complete

**Example Usage**

```lua
-- Track blur drawing completion
hook.Add("HUDExtrasPostDrawBlur", "TrackBlurDrawingCompletion", function(blurValue)
    local char = LocalPlayer():getChar()
    if char then
        local blurDrawings = char:getData("blur_drawings", 0)
        char:setData("blur_drawings", blurDrawings + 1)
    end
end)

-- Apply post-blur drawing effects
hook.Add("HUDExtrasPostDrawBlur", "PostBlurDrawingEffects", function(blurValue)
    -- Play completion sound
    LocalPlayer():EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    LocalPlayer():notify("Blur effect applied!")
end)

-- Track blur drawing statistics
hook.Add("HUDExtrasPostDrawBlur", "TrackBlurDrawingStats", function(blurValue)
    local char = LocalPlayer():getChar()
    if char then
        -- Track drawing frequency
        local drawingFrequency = char:getData("blur_drawing_frequency", 0)
        char:setData("blur_drawing_frequency", drawingFrequency + 1)
        
        -- Track drawing patterns
        local drawingPatterns = char:getData("blur_drawing_patterns", {})
        table.insert(drawingPatterns, {
            value = blurValue,
            time = os.time()
        })
        char:setData("blur_drawing_patterns", drawingPatterns)
    end
end)
```

---

## HUDExtrasPostDrawFPS

**Purpose**

Called after FPS counter is drawn on the HUD.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- FPS counter has been drawn on the HUD
- After `HUDExtrasPreDrawFPS` hook
- When FPS rendering is complete

**Example Usage**

```lua
-- Track FPS drawing completion
hook.Add("HUDExtrasPostDrawFPS", "TrackFPSDrawingCompletion", function()
    local char = LocalPlayer():getChar()
    if char then
        local fpsDrawings = char:getData("fps_drawings", 0)
        char:setData("fps_drawings", fpsDrawings + 1)
    end
end)

-- Apply post-FPS drawing effects
hook.Add("HUDExtrasPostDrawFPS", "PostFPSDrawingEffects", function()
    -- Play completion sound
    LocalPlayer():EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    LocalPlayer():notify("FPS counter drawn!")
end)

-- Track FPS drawing statistics
hook.Add("HUDExtrasPostDrawFPS", "TrackFPSDrawingStats", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Track drawing frequency
        local drawingFrequency = char:getData("fps_drawing_frequency", 0)
        char:setData("fps_drawing_frequency", drawingFrequency + 1)
        
        -- Track drawing patterns
        local drawingPatterns = char:getData("fps_drawing_patterns", {})
        table.insert(drawingPatterns, {
            time = os.time()
        })
        char:setData("fps_drawing_patterns", drawingPatterns)
    end
end)
```

---

## HUDExtrasPostDrawVignette

**Purpose**

Called after vignette effects are drawn on the HUD.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Vignette effects have been drawn on the HUD
- After `HUDExtrasPreDrawVignette` hook
- When vignette rendering is complete

**Example Usage**

```lua
-- Track vignette drawing completion
hook.Add("HUDExtrasPostDrawVignette", "TrackVignetteDrawingCompletion", function()
    local char = LocalPlayer():getChar()
    if char then
        local vignetteDrawings = char:getData("vignette_drawings", 0)
        char:setData("vignette_drawings", vignetteDrawings + 1)
    end
end)

-- Apply post-vignette drawing effects
hook.Add("HUDExtrasPostDrawVignette", "PostVignetteDrawingEffects", function()
    -- Play completion sound
    LocalPlayer():EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    LocalPlayer():notify("Vignette effect drawn!")
end)

-- Track vignette drawing statistics
hook.Add("HUDExtrasPostDrawVignette", "TrackVignetteDrawingStats", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Track drawing frequency
        local drawingFrequency = char:getData("vignette_drawing_frequency", 0)
        char:setData("vignette_drawing_frequency", drawingFrequency + 1)
        
        -- Track drawing patterns
        local drawingPatterns = char:getData("vignette_drawing_patterns", {})
        table.insert(drawingPatterns, {
            time = os.time()
        })
        char:setData("vignette_drawing_patterns", drawingPatterns)
    end
end)
```

---

## HUDExtrasPostDrawWatermark

**Purpose**

Called after watermark is drawn on the HUD.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Watermark has been drawn on the HUD
- After `HUDExtrasPreDrawWatermark` hook
- When watermark rendering is complete

**Example Usage**

```lua
-- Track watermark drawing completion
hook.Add("HUDExtrasPostDrawWatermark", "TrackWatermarkDrawingCompletion", function()
    local char = LocalPlayer():getChar()
    if char then
        local watermarkDrawings = char:getData("watermark_drawings", 0)
        char:setData("watermark_drawings", watermarkDrawings + 1)
    end
end)

-- Apply post-watermark drawing effects
hook.Add("HUDExtrasPostDrawWatermark", "PostWatermarkDrawingEffects", function()
    -- Play completion sound
    LocalPlayer():EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    LocalPlayer():notify("Watermark drawn!")
end)

-- Track watermark drawing statistics
hook.Add("HUDExtrasPostDrawWatermark", "TrackWatermarkDrawingStats", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Track drawing frequency
        local drawingFrequency = char:getData("watermark_drawing_frequency", 0)
        char:setData("watermark_drawing_frequency", drawingFrequency + 1)
        
        -- Track drawing patterns
        local drawingPatterns = char:getData("watermark_drawing_patterns", {})
        table.insert(drawingPatterns, {
            time = os.time()
        })
        char:setData("watermark_drawing_patterns", drawingPatterns)
    end
end)
```

---

## HUDExtrasPreDrawBlur

**Purpose**

Called before blur effects are drawn on the HUD.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Blur effects are about to be drawn on the HUD
- Before any blur rendering begins
- Before `HUDExtrasPostDrawBlur` hook

**Example Usage**

```lua
-- Track blur drawing preparation
hook.Add("HUDExtrasPreDrawBlur", "TrackBlurDrawingPreparation", function()
    local char = LocalPlayer():getChar()
    if char then
        local blurPreparations = char:getData("blur_preparations", 0)
        char:setData("blur_preparations", blurPreparations + 1)
    end
end)

-- Apply pre-blur drawing effects
hook.Add("HUDExtrasPreDrawBlur", "PreBlurDrawingEffects", function()
    -- Play preparation sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    LocalPlayer():notify("Preparing blur effect...")
end)

-- Track blur drawing preparation statistics
hook.Add("HUDExtrasPreDrawBlur", "TrackBlurDrawingPreparationStats", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Track preparation frequency
        local preparationFrequency = char:getData("blur_preparation_frequency", 0)
        char:setData("blur_preparation_frequency", preparationFrequency + 1)
        
        -- Track preparation patterns
        local preparationPatterns = char:getData("blur_preparation_patterns", {})
        table.insert(preparationPatterns, {
            time = os.time()
        })
        char:setData("blur_preparation_patterns", preparationPatterns)
    end
end)
```

---

## HUDExtrasPreDrawFPS

**Purpose**

Called before FPS counter is drawn on the HUD.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- FPS counter is about to be drawn on the HUD
- Before any FPS rendering begins
- Before `HUDExtrasPostDrawFPS` hook

**Example Usage**

```lua
-- Track FPS drawing preparation
hook.Add("HUDExtrasPreDrawFPS", "TrackFPSDrawingPreparation", function()
    local char = LocalPlayer():getChar()
    if char then
        local fpsPreparations = char:getData("fps_preparations", 0)
        char:setData("fps_preparations", fpsPreparations + 1)
    end
end)

-- Apply pre-FPS drawing effects
hook.Add("HUDExtrasPreDrawFPS", "PreFPSDrawingEffects", function()
    -- Play preparation sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    LocalPlayer():notify("Preparing FPS counter...")
end)

-- Track FPS drawing preparation statistics
hook.Add("HUDExtrasPreDrawFPS", "TrackFPSDrawingPreparationStats", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Track preparation frequency
        local preparationFrequency = char:getData("fps_preparation_frequency", 0)
        char:setData("fps_preparation_frequency", preparationFrequency + 1)
        
        -- Track preparation patterns
        local preparationPatterns = char:getData("fps_preparation_patterns", {})
        table.insert(preparationPatterns, {
            time = os.time()
        })
        char:setData("fps_preparation_patterns", preparationPatterns)
    end
end)
```

---

## HUDExtrasPreDrawVignette

**Purpose**

Called before vignette effects are drawn on the HUD.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Vignette effects are about to be drawn on the HUD
- Before any vignette rendering begins
- Before `HUDExtrasPostDrawVignette` hook

**Example Usage**

```lua
-- Track vignette drawing preparation
hook.Add("HUDExtrasPreDrawVignette", "TrackVignetteDrawingPreparation", function()
    local char = LocalPlayer():getChar()
    if char then
        local vignettePreparations = char:getData("vignette_preparations", 0)
        char:setData("vignette_preparations", vignettePreparations + 1)
    end
end)

-- Apply pre-vignette drawing effects
hook.Add("HUDExtrasPreDrawVignette", "PreVignetteDrawingEffects", function()
    -- Play preparation sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    LocalPlayer():notify("Preparing vignette effect...")
end)

-- Track vignette drawing preparation statistics
hook.Add("HUDExtrasPreDrawVignette", "TrackVignetteDrawingPreparationStats", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Track preparation frequency
        local preparationFrequency = char:getData("vignette_preparation_frequency", 0)
        char:setData("vignette_preparation_frequency", preparationFrequency + 1)
        
        -- Track preparation patterns
        local preparationPatterns = char:getData("vignette_preparation_patterns", {})
        table.insert(preparationPatterns, {
            time = os.time()
        })
        char:setData("vignette_preparation_patterns", preparationPatterns)
    end
end)
```

---

## HUDExtrasPreDrawWatermark

**Purpose**

Called before watermark is drawn on the HUD.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Watermark is about to be drawn on the HUD
- Before any watermark rendering begins
- Before `HUDExtrasPostDrawWatermark` hook

**Example Usage**

```lua
-- Track watermark drawing preparation
hook.Add("HUDExtrasPreDrawWatermark", "TrackWatermarkDrawingPreparation", function()
    local char = LocalPlayer():getChar()
    if char then
        local watermarkPreparations = char:getData("watermark_preparations", 0)
        char:setData("watermark_preparations", watermarkPreparations + 1)
    end
end)

-- Apply pre-watermark drawing effects
hook.Add("HUDExtrasPreDrawWatermark", "PreWatermarkDrawingEffects", function()
    -- Play preparation sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    LocalPlayer():notify("Preparing watermark...")
end)

-- Track watermark drawing preparation statistics
hook.Add("HUDExtrasPreDrawWatermark", "TrackWatermarkDrawingPreparationStats", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Track preparation frequency
        local preparationFrequency = char:getData("watermark_preparation_frequency", 0)
        char:setData("watermark_preparation_frequency", preparationFrequency + 1)
        
        -- Track preparation patterns
        local preparationPatterns = char:getData("watermark_preparation_patterns", {})
        table.insert(preparationPatterns, {
            time = os.time()
        })
        char:setData("watermark_preparation_patterns", preparationPatterns)
    end
end)
```

---

## ShouldDrawBlur

**Purpose**

Called to determine if blur effects should be drawn.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- HUD blur effects are being checked
- Before any blur rendering
- During the blur drawing process

**Example Usage**

```lua
-- Control blur drawing
hook.Add("ShouldDrawBlur", "ControlBlurDrawing", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Check if blur is disabled
        if char:getData("blur_disabled", false) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
        
        -- Check if player is in a vehicle
        if LocalPlayer():InVehicle() then
            return false
        end
        
        -- Check if player is in water
        if LocalPlayer():WaterLevel() >= 2 then
            return false
        end
    end
    
    return true
end)

-- Track blur drawing checks
hook.Add("ShouldDrawBlur", "TrackBlurDrawingChecks", function()
    local char = LocalPlayer():getChar()
    if char then
        local blurChecks = char:getData("blur_checks", 0)
        char:setData("blur_checks", blurChecks + 1)
    end
end)

-- Apply blur drawing check effects
hook.Add("ShouldDrawBlur", "BlurDrawingCheckEffects", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Check if blur is disabled
        if char:getData("blur_disabled", false) then
            LocalPlayer():notify("Blur is disabled!")
        end
    end
end)
```

---

## ShouldDrawWatermark

**Purpose**

Called to determine if watermark should be drawn.

**Parameters**

None.

**Realm**

Client.

**When Called**

This hook is triggered when:
- HUD watermark is being checked
- Before any watermark rendering
- During the watermark drawing process

**Example Usage**

```lua
-- Control watermark drawing
hook.Add("ShouldDrawWatermark", "ControlWatermarkDrawing", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Check if watermark is disabled
        if char:getData("watermark_disabled", false) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
        
        -- Check if player is in a vehicle
        if LocalPlayer():InVehicle() then
            return false
        end
        
        -- Check if player is in water
        if LocalPlayer():WaterLevel() >= 2 then
            return false
        end
    end
    
    return true
end)

-- Track watermark drawing checks
hook.Add("ShouldDrawWatermark", "TrackWatermarkDrawingChecks", function()
    local char = LocalPlayer():getChar()
    if char then
        local watermarkChecks = char:getData("watermark_checks", 0)
        char:setData("watermark_checks", watermarkChecks + 1)
    end
end)

-- Apply watermark drawing check effects
hook.Add("ShouldDrawWatermark", "WatermarkDrawingCheckEffects", function()
    local char = LocalPlayer():getChar()
    if char then
        -- Check if watermark is disabled
        if char:getData("watermark_disabled", false) then
            LocalPlayer():notify("Watermark is disabled!")
        end
    end
end)
```
