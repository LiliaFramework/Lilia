# Hooks

This document describes the hooks available in the Cursor module for managing custom cursor functionality.

---

## CursorThink

**Purpose**

Called every frame when the cursor is active and hovering over a panel.

**Parameters**

* `hoverPanel` (*Panel*): The panel currently being hovered over.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The cursor is active
- A panel is being hovered over
- Every frame during the Think hook
- After `PreCursorThink` hook

**Example Usage**

```lua
-- Track cursor hover statistics
hook.Add("CursorThink", "TrackCursorHover", function(hoverPanel)
    local char = LocalPlayer():getChar()
    if char then
        local hoverTime = char:getData("cursor_hover_time", 0)
        char:setData("cursor_hover_time", hoverTime + FrameTime())
        
        -- Track hovered panel types
        local panelType = hoverPanel:GetName() or "Unknown"
        local panelHovers = char:getData("panel_hovers", {})
        panelHovers[panelType] = (panelHovers[panelType] or 0) + 1
        char:setData("panel_hovers", panelHovers)
    end
end)

-- Apply cursor hover effects
hook.Add("CursorThink", "CursorHoverEffects", function(hoverPanel)
    -- Apply screen effect based on panel type
    if hoverPanel:GetName() == "DButton" then
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 2), 0.1, 0)
    elseif hoverPanel:GetName() == "DTextEntry" then
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 2), 0.1, 0)
    end
end)

-- Customize cursor behavior
hook.Add("CursorThink", "CustomizeCursorBehavior", function(hoverPanel)
    -- Change cursor based on panel type
    if hoverPanel:GetName() == "DButton" then
        hoverPanel:SetCursor("hand")
    elseif hoverPanel:GetName() == "DTextEntry" then
        hoverPanel:SetCursor("ibeam")
    else
        hoverPanel:SetCursor("blank")
    end
end)

-- Track cursor performance
hook.Add("CursorThink", "TrackCursorPerformance", function(hoverPanel)
    local char = LocalPlayer():getChar()
    if char then
        local frameTime = char:getData("cursor_frame_time", 0)
        char:setData("cursor_frame_time", frameTime + FrameTime())
        
        -- Track frame rate
        local frameCount = char:getData("cursor_frame_count", 0)
        char:setData("cursor_frame_count", frameCount + 1)
    end
end)
```

---

## PostRenderCursor

**Purpose**

Called after the custom cursor is rendered.

**Parameters**

* `cursorMaterial` (*string*): The material path of the cursor being rendered.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The custom cursor has been rendered
- After `PreRenderCursor` hook
- Every frame when the cursor is active

**Example Usage**

```lua
-- Track cursor rendering
hook.Add("PostRenderCursor", "TrackCursorRendering", function(cursorMaterial)
    local char = LocalPlayer():getChar()
    if char then
        local renderCount = char:getData("cursor_render_count", 0)
        char:setData("cursor_render_count", renderCount + 1)
        
        -- Track cursor material usage
        local materialUsage = char:getData("cursor_material_usage", {})
        materialUsage[cursorMaterial] = (materialUsage[cursorMaterial] or 0) + 1
        char:setData("cursor_material_usage", materialUsage)
    end
end)

-- Apply post-render effects
hook.Add("PostRenderCursor", "PostRenderEffects", function(cursorMaterial)
    -- Apply screen effect after cursor render
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 1), 0.1, 0)
    
    -- Create particle effect at cursor position
    local cursorPos = gui.MousePos()
    local effect = EffectData()
    effect:SetOrigin(Vector(cursorPos.x, cursorPos.y, 0))
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Customize cursor rendering
hook.Add("PostRenderCursor", "CustomizeCursorRendering", function(cursorMaterial)
    -- Override cursor rendering with custom effects
    local cursorPos = gui.MousePos()
    
    -- Draw custom cursor outline
    surface.SetDrawColor(255, 255, 255, 100)
    surface.DrawRect(cursorPos.x - 1, cursorPos.y - 1, 3, 3)
    
    -- Draw custom cursor center
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(cursorPos.x, cursorPos.y, 1, 1)
end)

-- Track cursor performance
hook.Add("PostRenderCursor", "TrackCursorPerformance", function(cursorMaterial)
    local char = LocalPlayer():getChar()
    if char then
        local renderTime = char:getData("cursor_render_time", 0)
        char:setData("cursor_render_time", renderTime + FrameTime())
        
        -- Track render frequency
        local renderFrequency = char:getData("cursor_render_frequency", 0)
        char:setData("cursor_render_frequency", renderFrequency + 1)
    end
end)
```

---

## PreCursorThink

**Purpose**

Called before the cursor Think hook processes the hovered panel.

**Parameters**

* `hoverPanel` (*Panel*): The panel currently being hovered over.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The cursor is active
- A panel is being hovered over
- Before the cursor Think hook processes the panel
- Before `CursorThink` hook

**Example Usage**

