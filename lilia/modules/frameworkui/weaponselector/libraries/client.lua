local NewWeaponSelecter = NewWeaponSelecter or {
    index = 1,
    deltaIndex = 1,
    infoAlpha = 0,
    alpha = 0,
    alphaDelta = 0,
    fadeTime = 0,
    weapons = {}
}

local UnhighLightColor = Color(100, 100, 100, 100)
local isEnabled = true
local fontName = "NewWeaponSelectFont"
local function OnIndexChanged(weapon)
    NewWeaponSelecter.alpha = 1
    NewWeaponSelecter.fadeTime = CurTime() + 5
    NewWeaponSelecter.markup = nil
    if IsValid(weapon) then
        local source, pitch = hook.Run("WeaponCycleSound")
        LocalPlayer():EmitSound(source or "common/talk.wav", 50, pitch or 180)
    end
end

function MODULE:HUDPaint()
    if not LocalPlayer():getChar() then return end
    if not isEnabled then return end
    local frameTime = FrameTime()
    NewWeaponSelecter.alphaDelta = Lerp(frameTime * 10, NewWeaponSelecter.alphaDelta, NewWeaponSelecter.alpha)
    local fraction = NewWeaponSelecter.alphaDelta
    if fraction > 0.01 then
        local x, y = 100, ScrH() * 0.4
        local spacing = ScrH() / 380
        local radius = 240 * NewWeaponSelecter.alphaDelta
        local shiftX = ScrW() * 0.02
        NewWeaponSelecter.deltaIndex = Lerp(frameTime * 12, NewWeaponSelecter.deltaIndex, NewWeaponSelecter.index)
        local index = NewWeaponSelecter.deltaIndex
        if not NewWeaponSelecter.weapons[NewWeaponSelecter.index] then NewWeaponSelecter.index = #NewWeaponSelecter.weapons end
        for i = 1, #NewWeaponSelecter.weapons do
            local theta = (i - index) * 0.1
            local selectedColor = lia.config and lia.config.Color or Color(155, 20, 121, 100)
            local color2 = i == NewWeaponSelecter.index and selectedColor or UnhighLightColor
            color2.a = (color2.a - math.abs(theta * 3) * color2.a) * fraction
            local color3 = ColorAlpha(Color(255, 255, 255, 255), (255 - math.abs(theta * 3) * 255) * fraction)
            if i == NewWeaponSelecter.index then
                color3 = lia.config and lia.config.Color and ColorAlpha(lia.config.Color, (255 - math.abs(theta * 3) * 255) * fraction) or ColorAlpha(Color(155, 20, 121, 100), (255 - math.abs(theta * 3) * 255) * fraction)
            end

            local ebatTextKruto = i == NewWeaponSelecter.index and 10 + math.sin(CurTime() * 4) * 5 or 10
            local lastY = 0
            if NewWeaponSelecter.markup and (i < NewWeaponSelecter.index or i == 1) then
                if NewWeaponSelecter.index ~= 1 then
                    local _, h = NewWeaponSelecter.markup:Size()
                    lastY = h * fraction
                end

                if i == 1 or i == NewWeaponSelecter.index - 1 then
                    NewWeaponSelecter.infoAlpha = Lerp(frameTime * 3, NewWeaponSelecter.infoAlpha, 255)
                    NewWeaponSelecter.markup:Draw(x + 6 + shiftX, y + 30, 0, 0, NewWeaponSelecter.infoAlpha * fraction)
                end
            end

            surface.SetFont(fontName)
            local weaponName = NewWeaponSelecter.weapons[i]:GetPrintName():upper()
            local _, ty = surface.GetTextSize(weaponName)
            local scale = 1 - math.abs(theta * 2)
            local matrix = Matrix()
            matrix:Translate(Vector(shiftX + x + math.cos(theta * spacing + math.pi) * radius + radius, y + lastY + math.sin(theta * spacing + math.pi) * radius - ty / 2, 1))
            matrix:Scale(Vector(1, 1, 0) * scale)
            cam.PushModelMatrix(matrix)
            draw.TextShadow({
                text = weaponName,
                font = fontName,
                pos = {ebatTextKruto, ty / 2 - 1},
                color = color3,
                xalign = 0,
                yalign = 1
            }, 1, color3.a * 0.575)

            if i > NewWeaponSelecter.index - 4 and i < NewWeaponSelecter.index + 4 then
                surface.SetTexture(surface.GetTextureID("vgui/gradient-l"))
                surface.SetDrawColor(color2)
                surface.DrawTexturedRect(0, 0, 400, ScreenScale(16))
            end

            cam.PopModelMatrix()
        end

        if NewWeaponSelecter.fadeTime < CurTime() and NewWeaponSelecter.alpha > 0 then NewWeaponSelecter.alpha = 0 end
    elseif #NewWeaponSelecter.weapons > 0 then
        NewWeaponSelecter.weapons = {}
    end
end

function MODULE:HUDShouldDraw(name)
    if name == "CHudWeaponSelection" then return false end
end

function MODULE:PlayerBindPress(ply, bind, pressed)
    if not ply:getChar() then return end
    if not isEnabled then return end
    bind = bind:lower()
    if not pressed or (not bind:find("invprev") and not bind:find("invnext") and not bind:find("slot") and not bind:find("attack")) then return end
    local currentWeapon = ply:GetActiveWeapon()
    if IsValid(currentWeapon) and (currentWeapon:GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK)) then return end
    if IsValid(currentWeapon) and currentWeapon:GetClass() == "gmod_tool" then
        local tool = ply:GetTool()
        if tool and tool.Scroll ~= nil then return end
    end

    NewWeaponSelecter.weapons = {}
    for _, v in pairs(ply:GetWeapons()) do
        table.insert(NewWeaponSelecter.weapons, v)
    end

    if bind:find("invprev") then
        local oldIndex = NewWeaponSelecter.index
        NewWeaponSelecter.index = math.min(NewWeaponSelecter.index + 1, #NewWeaponSelecter.weapons)
        if NewWeaponSelecter.alpha == 0 or oldIndex ~= NewWeaponSelecter.index then OnIndexChanged(NewWeaponSelecter.weapons[NewWeaponSelecter.index]) end
        return true
    elseif bind:find("invnext") then
        local oldIndex = NewWeaponSelecter.index
        NewWeaponSelecter.index = math.max(NewWeaponSelecter.index - 1, 1)
        if NewWeaponSelecter.alpha == 0 or oldIndex ~= NewWeaponSelecter.index then OnIndexChanged(NewWeaponSelecter.weapons[NewWeaponSelecter.index]) end
        return true
    elseif bind:find("slot") then
        NewWeaponSelecter.index = math.Clamp(tonumber(bind:match("slot(%d)")) or 1, 1, #NewWeaponSelecter.weapons)
        OnIndexChanged(NewWeaponSelecter.weapons[NewWeaponSelecter.index])
        return true
    elseif bind:find("attack") and NewWeaponSelecter.alpha > 0 then
        local weapon = NewWeaponSelecter.weapons[NewWeaponSelecter.index]
        if IsValid(weapon) then
            LocalPlayer():EmitSound("HL2Player.Use")
            input.SelectWeapon(weapon)
            NewWeaponSelecter.alpha = 0
        end
        return true
    end
end

function MODULE:Think()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then NewWeaponSelecter.alpha = 0 end
end

function MODULE:LoadFonts()
    surface.CreateFont("NewWeaponSelectFont", {
        font = "Roboto Th",
        size = ScreenScale(16),
        weight = 500
    })
end