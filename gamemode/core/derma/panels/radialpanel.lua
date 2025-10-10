local PANEL = {}
local math_rad = math.rad
local math_cos = math.cos
local math_sin = math.sin
local math_atan2 = math.atan2
local math_sqrt = math.sqrt
local math_min = math.min
function PANEL:Init(options)
    options = options or {}
    self.options = {}
    self.menuStack = {}
    self.currentMenu = nil
    local baseRadius = options.radius or 280
    local baseInnerRadius = options.inner_radius or 96
    local minWidth = 1366
    local minHeight = 768
    local scale = 1
    if ScrW() > minWidth and ScrH() > minHeight then scale = math_min(math_min(ScrW() / 1920, ScrH() / 1080), 1.5) end
    local paddingScale = 1
    if ScrW() <= 1280 then paddingScale = 1.3 end
    self.radius = baseRadius * (ScrW() / 1920) * scale
    self.innerRadius = baseInnerRadius * (ScrW() / 1920) * scale
    self.paddingScale = paddingScale
    self.selectedOption = nil
    self.hoverOption = nil
    self.hoverAnim = 0
    self.centerText = L("menu")
    self.centerDesc = L("selectOption")
    self.font = "LiliaFont.20"
    self.descFont = "LiliaFont.16"
    self.titleFont = "LiliaFont.28"
    self.blurStart = SysTime()
    self.fadeInTime = 0.2
    self.currentAlpha = 0
    self.scaleAnim = 0
    self.scale = scale
    self.disable_background = options.disable_background or false
    self.hover_sound = options.hover_sound or "ratio_button.wav"
    self.scale_animation = options.scale_animation ~= false
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetDrawOnTop(true)
    self:SetMouseInputEnabled(true)
    self._mouseWasDown = false
    self.Think = function()
        if self.currentAlpha < 255 then
            self.currentAlpha = math.Clamp(255 * ((SysTime() - self.blurStart) / self.fadeInTime), 0, 255)
            if self.scale_animation then
                self.scaleAnim = math.Clamp((SysTime() - self.blurStart) / self.fadeInTime, 0, 1)
                self.scaleAnim = 0.8 + (self.scaleAnim * 0.2)
            else
                self.scaleAnim = 1
            end
        end

        local mouseDown = input.IsMouseDown(MOUSE_LEFT)
        if mouseDown and not self._mouseWasDown then
            local mouseX, mouseY = self:CursorPos()
            local centerX, centerY = ScrW() / 2, ScrH() / 2
            local dist = math_sqrt((mouseX - centerX) ^ 2 + (mouseY - centerY) ^ 2)
            if dist > self.innerRadius and dist < self.radius then
                local angle = math_atan2(mouseY - centerY, mouseX - centerX)
                if angle < 0 then angle = angle + math_rad(360) end
                local optionCount = #self:GetCurrentOptions()
                if optionCount > 0 then
                    local sectorSize = math_rad(360) / optionCount
                    local selectedIndex = math.floor(angle / sectorSize) + 1
                    if selectedIndex <= optionCount then
                        self:SelectOption(selectedIndex)
                        surface.PlaySound("button_click.wav")
                    end
                end
            elseif dist <= self.innerRadius then
                if #self.menuStack > 0 then
                    self:GoBack()
                    surface.PlaySound("button_click.wav")
                else
                    self:Remove()
                end
            elseif dist >= self.radius then
                self:Remove()
            end
        end

        local mouseX, mouseY = self:CursorPos()
        local centerX, centerY = ScrW() / 2, ScrH() / 2
        local dist = math_sqrt((mouseX - centerX) ^ 2 + (mouseY - centerY) ^ 2)
        local hovered = nil
        if dist > self.innerRadius and dist < self.radius then
            local angle = math_atan2(mouseY - centerY, mouseX - centerX)
            if angle < 0 then angle = angle + math_rad(360) end
            local optionCount = #self:GetCurrentOptions()
            if optionCount > 0 then
                local sectorSize = math_rad(360) / optionCount
                hovered = math.floor(angle / sectorSize) + 1
                if hovered > optionCount then hovered = nil end
            end
        end

        if self.hoverOption ~= hovered and hovered and self.hover_sound then surface.PlaySound(self.hover_sound) end
        self.hoverOption = hovered
        self.hoverAnim = math.Clamp(self.hoverAnim + (self.hoverOption and 4 or -8) * FrameTime(), 0, 1)
        self._mouseWasDown = mouseDown
    end
