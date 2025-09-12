# Bars Library

This page documents the functions for working with HUD bars and progress indicators.

---

## Overview

The bars library (`lia.bar`) provides a comprehensive system for creating and managing HUD bars, progress indicators, and visual feedback elements in the Lilia framework, serving as the core visual interface system that enhances player experience through dynamic and informative display elements. This library handles sophisticated bar management with support for multiple bar types including health, armor, custom indicators, and action bars with advanced animation systems, priority management, and delta smoothing that create smooth and responsive visual feedback. The system features advanced bar customization with support for custom colors, gradients, textures, and styling options that enable rich visual customization and thematic consistency throughout the user interface. It includes comprehensive animation support with smooth transitions, easing functions, and dynamic value changes that provide intuitive visual feedback for all player actions and status changes. The library provides robust priority management with support for layered bar systems, conflict resolution, and intelligent display ordering that ensures important information is always visible and accessible to players. Additional features include integration with the framework's character system for automatic health and status updates, performance optimization for complex bar animations, and comprehensive accessibility options that ensure all players can effectively use the visual interface elements, making it essential for creating engaging and informative user interfaces that enhance gameplay immersion and provide clear feedback for all player actions and status changes.

---

### lia.bar.get

**Purpose**

Retrieves a bar by its identifier from the bar list.

**Parameters**

* `identifier` (*string*): The unique identifier of the bar to retrieve.

**Returns**

* `bar` (*table|nil*): The bar table if found, nil otherwise.

**Realm**

Client.

**Example Usage**

```lua
-- Get a specific bar
local healthBar = lia.bar.get("health")
if healthBar then
    print("Health bar found with priority: " .. healthBar.priority)
end

-- Get a custom bar
local customBar = lia.bar.get("myCustomBar")
if customBar then
    print("Custom bar color: " .. tostring(customBar.color))
end

-- Check if a bar exists before modifying
local bar = lia.bar.get("stamina")
if bar then
    bar.visible = true
end
```

---

### lia.bar.add

**Purpose**

Adds a new bar to the bar system with specified properties.

**Parameters**

* `getValue` (*function*): Function that returns the current value (0-1) for the bar.
* `color` (*Color*): The color of the bar.
* `priority` (*number*): Priority for bar ordering (lower numbers appear first).
* `identifier` (*string*): Unique identifier for the bar.

**Returns**

* `priority` (*number*): The assigned priority of the bar.

**Realm**

Client.

**Example Usage**

```lua
-- Add a health bar
lia.bar.add(function()
    local client = LocalPlayer()
    return client:Health() / client:GetMaxHealth()
end, Color(200, 50, 40), 1, "health")

-- Add an armor bar
lia.bar.add(function()
    local client = LocalPlayer()
    return client:Armor() / client:GetMaxArmor()
end, Color(30, 70, 180), 3, "armor")

-- Add a custom stamina bar
local stamina = 100
lia.bar.add(function()
    return stamina / 100
end, Color(100, 200, 100), 2, "stamina")

-- Add a hunger bar
local hunger = 80
lia.bar.add(function()
    return hunger / 100
end, Color(255, 165, 0), 4, "hunger")

-- Add a thirst bar
local thirst = 60
lia.bar.add(function()
    return thirst / 100
end, Color(0, 150, 255), 5, "thirst")

-- Add a custom progress bar
local progress = 0
lia.bar.add(function()
    return progress
end, Color(255, 255, 0), 10, "customProgress")

-- Update progress
timer.Create("UpdateProgress", 0.1, 0, function()
    progress = math.min(progress + 0.01, 1)
    if progress >= 1 then
        timer.Remove("UpdateProgress")
    end
end)
```

---

### lia.bar.remove

**Purpose**

Removes a bar from the bar system by its identifier.

**Parameters**

* `identifier` (*string*): The unique identifier of the bar to remove.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Remove a specific bar
lia.bar.remove("customProgress")

-- Remove a bar after it's no longer needed
local bar = lia.bar.get("temporaryBar")
if bar then
    lia.bar.remove("temporaryBar")
end

-- Remove multiple bars
local barsToRemove = {"temp1", "temp2", "temp3"}
for _, id in ipairs(barsToRemove) do
    lia.bar.remove(id)
end

