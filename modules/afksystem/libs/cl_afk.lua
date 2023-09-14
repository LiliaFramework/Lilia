
--------------------------------------------------------------------------------------------------------
local ignoreinput = false
--------------------------------------------------------------------------------------------------------
local local_afk
--------------------------------------------------------------------------------------------------------
local last_input = SysTime() + 5
--------------------------------------------------------------------------------------------------------
local last_focus = SysTime() + 5
--------------------------------------------------------------------------------------------------------
local last_mouse = SysTime() + 5
--------------------------------------------------------------------------------------------------------
local oldmouse = 1
--------------------------------------------------------------------------------------------------------
local mx, my = gui.MouseX, gui.MouseY
--------------------------------------------------------------------------------------------------------
local outafk, inafk
--------------------------------------------------------------------------------------------------------
local fadeoutlen = 3
--------------------------------------------------------------------------------------------------------
local DrawText = surface.DrawText
--------------------------------------------------------------------------------------------------------
local PopModelMatrix = cam.PopModelMatrix
--------------------------------------------------------------------------------------------------------
local PushModelMatrix = cam.PushModelMatrix
--------------------------------------------------------------------------------------------------------
local cl_afkui = CreateClientConVar("cl_afkui", "1", true, false)
--------------------------------------------------------------------------------------------------------
local matrixScale = Vector(0, 0, 0)
--------------------------------------------------------------------------------------------------------
local matrixTranslation = Vector(0, 0, 0)
--------------------------------------------------------------------------------------------------------
local last
--------------------------------------------------------------------------------------------------------
local oldkeys = nil
--------------------------------------------------------------------------------------------------------
local old_y = nil
--------------------------------------------------------------------------------------------------------
local last_32 = false
--------------------------------------------------------------------------------------------------------
local last_33 = false
--------------------------------------------------------------------------------------------------------
local last_27 = false
--------------------------------------------------------------------------------------------------------
local last_29 = false
--------------------------------------------------------------------------------------------------------
local last_31 = false
--------------------------------------------------------------------------------------------------------
local last_19 = false
--------------------------------------------------------------------------------------------------------
local last_11 = false
--------------------------------------------------------------------------------------------------------
local last_14 = false
--------------------------------------------------------------------------------------------------------
local last_15 = false
--------------------------------------------------------------------------------------------------------
local last_25 = false
--------------------------------------------------------------------------------------------------------
local last_79 = false
--------------------------------------------------------------------------------------------------------
local last_65 = false
--------------------------------------------------------------------------------------------------------
local isdown = input.IsKeyDown
--------------------------------------------------------------------------------------------------------
function MODULE:ClientAFK(client, afk, id, len)
    if client ~= LocalPlayer() then return end
    self:AFKage(afk)
end
--------------------------------------------------------------------------------------------------------
function MODULE:ClientAFKMonChanged()
    ignoreinput = true
    timer.Simple(0.1, function() ignoreinput = false end)
end
--------------------------------------------------------------------------------------------------------
function MODULE:SetAFKMode(client, afk)
    local bool = (afk and true) or falses
    netstream.Start("AFKMonGoner", bool)
    hook.Run("AFKMonChanged", client, bool)
end
--------------------------------------------------------------------------------------------------------
function MODULE:InputReceived()
    if ignoreinput then return end
    last_input = SysTime()
end
--------------------------------------------------------------------------------------------------------
function MODULE:StartTimer()
    local newmouse = mx() + my()
    if newmouse ~= oldmouse then
        oldmouse = newmouse
        last_mouse = SysTime()
    end

    if system.HasFocus() then last_focus = SysTime() end
    local max = lia.config.AFKTimer
    local var = SysTime() - max
    local client = LocalPlayer()
    if (last_mouse < var and last_input < var) or last_focus < var then
        if not local_afk then
            local_afk = true
            self:SetAFKMode(client, true)
        end
    elseif local_afk then
        local_afk = false
        self:SetAFKMode(client, false)
    end
end
--------------------------------------------------------------------------------------------------------
function MODULE:KeyPress()
    self:InputReceived()
end
--------------------------------------------------------------------------------------------------------
function MODULE:KeyRelease()
    self:InputReceived()
end
--------------------------------------------------------------------------------------------------------
function MODULE:PlayerBindPress()
    self:InputReceived()
