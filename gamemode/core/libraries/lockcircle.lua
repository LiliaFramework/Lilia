if SERVER then return end
local defaultLabel = "LOCKING THIS ENTITY..."
local defaultDuration = 3
local fadeDuration = 0.75
local fillColor = Color(176, 104, 255, 255)
local ringColor = Color(70, 70, 70, 180)
local percentFont = "LiliaFont.48b"
local labelFont = "LiliaFont.24b"
local radius = 78
local thickness = 14
local lockDisplay = {
    label = defaultLabel,
    startTime = 0,
    duration = defaultDuration,
    fadeStart = nil,
    active = false
}

local function scaledColor(base, factor)
    local alpha = math.Clamp(math.floor((base.a or 255) * factor), 0, 255)
    return Color(base.r, base.g, base.b, alpha)
end

local function drawRingSegment(centerX, centerY, outerRadius, innerRadius, startAngle, endAngle, segments)
    local points = {}
    for i = 0, segments do
        local fraction = i / segments
        local angle = math.rad(startAngle + (endAngle - startAngle) * fraction)
        points[#points + 1] = {
            x = centerX + math.cos(angle) * outerRadius,
            y = centerY + math.sin(angle) * outerRadius
        }
    end

    for i = segments, 0, -1 do
        local fraction = i / segments
        local angle = math.rad(startAngle + (endAngle - startAngle) * fraction)
        points[#points + 1] = {
            x = centerX + math.cos(angle) * innerRadius,
            y = centerY + math.sin(angle) * innerRadius
        }
    end

    surface.DrawPoly(points)
end

local function drawRing(centerX, centerY, outerRadius, thickness, progress)
    if progress <= 0 then return end
    local innerRadius = math.max(outerRadius - thickness, 0)
    local segments = 64
    local startAngle = -90
    local endAngle = startAngle + progress * 360
    drawRingSegment(centerX, centerY, outerRadius, innerRadius, startAngle, endAngle, segments)
end

local function setActive(label, duration)
    local text = label and label ~= "" and label or defaultLabel
    lockDisplay.label = text
    lockDisplay.duration = math.max(duration or defaultDuration, 0.1)
    lockDisplay.startTime = CurTime()
    lockDisplay.fadeStart = nil
    lockDisplay.active = true
end

local function parseArgs(args)
    local parts = {}
    if args then
        for i = 1, #args do
            parts[#parts + 1] = args[i]
        end
    end

    local duration
    if #parts > 0 then
        local candidate = tonumber(parts[#parts])
        if candidate then
            duration = candidate
            parts[#parts] = nil
        end
    end
    return #parts > 0 and table.concat(parts, " ") or "", duration
end

hook.Add("HUDPaint", "liaLockCircleDisplay", function()
    if not lockDisplay.active then return end
    local now = CurTime()
    local progress = math.Clamp((now - lockDisplay.startTime) / lockDisplay.duration, 0, 1)
    local alphaFactor = 1
    if progress >= 1 then
        if not lockDisplay.fadeStart then lockDisplay.fadeStart = now end
        local fadeProgress = math.Clamp((now - lockDisplay.fadeStart) / fadeDuration, 0, 1)
        alphaFactor = 1 - fadeProgress
        if fadeProgress >= 1 then
            lockDisplay.active = false
            return
        end
    end

    local centerX = ScrW() * 0.5
    local centerY = ScrH() * 0.55
    draw.NoTexture()
    surface.SetDrawColor(scaledColor(ringColor, alphaFactor))
    drawRing(centerX, centerY, radius, thickness, 1)
    surface.SetDrawColor(scaledColor(fillColor, alphaFactor))
    drawRing(centerX, centerY, radius, thickness, progress)
    local percentValue = math.floor(progress * 100 + 0.5)
    draw.SimpleText(percentValue .. "%", percentFont, centerX, centerY - 4, scaledColor(Color(255, 255, 255, 255), alphaFactor), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(lockDisplay.label, labelFont, centerX, centerY + radius * 0.9, scaledColor(Color(255, 255, 255, 210), alphaFactor), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

concommand.Add("lia_lock_circle", function(_, _, args)
    local label, duration = parseArgs(args)
    setActive(label, duration)
end)