--------------------------------------------------------------------------------------------------------
local index = index or 1
local deltaIndex = deltaIndex or index
local infoAlpha = infoAlpha or 0
local alpha = alpha or 0
local alphaDelta = alphaDelta or alpha
local fadetime = fadetime or 0
local IsValid, tonumber, FrameTime, Lerp, ScrW, ScrH, CurTime, ipairs = IsValid, tonumber, FrameTime, Lerp, ScrW, ScrH, CurTime, ipairs
local RunConsoleCommand, LocalPlayer, math, color_white, surface = RunConsoleCommand, LocalPlayer, math, color_white, surface

local weaponInfo = {"Author", "Contact", "Purpose", "Instructions"}

lia.config.InjuryTextTable = {
    [.2] = {"Critical Injury", Color(255, 0, 0)},
    [.4] = {"Severe Injury", Color(255, 165, 0)},
    [.7] = {"Moderate Injury", Color(255, 215, 0)},
    [.9] = {"Minor Injury", Color(255, 255, 0)},
    [1] = {"Healthy", Color(0, 255, 0)},
}

--------------------------------------------------------------------------------------------------------
local function onIndexChanged()
    alpha = 1
    fadetime = CurTime() + 5
    local client = LocalPlayer()
    local weapon = client:GetWeapons()[index]
    markup = nil

    if IsValid(weapon) then
        local text = ""

        for k, v in ipairs(weaponInfo) do
            if weapon[v] and weapon[v]:find("%S") then
                local color = lia.config.Color
                text = text .. "<font=liaItemBoldFont><color=" .. color.r .. "," .. color.g .. "," .. color.b .. ">" .. L(v) .. "</font></color>\n" .. weapon[v] .. "\n"
            end
        end

        if text ~= "" then
            markup = markup.Parse("<font=liaItemDescFont>" .. text, ScrW() * 0.3)
            infoAlpha = 0
        end

        local source, pitch = hook.Run("WeaponCycleSound") or "common/talk.wav"
        client:EmitSound(source or "common/talk.wav", 50, pitch or 180)
    end
end

--------------------------------------------------------------------------------------------------------
hook.Add("HUDPaint", "WeaponSelectorHUDPaint", function()
    local frameTime = FrameTime()
    alphaDelta = Lerp(frameTime * 10, alphaDelta, alpha)
    local fraction = alphaDelta

    if fraction > 0 then
        local client = LocalPlayer()
        local weapons = client:GetWeapons()
        local total = #weapons
        local x, y = ScrW() * 0.5, ScrH() * 0.5
        local spacing = math.pi * 0.85
        local radius = 240 * alphaDelta
        deltaIndex = Lerp(frameTime * 12, deltaIndex, index)
        local currentIndex = deltaIndex

        for k, v in ipairs(weapons) do
            if not weapons[currentIndex] then
                currentIndex = total
            end

            local theta = (k - currentIndex) * 0.1
            local color = ColorAlpha(k == currentIndex and lia.config.Color or color_white, (255 - math.abs(theta * 3) * 255) * fraction)
            local lastY = 0
            local shiftX = ScrW() * .02

            if markup and k < currentIndex then
                local w, h = markup:Size()
                lastY = h * fraction

                if k == currentIndex - 1 then
                    infoAlpha = Lerp(frameTime * 3, infoAlpha, 255)
                    markup:Draw(x + 6 + shiftX, y + 30, 0, 0, infoAlpha * fraction)
                end
            end

            surface.SetFont("liaSubTitleFont")
            local tx, ty = surface.GetTextSize(v:GetPrintName():upper())
            local scale = 1 - math.abs(theta * 2)
            local matrix = Matrix()
            matrix:Translate(Vector(shiftX + x + math.cos(theta * spacing + math.pi) * radius + radius, y + lastY + math.sin(theta * spacing + math.pi) * radius - ty / 2, 1))
            matrix:Rotate(angle or Angle(0, 0, 0))
            matrix:Scale(Vector(1, 1, 0) * scale)
            cam.PushModelMatrix(matrix)
            lia.util.drawText(v:GetPrintName():upper(), 2, ty / 2, color, 0, 1, "liaSubTitleFont")
            cam.PopModelMatrix()
        end

        if fadetime < CurTime() and alpha > 0 then
            alpha = 0
        end
    end
end)

--------------------------------------------------------------------------------------------------------
hook.Add("PlayerBindPress", "WeaponSelectorPlayerBindPress", function(client, bind, pressed)
    local weapon = client:GetActiveWeapon()
    local lPly = LocalPlayer()

    if not client:InVehicle() and (not IsValid(weapon) or weapon:GetClass() ~= "weapon_physgun" or not client:KeyDown(IN_ATTACK)) then
        if IsValid(weapon) and weapon.CW20Weapon and not bind:find("invprev") and not bind:find("invnext") and not (bind:find("attack") and alpha > 0) and not (bind:find("slot") and weapon.dt.State ~= CW_CUSTOMIZE) then return end
        bind = bind:lower()

        if bind:find("invprev") and pressed then
            index = index - 1

            if index < 1 then
                index = #client:GetWeapons()
            end

            onIndexChanged()

            return true
        elseif bind:find("invnext") and pressed then
            index = index + 1

            if index > #client:GetWeapons() then
                index = 1
            end

            onIndexChanged()

            return true
        elseif bind:find("slot") then
            index = math.Clamp(tonumber(bind:match("slot(%d)")) or 1, 1, #lPly:GetWeapons())
            onIndexChanged()

            return true
        elseif bind:find("attack") and pressed and alpha > 0 then
            if self ~= nil and lPly ~= nil and lPly:GetWeapons() ~= nil and lPly:GetWeapons()[index] ~= nil then
                lPly:EmitSound(hook.Run("WeaponSelectSound", lPly:GetWeapons()[index]) or "buttons/button16.wav")
                lPly:SelectWeapon(lPly:GetWeapons()[index]:GetClass())
                alpha = 0

                return true
            end
        end
    end
end)

--------------------------------------------------------------------------------------------------------
hook.Add("GetInjuredText", "HUDGetInjuredText", function(client)
    local health = client:Health()

    for k, v in pairs(lia.config.InjuryTextTable) do
        if (health / client:GetMaxHealth()) < k then return v[1], v[2] end
    end
end)
--------------------------------------------------------------------------------------------------------