local animDuration = 0.3
local GRADIENT_MAT = Material("vgui/gradient-d")
local DEFAULT_BUTTON_SHADOW = Color(18, 32, 32, 35)
local PANEL = {}
function PANEL:Init()
    self._activeShadowTimer = 0
    self._activeShadowMinTime = 0.03
    self._activeShadowLerp = 0
    self.hover_status = 0
    self.bool_hover = true
    self.font = "LiliaFont.18"
    self.radius = 16
    self.icon = ""
    self.icon_size = 16
    self.text = L("button")
    self.col = (lia.color.theme and lia.color.theme.panel and lia.color.theme.panel[1]) or Color(34, 62, 62)
    self.col_hov = (lia.color.theme and lia.color.theme.button_hovered) or Color(70, 140, 140)
    self.bool_gradient = true
    self.click_alpha = 0
    self.click_x = 0
    self.click_y = 0
    self.ripple_speed = 4
    self.enable_ripple = false
    self.ripple_color = Color(255, 255, 255, 30)
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
    -- Set the base color
    self:SetColor(baseColor)
    -- If hover color is provided, use it; otherwise auto-generate a lighter version
    if hoverColor then
        self:SetColorHover(hoverColor)
    else
        -- Auto-generate hover color by brightening the base color
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

local math_clamp = math.Clamp
function PANEL:Paint(w, h)
    if self:IsHovered() then
        self.hover_status = math_clamp(self.hover_status + 4 * FrameTime(), 0, 1)
    else
        self.hover_status = math_clamp(self.hover_status - 8 * FrameTime(), 0, 1)
    end

    local isActive = (self:IsDown() or self.Depressed) and self.hover_status > 0.8
    if isActive then self._activeShadowTimer = SysTime() + self._activeShadowMinTime end
    local showActiveShadow = isActive or (self._activeShadowTimer > SysTime())
    local activeTarget = showActiveShadow and 10 or 0
    local activeSpeed = (activeTarget > 0) and 7 or 3
    self._activeShadowLerp = Lerp(FrameTime() * activeSpeed, self._activeShadowLerp, activeTarget)
    if self._activeShadowLerp > 0 then
        local col = Color(self.col_hov.r, self.col_hov.g, self.col_hov.b, math.Clamp(self.col_hov.a * 1.5, 0, 255))
        draw.RoundedBox(self.radius, 0, 0, w, h, col)
    end

    draw.RoundedBox(self.radius, 0, 0, w, h, self.col)
    if self.bool_gradient then
        local shadowCol = (lia.color.theme and lia.color.theme.button_shadow) or DEFAULT_BUTTON_SHADOW
        surface.SetDrawColor(shadowCol)
        surface.SetMaterial(GRADIENT_MAT)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    if self.bool_hover and self.hover_status > 0 then
        local hoverCol = Color(self.col_hov.r, self.col_hov.g, self.col_hov.b, self.hover_status * 255)
        draw.RoundedBox(self.radius, 0, 0, w, h, hoverCol)
    end

    if self.click_alpha > 0 then
        self.click_alpha = math_clamp(self.click_alpha - FrameTime() * self.ripple_speed, 0, 1)
        local ripple_size = (1 - self.click_alpha) * math.max(w, h) * 2
        local ripple_color = Color(self.ripple_color.r, self.ripple_color.g, self.ripple_color.b, self.ripple_color.a * self.click_alpha)
        draw.RoundedBox(ripple_size * 0.5, self.click_x - ripple_size * 0.5, self.click_y - ripple_size * 0.5, ripple_size, ripple_size, ripple_color)
    end

    local iconSize = self.icon_size or 16
    if self.text ~= "" then
        draw.SimpleText(self.text, self.font, w * 0.5 + (self.icon and self.icon ~= "" and iconSize * 0.5 + 2 or 0), h * 0.5, (lia.color.theme and lia.color.theme.text) or Color(210, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
local function PaintButton(self, w, h)
    local colorTable = lia.config.get("Color")
    local r = (colorTable and colorTable.r) or 255
    local g = (colorTable and colorTable.g) or 255
    local b = (colorTable and colorTable.b) or 255
    local cornerRadius = 8
    if self.Base then
        draw.RoundedBox(cornerRadius, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.RoundedBox(cornerRadius, 0, 0, w, h, Color(0, 0, 0, 100))
    end

    draw.SimpleText(self:GetText(), self:GetFont(), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if self:IsHovered() or self:IsSelected() then
        self.startTime = self.startTime or CurTime()
        local elapsed = CurTime() - self.startTime
        local anim = math.min(w, elapsed / animDuration * w) / 2
        draw.RoundedBox(cornerRadius, 0, 0, w, h, Color(0, 0, 0, 30))
        draw.RoundedBox(cornerRadius, 0, 0, w, h, Color(r, g, b, 40))
        if anim > 0 then
            local lineWidth = math.min(w - cornerRadius * 2, anim * 2)
            local lineX = (w - lineWidth) / 2
            draw.RoundedBox(1, lineX, h - 3, lineWidth, 2, Color(r, g, b))
        end
    else
        self.startTime = nil
    end
    return true
end

local function RegisterButton(name, defaultFont, useBase)
    local BUTTON_PANEL = {}
    BUTTON_PANEL.DefaultFont = defaultFont or "LiliaFont.17"
    BUTTON_PANEL.Base = useBase
    function BUTTON_PANEL:Init()
        self:SetFont(self.DefaultFont)
        self.Selected = false
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

    function BUTTON_PANEL:Paint(w, h)
        return PaintButton(self, w, h)
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
