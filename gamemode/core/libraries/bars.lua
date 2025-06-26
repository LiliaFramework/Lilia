local surfaceSetDrawColor, surfaceDrawRect, surfaceDrawOutlinedRect = surface.SetDrawColor, surface.DrawRect, surface.DrawOutlinedRect
lia.bar = lia.bar or {}
lia.bar.delta = lia.bar.delta or {}
lia.bar.list = {}
local function findIndexByIdentifier(identifier)
    for idx, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return idx end
    end
end

function lia.bar.get(identifier)
    for _, bar in ipairs(lia.bar.list) do
        if bar.identifier == identifier then return bar end
    end
end

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

function lia.bar.drawBar(x, y, w, h, pos, max, color)
    pos = math.min(pos, max)
    local usable = math.max(w - 6, 0)
    local fill = usable * pos / max
    PaintPanel(x, y, w + 6, h)
    surfaceSetDrawColor(color.r, color.g, color.b)
    surfaceDrawRect(x + 3, y + 3, fill, h - 6)
end

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