end

function PANEL:OnMousePressed()
    local mouseX, mouseY = self:CursorPos()
    local centerX, centerY = ScrW() / 2, ScrH() / 2
    local dist = math_sqrt((mouseX - centerX) ^ 2 + (mouseY - centerY) ^ 2)
    if dist <= self.radius then return self:MouseCapture(true) end
    self:Remove()
    return true
end

function PANEL:OnMouseReleased()
    self:MouseCapture(false)
end

function PANEL:Paint(w, h)
    local centerX, centerY = ScrW() / 2, ScrH() / 2
    local alpha = self.currentAlpha / 255
    if not self.disable_background then
        local bgCol = Color(0, 0, 0, 100 * alpha)
        lia.derma.rect(0, 0, w, h):Color(bgCol):Shape(lia.derma.SHAPE_RECT):Draw()
    end

    local outerSize = self.radius * 2 + 20 * (ScrW() / 1920) * self.scale
    local currentRadius = self.radius * self.scaleAnim
    local currentInnerRadius = self.innerRadius * self.scaleAnim
    BShadows.BeginShadow()
    lia.derma.circle(centerX, centerY, outerSize * self.scaleAnim):Color(ColorAlpha(lia.color.theme.background, 220 * alpha)):Draw()
    BShadows.EndShadow(1, 2, 2, 255 * alpha, 0, 0)
    BShadows.BeginShadow()
    lia.derma.circle(centerX, centerY, currentRadius * 2):Color(ColorAlpha(lia.color.theme.background, 240 * alpha)):Draw()
    BShadows.EndShadow(1, 2, 2, 255 * alpha, 0, 0)
    BShadows.BeginShadow()
    lia.derma.circle(centerX, centerY, currentInnerRadius * 2):Color(ColorAlpha(lia.color.theme.background_panelpopup, self.currentAlpha)):Draw()
    BShadows.EndShadow(1, 1, 1, (lia.color.getCurrentTheme() == 'light' and 150 or 200) * alpha, 0, 0)
    local textColor = lia.color.getCurrentTheme() == 'light' and Color(30, 30, 30) or Color(255, 255, 255)
    draw.SimpleText(self.centerText, self.titleFont, centerX, centerY - 13 * (ScrH() / 1080) * self.scale, ColorAlpha(textColor, self.currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.centerDesc, self.descFont, centerX, centerY + 13 * (ScrH() / 1080) * self.scale, ColorAlpha(textColor, 180 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local optionCount = #self:GetCurrentOptions()
    if optionCount > 0 then
        local sectorSize = math_rad(360) / optionCount
        for i, option in ipairs(self:GetCurrentOptions()) do
            local startAngle = (i - 1) * sectorSize
            local midAngle = startAngle + sectorSize / 2
            local isHovered = self.hoverOption == i
            local textX = centerX + (currentInnerRadius + (currentRadius - currentInnerRadius) / 2) * math_cos(midAngle)
            local textY = centerY + (currentInnerRadius + (currentRadius - currentInnerRadius) / 2) * math_sin(midAngle)
            local baseColor = lia.color.getCurrentTheme() == 'light' and Color(30, 30, 30) or Color(255, 255, 255)
            local optionTextColor = ColorAlpha(baseColor, (isHovered and 255 or 200) * alpha)
            if option.icon and option.icon ~= false and option.icon ~= nil then
                local iconMat = Material(option.icon)
                local iconSize = 32 * (ScrW() / 1920) * self.scale * self.scaleAnim
                local iconColor = ColorAlpha(color_white, self.currentAlpha)
                lia.derma.drawMaterial(0, textX - iconSize / 2, textY - iconSize - 8 * (ScrH() / 1080) * self.scale * self.paddingScale, iconSize, iconSize, iconColor, iconMat)
                draw.SimpleText(option.text, self.font, textX, textY + 4 * (ScrH() / 1080) * self.scale * self.paddingScale, optionTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                if option.desc and isHovered then draw.SimpleText(option.desc, self.descFont, textX, textY + 20 * (ScrH() / 1080) * self.scale * self.paddingScale, ColorAlpha(baseColor, 180 * self.hoverAnim * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            else
                draw.SimpleText(option.text, self.font, textX, textY - 8 * (ScrH() / 1080) * self.scale * self.paddingScale, optionTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                if option.desc and isHovered then draw.SimpleText(option.desc, self.descFont, textX, textY + 8 * (ScrH() / 1080) * self.scale * self.paddingScale, ColorAlpha(baseColor, 180 * self.hoverAnim * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
            end
        end
    end

    if optionCount > 0 then
        local lineHighlightColor = ColorAlpha(lia.color.theme.theme, (lia.color.getCurrentTheme() == 'light' and 100 or 60) * alpha)
        self:DrawCircleOutline(centerX, centerY, currentRadius, lineHighlightColor, 1)
        self:DrawCircleOutline(centerX, centerY, currentInnerRadius, lineHighlightColor, 1)
    end
end

function PANEL:DrawCircleOutline(cx, cy, radius, color)
    local segments = 64
    local points = {}
    for i = 0, segments do
        local angle = math_rad((i / segments) * 360)
        table.insert(points, {
            x = cx + radius * math_cos(angle),
            y = cy + radius * math_sin(angle)
        })
    end

    surface.SetDrawColor(color)
    for i = 1, #points - 1 do
        surface.DrawLine(points[i].x, points[i].y, points[i + 1].x, points[i + 1].y)
    end

    surface.DrawLine(points[#points].x, points[#points].y, points[1].x, points[1].y)
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

function PANEL:SelectOption(index)
    local options = self:GetCurrentOptions()
    if options[index] then
        local option = options[index]
        if option.submenu then
            table.insert(self.menuStack, self.currentMenu)
            self.currentMenu = option.submenu
            self:UpdateCenterText()
        elseif option.func then
            option.func()
            self:Remove()
        end
    end
end

function PANEL:SetCenterText(title, desc)
    self.centerText = title or L("menu")
    self.centerDesc = desc or L("selectOption")
end

function PANEL:IsMouseOver()
    local mouseX, mouseY = self:CursorPos()
    local centerX, centerY = ScrW() / 2, ScrH() / 2
    return math_sqrt((mouseX - centerX) ^ 2 + (mouseY - centerY) ^ 2) <= self.radius
end

function PANEL:OnCursorMoved()
    if not self:IsMouseOver() then self.hoverOption = nil end
end

function PANEL:OnRemove()
    if lia.derma.menu_radial == self then lia.derma.menu_radial = nil end
end

vgui.Register("liaRadialPanel", PANEL, "DPanel")
function lia.derma.radial_menu(options)
    if IsValid(lia.derma.menu_radial) then lia.derma.menu_radial:Remove() end
    local m = vgui.Create("liaRadialPanel")
    m:Init(options)
    lia.derma.menu_radial = m
    return m
end

function PANEL:GetCurrentOptions()
    if self.currentMenu then return self.currentMenu.options or {} end
    return self.options
end

function PANEL:GoBack()
    if #self.menuStack > 0 then
        self.currentMenu = table.remove(self.menuStack)
        self:UpdateCenterText()
    end
end

function PANEL:UpdateCenterText()
    if self.currentMenu then
        self.centerText = self.currentMenu.title or L("menu")
        self.centerDesc = self.currentMenu.desc or L("selectOption")
    else
        self.centerText = L("menu")
        self.centerDesc = L("selectOption")
    end
end

function PANEL:CreateSubMenu(title, desc)
    local submenu = {
        title = title,
        desc = desc,
        options = {}
    }

    function submenu:AddOption(text, func, icon, optionDesc)
        table.insert(self.options, {
            text = text,
            func = func,
            icon = icon,
            desc = optionDesc
        })
        return #self.options
    end
    return submenu
end

function PANEL:AddSubMenuOption(text, submenu, icon, desc)
    return self:AddOption(text, nil, icon, desc, submenu)
end
