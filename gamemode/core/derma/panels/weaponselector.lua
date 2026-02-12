local index = index or 1
local deltaIndex = deltaIndex or index
local alpha = alpha or 0
local alphaDelta = alphaDelta or alpha
local fadeTime = fadeTime or 0
local IsValid = IsValid
local tonumber = tonumber
local FrameTime = FrameTime
local Lerp = Lerp
local CurTime = CurTime
local ipairs = ipairs
local LocalPlayer = LocalPlayer
local math = math
local color_white = color_white
local surface = surface
local IN_ATTACK = IN_ATTACK
local function getWeaponFromIndex(i, weapons)
    return weapons[i] or NULL
end

local function shouldDrawWepSelect(client)
    client = client or LocalPlayer()
    return hook.Run("ShouldDrawWepSelect", client) ~= false
end

local function HUDPaint()
    if not shouldDrawWepSelect() then return end
    local frameTime = FrameTime()
    local fraction = alphaDelta
    if fraction <= 0.01 and alpha == 0 then
        alphaDelta = 0
        return
    else
        alphaDelta = Lerp(frameTime * 10, alphaDelta, alpha)
    end

    local client = LocalPlayer()
    local weapons = client:GetWeapons()
    local total = #weapons
    if total == 0 then return end
    if index > total then index = total end
    if index < 1 then index = 1 end
    deltaIndex = Lerp(frameTime * 12, deltaIndex, index)
    local screenW, screenH = ScrW(), ScrH()
    local position = lia.option.get("weaponSelectorPosition", "Left")
    local centerX = screenW * 0.5
    if position == "Left" then
        centerX = screenW * 0.35
    elseif position == "Right" then
        centerX = screenW * 0.65
    end

    local centerY = screenH * 0.5
    local cardW = math.min(screenW * 0.35, 360)
    local baseH = 80
    local accent = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme or color_white
    local detailColor = Color(200, 200, 200)
    local function wrapText(text, font, maxWidth, lineHeight)
        surface.SetFont(font)
        local lines = {}
        local textLines = string.Explode("\n", text or "")
        for _, textLine in ipairs(textLines) do
            local words = string.Explode(" ", textLine)
            local line = ""
            for _, word in ipairs(words) do
                local test = line ~= "" and (line .. " " .. word) or word
                local textW = surface.GetTextSize(test)
                if textW > maxWidth and line ~= "" then
                    table.insert(lines, line)
                    line = word
                else
                    line = test
                end
            end

            if line ~= "" then table.insert(lines, line) end
        end
        return lines, #lines > 0 and #lines * lineHeight or 0
    end

    local function buildInfoLines(weapon, maxWidth)
        local lines = {}
        local lineHeight = 20
        local function addBlock(label, value)
            if not value or not value:find("%S") then return end
            local block = label .. ": " .. value
            local blockLines = wrapText(block, "LiliaFont.17", maxWidth, lineHeight)
            for _, l in ipairs(blockLines) do
                table.insert(lines, l)
            end
        end

        if weapon.Purpose and weapon.Purpose:find("%S") then addBlock("Purpose", weapon.Purpose) end
        if weapon.Instructions and weapon.Instructions:find("%S") then
            table.insert(lines, "Instructions:")
            local instructionLines = wrapText(weapon.Instructions, "LiliaFont.17", maxWidth, lineHeight)
            for _, l in ipairs(instructionLines) do
                table.insert(lines, l)
            end
        end
        return lines, #lines > 0 and #lines * lineHeight or 0, lineHeight
    end

    local maxHeight = 0
    for i = 1, total do
        local offset = i - deltaIndex
        local scale = math.max(0.85, 1 - math.abs(offset) * 0.08)
        local w = cardW * scale
        local infoHeight = 0
        if i == index then
            local _, hInfo = buildInfoLines(weapons[i], w - 36 * scale)
            infoHeight = hInfo
        end

        local h = (baseH + infoHeight) * scale
        if h > maxHeight then maxHeight = h end
    end

    local spacing = maxHeight * 1.08
    for i = 1, total do
        local offset = i - deltaIndex
        local scale = math.max(0.85, 1 - math.abs(offset) * 0.08)
        local entryAlpha = math.Clamp(255 - math.abs(offset) * 90, 60, 255) * fraction
        local w = cardW * scale
        local weapon = weapons[i]
        local infoLines, infoHeight, lineHeight = {}, 0, 20
        if i == index then infoLines, infoHeight, lineHeight = buildInfoLines(weapon, w - 36 * scale) end
        local h = (baseH + infoHeight) * scale
        local x = centerX - w / 2
        local y = centerY + offset * spacing - h / 2
        local bgColor = Color(25, 28, 35, 250)
        lia.derma.rect(x, y, w, h):Rad(12):Color(Color(0, 0, 0, 180 * fraction)):Shadow(15, 20):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(x, y, w, h):Rad(12):Color(Color(bgColor.r, bgColor.g, bgColor.b, entryAlpha)):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(x, y, w, 4 * scale):Radii(12, 12, 0, 0):Color(Color(accent.r, accent.g, accent.b, entryAlpha)):Shape(lia.derma.SHAPE_IOS):Draw()
        local isActive = i == index
        surface.SetFont("LiliaFont.28")
        surface.SetTextColor(255, 255, 255, entryAlpha)
        surface.SetTextPos(x + 18 * scale, y + 12 * scale)
        local name = hook.Run("GetWeaponName", weapon) or language.GetPhrase(weapon:GetPrintName())
        surface.DrawText(name)
        local detailY = y + 44 * scale
        local ammoName = game.GetAmmoName(weapon:GetPrimaryAmmoType() or -1)
        local clip = weapon:Clip1()
        local reserve = ammoName and client:GetAmmoCount(ammoName) or nil
        local infoText = ""
        if ammoName and ammoName ~= "" then
            if clip and clip >= 0 then
                infoText = string.format("%s %d/%d", ammoName, clip, reserve or 0)
            else
                infoText = ammoName
            end
        end

        surface.SetFont("LiliaFont.18")
        surface.SetTextColor(detailColor.r, detailColor.g, detailColor.b, entryAlpha)
        surface.SetTextPos(x + 18 * scale, detailY)
        surface.DrawText(infoText)
        if isActive and #infoLines > 0 then
            local hasPurpose = weapon.Purpose and weapon.Purpose:find("%S")
            local descY = detailY + (hasPurpose and 22 or 12) * scale
            surface.SetFont("LiliaFont.17")
            surface.SetTextColor(detailColor.r, detailColor.g, detailColor.b, entryAlpha)
            for li, line in ipairs(infoLines) do
                surface.SetTextPos(x + 18 * scale, descY + (li - 1) * lineHeight)
                surface.DrawText(line)
            end
        end
    end

    if fadeTime < CurTime() and alpha > 0 then alpha = 0 end
end

local function onIndexChanged()
    if not shouldDrawWepSelect() then return end
    alpha = 1
    fadeTime = CurTime() + 5
    local client = LocalPlayer()
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
    if client:InVehicle() then return end
    local weapon = client:GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "weapon_physgun" and client:KeyDown(IN_ATTACK) then return end
    if hook.Run("CanPlayerChooseWeapon", weapon) == false then return end
    bind = bind:lower()
    local weapons = client:GetWeapons()
    local total = #weapons
    local isInvPrev = bind:find("invprev") ~= nil
    local isInvNext = bind:find("invnext") ~= nil
    if lia.option.get("invertWeaponScroll", false) then isInvPrev, isInvNext = isInvNext, isInvPrev end
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
    elseif bind:find("slot") then
        local slot = tonumber(bind:match("slot(%d)"))
        index = math.Clamp(slot or 1, 1, total)
        onIndexChanged()
        return true
    elseif bind:find("attack") and alpha > 0 then
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
