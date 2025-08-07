--[[
# Bars Library

This page documents the functions for working with HUD bars and progress indicators.

---

## Overview

The bars library provides a system for creating and managing HUD bars and progress indicators within the Lilia framework. It handles bar registration, rendering, and provides utilities for displaying various types of progress bars such as health, stamina, and other character statistics. The library supports customizable colors, priorities, and dynamic value updates.
]]
local surfaceSetDrawColor, surfaceDrawRect, surfaceDrawOutlinedRect = surface.SetDrawColor, surface.DrawRect, surface.DrawOutlinedRect
lia.bar = lia.bar or {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.values = lia.bar.values or {}
lia.bar.list = {}
lia.bar.counter = lia.bar.counter or 0
local function findIndexByIdentifier(identifier)
    for idx, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return idx end
    end
end

--[[
    lia.bar.get

    Purpose:
        Retrieves a bar object from the bar list by its identifier.

    Parameters:
        identifier (string) - The unique identifier of the bar to retrieve.

    Returns:
        bar (table or nil) - The bar object if found, or nil if not found.

    Realm:
        Client.

    Example Usage:
        local healthBar = lia.bar.get("health")
        if healthBar then
            print("Health bar color:", healthBar.color)
        end
]]
function lia.bar.get(identifier)
    for _, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return bar end
    end
end

--[[
    lia.bar.add

    Purpose:
        Adds a new bar to the HUD bar list, or replaces an existing bar with the same identifier.
        Bars are sorted by priority and order for display.

    Parameters:
        getValue (function) - Function that returns the current value of the bar (should return a number between 0 and 1).
        color (Color) - The color of the bar. If nil, a random color is chosen.
        priority (number) - The display priority (lower numbers are drawn first). Optional.
        identifier (string) - Unique identifier for the bar. Optional.

    Returns:
        priority (number) - The priority assigned to the bar.

    Realm:
        Client.

    Example Usage:
        lia.bar.add(
            function()
                local client = LocalPlayer()
                return client:Health() / client:GetMaxHealth()
            end,
            Color(255, 0, 0),
            1,
            "health"
        )
]]
function lia.bar.add(getValue, color, priority, identifier)
    if identifier then
        local existingIdx = findIndexByIdentifier(identifier)
        if existingIdx then table.remove(lia.bar.list, existingIdx) end
    end

    priority = priority or #lia.bar.list + 1
    lia.bar.counter = lia.bar.counter + 1
    table.insert(lia.bar.list, {
        getValue = getValue,
        color = color or Color(math.random(150, 255), math.random(150, 255), math.random(150, 255)),
        priority = priority,
        lifeTime = 0,
        identifier = identifier,
        order = lia.bar.counter
    })
    return priority
end

--[[
    lia.bar.remove

    Purpose:
        Removes a bar from the HUD bar list by its identifier.

    Parameters:
        identifier (string) - The unique identifier of the bar to remove.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        lia.bar.remove("armor")
]]
function lia.bar.remove(identifier)
    local idx = findIndexByIdentifier(identifier)
    if idx then table.remove(lia.bar.list, idx) end
end

local function PaintPanel(x, y, w, h)
    surfaceSetDrawColor(0, 0, 0, 255)
    surfaceDrawOutlinedRect(x, y, w, h)
    surfaceSetDrawColor(0, 0, 0, 150)
    surfaceDrawRect(x + 1, y + 1, w - 2, h - 2)
end

--[[
    lia.bar.drawBar

    Purpose:
        Draws a single bar at the specified position and size, with the given value and color.

    Parameters:
        x (number) - The x-coordinate of the bar.
        y (number) - The y-coordinate of the bar.
        w (number) - The width of the bar.
        h (number) - The height of the bar.
        pos (number) - The current value of the bar (should be between 0 and max).
        max (number) - The maximum value of the bar.
        color (Color) - The color to draw the bar.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        lia.bar.drawBar(10, 10, 200, 16, 0.5, 1, Color(0, 255, 0))
]]
function lia.bar.drawBar(x, y, w, h, pos, max, color)
    pos = math.min(pos, max)
    local usable = math.max(w - 6, 0)
    local fill = usable * pos / max
    PaintPanel(x, y, w + 6, h)
    surfaceSetDrawColor(color.r, color.g, color.b)
    surfaceDrawRect(x + 3, y + 3, fill, h - 6)
end

--[[
    lia.bar.drawAction

    Purpose:
        Displays an action bar with a progress animation and text for a specified duration.

    Parameters:
        text (string) - The text to display above the action bar.
        duration (number) - The duration in seconds for which the action bar should be displayed.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        lia.bar.drawAction("Lockpicking...", 3)
]]
function lia.bar.drawAction(text, duration)
    local startTime, endTime = CurTime(), CurTime() + duration
    hook.Remove("HUDPaint", "liaBarDrawAction")
    hook.Add("HUDPaint", "liaBarDrawAction", function()
        local curTime = CurTime()
        if curTime >= endTime then
            hook.Remove("HUDPaint", "liaBarDrawAction")
            return
        end

        local frac = 1 - math.TimeFraction(startTime, endTime, curTime)
        local w, h = ScrW() * 0.35, 28
        local x, y = ScrW() * 0.5 - w * 0.5, ScrH() * 0.725 - h * 0.5
        lia.util.drawBlurAt(x, y, w, h)
        PaintPanel(x, y, w, h)
        surfaceSetDrawColor(lia.config.get("Color"))
        surfaceDrawRect(x + 4, y + 4, w * frac - 8, h - 8)
        surfaceSetDrawColor(200, 200, 200, 20)
        surface.SetMaterial(lia.util.getMaterial("vgui/gradient-d"))
        surface.DrawTexturedRect(x + 4, y + 4, w * frac - 8, h - 8)
        draw.SimpleText(text, "liaMediumFont", x + 2, y - 22, Color(20, 20, 20))
        draw.SimpleText(text, "liaMediumFont", x, y - 24, Color(240, 240, 240))
    end)
end

--[[
    lia.bar.drawAll

    Purpose:
        Draws all registered bars on the HUD, handling their animation, visibility, and order.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        -- This is automatically called via the HUDPaintBackground hook, but can be called manually:
        lia.bar.drawAll()
]]
function lia.bar.drawAll()
    if hook.Run("ShouldHideBars") then return end
    table.sort(lia.bar.list, function(a, b)
        if a.priority == b.priority then return (a.order or 0) < (b.order or 0) end
        return a.priority < b.priority
    end)

    local w, h = ScrW() * 0.35, 14
    local x, y = 4, 4
    local deltas = lia.bar.delta
    local update = FrameTime() * 0.6
    local now = CurTime()
    local always = lia.option.get("BarsAlwaysVisible")
    local values = lia.bar.values
    for i, bar in ipairs(lia.bar.list) do
        local id = bar.identifier or i
        local target = bar.getValue()
        local last = values[id]
        values[id] = target
        deltas[id] = deltas[id] or target
        deltas[id] = math.Approach(deltas[id], target, update)
        local value = deltas[id]
        if last ~= nil and last ~= target then
            bar.lifeTime = now + 5
        elseif value ~= target then
            bar.lifeTime = now + 5
        end

        if always and value > 0 or bar.lifeTime >= now or bar.visible or hook.Run("ShouldBarDraw", bar) then
            lia.bar.drawBar(x, y, w, h, value, 1, bar.color)
            y = y + h + 2
        end
    end
end

lia.bar.add(function()
    local client = LocalPlayer()
    return client:Health() / client:GetMaxHealth()
end, Color(200, 50, 40), 1, "health")

lia.bar.add(function()
    local client = LocalPlayer()
    return client:Armor() / client:GetMaxArmor()
end, Color(30, 70, 180), 3, "armor")

hook.Add("HUDPaintBackground", "liaBarDraw", lia.bar.drawAll)
