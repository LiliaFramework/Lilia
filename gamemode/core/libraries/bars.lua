local surfaceSetDrawColor, surfaceDrawRect, surfaceDrawOutlinedRect = surface.SetDrawColor, surface.DrawRect, surface.DrawOutlinedRect
lia.bar = lia.bar or {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.list = {}
local function findIndexByIdentifier(identifier)
    for idx, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return idx end
    end
end

--[[
    lia.bar.get(identifier)

    Description:
        Retrieves a bar object from the list by its unique identifier.

    Parameters:
        identifier (string) – The unique identifier of the bar to retrieve.

    Realm:
        Client

    Returns:
        table or nil – The bar table if found, or nil if not found.

    Example Usage:
        local bar = lia.bar.get("health")
]]
function lia.bar.get(identifier)
    for _, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return bar end
    end
end

--[[
    lia.bar.add(getValue, color, priority, identifier)

    Description:
        Adds a new bar or replaces an existing one in the bar list.
        If the identifier matches an existing bar, the old bar is removed first.
        Bars are drawn in order of ascending priority.

    Parameters:
        getValue (function) – A callback that returns the current value of the bar.
        color (Color) – The fill color for the bar. Defaults to a random pastel color.
        priority (number) – Determines drawing order; lower values draw first. Defaults to end of list.
        identifier (string) – Optional unique identifier for the bar.

    Realm:
        Client

    Returns:
        number – The priority assigned to the added bar.

    Example Usage:
        lia.bar.add(function() return 1 end, Color(255,0,0), 1, "example")
]]
function lia.bar.add(getValue, color, priority, identifier)
    if identifier then
        local existingIdx = findIndexByIdentifier(identifier)
        if existingIdx then table.remove(lia.bar.list, existingIdx) end
    end

    priority = priority or #lia.bar.list + 1
    table.insert(lia.bar.list, {
        getValue = getValue,
        color = color or Color(math.random(150, 255), math.random(150, 255), math.random(150, 255)),
        priority = priority,
        lifeTime = 0,
        identifier = identifier
    })
    return priority
end

--[[
    lia.bar.remove(identifier)

    Description:
        Removes a bar from the list based on its unique identifier.

    Parameters:
        identifier (string) – The unique identifier of the bar to remove.

    Realm:
        Client

    Returns:
        None

    Example Usage:
        lia.bar.remove("example")
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
    lia.bar.drawBar(x, y, w, h, pos, max, color)

    Description:
        Draws a single horizontal bar at the specified screen coordinates,
        filling it proportionally based on pos and max.

    Parameters:
        x (number) – The x-coordinate of the bar's top-left corner.
        y (number) – The y-coordinate of the bar's top-left corner.
        w (number) – The total width of the bar (including padding).
        h (number) – The total height of the bar.
        pos (number) – The current value to display (will be clamped to max).
        max (number) – The maximum possible value for the bar.
        color (Color) – The color to fill the bar.

    Realm:
        Client

    Returns:
        None

    Example Usage:
        lia.bar.drawBar(10, 10, 200, 20, 0.5, 1, Color(255,0,0))
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
    lia.bar.drawAction(text, duration)

    Description:
        Displays a temporary action progress bar with accompanying text
        for the specified duration on the HUD.

    Parameters:
        text (string) – The text to display above the progress bar.
        duration (number) – Duration in seconds for which the bar is displayed.

    Realm:
        Client

    Returns:
        None

    Example Usage:
        lia.bar.drawAction("Reloading", 2)
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
    lia.bar.drawAll()

    Description:
        Iterates through all registered bars, applies smoothing to their values,
        and draws them on the HUD according to their priority and visibility rules.

    Parameters:
        None

    Realm:
        Client

    Returns:
        None

    Example Usage:
        hook.Add("HUDPaintBackground", "liaBarDraw", lia.bar.drawAll)
]]
function lia.bar.drawAll()
    if hook.Run("ShouldHideBars") then return end
    table.sort(lia.bar.list, function(a, b) return a.priority < b.priority end)
    local w, h = ScrW() * 0.35, 14
    local x, y = 4, 4
    local deltas = lia.bar.delta
    local update = FrameTime() * 0.6
    local now = CurTime()
    local always = lia.option.get("BarsAlwaysVisible")
    for i, bar in ipairs(lia.bar.list) do
        local target = bar.getValue()
        deltas[i] = deltas[i] or target
        deltas[i] = math.Approach(deltas[i], target, update)
        local value = deltas[i]
        if value ~= target then bar.lifeTime = now + 5 end
        if always or bar.lifeTime >= now or bar.visible or hook.Run("ShouldBarDraw", bar) then
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
