local PANEL = {}
local pi = math.pi
local math_cos = math.cos
local math_sin = math.sin
local math_atan2 = math.atan2
local math_sqrt = math.sqrt
local math_floor = math.floor
local math_min = math.min
local FrameTime = FrameTime
local SysTime = SysTime
local CurTime = CurTime
local EPS = 1e-6
local EPS_ANGLE = 1e-4
local function GetSectorIndexFromAngle(angle, cnt)
    if not angle or cnt <= 0 then return nil end
    local sector = (2 * pi) / cnt
    local raw = angle / sector
    local idx = (math_floor(raw + EPS) % cnt) + 1
    return idx
end

local function ClampEndAngle(a)
    if a >= 360 then return 360 - EPS_ANGLE end
    return a
end

function PANEL:Init(options)
    options = options or {}
    self.options = {}
    self.rootMenu = {
        title = L("menu"),
        desc = L("radial_select_option"),
        options = self.options
    }

    self.menuStack = {}
    self.currentMenu = self.rootMenu
    local baseRadius = options.radius or 320
    local baseInner = options.inner_radius or 110
    local minW, minH = 1366, 768
    local scale = 1
    if ScrW() > minW and ScrH() > minH then scale = math_min(math_min(ScrW() / 1920, ScrH() / 1080), 1.15) end
    self.radius = ScreenScale(baseRadius) * scale
    self.innerRadius = ScreenScale(baseInner) * scale
    self.scale = scale
    self.titleFont = 'Fated.28'
    self.font = 'Fated.20'
    self.descFont = 'Fated.14'
    self.fadeInTime = 0.18
    self.openTime = SysTime()
    self.currentAlpha = 0
    self.scaleAnim = 0.96
    self.scale_animation = options.scale_animation ~= false
    self.disable_background = options.disable_background or false
    self.hover_sound = options.hover_sound or 'ratio_button.wav'
    self.hoverOption = nil
    self.hoverAnim = 0
    self.selectedOption = nil
    self._hotkeyCooldown = {}
    self.optionHover = {}
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:MakePopup()
    self:SetKeyboardInputEnabled(true)
    self:SetDrawOnTop(true)
    self:SetMouseInputEnabled(true)
    self._mouseWasDown = false
    self.Think = function()
        if self.currentAlpha < 255 then
            self.currentAlpha = math.Clamp(255 * ((SysTime() - self.openTime) / self.fadeInTime), 0, 255)
            if self.scale_animation then
                local t = math.Clamp((SysTime() - self.openTime) / self.fadeInTime, 0, 1)
                self.scaleAnim = 0.96 + (1 - (1 - t) ^ 2) * 0.04
            else
                self.scaleAnim = 1
            end
        end

        local curOuter = self.radius * self.scaleAnim
        local curInner = self.innerRadius * self.scaleAnim
        local mouseDown = input.IsMouseDown(MOUSE_LEFT)
        if mouseDown and not self._mouseWasDown then
            local mx, my = self:CursorPos()
            local cx, cy = ScrW() / 2, ScrH() / 2
            local dist = math_sqrt((mx - cx) ^ 2 + (my - cy) ^ 2)
            if dist > curInner and dist < curOuter then
                local ang = math_atan2(my - cy, mx - cx)
                if ang < 0 then ang = ang + 2 * pi end
                local opts = self:GetCurrentOptions()
                local cnt = #opts
                if cnt > 0 then
                    local idx = GetSectorIndexFromAngle(ang, cnt)
                    if idx and opts[idx] then
                        self:SelectOption(idx)
                        if self.hover_sound then surface.PlaySound(self.hover_sound) end
                    end
                end
            elseif dist <= curInner then
                if #self.menuStack > 0 then
                    self:GoBack()
                    if self.hover_sound then surface.PlaySound(self.hover_sound) end
                else
                    self:Remove()
                end
            else
                if dist >= curOuter then self:Remove() end
            end
        end

        local mx, my = self:CursorPos()
        local cx, cy = ScrW() / 2, ScrH() / 2
        local dist = math_sqrt((mx - cx) ^ 2 + (my - cy) ^ 2)
        local hovered = nil
        if dist > curInner and dist < curOuter then
            local ang = math_atan2(my - cy, mx - cx)
            if ang < 0 then ang = ang + 2 * pi end
            local opts = self:GetCurrentOptions()
            local cnt = #opts
            if cnt > 0 then hovered = GetSectorIndexFromAngle(ang, cnt) end
        end

        if self.hoverOption ~= hovered and hovered and self.hover_sound then surface.PlaySound(self.hover_sound) end
        self.hoverOption = hovered
        self.hoverAnim = math.Clamp(self.hoverAnim + (self.hoverOption and 10 or -20) * FrameTime(), 0, 1)
        self._mouseWasDown = mouseDown
        local dt = FrameTime()
        local opts = self:GetCurrentOptions()
        for i = 1, #opts do
            local target = (self.hoverOption == i) and 1 or 0
            self.optionHover[i] = lia.util.approachExp(self.optionHover[i] or 0, target, 18, dt)
        end

        for i = 1, math_min(9, #self:GetCurrentOptions()) do
            local k = KEY_1 + (i - 1)
            if input.IsKeyDown(k) then
                local last = self._hotkeyCooldown[k] or 0
                if CurTime() - last > 0.18 then
                    self._hotkeyCooldown[k] = CurTime()
                    self:SelectOption(i)
                    if self.hover_sound then surface.PlaySound(self.hover_sound) end
                end
            end
        end
    end
end

function PANEL:OnMousePressed(_)
    local mx, my = self:CursorPos()
    local cx, cy = ScrW() / 2, ScrH() / 2
    local curOuter = self.radius * self.scaleAnim
    local dist = math_sqrt((mx - cx) ^ 2 + (my - cy) ^ 2)
    if dist <= curOuter then return self:MouseCapture(true) end
    self:Remove()
    return true
end

function PANEL:OnMouseReleased(_)
    self:MouseCapture(false)
end

function PANEL:CreateSubMenu(title, desc)
    local submenu = {
        title = title or 'Подменю',
        desc = desc or '',
        options = {}
    }

    function submenu:AddOption(text, func, icon, desc)
        table.insert(submenu.options, {
            text = text,
            func = func,
            icon = icon,
            desc = desc
        })
        return #submenu.options
    end
    return submenu
end

function PANEL:AddSubMenuOption(text, submenu, icon, desc)
    return self:AddOption(text, nil, icon, desc, submenu)
end

function PANEL:AddOption(text, func, icon, desc, submenu)
    table.insert(self.options, {
        text = text,
        func = func,
        icon = icon,
        desc = desc,
        submenu = submenu
    })
    return #self.options
end

function PANEL:GetCurrentOptions()
    if self.currentMenu and self.currentMenu.options then return self.currentMenu.options end
    return self.options
end

function PANEL:SelectOption(index)
    local opts = self:GetCurrentOptions()
    if not opts or not opts[index] then return end
    local opt = opts[index]
    if opt.submenu then
        table.insert(self.menuStack, self.currentMenu)
        self.currentMenu = opt.submenu
        self:UpdateCenterText()
        return
    end

    self.selectedOption = opt
    if opt.func then
        local ok, err = pcall(opt.func)
        if not ok then ErrorNoHalt(tostring(err) .. '\n') end
    end

    self:Remove()
end

function PANEL:GoBack()
    if #self.menuStack > 0 then
        self.currentMenu = table.remove(self.menuStack)
        self:UpdateCenterText()
    end
end

function PANEL:SetCenterText(title, desc)
    self.rootMenu.title = title or self.rootMenu.title
    self.rootMenu.desc = desc or self.rootMenu.desc
    self:UpdateCenterText()
end

function PANEL:UpdateCenterText()
    if self.currentMenu then
        self.centerText = self.currentMenu.title or self.rootMenu.title
        self.centerDesc = self.currentMenu.desc or self.rootMenu.desc
    else
        self.centerText = self.rootMenu.title
        self.centerDesc = self.rootMenu.desc
    end
end

function PANEL:IsMouseOver()
    local mx, my = self:CursorPos()
    local cx, cy = ScrW() / 2, ScrH() / 2
    local curOuter = self.radius * self.scaleAnim
    return math_sqrt((mx - cx) ^ 2 + (my - cy) ^ 2) <= curOuter
end

function PANEL:OnCursorMoved(x, y)
    if not self:IsMouseOver() then self.hoverOption = nil end
end

function PANEL:OnRemove()
end

function PANEL:Paint(w, h)
    local cx, cy = ScrW() / 2, ScrH() / 2
    local alpha = math.Clamp(self.currentAlpha / 255, 0, 1)
    local opts = self:GetCurrentOptions()
    local cnt = #opts
    if not self.disable_background then lia.rndx.Rect(0, 0, w, h):Radii(0, 0, 0, 0):Color(Color(0, 0, 0, 140 * alpha)):Draw() end
    local outerR = self.radius * self.scaleAnim
    local innerR = self.innerRadius * self.scaleAnim
    local outerD = outerR * 2
    local innerD = innerR * 2
    lia.rndx.Circle(cx, cy, outerD + 12):Color(lia.color.theme.window_shadow):Shadow(8, 24):Draw()
    lia.rndx.Circle(cx, cy, outerD):Color(Color(lia.color.theme.background.r, lia.color.theme.background.g, lia.color.theme.background.b, math_floor(240 * alpha))):Draw()
    local currentTheme = lia.color.theme
    lia.rndx.Circle(cx, cy, outerD):Outline(2):Color(Color(currentTheme.accent.r, currentTheme.accent.g, currentTheme.accent.b, math_floor(160 * alpha))):Draw()
    if cnt > 0 then
        local sectorDeg = 360 / cnt
        local baseCol = lia.color.theme.background
        local baseSectorCol = Color(baseCol.r, baseCol.g, baseCol.b, math_floor(255 * alpha))
        for i = 1, cnt do
            local startDeg = (i - 1) * sectorDeg
            local endDeg = i * sectorDeg
            if startDeg < 0 then startDeg = 0 end
            endDeg = ClampEndAngle(endDeg)
            if endDeg > startDeg then
                lia.rndx.Circle(cx, cy, outerD):StartAngle(startDeg):EndAngle(endDeg):Color(baseSectorCol):Draw()
                lia.rndx.Circle(cx, cy, outerD):StartAngle(startDeg):EndAngle(endDeg):Outline(2):Color(Color(lia.color.theme.background.r, lia.color.theme.background.g, lia.color.theme.background.b, math_floor(160 * alpha))):Draw()
            end
        end

        if self.hoverOption and opts[self.hoverOption] then
            local i = self.hoverOption
            local startDeg = (i - 1) * sectorDeg
            local endDeg = i * sectorDeg
            if startDeg < 0 then startDeg = 0 end
            endDeg = ClampEndAngle(endDeg)
            if endDeg > startDeg then
                local th = currentTheme.theme
                local hoverAlpha = math_floor(200 * self.hoverAnim * alpha)
                lia.rndx.Circle(cx, cy, outerD):StartAngle(startDeg):EndAngle(endDeg):Color(Color(th.r, th.g, th.b, math_floor(22 * self.hoverAnim * alpha))):Draw()
                lia.rndx.Circle(cx, cy, outerD):StartAngle(startDeg):EndAngle(endDeg):Outline(2):Color(Color(th.r, th.g, th.b, hoverAlpha)):Draw()
            end
        end

        lia.rndx.Circle(cx, cy, innerD):Color(Color(lia.color.theme.background.r, lia.color.theme.background.g, lia.color.theme.background.b, math_floor(255 * alpha))):Draw()
        local tintA = math_floor(36 * alpha)
        lia.rndx.Circle(cx, cy, innerD - 8):Color(Color(currentTheme.theme.r, currentTheme.theme.g, currentTheme.theme.b, tintA)):Draw()
        lia.rndx.Circle(cx, cy, innerD):Outline(2):Color(Color(currentTheme.theme.r, currentTheme.theme.g, currentTheme.theme.b, math_floor(80 * alpha))):Draw()
        local sectorRad = (2 * pi) / cnt
        for i, option in ipairs(opts) do
            local startA = (i - 1) * sectorRad
            local midA = startA + sectorRad * 0.5
            local hv = self.optionHover[i] or 0
            local eased = lia.util.easeOutCubic(math.Clamp(hv, 0, 1))
            local labelR = innerR + (outerR - innerR) * (0.5 + 0.06 * eased)
            local numberR = innerR + (labelR - innerR) * 0.35
            local lx = cx + labelR * math_cos(midA)
            local ly = cy + labelR * math_sin(midA)
            local nx = cx + numberR * math_cos(midA)
            local ny = cy + numberR * math_sin(midA)
            local isHovered = self.hoverOption == i
            local txtAlpha = math_floor((isHovered and 255 or 220) * alpha)
            local currentTheme = lia.color.theme
            local txtCol = Color(currentTheme.text.r, currentTheme.text.g, currentTheme.text.b, txtAlpha)
            if option.icon and option.icon ~= false and option.icon ~= nil then
                local iconSize = ScreenScale(28) * self.scale * (1 + 0.06 * eased)
                local iconX = lx - iconSize * 0.5
                local iconY = ly - iconSize * 0.5 - ScreenScaleH(6) * self.scale
                local mat = Material(option.icon)
                if mat and not mat:IsError() then
                    surface.SetDrawColor(255, 255, 255, math_floor(230 * alpha))
                    surface.SetMaterial(mat)
                    surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
                end

                draw.SimpleText(option.text or '', self.font, lx, ly + iconSize * 0.5 - ScreenScaleH(4) * self.scale, txtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                if option.desc and isHovered then draw.SimpleText(option.desc, self.descFont, lx, ly + iconSize * 0.5 + ScreenScaleH(16) * self.scale, Color(lia.color.theme.text.r, lia.color.theme.text.g, lia.color.theme.text.b, math_floor(180 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP) end
                if i <= 9 then draw.SimpleText(tostring(i), 'Fated.14', nx, ny, Color(currentTheme.accent.r, currentTheme.accent.g, currentTheme.accent.b, math_floor(200 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            else
                draw.SimpleText(option.text or '', self.font, lx, ly - ScreenScaleH(4) * self.scale, txtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                if option.desc and isHovered then draw.SimpleText(option.desc, self.descFont, lx, ly + ScreenScaleH(18) * self.scale, Color(lia.color.theme.text.r, lia.color.theme.text.g, lia.color.theme.text.b, math_floor(180 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP) end
                if i <= 9 then draw.SimpleText(tostring(i), 'Fated.14', nx, ny, Color(currentTheme.accent.r, currentTheme.accent.g, currentTheme.accent.b, math_floor(200 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            end
        end
    else
        lia.rndx.Circle(cx, cy, outerD):Color(Color(lia.color.theme.background.r, lia.color.theme.background.g, lia.color.theme.background.b, math_floor(240 * alpha))):Draw()
        lia.rndx.Circle(cx, cy, innerD):Color(Color(lia.color.theme.background.r, lia.color.theme.background.g, lia.color.theme.background.b, math_floor(255 * alpha))):Draw()
    end

    if self.selectedOption then
        local opt = self.selectedOption
        if opt.icon and opt.icon ~= false and opt.icon ~= nil then
            local isz = ScreenScale(48) * self.scale
            local mat = Material(opt.icon)
            if mat and not mat:IsError() then
                surface.SetDrawColor(255, 255, 255, math_floor(255 * alpha))
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(cx - isz / 2, cy - isz / 2 - ScreenScaleH(6) * self.scale, isz, isz)
            end

            draw.SimpleText(opt.text or '', self.titleFont, cx + isz * 0.6, cy - ScreenScaleH(6) * self.scale, Color(currentTheme.text.r, currentTheme.text.g, currentTheme.text.b, math_floor(255 * alpha)), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            if opt.desc then draw.SimpleText(opt.desc, self.descFont, cx + isz * 0.6, cy + ScreenScaleH(18) * self.scale, Color(lia.color.theme.text.r, lia.color.theme.text.g, lia.color.theme.text.b, math_floor(180 * alpha)), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
        else
            draw.SimpleText(opt.text or '', self.titleFont, cx, cy - ScreenScaleH(6) * self.scale, Color(lia.color.theme.text.r, lia.color.theme.text.g, lia.color.theme.text.b, math_floor(255 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if opt.desc then draw.SimpleText(opt.desc, self.descFont, cx, cy + ScreenScaleH(18) * self.scale, Color(lia.color.theme.text.r, lia.color.theme.text.g, lia.color.theme.text.b, math_floor(180 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        end
    else
        draw.SimpleText(self.centerText or self.rootMenu.title, self.titleFont, cx, cy - ScreenScaleH(8) * self.scale, Color(lia.color.theme.text.r, lia.color.theme.text.g, lia.color.theme.text.b, math_floor(255 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(self.centerDesc or self.rootMenu.desc, self.descFont, cx, cy + ScreenScaleH(18) * self.scale, Color(lia.color.theme.text.r, lia.color.theme.text.g, lia.color.theme.text.b, math_floor(160 * alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:AddButton(text, callback, icon, desc)
    local option = {
        text = text,
        callback = callback,
        icon = icon,
        desc = desc
    }

    table.insert(self.options, option)
    return option
end

vgui.Register("liaRadialPanel", PANEL, "liaBasePanel")
