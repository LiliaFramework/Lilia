local ceil, clamp = math.ceil, math.Clamp
local fade, shadowFade = 0, 0
local hideKey = false
local fastFade = false
local deathTimeReceived = 0
local lastDeathTimeValue = 0
local function getHUDFont(size)
    return "HUDFont." .. tostring(size)
end

local function resolveText(key, fallback, ...)
    local value = L(key, ...)
    if not isstring(value) or value == key then return fallback end
    return value
end

local function getThemeAccent()
    local theme = lia.color and lia.color.theme or {}
    return theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
end

local function alphaColor(color, alpha)
    return Color(color.r, color.g, color.b, math.floor((color.a or 255) * alpha))
end

local function drawPanelBox(x, y, w, h, radius, color, outline, alpha)
    local boxColor = alphaColor(color, alpha)
    local outlineColor = outline and alphaColor(outline, alpha) or nil
    if lia.derma and lia.derma.rect then
        lia.derma.rect(x, y, w, h):Rad(radius):Color(boxColor):Shape(lia.derma.SHAPE_IOS):Draw()
        if outlineColor then lia.derma.rect(x, y, w, h):Rad(radius):Color(outlineColor):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
        return
    end

    draw.RoundedBox(radius, x, y, w, h, boxColor)
    if outlineColor then
        surface.SetDrawColor(outlineColor)
        surface.DrawOutlinedRect(x, y, w, h, 1)
    end
end

local function drawCenteredText(text, font, x, y, color, ax, ay)
    lia.util.drawText(text, x, y, color, ax or TEXT_ALIGN_CENTER, ay or TEXT_ALIGN_TOP, font)
end

local function drawSegmentedCenteredText(segments, font, x, y, alpha, ay)
    surface.SetFont(font)
    local totalWidth = 0
    for _, segment in ipairs(segments) do
        totalWidth = totalWidth + select(1, surface.GetTextSize(segment.text))
    end

    local cursor = x - totalWidth * 0.5
    for _, segment in ipairs(segments) do
        local width = select(1, surface.GetTextSize(segment.text))
        lia.util.drawText(segment.text, cursor, y, alphaColor(segment.color, alpha), TEXT_ALIGN_LEFT, ay or TEXT_ALIGN_TOP, font)
        cursor = cursor + width
    end
end

local function drawDeathBadge(x, y, size, alpha)
    local red = Color(235, 76, 86)
    local redSoft = Color(235, 76, 86, 42)
    local bright = Color(245, 249, 249)
    drawPanelBox(x, y, size, size, 7, Color(35, 10, 14, 235), redSoft, alpha)
    surface.SetDrawColor(alphaColor(red, alpha))
    surface.DrawLine(x - 18, y + size * 0.5, x - 5, y + size * 0.5)
    surface.DrawLine(x + size + 5, y + size * 0.5, x + size + 18, y + size * 0.5)
    surface.DrawLine(x + size * 0.5, y - 18, x + size * 0.5, y - 5)
    surface.DrawLine(x + size * 0.5, y + size + 5, x + size * 0.5, y + size + 18)
    local innerW = math.floor(size * 0.12)
    local innerH = math.floor(size * 0.34)
    local innerX = x + size * 0.5 - innerW * 0.5
    local innerY = y + size * 0.24
    surface.SetDrawColor(alphaColor(bright, alpha))
    surface.DrawRect(innerX, innerY, innerW, innerH)
    local dotSize = math.max(5, math.floor(size * 0.09))
    local dotX = x + size * 0.5 - dotSize * 0.5
    local dotY = y + size * 0.7
    surface.DrawRect(dotX, dotY, dotSize, dotSize)
end

local function drawEyelids(progress)
    progress = clamp(progress, 0, 1)
    if progress <= 0 then return end
    local w, h = ScrW(), ScrH()
    if progress >= 0.999 then
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, w, h)
        return
    end

    local smooth = progress * progress * (3 - 2 * progress)
    local overlap = math.max(24, h * 0.035)
    local closeDistance = (h + overlap) * smooth
    local curveStrength = h * 0.1 * math.sin(smooth * math.pi)
    local steps = 64
    local eyelid = {
        {
            x = 0,
            y = 0
        },
        {
            x = w,
            y = 0
        }
    }

    for i = steps, 0, -1 do
        local t = i / steps
        local normalized = t * 2 - 1
        local arch = 1 - normalized * normalized
        eyelid[#eyelid + 1] = {
            x = w * t,
            y = math.min(closeDistance + curveStrength * arch, h + overlap)
        }
    end

    draw.NoTexture()
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawPoly(eyelid)
end

