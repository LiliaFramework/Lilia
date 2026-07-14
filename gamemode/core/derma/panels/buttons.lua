local PANEL = {}
local function getButtonColors()
    local theme = lia.color.theme or {}
    local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
    return {
        accent = accent,
        text = theme.text or Color(225, 238, 238),
        muted = Color(191, 207, 207),
        mutedIcon = Color(165, 186, 186)
    }
end

local function getSharedButtonShell()
    return {
        base = Color(8, 18, 24, 228),
        hover = Color(10, 22, 28, 236),
        selected = Color(12, 26, 33, 240)
    }
end

function PANEL:Init()
    self.hover_status = 0
    self.bool_hover = true
    self.font = "LiliaFont.18"
    self.radius = 12
    self.icon = ""
    self.icon_size = 16
    self.text = L("button")
    self.col = Color(13, 30, 35, 225)
    self.col_hov = (lia.color.theme and lia.color.theme.button_hovered) or Color(16, 34, 40, 235)
    self._customColor = false
    self._customHoverColor = false
    self._customTextColor = false
    self._defaultTextColor = (lia.color.theme and lia.color.theme.text) or Color(225, 238, 238)
    self:SetTextColor(self._defaultTextColor)
    self.BaseClass.SetText(self, "")
end

function PANEL:SetHover(is_hover)
    self.bool_hover = is_hover
end

function PANEL:SetFont(font)
    self.font = font
end

function PANEL:SetRadius(rad)
    self.radius = rad
end

function PANEL:SetIcon(icon, icon_size)
    if not icon or icon == "" then
        self.icon = nil
    elseif type(icon) == "IMaterial" then
        self.icon = icon
    else
        local mat = Material(icon)
        if mat and mat:IsValid() then
            self.icon = mat
        else
            self.icon = nil
        end
    end

    self.icon_size = icon_size or 16
end

function PANEL:SetTxt(text)
    self.text = text or ""
end

function PANEL:SetText(text)
    self:SetTxt(text)
    self.BaseClass.SetText(self, "")
end

function PANEL:GetText()
    return self.text
end

function PANEL:SetColor(col)
    self._customColor = col ~= nil
    self.col = col or Color(13, 30, 35, 225)
end

function PANEL:SetColorHover(col)
    self._customHoverColor = col ~= nil
    self.col_hov = col or (lia.color.theme and lia.color.theme.button_hovered) or Color(16, 34, 40, 235)
end

function PANEL:SetTextColor(col)
    self._customTextColor = col ~= nil
    self.BaseClass.SetTextColor(self, col or self._defaultTextColor or Color(225, 238, 238))
end

function PANEL:PaintButton(baseColor, hoverColor)
    if not baseColor then return end
    self:SetColor(baseColor)
    if hoverColor then
        self:SetColorHover(hoverColor)
    else
        local r = math.min(baseColor.r + 30, 255)
        local g = math.min(baseColor.g + 30, 255)
        local b = math.min(baseColor.b + 30, 255)
        local a = baseColor.a or 255
        self:SetColorHover(Color(r, g, b, a))
    end
end

function PANEL:SetGradient(is_grad)
    self.bool_gradient = is_grad
end

function PANEL:SetRipple(enable)
    self.enable_ripple = enable
end

function PANEL:OnMousePressed(mousecode)
    self.BaseClass.OnMousePressed(self, mousecode)
    if self.enable_ripple and mousecode == MOUSE_LEFT then
        self.click_alpha = 1
        self.click_x, self.click_y = self:CursorPos()
    end
end

function PANEL:DoClick()
    lia.websound.playButtonSound()
    self.BaseClass.DoClick(self)
end

