local PANEL = {}
local math_rad = math.rad
local math_cos = math.cos
local math_sin = math.sin
local math_atan2 = math.atan2
local math_sqrt = math.sqrt
local math_min = math.min
local math_max = math.max
local math_floor = math.floor
local math_ceil = math.ceil
local function FitText(text, font, maxWidth)
    text = tostring(text or "")
    surface.SetFont(font)
    if surface.GetTextSize(text) <= maxWidth then return text end
    local suffix = "..."
    if surface.GetTextSize(suffix) > maxWidth then return "" end
    local characterCount = utf8 and utf8.len(text) or #text
    local getOffset = utf8 and utf8.offset
    if not characterCount then
        characterCount = #text
        getOffset = nil
    end

    local low, high = 0, characterCount
    while low < high do
        local middle = math_floor((low + high + 1) / 2)
        local endPosition = getOffset and getOffset(text, middle + 1) or middle + 1
        local candidate = string.sub(text, 1, (endPosition or #text + 1) - 1)
        if surface.GetTextSize(candidate .. suffix) <= maxWidth then
            low = middle
        else
            high = middle - 1
        end
    end

    local endPosition = getOffset and getOffset(text, low + 1) or low + 1
    return string.sub(text, 1, (endPosition or #text + 1) - 1) .. suffix
end

function PANEL:Init(options)
    options = options or {}
    self.options = {}
    self.menuStack = {}
    self.pageStack = {}
    self.currentMenu = nil
    self.currentPage = 1
    self.maxOptionsPerPage = math_max(1, math_floor(options.max_options_per_page or 8))
    self.pageCache = nil
    local baseRadius = options.radius or 280
    local baseInnerRadius = options.inner_radius or 96
    local scale = 1
    if ScrW() > 1366 and ScrH() > 768 then scale = math_min(math_min(ScrW() / 1920, ScrH() / 1080), 1.5) end
    self.radius = baseRadius * (ScrW() / 1920) * scale
    self.innerRadius = baseInnerRadius * (ScrW() / 1920) * scale
    self.paddingScale = ScrW() <= 1280 and 1.3 or 1
    self.selectedOption = nil
    self.hoverOption = nil
    self.hoverAnim = 0
    self.hoverLevels = {}
    self.centerText = "Menu"
    self.centerDesc = "Select Option"
    self.rootCenterText = self.centerText
    self.rootCenterDesc = self.centerDesc
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
    self._mouseWasDown = false
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetDrawOnTop(true)
    self:SetMouseInputEnabled(true)
end

function PANEL:Think()
    if self.currentAlpha < 255 then
        self.currentAlpha = math.Clamp(255 * ((SysTime() - self.blurStart) / self.fadeInTime), 0, 255)
        if self.scale_animation then
            self.scaleAnim = 0.8 + math.Clamp((SysTime() - self.blurStart) / self.fadeInTime, 0, 1) * 0.2
        else
            self.scaleAnim = 1
        end
    end

    local mouseDown = input.IsMouseDown(MOUSE_LEFT)
    local mouseX, mouseY = self:CursorPos()
    local centerX, centerY = ScrW() / 2, ScrH() / 2
    local dist = math_sqrt((mouseX - centerX) ^ 2 + (mouseY - centerY) ^ 2)
    if mouseDown and not self._mouseWasDown then
        if dist > self.innerRadius and dist < self.radius then
            local angle = math_atan2(mouseY - centerY, mouseX - centerX)
            if angle < 0 then angle = angle + math_rad(360) end
            local optionCount = #self:GetCurrentOptions()
            if optionCount > 0 then
                local index = math_floor(angle / (math_rad(360) / optionCount)) + 1
                if index <= optionCount then
                    self:SelectOption(index)
                    lia.webcontent.playButtonSound()
                end
            end
        elseif dist <= self.innerRadius then
            if #self.menuStack > 0 then
                self:GoBack()
            else
                self:Remove()
            end

            lia.webcontent.playButtonSound()
        else
            self:Remove()
        end
    end

    local hovered = nil
    if dist > self.innerRadius and dist < self.radius then
        local angle = math_atan2(mouseY - centerY, mouseX - centerX)
        if angle < 0 then angle = angle + math_rad(360) end
        local optionCount = #self:GetCurrentOptions()
        if optionCount > 0 then
            hovered = math_floor(angle / (math_rad(360) / optionCount)) + 1
            if hovered > optionCount then hovered = nil end
        end
    end

    if self.hoverOption ~= hovered and hovered and self.hover_sound then surface.PlaySound(self.hover_sound) end
    self.hoverOption = hovered
    self.hoverAnim = math.Clamp(self.hoverAnim + (hovered and 4 or -8) * FrameTime(), 0, 1)
    local optionCount = #self:GetCurrentOptions()
    for i = 1, optionCount do
        local target = hovered == i and 1 or 0
        self.hoverLevels[i] = math.Approach(self.hoverLevels[i] or 0, target, FrameTime() * (target == 1 and 9 or 12))
    end

    for i = optionCount + 1, #self.hoverLevels do
        self.hoverLevels[i] = nil
    end

    self._mouseWasDown = mouseDown
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

function PANEL:OnMouseWheeled(delta)
    if self:ChangePage(delta > 0 and -1 or 1) then
        lia.webcontent.playButtonSound()
        return true
    end
end

function PANEL:DrawFittedText(text, font, x, y, maxWidth, textColor)
    draw.SimpleText(FitText(text, font, maxWidth), font, x, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:DrawSectorOverlay(cx, cy, innerRadius, outerRadius, startAngle, endAngle, overlayColor)
    local segments = math_max(1, math_ceil((endAngle - startAngle) / math_rad(5)))
    local step = (endAngle - startAngle) / segments
    draw.NoTexture()
    surface.SetDrawColor(overlayColor)
    for i = 0, segments - 1 do
        local firstAngle = startAngle + i * step
        local secondAngle = firstAngle + step
        local firstCos, firstSin = math_cos(firstAngle), math_sin(firstAngle)
        local secondCos, secondSin = math_cos(secondAngle), math_sin(secondAngle)
        surface.DrawPoly({
            {
                x = cx + outerRadius * firstCos,
                y = cy + outerRadius * firstSin
            },
            {
                x = cx + outerRadius * secondCos,
                y = cy + outerRadius * secondSin
            },
            {
                x = cx + innerRadius * secondCos,
                y = cy + innerRadius * secondSin
            },
            {
                x = cx + innerRadius * firstCos,
                y = cy + innerRadius * firstSin
            }
        })
    end
end

function PANEL:Paint(w, h)
    local centerX, centerY = ScrW() / 2, ScrH() / 2
    local alpha = self.currentAlpha / 255
    if not self.disable_background then lia.derma.rect(0, 0, w, h):Color(Color(0, 0, 0, 100 * alpha)):Shape(lia.derma.SHAPE_RECT):Draw() end
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
    BShadows.EndShadow(1, 1, 1, (lia.color.getCurrentTheme() == "light" and 150 or 200) * alpha, 0, 0)
    local isLight = lia.color.getCurrentTheme() == "light"
    local textColor = isLight and Color(30, 30, 30) or color_white
    local textScale = (ScrH() / 1080) * self.scale
    draw.SimpleText(self.centerText, self.titleFont, centerX, centerY - 13 * textScale, ColorAlpha(textColor, self.currentAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.centerDesc, self.descFont, centerX, centerY + 13 * textScale, ColorAlpha(textColor, 180 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local options = self:GetCurrentOptions()
    local optionCount = #options
    if optionCount == 0 then return end
    local sectorSize = math_rad(360) / optionCount
    local labelRadius = currentInnerRadius + (currentRadius - currentInnerRadius) * 0.58
    local maxLabelWidth = optionCount == 1 and math_max(80, (currentRadius - currentInnerRadius) * 1.6) or math_max(40, 2 * labelRadius * math_sin(sectorSize / 2) * 0.86)
    local dividerColor = ColorAlpha(lia.color.theme.theme, (isLight and 125 or 90) * alpha)
    for i = 1, optionCount do
        local hoverLevel = self.hoverLevels[i] or 0
        if hoverLevel > 0 then
            local startAngle = (i - 1) * sectorSize
            local endAngle = startAngle + sectorSize
            self:DrawSectorOverlay(centerX, centerY, currentInnerRadius, currentRadius, startAngle, endAngle, ColorAlpha(lia.color.theme.theme, (isLight and 48 or 78) * hoverLevel * alpha))
        end
    end

    for i, option in ipairs(options) do
        local startAngle = (i - 1) * sectorSize
        local midAngle = startAngle + sectorSize / 2
        local textX = centerX + labelRadius * math_cos(midAngle)
        local textY = centerY + labelRadius * math_sin(midAngle)
        local isHovered = self.hoverOption == i
        local hasDescription = isHovered and option.desc and option.desc ~= ""
        local hasIcon = option.icon and option.icon ~= false
        local font = self.font
        surface.SetFont(font)
        if surface.GetTextSize(tostring(option.text or "")) > maxLabelWidth then font = self.descFont end
        if hasIcon then
            if not option._iconMaterial or option._iconPath ~= option.icon then
                option._iconMaterial = Material(option.icon)
                option._iconPath = option.icon
            end

            local iconSize = 32 * (ScrW() / 1920) * self.scale * self.scaleAnim
            lia.derma.drawMaterial(0, textX - iconSize / 2, textY - iconSize - 7 * textScale * self.paddingScale, iconSize, iconSize, ColorAlpha(color_white, self.currentAlpha), option._iconMaterial)
        end

        local titleY = textY + (hasIcon and 8 or hasDescription and -9 or 0) * textScale * self.paddingScale
        self:DrawFittedText(option.text, font, textX, titleY, maxLabelWidth, ColorAlpha(textColor, (isHovered and 255 or 225) * alpha))
        if hasDescription then
            local descY = textY + (hasIcon and 25 or 11) * textScale * self.paddingScale
            self:DrawFittedText(option.desc, self.descFont, textX, descY, maxLabelWidth, ColorAlpha(textColor, 190 * self.hoverAnim * alpha))
        end

        local innerX = centerX + currentInnerRadius * math_cos(startAngle)
        local innerY = centerY + currentInnerRadius * math_sin(startAngle)
        local outerX = centerX + currentRadius * math_cos(startAngle)
        local outerY = centerY + currentRadius * math_sin(startAngle)
        surface.SetDrawColor(dividerColor)
        surface.DrawLine(innerX, innerY, outerX, outerY)
    end

    for i = 1, optionCount do
        local hoverLevel = self.hoverLevels[i] or 0
        if hoverLevel > 0 then
            local startAngle = (i - 1) * sectorSize
            local endAngle = startAngle + sectorSize
            local edgeColor = ColorAlpha(lia.color.theme.theme, 190 * hoverLevel * alpha)
            surface.SetDrawColor(edgeColor)
            surface.DrawLine(centerX + currentInnerRadius * math_cos(startAngle), centerY + currentInnerRadius * math_sin(startAngle), centerX + currentRadius * math_cos(startAngle), centerY + currentRadius * math_sin(startAngle))
            surface.DrawLine(centerX + currentInnerRadius * math_cos(endAngle), centerY + currentInnerRadius * math_sin(endAngle), centerX + currentRadius * math_cos(endAngle), centerY + currentRadius * math_sin(endAngle))
        end
    end

    local outlineColor = ColorAlpha(lia.color.theme.theme, (isLight and 100 or 60) * alpha)
    self:DrawCircleOutline(centerX, centerY, currentRadius, outlineColor)
    self:DrawCircleOutline(centerX, centerY, currentInnerRadius, outlineColor)
    local pageCount = self:GetPageCount()
    if pageCount > 1 then
        draw.SimpleText(string.format("Page %d / %d  |  Scroll to navigate", self.currentPage, pageCount), self.descFont, centerX, centerY + currentRadius + 24 * textScale, ColorAlpha(textColor, 190 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:DrawCircleOutline(cx, cy, radius, outlineColor)
    local segments = 64
    local previousX = cx + radius
    local previousY = cy
    surface.SetDrawColor(outlineColor)
    for i = 1, segments do
        local angle = math_rad((i / segments) * 360)
        local x = cx + radius * math_cos(angle)
        local y = cy + radius * math_sin(angle)
        surface.DrawLine(previousX, previousY, x, y)
        previousX, previousY = x, y
    end
end

function PANEL:AddOption(text, func, icon, desc, submenu)
    self.options[#self.options + 1] = {
        text = text,
        func = func,
        icon = icon,
        desc = desc,
        submenu = submenu
    }
    self.pageCache = nil
    return #self.options
end

function PANEL:SelectOption(index)
    local option = self:GetCurrentOptions()[index]
    if not option then return end
    if option.pageDelta then
        self:ChangePage(option.pageDelta)
    elseif option.submenu then
        self.menuStack[#self.menuStack + 1] = self.currentMenu or false
        self.pageStack[#self.pageStack + 1] = self.currentPage
        self.currentMenu = option.submenu
        self.currentPage = 1
        self.pageCache = nil
        self.hoverOption = nil
        self.hoverLevels = {}
        self:UpdateCenterText()
    elseif option.func then
        option.func()
        self:Remove()
    end
end

function PANEL:SetCenterText(title, desc)
    self.centerText = title or "Menu"
    self.centerDesc = desc or "Select Option"
    self.rootCenterText = self.centerText
    self.rootCenterDesc = self.centerDesc
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

function PANEL:GetPageCount()
    local options = self.currentMenu and self.currentMenu.options or self.options
    return math_max(1, math_ceil(#options / self.maxOptionsPerPage))
end

function PANEL:GetCurrentOptions()
    local options = self.currentMenu and self.currentMenu.options or self.options
    local count = #options
    local pageCount = self:GetPageCount()
    self.currentPage = math.Clamp(self.currentPage, 1, pageCount)
    if pageCount == 1 then return options end
    local cached = self.pageCache
    if cached and cached.source == options and cached.count == count and cached.page == self.currentPage then return cached.options end
    local pageSize = math_ceil(count / pageCount)
    local visible = {}
    if self.currentPage > 1 then
        visible[#visible + 1] = {
            text = "Previous",
            desc = string.format("Page %d of %d", self.currentPage - 1, pageCount),
            pageDelta = -1
        }
    end

    for index = (self.currentPage - 1) * pageSize + 1, math_min(self.currentPage * pageSize, count) do
        visible[#visible + 1] = options[index]
    end

    if self.currentPage < pageCount then
        visible[#visible + 1] = {
            text = "Next",
            desc = string.format("Page %d of %d", self.currentPage + 1, pageCount),
            pageDelta = 1
        }
    end

    self.pageCache = {
        source = options,
        count = count,
        page = self.currentPage,
        options = visible
    }
    return visible
end

function PANEL:ChangePage(delta)
    local nextPage = math.Clamp(self.currentPage + delta, 1, self:GetPageCount())
    if nextPage == self.currentPage then return false end
    self.currentPage = nextPage
    self.pageCache = nil
    self.hoverOption = nil
    self.hoverAnim = 0
    self.hoverLevels = {}
    return true
end

function PANEL:GoBack()
    if #self.menuStack == 0 then return end
    local previousMenu = table.remove(self.menuStack)
    self.currentMenu = previousMenu or nil
    self.currentPage = table.remove(self.pageStack) or 1
    self.pageCache = nil
    self.hoverOption = nil
    self.hoverAnim = 0
    self.hoverLevels = {}
    self:UpdateCenterText()
end

function PANEL:UpdateCenterText()
    if self.currentMenu then
        self.centerText = "Back"
        self.centerDesc = "Previous Menu"
    else
        self.centerText = self.rootCenterText or "Menu"
        self.centerDesc = self.rootCenterDesc or "Select Option"
    end
end

function PANEL:CreateSubMenu(title, desc)
    local submenu = {
        title = title,
        desc = desc,
        options = {}
    }

    function submenu:AddOption(text, func, icon, optionDesc)
        self.options[#self.options + 1] = {
            text = text,
            func = func,
            icon = icon,
            desc = optionDesc
        }
        return #self.options
    end
    return submenu
end

function PANEL:AddSubMenuOption(text, submenu, icon, desc)
    return self:AddOption(text, nil, icon, desc, submenu)
end

vgui.Register("liaRadialPanel", PANEL, "DPanel")