end
--------------------------------------------------------------------------------------------------------
function MODULE:CreateMove()
    self:CheckStuff(UCMD)
end
--------------------------------------------------------------------------------------------------------
function HUDPaintAFK()
    local sw, sh = ScrW(), ScrH()
    local bw, bh = 500, 200
    local now = RealTime()
    local len = LocalPlayer():AFKTime()
    local frac = len / 0.5
    frac = frac > 1 and 1 or frac < 0 and 0 or frac
    if outafk then
        frac = frac + 5 - (now - outafk) * 2
        frac = frac > 1 and 1 or frac < 0 and 0 or frac
    end

    local h = math.floor(len / 60 / 60)
    local m = math.floor(len / 60 - h * 60)
    local s = math.floor(len - m * 60 - h * 60 * 60)
    surface.SetFont"closecaption_bold"
    surface.SetTextColor(255, 255, 255, frac * 255)
    surface.SetDrawColor(255, 255, 255, frac * 255)
    local txt = outafk and last or string.format("AFK %.2d:%.2d:%.2d", h, m, s)
    last = txt
    local tw, th = surface.GetTextSize(txt)
    surface.SetTextPos(0, 0)
    local scl = ScreenScale(0.9)
    local matrix = Matrix()
    matrixTranslation.x = sw * 0.5 - tw * scl * 0.5
    matrixTranslation.y = sh * 0.1 --th*scl*0.5
    matrix:SetTranslation(matrixTranslation)
    matrixScale.x = scl
    matrixScale.y = scl
    matrix:Scale(matrixScale)
    PushModelMatrix(matrix)
    surface.SetTextPos(1, 1)
    surface.SetTextColor(30, 30, 30, frac * 100)
    DrawText(txt)
    if outafk then
        surface.SetTextColor(236, 253, 154, frac * 200)
    else
        surface.SetTextColor(244, 254, 255, frac * 200)
    end

    surface.SetTextPos(0, 0)
    DrawText(txt)
    PopModelMatrix()
    if outafk and now - outafk > fadeoutlen then hook.Remove("HUDPaint", "afkui") end
end
--------------------------------------------------------------------------------------------------------
function MODULE:AFKage(afk)
    if afk then
        inafk = RealTime()
        outafk = false
        hook.Add("HUDPaint", "afkui", function()
            self:HUDPaintAFK()
        end)
    else
        outafk = RealTime()
    end
end
--------------------------------------------------------------------------------------------------------
function MODULE:CheckStuff(UCMD)
    if oldkeys ~= UCMD:GetButtons() then
        self:InputReceived()
        oldkeys = UCMD:GetButtons()
    end

    if old_y ~= UCMD:GetMouseX() then
        self:InputReceived()
        old_y = UCMD:GetMouseX()
    end

    if isdown(33) ~= last_33 then
        last_33 = isdown(33)
        self:InputReceived()
        return
    end

    if isdown(27) ~= last_27 then
        last_27 = isdown(27)
        self:InputReceived()
        return
    end

    if isdown(29) ~= last_29 then
        last_29 = isdown(29)
        self:InputReceived()
        return
    end

    if isdown(31) ~= last_31 then
        last_31 = isdown(31)
        self:InputReceived()
        return
    end

    if isdown(19) ~= last_19 then
        last_19 = isdown(19)
        self:InputReceived()
        return
    end

    if isdown(11) ~= last_11 then
        last_11 = isdown(11)
        self:InputReceived()
        return
    end

    if isdown(14) ~= last_14 then
        last_14 = isdown(14)
        self:InputReceived()
        return
    end

    if isdown(15) ~= last_15 then
        last_ = isdown(15)
        self:InputReceived()
        return
    end

    if isdown(25) ~= last_25 then
        last_25 = isdown(25)
        self:InputReceived()
        return
    end

    if isdown(32) ~= last_32 then
        last_32 = isdown(32)
        self:InputReceived()
        return
    end

    if isdown(79) ~= last_79 then
        last_79 = isdown(79)
        self:InputReceived()
        return
    end

    if isdown(65) ~= last_65 then
        last_65 = isdown(65)
        self:InputReceived()
        return
    end
end
--------------------------------------------------------------------------------------------------------
timer.Simple(10, function() timer.Create("AFKMon", 0.2, 0, function() MODULE:StartTimer() end) end)
--------------------------------------------------------------------------------------------------------
