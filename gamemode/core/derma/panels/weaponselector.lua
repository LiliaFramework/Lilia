local index = index or 1
local deltaIndex = deltaIndex or index
local alpha = alpha or 0
local alphaDelta = alphaDelta or alpha
local fadeTime = fadeTime or 0
local IsValid = IsValid
local tonumber = tonumber
local tostring = tostring
local FrameTime = FrameTime
local Lerp = Lerp
local CurTime = CurTime
local ipairs = ipairs
local LocalPlayer = LocalPlayer
local ScrW = ScrW
local ScrH = ScrH
local Color = Color
local hook = hook
local surface = surface
local draw = draw
local language = language
local game = game
local string = string
local math = math
local IN_ATTACK = IN_ATTACK
local TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER
local TEXT_ALIGN_TOP = TEXT_ALIGN_TOP
local darkCard = Color(9, 28, 34, 232)
local darkCardHover = Color(13, 38, 45, 238)
local darkIcon = Color(14, 35, 41, 245)
local textPrimary = Color(234, 239, 238)
local textSecondary = Color(166, 179, 178)
local bronzeFallback = Color(180, 119, 51)
local softLine = Color(65, 84, 84)
local function getWeaponFromIndex(i, weapons)
    return weapons[i] or NULL
end

local function getOption(name, fallback)
    if lia and lia.option and lia.option.get then return lia.option.get(name, fallback) end
    return fallback
end

local function getAccent()
    local theme = lia and lia.color and lia.color.theme
    return theme and (theme.accent or theme.header or theme.theme) or bronzeFallback
end

local function withAlpha(color, alphaValue)
    return Color(color.r, color.g, color.b, math.Clamp(alphaValue, 0, 255))
end

local function scaled(color, fraction, alphaOverride)
    return withAlpha(color, (alphaOverride or color.a or 255) * fraction)
end

local function drawText(text, font, x, y, color, fraction, alignX, alignY)
    draw.SimpleText(tostring(text or ""), font, x, y, scaled(color, fraction), alignX or TEXT_ALIGN_LEFT, alignY or TEXT_ALIGN_TOP)
end

local function ellipsize(text, font, maxWidth)
    text = tostring(text or "")
    if maxWidth <= 0 then return "" end
    surface.SetFont(font)
    if surface.GetTextSize(text) <= maxWidth then return text end
    local suffix = "..."
    while #text > 0 and surface.GetTextSize(text .. suffix) > maxWidth do
        text = text:sub(1, -2)
    end
    return text .. suffix
end

