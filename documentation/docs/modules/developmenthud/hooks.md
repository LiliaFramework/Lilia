# Hooks

This document describes the hooks available in the Development HUD module for managing staff-only development interface functionality.

---

## DevelopmentHUDPaint

**Purpose**

Called when the development HUD is being painted on the screen.

**Parameters**

* `client` (*Player*): The client whose HUD is being painted.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The development HUD is being rendered
- After `DevelopmentHUDPrePaint` hook
- When the HUD drawing is complete

**Example Usage**

```lua
-- Add custom development HUD elements
hook.Add("DevelopmentHUDPaint", "AddCustomDevHUD", function(client)
    local char = client:getChar()
    if char and client:hasPrivilege("developmentHUD") then
        local x = ScrW() / 5.25
        local y = ScrH() / 1.04
        
        -- Add custom information
        draw.SimpleText("| Custom Info: " .. char:getName() .. " |", "DermaDefault", x, y, Color(255, 255, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        -- Add server uptime
        local uptime = os.time() - (GetConVar("sv_starttime"):GetInt() or 0)
        local uptimeText = string.format("%02d:%02d:%02d", math.floor(uptime / 3600), math.floor((uptime % 3600) / 60), uptime % 60)
        draw.SimpleText("| Uptime: " .. uptimeText .. " |", "DermaDefault", x, y + 20, Color(0, 255, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end)

-- Track HUD painting
hook.Add("DevelopmentHUDPaint", "TrackHUDPainting", function(client)
    local char = client:getChar()
    if char then
        local hudPaints = char:getData("dev_hud_paints", 0)
        char:setData("dev_hud_paints", hudPaints + 1)
    end
end)

-- Apply HUD effects
hook.Add("DevelopmentHUDPaint", "HUDPaintEffects", function(client)
    -- Add subtle glow effect
    local x = ScrW() / 5.25
    local y = ScrH() / 1.12
    
    surface.SetDrawColor(255, 255, 255, 10)
    surface.DrawRect(x - 5, y - 5, 200, 20)
end)
```

---

## DevelopmentHUDPrePaint

**Purpose**

Called before the development HUD is painted on the screen.

**Parameters**

* `client` (*Player*): The client whose HUD is about to be painted.

**Realm**

Client.

**When Called**

This hook is triggered when:
- The development HUD is about to be rendered
- Before any HUD drawing begins
- Before `DevelopmentHUDPaint` hook

**Example Usage**

```lua
-- Prepare HUD data
hook.Add("DevelopmentHUDPrePaint", "PrepareHUDData", function(client)
    local char = client:getChar()
    if char and client:hasPrivilege("developmentHUD") then
        -- Cache frequently used data
        char:setData("cached_pos", client:GetPos())
        char:setData("cached_ang", client:GetAngles())
        char:setData("cached_health", client:Health())
        char:setData("cached_armor", client:Armor())
    end
end)

-- Validate HUD access
hook.Add("DevelopmentHUDPrePaint", "ValidateHUDAccess", function(client)
    local char = client:getChar()
    if not char then
        return false
    end
    
    -- Check if HUD is disabled
    if char:getData("dev_hud_disabled", false) then
        return false
    end
    
    -- Check cooldown
    local lastPaint = char:getData("last_hud_paint_time", 0)
    if os.time() - lastPaint < 1 then -- 1 second cooldown
        return false
    end
    
    -- Update last paint time
    char:setData("last_hud_paint_time", os.time())
end)

-- Track HUD preparation
hook.Add("DevelopmentHUDPrePaint", "TrackHUDPreparation", function(client)
    local char = client:getChar()
    if char then
        local hudPreparations = char:getData("dev_hud_preparations", 0)
        char:setData("dev_hud_preparations", hudPreparations + 1)
    end
end)
```
