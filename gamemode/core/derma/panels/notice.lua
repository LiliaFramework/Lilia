local NotificationMaxWidth = 450
local NotificationHeight = 54
local NotificationPadding = 18
local NotificationLifetime = 6
local NotificationFadeoutTime = 1
local NotifIcons = {
    info = Material("icon16/information.png"),
    error = Material("icon16/exclamation.png"),
    success = Material("icon16/accept.png"),
    warning = Material("icon16/error.png"),
    money = Material("icon16/money.png"),
    admin = Material("icon16/shield.png"),
    default = Material("icon16/lightbulb.png")
}

local NotifColors = {
    info = Color(70, 130, 180),
    error = Color(180, 60, 60),
    success = Color(60, 180, 75),
    warning = Color(180, 150, 60),
    money = Color(50, 150, 100),
    admin = Color(140, 70, 180),
    default = Color(40, 40, 40)
}

local PANEL = {}
function PANEL:Init()
    self.msg = ""
    self.ntype = "default"
    self.alpha = 255
    self.startTime = CurTime()
    self.scale = ScrH() / 1080
    self:RecalcSize()
    self:DockPadding(0, 0, 0, 0)
    self:SetDrawOnTop(true)
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
    self:InvalidateLayout(true)
    self:SetPos(-self:GetWide(), 0)
end

function PANEL:RecalcSize()
    self.scale = ScrH() / 1080
    surface.SetFont("liaSmallFont")
    local tw, th = surface.GetTextSize(self.msg or "")
    local minWidth = 200 * self.scale
    local maxWidth = NotificationMaxWidth * self.scale
    local extraSpacing = 20 * self.scale
    local textAreaWidth = tw + (NotificationPadding * 2) + (24 * self.scale) + extraSpacing
    local w = math.Clamp(textAreaWidth, minWidth, maxWidth)
    local h = math.max(NotificationHeight * self.scale, th + NotificationPadding * self.scale)
    self:SetSize(w, h)
    self.iconSize = 24 * self.scale
    self.padding = NotificationPadding * self.scale
    self.baseX = 32 * self.scale
end

function PANEL:SetText(t)
    self.msg = tostring(t or "")
    self:RecalcSize()
end

function PANEL:SetType(t)
    self.ntype = NotifColors[t] and t or "default"
end

function PANEL:Think()
    if self._lastScrH ~= ScrH() then
        self._lastScrH = ScrH()
        self:RecalcSize()
        OrganizeNotices()
    end

    local elapsed = CurTime() - self.startTime
    if elapsed > NotificationLifetime then
        local fadeProgress = math.Clamp((elapsed - NotificationLifetime) / NotificationFadeoutTime, 0, 1)
        self.alpha = Lerp(fadeProgress, 255, 0)
    else
        self.alpha = 255
    end

    if self.alpha <= 0 then
        for k, v in ipairs(lia.notices) do
            if v == self then
                table.remove(lia.notices, k)
                break
            end
        end

        self:Remove()
        OrganizeNotices()
        return
    end

    local slideProgress = math.min(1, elapsed * 5)
    local slideX = Lerp(slideProgress, -self:GetWide(), self.baseX)
    local y = self.targetY or 0
    self:SetPos(math.floor(slideX), math.floor(y))
end

function PANEL:Paint(w, h)
    local typeColor = NotifColors[self.ntype] or NotifColors.default
    local icon = NotifIcons[self.ntype] or NotifIcons.default
    draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, math.floor(200 * (self.alpha / 255))))
    draw.RoundedBox(8, 0, 0, 4, h, Color(typeColor.r, typeColor.g, typeColor.b, math.floor(255 * (self.alpha / 255))))
    draw.RoundedBox(8, 4, 0, w - 4, h, Color(typeColor.r * 0.2, typeColor.g * 0.2, typeColor.b * 0.2, math.floor(150 * (self.alpha / 255))))
    surface.SetDrawColor(0, 0, 0, math.floor(100 * (self.alpha / 255)))
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    if icon then
        surface.SetMaterial(icon)
        surface.SetDrawColor(255, 255, 255, self.alpha)
        surface.DrawTexturedRect(self.padding, (h - self.iconSize) / 2, self.iconSize, self.iconSize)
    end

    draw.SimpleText(self.msg or "", "liaSmallFont", self.padding + self.iconSize + self.padding / 2, h / 2, Color(255, 255, 255, self.alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("liaNotice", PANEL, "DPanel")