local function wrapText(text, font, maxWidth, maxLines)
    local lines = {}
    text = tostring(text or "")
    maxLines = maxLines or 6
    if maxWidth <= 0 or maxLines <= 0 or not text:find("%S") then return lines end
    surface.SetFont(font)
    local textLines = string.Explode("\n", text)
    for _, textLine in ipairs(textLines) do
        local words = string.Explode(" ", textLine)
        local line = ""
        for _, word in ipairs(words) do
            local test = line ~= "" and line .. " " .. word or word
            if surface.GetTextSize(test) > maxWidth and line ~= "" then
                lines[#lines + 1] = line
                line = word
                if #lines >= maxLines then
                    lines[#lines] = ellipsize(lines[#lines], font, maxWidth)
                    return lines
                end
            else
                line = test
            end
        end

        if line ~= "" then
            lines[#lines + 1] = line
            if #lines >= maxLines then
                lines[#lines] = ellipsize(lines[#lines], font, maxWidth)
                return lines
            end
        end
    end
    return lines
end

local function appendWrapped(lines, text, font, maxWidth, maxLines)
    if maxLines <= 0 then return end
    local wrapped = wrapText(text, font, maxWidth, maxLines)
    for _, line in ipairs(wrapped) do
        lines[#lines + 1] = line
    end
end

local function getWeaponName(weapon)
    if not IsValid(weapon) then return "Unknown" end
    local customName = hook.Run("GetWeaponName", weapon)
    if customName and tostring(customName):find("%S") then return tostring(customName) end
    local printName = weapon:GetPrintName()
    if printName and tostring(printName):find("%S") then return language.GetPhrase(printName) end
    return weapon:GetClass()
end

local function getWeaponDetail(client, weapon)
    if not IsValid(weapon) then return "" end
    local ammoName = game.GetAmmoName(weapon:GetPrimaryAmmoType() or -1)
    local clip = weapon:Clip1()
    if ammoName and ammoName ~= "" then
        local reserve = client:GetAmmoCount(ammoName) or 0
        if clip and clip >= 0 then return string.format("%s  %d/%d", ammoName, clip, reserve) end
        return ammoName
    end
    return weapon:GetClass()
end

local function buildInfoLines(weapon, maxWidth)
    local lines = {}
    if not IsValid(weapon) then return lines, 0, 19 end
    local maxLines = 5
    if weapon.Purpose and tostring(weapon.Purpose):find("%S") then appendWrapped(lines, "Purpose: " .. tostring(weapon.Purpose), "LiliaFont.17", maxWidth, maxLines - #lines) end
    if #lines < maxLines and weapon.Instructions and tostring(weapon.Instructions):find("%S") then
        lines[#lines + 1] = "Instructions:"
        appendWrapped(lines, tostring(weapon.Instructions), "LiliaFont.17", maxWidth, maxLines - #lines)
    end
    return lines, #lines > 0 and #lines * 19 or 0, 19
end

local function shouldDrawWepSelect(client)
    client = client or LocalPlayer()
    return hook.Run("ShouldDrawWepSelect", client) ~= false
end

local function drawEntry(client, weapon, i, selectedIndex, x, y, w, h, infoLines, lineHeight, fraction, accent)
    local isActive = i == selectedIndex
    local background = isActive and darkCardHover or darkCard
    local outlineAlpha = isActive and 190 or 72
    local name = getWeaponName(weapon)
    local detail = getWeaponDetail(client, weapon)
    local iconText = weapon.IconLetter and tostring(weapon.IconLetter):sub(1, 1) or tostring(name):sub(1, 1):upper()
    local iconSize = 50
    local iconX = x + 14
    local iconY = y + 13
    local slotW = 24
    local slotH = 24
    local slotX = x + w - slotW - 14
    local slotY = y + 20
    draw.RoundedBox(6, x, y, w, h, scaled(background, fraction))
    surface.SetDrawColor(accent.r, accent.g, accent.b, outlineAlpha * fraction)
    surface.DrawOutlinedRect(x, y, w, h)
    if isActive then draw.RoundedBox(0, x, y, 3, h, Color(accent.r, accent.g, accent.b, 220 * fraction)) end
    draw.RoundedBox(6, iconX, iconY, iconSize, iconSize, scaled(darkIcon, fraction))
    surface.SetDrawColor(softLine.r, softLine.g, softLine.b, 80 * fraction)
    surface.DrawOutlinedRect(iconX, iconY, iconSize, iconSize)
    drawText(iconText, "LiliaFont.28", iconX + iconSize * 0.5, iconY + iconSize * 0.5 - 1, isActive and accent or textSecondary, fraction, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    drawText(ellipsize(name, "LiliaFont.28", w - 120), "LiliaFont.28", x + 78, y + 18, textPrimary, fraction)
    drawText(ellipsize(detail, "LiliaFont.17", w - 120), "LiliaFont.17", x + 78, y + 47, textSecondary, fraction)
    draw.RoundedBox(4, slotX, slotY, slotW, slotH, Color(0, 0, 0, 45 * fraction))
    surface.SetDrawColor(accent.r, accent.g, accent.b, 95 * fraction)
    surface.DrawOutlinedRect(slotX, slotY, slotW, slotH)
    drawText(i, "LiliaFont.18", slotX + slotW * 0.5, slotY + slotH * 0.5, accent, fraction, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if isActive and #infoLines > 0 then
        local infoY = y + 76
        surface.SetDrawColor(softLine.r, softLine.g, softLine.b, 75 * fraction)
        surface.DrawLine(x + 14, infoY - 8, x + w - 14, infoY - 8)
        for lineIndex, line in ipairs(infoLines) do
            drawText(line, "LiliaFont.17", x + 18, infoY + (lineIndex - 1) * lineHeight, textSecondary, fraction)
        end
    end
end

local function getVisibleBounds(total, selectedIndex, count)
    if total <= count then return 1, total end
    local half = math.floor(count * 0.5)
    local first = selectedIndex - half
    local last = selectedIndex + half
    if first < 1 then
        last = last + 1 - first
        first = 1
    end

    if last > total then
        first = first - (last - total)
        last = total
    end
    return math.max(first, 1), math.min(last, total)
end

local function HUDPaint()
    if not shouldDrawWepSelect() then return end
    local frameTime = FrameTime()
    local fraction = alphaDelta
    if fraction <= 0.01 and alpha == 0 then
        alphaDelta = 0
        return
    end

    alphaDelta = Lerp(frameTime * 10, alphaDelta, alpha)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local weapons = client:GetWeapons()
    local total = #weapons
    if total == 0 then return end
    if index > total then index = total end
    if index < 1 then index = 1 end
    deltaIndex = Lerp(frameTime * 12, deltaIndex, index)
    local screenW, screenH = ScrW(), ScrH()
    local position = tostring(getOption("weaponSelectorPosition", "right")):lower()
    local centerX = screenW * 0.5
    if position == "left" then
        centerX = screenW * 0.34
    elseif position == "right" then
        centerX = screenW * 0.66
    end

    local accent = getAccent()
    local visibleCount = math.Clamp(math.floor((screenH - 210) / 92), 3, 7)
    if visibleCount % 2 == 0 then visibleCount = visibleCount - 1 end
    local firstIndex, lastIndex = getVisibleBounds(total, index, visibleCount)
    local panelW = math.Clamp(screenW * 0.32, 390, 500)
    local padding = 14
    local gap = 10
    local baseEntryH = 76
    local entryData = {}
    local entriesH = 0
    for i = firstIndex, lastIndex do
        local weapon = weapons[i]
        local infoLines, infoHeight, lineHeight = {}, 0, 19
        if i == index then infoLines, infoHeight, lineHeight = buildInfoLines(weapon, panelW - padding * 2 - 36) end
        local entryH = baseEntryH + (i == index and infoHeight > 0 and infoHeight + 14 or 0)
        entryData[i] = {
            weapon = weapon,
            h = entryH,
            lines = infoLines,
            lineHeight = lineHeight
        }

        entriesH = entriesH + entryH
        if i < lastIndex then entriesH = entriesH + gap end
    end

    local panelH = entriesH
    local x = math.Round(centerX - panelW * 0.5)
    local y = math.Round(screenH * 0.5 - panelH * 0.5)
    local cursorY = y
    for i = firstIndex, lastIndex do
        local data = entryData[i]
        drawEntry(client, data.weapon, i, index, x, cursorY, panelW, data.h, data.lines, data.lineHeight, fraction, accent)
        cursorY = cursorY + data.h + gap
    end
    if fadeTime < CurTime() and alpha > 0 then alpha = 0 end
end

local function onIndexChanged()
    if not shouldDrawWepSelect() then return end
    alpha = 1
    fadeTime = CurTime() + 5
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local weapons = client:GetWeapons()
    local weapon = getWeaponFromIndex(index, weapons)
    if IsValid(weapon) then
        local source, pitch = hook.Run("WeaponCycleSound")
        source = source or "common/talk.wav"
        pitch = pitch or 180
        client:EmitSound(source, 45, pitch)
    end
end

local function PlayerBindPress(client, bind, pressed)
    if not shouldDrawWepSelect(client) then return end
    if not pressed then return end
    if not IsValid(client) or client:InVehicle() then return end
    local weapon = client:GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "weapon_physgun" and client:KeyDown(IN_ATTACK) then return end
    if hook.Run("CanPlayerChooseWeapon", weapon) == false then return end
    bind = bind:lower()
    local weapons = client:GetWeapons()
    local total = #weapons
    if total == 0 then return end
    local isInvPrev = bind:find("invprev") ~= nil
    local isInvNext = bind:find("invnext") ~= nil
    if getOption("invertWeaponScroll", false) then isInvPrev, isInvNext = isInvNext, isInvPrev end
    if isInvPrev or isInvNext then
        if isInvPrev then
            index = index - 1
            if index < 1 then index = total end
        else
            index = index + 1
            if index > total then index = 1 end
        end

        onIndexChanged()
        return true
    end

    if bind:find("slot") then
        local slot = tonumber(bind:match("slot(%d)"))
        index = math.Clamp(slot or 1, 1, total)
        onIndexChanged()
        return true
    end

    if bind:find("attack") and alpha > 0 then
        local selectedWeapon = getWeaponFromIndex(index, weapons)
        if not IsValid(selectedWeapon) then
            alpha = 0
            return
        end

        local source, pitch = hook.Run("WeaponSelectSound")
        source = source or "common/talk.wav"
        pitch = pitch or 180
        client:EmitSound(source, 75, pitch)
        client:SelectWeapon(selectedWeapon:GetClass())
        alpha = 0
        return true
    end
end

local meta = FindMetaTable("Player")
function meta:SelectWeapon(class)
    if not shouldDrawWepSelect(self) then return end
    if not self:HasWeapon(class) then return end
    self.doWeaponSwitch = self:GetWeapon(class)
end

local function StartCommand(client, cmd)
    if not shouldDrawWepSelect(client) then return end
    if not IsValid(client.doWeaponSwitch) then return end
    cmd:SelectWeapon(client.doWeaponSwitch)
    if client:GetActiveWeapon() == client.doWeaponSwitch then client.doWeaponSwitch = nil end
end

hook.Add("HUDPaint", "liaWeaponSelectHUDPaint", HUDPaint)
hook.Add("PlayerBindPress", "liaWeaponSelectPlayerBindPress", PlayerBindPress)
hook.Add("StartCommand", "liaWeaponSelectStartCommand", StartCommand)