function PANEL:Paint(w, h)
    local colors = getButtonColors()
    local hovered = self.bool_hover and self:IsHovered()
    local down = self:IsDown()
    local baseColor = self.col or (lia.color.theme and lia.color.theme.panel and lia.color.theme.panel[1]) or Color(25, 28, 35, 250)
    local hoverColor = self.col_hov or (lia.color.theme and lia.color.theme.button_hovered) or Color(70, 140, 140)
    local background = (hovered or down) and hoverColor or baseColor
    local outlineSource = (hovered or down) and hoverColor or self._customColor and baseColor or colors.accent
    local outline = Color(outlineSource.r, outlineSource.g, outlineSource.b, (hovered or down) and 145 or 68)
    lia.derma.rect(0, 0, w, h):Rad(self.radius):Color(background):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(self.radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
    local iconSize = self.icon_size or 16
    local textColor = (hovered or down) and colors.text or self._customTextColor and self:GetTextColor() or (lia.color.theme and lia.color.theme.text) or self._defaultTextColor or Color(225, 238, 238)
    if self.text ~= "" then
        draw.SimpleText(self.text, self.font, w * 0.5 + (self.icon and self.icon ~= "" and iconSize * 0.5 + 2 or 0), h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if self.icon and self.icon ~= "" then
            surface.SetFont(self.font)
            local posX = (w - surface.GetTextSize(self.text) - iconSize) * 0.5 - 2
            local posY = (h - iconSize) * 0.5
            surface.SetMaterial(self.icon)
            surface.SetDrawColor((hovered or down) and colors.text or colors.mutedIcon)
            surface.DrawTexturedRect(posX, posY, iconSize, iconSize)
        end
    elseif self.icon and self.icon ~= "" then
        local posX = (w - iconSize) * 0.5
        local posY = (h - iconSize) * 0.5
        surface.SetMaterial(self.icon)
        surface.SetDrawColor((hovered or down) and colors.text or colors.mutedIcon)
        surface.DrawTexturedRect(posX, posY, iconSize, iconSize)
    end
end

vgui.Register("liaButton", PANEL, "Button")
local function RegisterButton(name, defaultFont, useBase)
    local BUTTON_PANEL = {}
    BUTTON_PANEL.DefaultFont = defaultFont or "LiliaFont.17"
    BUTTON_PANEL.Base = useBase
    function BUTTON_PANEL:Init()
        self:SetFont(self.DefaultFont)
        self.Selected = false
        self.ShowLine = false
        self._customTextColor = false
        self._defaultTextColor = (lia.color.theme and lia.color.theme.text) or Color(225, 238, 238)
        self:SetTextColor(self._defaultTextColor)
    end

    function BUTTON_PANEL:SetFont(font)
        self.ButtonFont = font
        self.BaseClass.SetFont(self, font)
    end

    function BUTTON_PANEL:GetFont()
        return self.ButtonFont
    end

    function BUTTON_PANEL:SetTextColor(col)
        self._customTextColor = col ~= nil
        DButton.SetTextColor(self, col or self._defaultTextColor or Color(225, 238, 238))
    end

    function BUTTON_PANEL:SetSelected(state)
        self.Selected = state
    end

    function BUTTON_PANEL:IsSelected()
        return self.Selected
    end

    function BUTTON_PANEL:SetShowLine(show)
        self.ShowLine = show
    end

    function BUTTON_PANEL:GetShowLine()
        return self.ShowLine
    end

    function BUTTON_PANEL:Paint(w, h)
        local colors = getButtonColors()
        local shell = getSharedButtonShell()
        local hovered = self:IsHovered()
        local selected = self:IsSelected()
        local accentAlpha = selected and 52 or hovered and 40 or 24
        local shellColor = selected and shell.selected or hovered and shell.hover or shell.base
        local background = Color(shellColor.r, shellColor.g, shellColor.b, shellColor.a)
        local tint = Color(colors.accent.r, colors.accent.g, colors.accent.b, accentAlpha)
        local outlineAlpha = selected and 220 or hovered and 190 or 156
        local outline = Color(colors.accent.r, colors.accent.g, colors.accent.b, outlineAlpha)
        if self.Base == false then background = Color(0, 0, 0, 0) end
        lia.derma.rect(0, 0, w, h):Rad(12):Color(background):Shape(lia.derma.SHAPE_IOS):Draw()
        if self.Base ~= false then
            lia.derma.rect(0, 0, w, h):Rad(12):Color(tint):Shape(lia.derma.SHAPE_IOS):Draw()
        end

        if self.Base ~= false then
            lia.derma.rect(0, 0, w, h):Rad(12):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(2):Draw()
        end

        if selected and self:GetShowLine() then
            surface.SetDrawColor(colors.accent.r, colors.accent.g, colors.accent.b, 240)
            surface.DrawRect(0, 7, 3, h - 14)
        end

        local textColor = hovered and Color(245, 250, 250) or self._customTextColor and self:GetTextColor() or colors.text
        draw.SimpleText(self:GetText(), self:GetFont(), w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return true
    end

    function BUTTON_PANEL:DoClick()
        lia.websound.playButtonSound()
        self.BaseClass.DoClick(self)
    end

    vgui.Register(name, BUTTON_PANEL, "DButton")
end

RegisterButton("liaHugeButton", "LiliaFont.72", true)
RegisterButton("liaBigButton", "LiliaFont.36", true)
RegisterButton("liaMediumButton", "LiliaFont.25", true)
RegisterButton("liaSmallButton", "LiliaFont.17", true)
RegisterButton("liaMiniButton", "LiliaFont.14", true)
RegisterButton("liaNoBGButton", "LiliaFont.36", false)
RegisterButton("liaCustomFontButton", "LiliaFont.17", true)