local function getRespawnState(ply)
    local baseTime = lia.config.get("SpawnTime", 5)
    baseTime = hook.Run("OverrideSpawnTime", ply, baseTime) or baseTime
    local lastDeath = ply:getLocalVar("lastDeathTime", os.time())
    if lastDeath ~= lastDeathTimeValue then
        lastDeathTimeValue = lastDeath
        deathTimeReceived = CurTime()
    end

    local timeSinceDeath = os.time() - lastDeath
    local preciseTimeSinceDeath = CurTime() - deathTimeReceived
    local left = clamp(baseTime - preciseTimeSinceDeath, 0, baseTime)
    if deathTimeReceived == 0 or preciseTimeSinceDeath < 0 then left = clamp(baseTime - timeSinceDeath, 0, baseTime) end
    if left >= baseTime and not ply:Alive() then left = baseTime end
    return baseTime, lastDeath, left
end

function MODULE:HUDPaint()
    local ply, ft = LocalPlayer(), FrameTime()
    if not IsValid(ply) or not ply:getChar() then return end
    local baseTime, lastDeath, left = getRespawnState(ply)
    if hook.Run("ShouldRespawnScreenAppear", ply, left, baseTime, lastDeath) == false then return end
    local safeBaseTime = math.max(baseTime, 0.1)
    local eyeClosure = 0
    if ply:Alive() then
        if deathTimeReceived > 0 then
            deathTimeReceived = 0
            lastDeathTimeValue = 0
        end

        if fade > 0 then
            shadowFade = clamp(shadowFade - ft * 2 / safeBaseTime, 0, 1)
            local fadeSpeed = fastFade and ft * 4 or ft / safeBaseTime
            if shadowFade == 0 then fade = clamp(fade - fadeSpeed, 0, 1) end
            if fade <= 0 then fastFade = false end
            hideKey = true
        end
    else
        hideKey = false
        local elapsed = clamp(safeBaseTime - left, 0, safeBaseTime)
        eyeClosure = clamp(elapsed / safeBaseTime, 0, 1)
        if left <= 0.05 then eyeClosure = 1 end
        if shadowFade < 1 then
            fade = clamp(fade + ft * 4 / safeBaseTime, 0, 1)
            if fade >= 0.1 then shadowFade = clamp(shadowFade + ft * 2 / safeBaseTime, 0, 1) end
        end
    end

    if IsValid(lia.gui.char) and lia.gui.char:IsVisible() then return end
    if fade <= 0.01 then return end
    local accent = getThemeAccent()
    local titleColor = Color(240, 246, 246)
    local bodyColor = Color(175, 194, 194)
    local dimColor = Color(120, 142, 142)
    local overlayAlpha = ceil((fade ^ 0.65) * 205)
    local panelAlpha = shadowFade
    surface.SetDrawColor(0, 0, 0, overlayAlpha)
    surface.DrawRect(-1, -1, ScrW() + 2, ScrH() + 2)
    surface.SetDrawColor(0, 18, 24, ceil(panelAlpha * 70))
    surface.DrawRect(-1, -1, ScrW() + 2, ScrH() + 2)
    drawEyelids(eyeClosure)
    local showForceHint = os.time() - lastDeath >= baseTime * 1.25
    local panelW = clamp(ScrW() * 0.4, 620, 760)
    local panelH = showForceHint and 446 or 398
    local introOffset = (1 - math.min(panelAlpha * 1.5, 1)) * 24
    local px = (ScrW() - panelW) * 0.5
    local py = (ScrH() - panelH) * 0.5 + introOffset
    drawPanelBox(px, py, panelW, panelH, 10, Color(5, 18, 23, 238), Color(accent.r, accent.g, accent.b, 90), panelAlpha)
    local badgeSize = 58
    local badgeX = px + panelW * 0.5 - badgeSize * 0.5
    local badgeY = py + 26
    drawDeathBadge(badgeX, badgeY, badgeSize, panelAlpha)
    drawCenteredText(resolveText("youHaveDied", "You have died"), getHUDFont(72), px + panelW * 0.5, py + 112, alphaColor(titleColor, panelAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    local causeText = hook.Run("GetRespawnScreenCause", ply, left, baseTime, lastDeath)
    if not isstring(causeText) or causeText == "" then causeText = "Killed by the environment" end
    drawCenteredText(causeText, getHUDFont(24), px + panelW * 0.5, py + 184, alphaColor(bodyColor, panelAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    local dividerW = math.min(panelW * 0.24, 176)
    local dividerY = py + 226
    surface.SetDrawColor(accent.r, accent.g, accent.b, ceil(panelAlpha * 55))
    surface.DrawLine(px + panelW * 0.5 - dividerW * 0.5, dividerY, px + panelW * 0.5 + dividerW * 0.5, dividerY)
    drawPanelBox(px + panelW * 0.5 - 2, dividerY - 2, 4, 4, 2, accent, nil, panelAlpha)
    if hideKey then return end
    local instructionY = py + 250
    if left <= 0 then
        drawSegmentedCenteredText({
            {
                text = "Press ",
                color = bodyColor
            },
            {
                text = resolveText("spaceKey", "SPACE"),
                color = accent
            },
            {
                text = " to respawn",
                color = bodyColor
            }
        }, getHUDFont(27), px + panelW * 0.5, instructionY, panelAlpha)
    else
        drawCenteredText(resolveText("respawnIn", "Respawn in %d", ceil(left)), getHUDFont(27), px + panelW * 0.5, instructionY, alphaColor(bodyColor, panelAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local buttonW = clamp(panelW - 190, 390, 470)
    local buttonH = 64
    local buttonX = px + panelW * 0.5 - buttonW * 0.5
    local buttonY = py + 294
    local ready = left <= 0
    local buttonBg = ready and Color(9, 24, 29, 245) or Color(7, 18, 22, 225)
    local buttonOutline = ready and Color(accent.r, accent.g, accent.b, 125) or Color(accent.r, accent.g, accent.b, 55)
    drawPanelBox(buttonX, buttonY, buttonW, buttonH, 8, buttonBg, buttonOutline, panelAlpha)
    local innerPadding = 10
    local segmentGap = 12
    local keyW = clamp(buttonW * 0.32, 116, 140)
    local keyX = buttonX + innerPadding
    local keyY = buttonY + 9
    local keyH = buttonH - 18
    local labelX = keyX + keyW + segmentGap
    local labelW = buttonX + buttonW - innerPadding - labelX
    local keyBg = ready and Color(16, 34, 40, 245) or Color(11, 25, 30, 225)
    local keyOutline = ready and Color(accent.r, accent.g, accent.b, 145) or Color(accent.r, accent.g, accent.b, 65)
    drawPanelBox(keyX, keyY, keyW, keyH, 6, keyBg, keyOutline, panelAlpha)
    drawCenteredText(resolveText("spaceKey", "SPACE"), getHUDFont(27), keyX + keyW * 0.5, keyY + 9, alphaColor(ready and titleColor or dimColor, panelAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    drawCenteredText("RESPAWN", getHUDFont(25), labelX + labelW * 0.5, buttonY + 18, alphaColor(ready and accent or dimColor, panelAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    if left > 0 then
        local fillFrac = 1 - clamp(left / safeBaseTime, 0, 1)
        local progressX = labelX + 8
        local progressY = buttonY + buttonH - 14
        local progressW = math.max(labelW - 16, 1)
        surface.SetDrawColor(accent.r, accent.g, accent.b, ceil(panelAlpha * 35))
        surface.DrawRect(progressX, progressY, progressW, 3)
        surface.SetDrawColor(accent.r, accent.g, accent.b, ceil(panelAlpha * 190))
        surface.DrawRect(progressX, progressY, progressW * fillFrac, 3)
    end

    if showForceHint then
        drawSegmentedCenteredText({
            {
                text = "If stuck, use ",
                color = dimColor
            },
            {
                text = "/forcerespawn",
                color = accent
            },
            {
                text = " to respawn",
                color = dimColor
            }
        }, getHUDFont(18), px + panelW * 0.5, py + 390, panelAlpha)
    end
end

function MODULE:PlayerButtonDown(client, key)
    local ply = LocalPlayer()
    local char = ply:getChar()
    if key ~= KEY_SPACE or not IsFirstTimePredicted() or not IsValid(ply) or ply ~= client or ply:Alive() or not char then return end
    local baseTime, lastDeath, left = getRespawnState(ply)
    if hook.Run("OnRespawnKeyPressed", ply, key, left, baseTime, lastDeath) == false then return end
    if left > 0 then return end
    fastFade = true
    net.Start("liaPlayerRespawn")
    net.SendToServer()
end
