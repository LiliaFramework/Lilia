lia.config.add("CurrencyNotificationImage", "Currency Notification Image", "icon16/money.png", nil, {
    desc = "The material path for the currency icon used in money-type notifications",
    category = "Notifications",
    type = "String"
})

local NotificationHeight = 54
local NotificationPadding = 18
local NotificationLifetime = 6
local NotificationFadeoutTime = 1
local function GetNotifIcon(notifType)
    local icons = {
        info = Material("icon16/information.png"),
        error = Material("icon16/exclamation.png"),
        success = Material("icon16/accept.png"),
        warning = Material("icon16/error.png"),
        money = Material(lia.config.get("CurrencyNotificationImage", "icon16/money.png")),
        admin = Material("icon16/shield.png"),
        default = Material("icon16/lightbulb.png")
    }
    return icons[notifType] or icons.default
end

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
    self.lines = {""}
    self.lineHeight = 0
    self.lineSpacing = 0
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
    surface.SetFont("LiliaFont.17")
    local msg = self.msg or ""
    -- Split message by newlines to handle multi-line text
    -- Manually split to ensure we preserve empty lines
    local lines = {}
    if msg == "" then
        lines = {""}
    else
        local startPos = 1
        while true do
            local pos = string.find(msg, "\n", startPos, true)
            if not pos then
                table.insert(lines, string.sub(msg, startPos))
                break
            end

            table.insert(lines, string.sub(msg, startPos, pos - 1))
            startPos = pos + 1
        end
    end

    if #lines == 0 then lines = {""} end
    -- Calculate width based on the longest line
    local maxWidth = 0
    local lineHeight = 0
    for _, line in ipairs(lines) do
        local tw, th = surface.GetTextSize(line)
        -- Handle empty lines by using space character for measurement
        if tw == 0 and th == 0 then tw, th = surface.GetTextSize(" ") end
        if tw > maxWidth then maxWidth = tw end
        if th > lineHeight then lineHeight = th end
    end

    if maxWidth == 0 or lineHeight == 0 then maxWidth, lineHeight = surface.GetTextSize(" ") end
    local minWidth = 300 * self.scale
    local extraSpacing = 40 * self.scale
    local iconWidth = 24 * self.scale
    local textPadding = math.min(60 * self.scale, maxWidth * 0.1)
    local requiredWidth = maxWidth + (NotificationPadding * 2) + iconWidth + extraSpacing + textPadding
    local w = math.max(requiredWidth, minWidth)
    -- Calculate height based on number of lines
    -- Add extra padding between lines
    local lineSpacing = 2 * self.scale
    local totalHeight = (lineHeight * #lines) + (lineSpacing * math.max(0, #lines - 1)) + (NotificationPadding * self.scale)
    local h = math.max(NotificationHeight * self.scale, totalHeight)
    self:SetSize(w, h)
    self.iconSize = iconWidth
    self.padding = NotificationPadding * self.scale
    self.baseX = 32 * self.scale
    self.lineHeight = lineHeight
    self.lines = lines
    self.lineSpacing = lineSpacing
end

function PANEL:SetText(t)
    self.msg = tostring(t or "")
    self:RecalcSize()
    self:InvalidateLayout(true)
end

function PANEL:SetType(t)
    self.ntype = NotifColors[t] and t or "default"
end

function PANEL:Think()
    if not self._lastScrH then self._lastScrH = ScrH() end
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
    if not self._cachedTypeColor then self._cachedTypeColor = NotifColors[self.ntype] or NotifColors.default end
    if not self._cachedIcon then self._cachedIcon = GetNotifIcon(self.ntype) end
    local typeColor = self._cachedTypeColor
    local icon = self._cachedIcon
    local alpha = self.alpha / 255
    lia.derma.rect(0, 0, w, h):Rad(8):Color(Color(40, 40, 40, math.floor(200 * alpha))):Draw()
    lia.derma.rect(0, 0, 4, h):Rad(8):Color(Color(typeColor.r, typeColor.g, typeColor.b, math.floor(255 * alpha))):Draw()
    lia.derma.rect(4, 0, w - 4, h):Rad(8):Color(Color(typeColor.r * 0.2, typeColor.g * 0.2, typeColor.b * 0.2, math.floor(150 * alpha))):Draw()
    lia.derma.rect(0, 0, w, h):Rad(8):Outline(1):Color(Color(0, 0, 0, math.floor(100 * alpha))):Draw()
    if icon then
        surface.SetMaterial(icon)
        surface.SetDrawColor(255, 255, 255, self.alpha)
        surface.DrawTexturedRect(self.padding, (h - self.iconSize) / 2, self.iconSize, self.iconSize)
    end

    -- Render multi-line text
    local textX = self.padding + self.iconSize + self.padding / 2
    local textColor = Color(255, 255, 255, self.alpha)
    if self.lines and #self.lines > 1 then
        -- Multi-line rendering
        local totalTextHeight = (self.lineHeight * #self.lines) + (self.lineSpacing * math.max(0, #self.lines - 1))
        local startY = (h - totalTextHeight) / 2
        for i, line in ipairs(self.lines) do
            local yPos = startY + (self.lineHeight * (i - 1)) + (self.lineSpacing * (i - 1)) + (self.lineHeight / 2)
            draw.SimpleText(line or "", "LiliaFont.17", textX, yPos, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    else
        -- Single-line rendering (backward compatibility)
        draw.SimpleText(self.msg or "", "LiliaFont.17", textX, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("liaNotice", PANEL, "DPanel")
PANEL = {}
function PANEL:Init()
    self.padding = 80
    self:SetSize(400, 60)
    self:SetContentAlignment(5)
    self.text = self:Add("DLabel")
    self.text:SetText(L("unassigned"))
    self.text:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    self.text:SetFont("LiliaFont.25")
    self.text:SetTextColor(color_white)
    self.text:SetDrawOnTop(true)
    function self.text:Think()
        self:SizeToContents()
        self:Center()
    end
end

function PANEL:CalcWidth(padding)
    self.text:SizeToContents()
    self:SetWide(self.text:GetWide() + padding)
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self, 10)
    derma.SkinHook("Paint", "Panel", self, w, h)
    if self.start then
        local w2 = TimeFraction(self.start, self.endTime, CurTime()) * w
        surfaceSetDrawColor(lia.config.get("Color"))
        surfaceDrawRect(w2, 0, w - w2, h)
    end

    surfaceSetDrawColor(lia.config.get("Color"))
    surfaceDrawOutlinedRect(0, 0, w, h)
end

vgui.Register("liaNoticePanel", PANEL, "DPanel")
