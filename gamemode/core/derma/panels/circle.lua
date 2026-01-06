local function getAccentColor()
    if lia.color and lia.color.getMainColor then return lia.color.getMainColor() end
    return Color(160, 120, 255)
end

local PANEL = {}
function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
end

function PANEL:Start(text, duration, options)
    options = options or {}
    duration = math.max(duration or 0.01, 0.01)
    local now = CurTime()
    self.data = {
        text = options.uppercase == false and (text or "") or string.upper(text or ""),
        startTime = now,
        endTime = now + duration,
        holdTime = options.holdTime or 0,
        color = options.color or getAccentColor(),
        background = options.background or Color(205, 205, 205, 255),
        textColor = options.textColor or color_white,
        percentFont = options.percentFont or "LiliaFont.24b",
        labelFont = options.labelFont or "LiliaFont.18b",
        radius = options.radius,
        thickness = options.thickness,
        startAngle = options.startAngle or -90,
        position = options.position
    }
end

function PANEL:Think()
    if not self.data then return end
    local now = CurTime()
    if now >= self.data.endTime then
        if not self.data.finishUntil then
            if self.data.holdTime > 0 then
                self.data.finishUntil = now + self.data.holdTime
            else
                self:Remove()
            end
        elseif now >= self.data.finishUntil then
            self:Remove()
        end
    end
end

function PANEL:OnRemove()
    if lia.gui.actionCircle == self then lia.gui.actionCircle = nil end
end

function PANEL:Paint()
    local data = self.data
    if not data then return end
    local now = CurTime()
    local progress = math.TimeFraction(data.startTime, data.endTime, now)
    if data.finishUntil then progress = 1 end
    progress = math.Clamp(progress, 0, 1)
    local sw, sh = ScrW(), ScrH()
    local radius = data.radius or math.min(sw, sh) * 0.04
    local thickness = data.thickness or math.max(8, radius * 0.26)
    local borderThickness = thickness + 3
    local cx = data.position and data.position.x or sw * 0.5
    local cy = data.position and data.position.y or (sh - (radius + thickness * 1.6 + 24))
    lia.derma.circle(cx, cy, radius * 2):Color(color_black):Outline(borderThickness):Draw()
    lia.derma.circle(cx, cy, radius * 2):Color(data.background):Outline(thickness):Draw()
    if progress > 0 then
        local startAngle = data.startAngle or -90
        local sweep = 360 * progress
        lia.derma.circle(cx, cy, radius * 2):Color(data.color):StartAngle(0):EndAngle(sweep):Rotation(startAngle):Outline(thickness):Draw()
    end

    local pct = math.floor(progress * 100 + 0.5)
    draw.SimpleText(pct .. "%", data.percentFont, cx, cy, data.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    if data.text ~= "" then draw.SimpleText(data.text, data.labelFont, cx, cy + radius + thickness * 1.1 + 6, data.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
end

vgui.Register("liaLockCircle", PANEL, "EditablePanel")