```lua
-- Validate cursor hover
hook.Add("PreCursorThink", "ValidateCursorHover", function(hoverPanel)
    -- Check if panel is valid
    if not IsValid(hoverPanel) then
        return false
    end
    
    -- Check if panel is visible
    if not hoverPanel:IsVisible() then
        return false
    end
    
    -- Check if panel is enabled
    if hoverPanel.IsEnabled and not hoverPanel:IsEnabled() then
        return false
    end
end)

-- Apply pre-think effects
hook.Add("PreCursorThink", "PreThinkEffects", function(hoverPanel)
    -- Apply screen effect before processing
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 1), 0.1, 0)
    
    -- Play hover sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
end)

-- Track cursor hover patterns
hook.Add("PreCursorThink", "TrackCursorPatterns", function(hoverPanel)
    local char = LocalPlayer():getChar()
    if char then
        -- Track hover frequency
        local hoverFrequency = char:getData("cursor_hover_frequency", 0)
        char:setData("cursor_hover_frequency", hoverFrequency + 1)
        
        -- Track panel types
        local panelType = hoverPanel:GetName() or "Unknown"
        local panelTypes = char:getData("cursor_panel_types", {})
        panelTypes[panelType] = (panelTypes[panelType] or 0) + 1
        char:setData("cursor_panel_types", panelTypes)
    end
end)

-- Apply cursor restrictions
hook.Add("PreCursorThink", "ApplyCursorRestrictions", function(hoverPanel)
    local char = LocalPlayer():getChar()
    if char then
        -- Check if cursor is disabled
        if char:getData("cursor_disabled", false) then
            return false
        end
        
        -- Check cursor cooldown
        local lastCursor = char:getData("last_cursor_time", 0)
        if os.time() - lastCursor < 1 then -- 1 second cooldown
            return false
        end
        
        -- Update last cursor time
        char:setData("last_cursor_time", os.time())
    end
end)
```

---

## PreRenderCursor

**Purpose**

Called before the custom cursor is rendered.

**Parameters**

* `cursorMaterial` (*string*): The material path of the cursor being rendered.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The custom cursor is about to be rendered
- Before the cursor material is drawn
- Every frame when the cursor is active

**Example Usage**

```lua
-- Track cursor rendering
hook.Add("PreRenderCursor", "TrackCursorRendering", function(cursorMaterial)
    local char = LocalPlayer():getChar()
    if char then
        local renderCount = char:getData("cursor_pre_render_count", 0)
        char:setData("cursor_pre_render_count", renderCount + 1)
        
        -- Track cursor material usage
        local materialUsage = char:getData("cursor_pre_material_usage", {})
        materialUsage[cursorMaterial] = (materialUsage[cursorMaterial] or 0) + 1
        char:setData("cursor_pre_material_usage", materialUsage)
    end
end)

-- Apply pre-render effects
hook.Add("PreRenderCursor", "PreRenderEffects", function(cursorMaterial)
    -- Apply screen effect before cursor render
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 1), 0.1, 0)
    
    -- Play render sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
end)

-- Customize cursor material
hook.Add("PreRenderCursor", "CustomizeCursorMaterial", function(cursorMaterial)
    -- Override cursor material based on context
    local hoverPanel = vgui.GetHoveredPanel()
    if IsValid(hoverPanel) then
        if hoverPanel:GetName() == "DButton" then
            cursorMaterial = "cursor/hand"
        elseif hoverPanel:GetName() == "DTextEntry" then
            cursorMaterial = "cursor/ibeam"
        end
    end
    
    -- Apply custom cursor effects
    local cursorPos = gui.MousePos()
    
    -- Draw custom cursor background
    surface.SetDrawColor(0, 0, 0, 100)
    surface.DrawRect(cursorPos.x - 2, cursorPos.y - 2, 4, 4)
    
    -- Draw custom cursor border
    surface.SetDrawColor(255, 255, 255, 200)
    surface.DrawRect(cursorPos.x - 1, cursorPos.y - 1, 2, 2)
end)

-- Track cursor performance
hook.Add("PreRenderCursor", "TrackCursorPerformance", function(cursorMaterial)
    local char = LocalPlayer():getChar()
    if char then
        local preRenderTime = char:getData("cursor_pre_render_time", 0)
        char:setData("cursor_pre_render_time", preRenderTime + FrameTime())
        
        -- Track render frequency
        local renderFrequency = char:getData("cursor_pre_render_frequency", 0)
        char:setData("cursor_pre_render_frequency", renderFrequency + 1)
    end
end)

-- Apply cursor restrictions
hook.Add("PreRenderCursor", "ApplyCursorRestrictions", function(cursorMaterial)
    local char = LocalPlayer():getChar()
    if char then
        -- Check if cursor is disabled
        if char:getData("cursor_disabled", false) then
            return false
        end
        
        -- Check cursor cooldown
        local lastCursor = char:getData("last_cursor_render_time", 0)
        if os.time() - lastCursor < 1 then -- 1 second cooldown
            return false
        end
        
        -- Update last cursor render time
        char:setData("last_cursor_render_time", os.time())
    end
end)
```