-- Remove bar with validation
if lia.bar.get("myBar") then
    lia.bar.remove("myBar")
    print("Bar removed successfully")
end
```

---

### lia.bar.drawBar

**Purpose**

Draws a single bar at the specified position with given properties.

**Parameters**

* `x` (*number*): X position of the bar.
* `y` (*number*): Y position of the bar.
* `w` (*number*): Width of the bar.
* `h` (*number*): Height of the bar.
* `pos` (*number*): Current position value (0-1).
* `max` (*number*): Maximum value (usually 1).
* `color` (*Color*): Color of the bar.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a health bar
lia.bar.drawBar(10, 10, 200, 20, 0.75, 1, Color(200, 50, 40))

-- Draw a custom progress bar
local progress = 0.5
lia.bar.drawBar(50, 50, 300, 15, progress, 1, Color(100, 200, 100))

-- Draw multiple bars
local bars = {
    {x = 10, y = 10, w = 200, h = 20, pos = 0.8, color = Color(200, 50, 40)},
    {x = 10, y = 35, w = 200, h = 20, pos = 0.6, color = Color(30, 70, 180)},
    {x = 10, y = 60, w = 200, h = 20, pos = 0.9, color = Color(100, 200, 100)}
}

for _, bar in ipairs(bars) do
    lia.bar.drawBar(bar.x, bar.y, bar.w, bar.h, bar.pos, 1, bar.color)
end

-- Draw animated bar
local animValue = 0
hook.Add("HUDPaint", "AnimatedBar", function()
    animValue = math.Approach(animValue, 0.7, FrameTime() * 0.5)
    lia.bar.drawBar(100, 100, 250, 25, animValue, 1, Color(255, 165, 0))
end)
```

---

### lia.bar.drawAction

**Purpose**

Draws an action bar with countdown timer for actions like reloading or using items.

**Parameters**

* `text` (*string*): Text to display above the action bar.
* `duration` (*number*): Duration of the action in seconds.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw reload action
lia.bar.drawAction("Reloading...", 2.5)

-- Draw item use action
lia.bar.drawAction("Using Medkit", 3.0)

-- Draw crafting action
lia.bar.drawAction("Crafting Item", 5.0)

-- Draw with custom text
local actionText = "Performing Action"
local actionDuration = 4.0
lia.bar.drawAction(actionText, actionDuration)

-- Draw action with validation
if IsValid(LocalPlayer()) and LocalPlayer():Alive() then
    lia.bar.drawAction("Special Action", 2.0)
end
```

---

### lia.bar.drawAll

**Purpose**

Draws all registered bars in priority order with delta smoothing and visibility management.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw all bars (usually called automatically)
lia.bar.drawAll()

-- Custom drawing with conditions
hook.Add("HUDPaint", "CustomBarDrawing", function()
    if not hook.Run("ShouldHideBars") then
        lia.bar.drawAll()
    end
end)

-- Draw bars with custom positioning
hook.Add("HUDPaint", "CustomBarPosition", function()
    local w, h = ScrW() * 0.4, 16
    local x, y = ScrW() * 0.3, 20
    
    -- Custom positioning before drawing
    for i, bar in ipairs(lia.bar.list) do
        local value = bar.getValue()
        if value > 0 then
            lia.bar.drawBar(x, y + (i - 1) * (h + 2), w, h, value, 1, bar.color)
        end
    end
end)

---

## Definitions

# Bar Fields

This document lists the standard keys used when defining HUD bars with `lia.bar.add` or retrieving them through `lia.bar.get`.

---

## Overview

Each bar represents a progress value such as health, armor, or stamina. The bar table stores callbacks and display information used by the HUD renderer.

---

## Field Summary

| Field | Type | Description |
| --- | --- | --- |
| `getValue` | `function` | Returns the bar's progress as a fraction. |
| `color` | `Color` | Bar fill colour. |
| `priority` | `number` | Draw order; lower priorities draw first. |
| `identifier` | `string` \| `nil` | Unique identifier, if provided. |
| `visible` | `boolean` \| `nil` | Set to `true` to force the bar to remain visible. |
| `lifeTime` | `number` | Internal timer used for fading; managed automatically. |
| `order` | `number` | Internal ordering counter for bars with same priority; managed automatically. |

---
```