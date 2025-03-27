lia.bar = lia.bar or {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.list = {}
local function findIndexByIdentifier(identifier)
    for idx, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return idx end
    end
end

--[[
   Function: lia.bar.get

   Description:
      Returns the bar object matching the given identifier.

   Parameters:
      identifier (string) - The unique identifier of the bar.

   Returns:
      table|nil - The bar object if found, or nil otherwise.

   Realm:
      Client

   Example Usage:
      local myBar = lia.bar.get("health")
]]
function lia.bar.get(identifier)
    for _, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return bar end
    end
end

--[[
   Function: lia.bar.add

   Description:
      Adds a new bar (or replaces an existing one) to the bar list.

   Parameters:
      getValue (function) — Function returning a normalized progress (0 to 1).
      color (Color) — The fill color of the bar (auto‑generated if nil).
      priority (number) — The draw order priority (lower renders first).
      identifier (string|nil) — Unique identifier of the bar.

   Returns:
      number — The assigned priority.

   Realm:
      Shared

   Example Usage:
      lia.bar.add(function()
         local client = LocalPlayer()
         return client:Health() / client:GetMaxHealth()
      end, Color(200, 50, 40), 1, "health")
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
   Function: lia.bar.remove

   Description:
      Removes the bar corresponding to the given identifier.

   Parameters:
      identifier (string) - The unique identifier of the bar to remove.

   Returns:
      nil

   Realm:
      Client

   Example Usage:
      lia.bar.remove("health")
]]
function lia.bar.remove(identifier)
    local idx = findIndexByIdentifier(identifier)
    if idx then table.remove(lia.bar.list, idx) end
end

--[[
   Function: lia.bar.drawBar

   Description:
      Draws a single horizontal progress bar on the HUD.

   Parameters:
      x, y (number) - The screen coordinates for the bar.
      w, h (number) - The width and height of the bar.
      pos (number) - The current progress value.
      max (number) - The maximum value for the progress.
      color (Color) - The color used to fill the bar.

   Returns:
      nil

   Realm:
      Client

   Example Usage:
      lia.bar.drawBar(10, 10, 200, 20, 0.5, 1, Color(0,255,0))
]]
function lia.bar.drawBar(x, y, w, h, pos, max, color)
    pos = math.min(pos, max)
    local usable = math.max(w - 2, 0)
    local fill = usable * pos / max
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(x, y, w + 6, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawOutlinedRect(x, y, w + 6, h)
    surface.SetDrawColor(color.r, color.g, color.b)
    surface.DrawRect(x + 3, y + 3, fill, h - 6)
end

--[[
   Function: lia.bar.drawAction

   Description:
      Draws an action bar on the HUD when an action is in progress.
      The bar shows a progress fill and a label based on the remaining time,
      using a blur effect for a clean visual presentation.

   Parameters:
      text (string) - The label text to display above the bar.
      time (number) - The duration of the action in seconds.

   Returns:
      nil

   Realm:
      Client

   Example Usage:
      lia.bar.drawAction("Reloading", 3)
]]
function lia.bar.drawAction(text, time)
    local now = CurTime()
    local endTime = now + time
    hook.Remove("HUDPaint", "liaDrawAction")
    hook.Add("HUDPaint", "liaDrawAction", function()
        local cur = CurTime()
        if endTime <= cur then
            hook.Remove("HUDPaint", "liaDrawAction")
            return
        end

        local frac = 1 - math.TimeFraction(now, endTime, cur)
        local w, h = ScrW() * 0.35, 28
        local x, y = ScrW() * 0.5 - w / 2, ScrH() * 0.725 - h / 2
        lia.util.drawBlurAt(x, y, w, h)
        surface.SetDrawColor(35, 35, 35, 100)
        surface.DrawRect(x, y, w, h)
        surface.SetDrawColor(0, 0, 0, 120)
        surface.DrawOutlinedRect(x, y, w, h)
        surface.SetDrawColor(lia.config.get("Color"))
        surface.DrawRect(x + 4, y + 4, w * frac - 8, h - 8)
        surface.SetDrawColor(200, 200, 200, 20)
        surface.SetMaterial(lia.util.getMaterial("vgui/gradient-d"))
        surface.DrawTexturedRect(x + 4, y + 4, w * frac - 8, h - 8)
        draw.SimpleText(text, "liaMediumFont", x + 2, y - 22, Color(20, 20, 20))
        draw.SimpleText(text, "liaMediumFont", x, y - 24, Color(240, 240, 240))
    end)
end

--[[
   Function: lia.bar.drawAll

   Description:
      Called from the HUDPaintBackground hook to draw all active bars on the HUD.
      Bars are sorted by priority and smoothly animated toward their target values.
      Bars will be drawn if they are set to always be visible, are within their lifetime,
      or if they pass a custom visibility hook.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Client

   Internal:
      Yes
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

hook.Add("HUDPaintBackground", "liaDrawBars", lia.bar.drawAll)