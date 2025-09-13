local pi = math.pi
local index = index or 1
local deltaIndex = deltaIndex or index
local infoAlpha = infoAlpha or 0
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

local infoMarkup
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
    local position = lia.option.get("weaponSelectorPosition", "Left")
    local x, y, shiftX
    if position == "Left" then
        shiftX = ScrW() * 0.02
        x, y = ScrW() * 0.05, ScrH() * 0.5
    elseif position == "Right" then
        shiftX = -ScrW() * 0.02
        x, y = ScrW() * 0.95, ScrH() * 0.5
    else
        shiftX = 0
        x, y = ScrW() * 0.5, ScrH() * 0.5
    end

    local spacing = pi * 0.85
    local radius = 240 * alphaDelta
    deltaIndex = Lerp(frameTime * 12, deltaIndex, index)
    local activeColor = lia.config.get("Color")
    for realIndex, weapon in ipairs(weapons) do
        local theta = (realIndex - deltaIndex) * 0.1
        local isActive = realIndex == index
        local colAlpha = (255 - math.abs(theta * 3) * 255) * fraction
        local col = ColorAlpha(isActive and activeColor or color_white, colAlpha)
        local lastY = 0
        if infoMarkup and (realIndex == 1 or realIndex < index) then
            local _, h = infoMarkup:Size()
            lastY = h * fraction
            if realIndex == index - 1 or realIndex == 1 then
                infoAlpha = Lerp(frameTime * 5, infoAlpha, 255)
                local infoX = x + 6 + shiftX
                if position == "Right" then
                    infoX = x + 6 + shiftX
                elseif position == "Center" then
                    infoX = x + 6 + shiftX
                end

                infoMarkup:Draw(infoX, y + 30, 0, 0, infoAlpha * fraction)
            end

            if index == 1 then lastY = 0 end
        end

        surface.SetFont("liaBigFont")
        local name = hook.Run("GetWeaponName", weapon) or language.GetPhrase(weapon:GetPrintName())
        local _, ty = surface.GetTextSize(name)
        local scale = math.max(1 - math.abs(theta * 2), 0)
        local matrix = Matrix()
        local textX, textY
        if position == "Right" then
            textX = shiftX + x + math.cos(theta * spacing + pi) * radius - radius
            textY = y + lastY + math.sin(theta * spacing + pi) * radius - ty / 2
        else
            textX = shiftX + x + math.cos(theta * spacing + pi) * radius + radius
            textY = y + lastY + math.sin(theta * spacing + pi) * radius - ty / 2
        end

        matrix:Translate(Vector(textX, textY, 1))
        matrix:Scale(Vector(scale, scale, 1))
        cam.PushModelMatrix(matrix)
        lia.util.drawText(name, 2, ty / 2, col, 0, 1, "liaBigFont")
        cam.PopModelMatrix()
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
    infoMarkup = nil
    infoAlpha = 0
    if IsValid(weapon) then
        local textParts = {}
        local activeColor = lia.config.get("Color")
        for _, key in ipairs({"Author", "Contact", "Purpose", "Instructions"}) do
            if weapon[key] and weapon[key]:find("%S") then table.insert(textParts, string.format("<font=liaItemBoldFont><color=%d,%d,%d>%s</font></color>\n%s\n", activeColor.r, activeColor.g, activeColor.b, L(key:lower()), weapon[key])) end
        end

        if #textParts > 0 then
            local text = table.concat(textParts)
            infoMarkup = markup.Parse("<font=liaItemDescFont>" .. text, ScrW() * 0.3)
        end

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
            infoAlpha = 0
            return
        end

        local source, pitch = hook.Run("WeaponSelectSound")
        source = source or "common/talk.wav"
        pitch = pitch or 180
        client:EmitSound(source, 75, pitch)
        client:SelectWeapon(selectedWeapon:GetClass())
        alpha = 0
        infoAlpha = 0
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