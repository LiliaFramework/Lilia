local PANEL = {}
function PANEL:Init()
    self._activeShadowTimer = 0
    self._activeShadowMinTime = 0.03
    self._activeShadowLerp = 0
    self.hover_status = 0
    self.bool_hover = true
    self.font = "Fated.18"
    self.radius = 16
    self.icon = ""
    self.icon_size = 16
    self.text = L("btn_default")
    self.col = lia.color.theme.liaButtonColor
    self.col_hov = lia.color.theme.liaButtonHoveredColor
    self.bool_gradient = true
    self.click_alpha = 0
    self.click_x = 0
    self.click_y = 0
    self.ripple_speed = 4
    self.enable_ripple = false
    self.ripple_color = lia.color.theme.liaButtonRippleColor
    self:SetText('')
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
    self.icon = (type(icon) == "IMaterial") and icon or Material(icon)
    self.icon_size = icon_size
end

function PANEL:SetText(text)
    self.text = text
end

function PANEL:SetColor(col)
    self.col = col or lia.color.theme.liaButtonColor
end

function PANEL:SetColorHover(col)
    self.col_hov = col or lia.color.theme.liaButtonHoveredColor
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

local math_clamp = math.Clamp
local btnFlags = lia.rndx.SHAPE_IOS
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
    local buttonColor = self.col or lia.color.theme.liaButtonColor
    local buttonHoveredColor = self.col_hov or lia.color.theme.liaButtonHoveredColor
    local buttonShadowColor = lia.color.theme.liaButtonShadowColor
    if self._activeShadowLerp > 0 then
        local col = Color(buttonHoveredColor.r, buttonHoveredColor.g, buttonHoveredColor.b, math.Clamp(buttonHoveredColor.a * 1.5, 0, 255))
        lia.rndx.Rect(0, 0, w, h):Rad(self.radius):Color(col):Shape(btnFlags):Shadow(self._activeShadowLerp * 1.5, 24):Draw()
    end

    lia.rndx.Rect(0, 0, w, h):Rad(self.radius):Color(buttonColor):Shape(btnFlags):Draw()
    if self.bool_gradient then lia.util.drawGradient(0, 0, w, h, 1, buttonShadowColor, self.radius, btnFlags) end
    if self.bool_hover then lia.rndx.Rect(0, 0, w, h):Rad(self.radius):Color(Color(buttonHoveredColor.r, buttonHoveredColor.g, buttonHoveredColor.b, self.hover_status * 255)):Shape(btnFlags):Draw() end
    if self.click_alpha > 0 then
        self.click_alpha = math_clamp(self.click_alpha - FrameTime() * self.ripple_speed, 0, 1)
        local ripple_size = (1 - self.click_alpha) * math.max(w, h) * 2
        local ripple_color = Color(self.ripple_color.r, self.ripple_color.g, self.ripple_color.b, (self.ripple_color.a or 255) * self.click_alpha)
        lia.rndx.Rect(self.click_x - ripple_size * 0.5, self.click_y - ripple_size * 0.5, ripple_size, ripple_size):Rad(100):Color(ripple_color):Shape(btnFlags):Draw()
    end

    if self.text ~= '' then
        draw.SimpleText(self.text, self.font, w * 0.5 + ((self.icon ~= '' and self.icon_size * 0.5 + 2) or 0), h * 0.5, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if self.icon ~= '' then
            surface.SetFont(self.font)
            local textW = surface.GetTextSize(self.text)
            local posX = (w - textW - self.icon_size) * 0.5 - 2
            local posY = (h - self.icon_size) * 0.5
            lia.rndx.Rect(posX, posY, self.icon_size, self.icon_size):Material(self.icon):Color(lia.color.theme.liaButtonIconColor):Shape(btnFlags):Draw()
        end
    elseif self.icon ~= '' then
        local posX = (w - self.icon_size) * 0.5
        local posY = (h - self.icon_size) * 0.5
        lia.rndx.Rect(posX, posY, self.icon_size, self.icon_size):Material(self.icon):Color(lia.color.theme.liaButtonIconColor):Shape(btnFlags):Draw()
    end
end

vgui.Register("liaButton", PANEL, "Button")
local animDuration = 0.3
local function ensureThemeColor(colorKey, fallbackColor)
    if lia.color.theme and lia.color.theme[colorKey] then return lia.color.theme[colorKey] end
    return fallbackColor
end

local function PaintButton(self, w, h)
    local themeColor = ensureThemeColor("accent", Color(106, 108, 197))
    local borderColor = ensureThemeColor("border", Color(100, 100, 100))
    local backgroundColor = ensureThemeColor("background", Color(25, 25, 25))
    local textColor = ensureThemeColor("text", Color(255, 255, 255))
    if self.Base then
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(1, 1, w - 2, h - 2)
    end

    draw.SimpleText(self:GetText(), self:GetFont(), w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if self:IsHovered() or self:IsSelected() then
        self.startTime = self.startTime or CurTime()
        local elapsed = CurTime() - self.startTime
        local anim = math.min(w, elapsed / animDuration * w) / 2
        surface.SetDrawColor(themeColor.r, themeColor.g, themeColor.b, themeColor.a or 255)
        surface.DrawLine(w / 2 - anim, h - 1, w / 2 + anim, h - 1)
    else
        self.startTime = nil
    end
    return true
end

local function RegisterButton(name, defaultFont, useBase)
    PANEL = {}
    PANEL.DefaultFont = defaultFont or name:match("lia(%w+)Button") .. "Font"
    PANEL.Base = useBase
    function PANEL:Init()
        self:SetFont(self.DefaultFont)
        self.Selected = false
    end

    function PANEL:SetFont(font)
        self.ButtonFont = font
    end

    function PANEL:GetFont()
        return self.ButtonFont
    end

    function PANEL:SetSelected(state)
        self.Selected = state
    end

    function PANEL:IsSelected()
        return self.Selected
    end

    function PANEL:Paint(w, h)
        return PaintButton(self, w, h)
    end

    vgui.Register(name, PANEL, "liaButton")
end

RegisterButton("liaHugeButton", "liaHugeFont", true)
RegisterButton("liaBigButton", "liaBigFont", true)
RegisterButton("liaMediumButton", "liaMediumFont", true)
RegisterButton("liaSmallButton", "liaSmallFont", true)
RegisterButton("liaMiniButton", "liaMiniFont", true)
RegisterButton("liaNoBGButton", "liaBigFont", false)
