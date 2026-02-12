local PANEL = {}
function PANEL:Init()
    self.hover_status = 0
    self.bool_hover = true
    self.font = "LiliaFont.18"
    self.radius = 12
    self.icon = ""
    self.icon_size = 16
    self.text = L("button")
    self.col = Color(25, 28, 35, 250)
    self.col_hov = (lia.color.theme and lia.color.theme.button_hovered) or Color(70, 140, 140)
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
    self.col = col or (lia.color.theme and lia.color.theme.panel and lia.color.theme.panel[1]) or Color(34, 62, 62)
end

function PANEL:SetColorHover(col)
    self.col_hov = col or (lia.color.theme and lia.color.theme.button_hovered) or Color(70, 140, 140)
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
    local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
    lia.derma.rect(0, 0, w, h):Rad(self.radius):Color(self.col):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(self.radius):Color(Color(255, 255, 255, 20)):Shape(lia.derma.SHAPE_ROUNDED):Draw()
    if self.bool_hover and (self:IsHovered() or self:IsDown()) then
        local hoverColor = Color(accentColor.r, accentColor.g, accentColor.b, 30)
        lia.derma.rect(0, 0, w, h):Rad(self.radius):Color(hoverColor):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, h):Rad(self.radius):Color(Color(255, 255, 255, 40)):Shape(lia.derma.SHAPE_ROUNDED):Draw()
    end

    local iconSize = self.icon_size or 16
    if self.text ~= "" then
        draw.SimpleText(self.text, self.font, w * 0.5 + (self.icon and self.icon ~= "" and iconSize * 0.5 + 2 or 0), h * 0.5, self:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if self.icon and self.icon ~= "" then
            surface.SetFont(self.font)
            local posX = (w - surface.GetTextSize(self.text) - iconSize) * 0.5 - 2
            local posY = (h - iconSize) * 0.5
            surface.SetMaterial(self.icon)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRect(posX, posY, iconSize, iconSize)
        end
    elseif self.icon and self.icon ~= "" then
        local posX = (w - iconSize) * 0.5
        local posY = (h - iconSize) * 0.5
        surface.SetMaterial(self.icon)
        surface.SetDrawColor(color_white)
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
    end

    function BUTTON_PANEL:SetFont(font)
        self.ButtonFont = font
        self.BaseClass.SetFont(self, font)
    end

    function BUTTON_PANEL:GetFont()
        return self.ButtonFont
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
        local accentColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
        local bgColor = Color(25, 28, 35, 250)
        lia.derma.rect(0, 0, w, h):Rad(12):Color(Color(0, 0, 0, 180)):Shadow(15, 20):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, h):Rad(12):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
        if self:IsHovered() or self:IsSelected() then
            local hoverColor = Color(accentColor.r, accentColor.g, accentColor.b, 30)
            lia.derma.rect(0, 0, w, h):Rad(12):Color(hoverColor):Shape(lia.derma.SHAPE_IOS):Draw()
        end

        draw.SimpleText(self:GetText(), self:GetFont(), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
