local PANEL = {}
function PANEL:Init()
    self.StartTime = CurTime()
    self.EndTime = self.StartTime + 5
    self.Text = ""
    self.BarColor = lia.config.get("Color")
    self.Fraction = 0
    self.GradientMat = lia.util.getMaterial("vgui/gradient-d")
    self.Font = "LiliaFont.17"
end

function PANEL:GetFraction()
    return self.Fraction or 0
end

function PANEL:SetFraction(fraction)
    self.Fraction = fraction or 0
end

function PANEL:SetProgress(startTime, endTime)
    self.StartTime = startTime or CurTime()
    self.EndTime = endTime or self.StartTime + 5
end

function PANEL:SetText(text)
    self.Text = text or ""
end

function PANEL:SetBarColor(color)
    self.BarColor = color or self.BarColor
end

function PANEL:SetAsActionBar(isAction)
    self.IsActionBar = isAction or false
end

function PANEL:Paint(w, h)
    local frac = math.Clamp(self.Fraction, 0, 1)
    local fillWidth = (w - 16) * frac
    local barHeight = self.IsActionBar and 32 or 22
    local barY = (h - barHeight) * 0.5
    if self.IsActionBar then
        local textPadding = 16
        local textHeight = 20
        if self.Text and self.Text ~= "" then
            local font = "LiliaFont.20"
            surface.SetFont(font)
            _, textHeight = surface.GetTextSize(self.Text)
        end

        local framePadding = 24
        local textBarSpacing = 24
        local frameW = w - 4
        local minTextHeight = 20
        local actualTextHeight = math.max(textHeight, minTextHeight)
        local frameH = framePadding + actualTextHeight + textPadding * 2 + textBarSpacing + barHeight + framePadding
        local frameX = 2
        local frameY = h - frameH
        lia.derma.rect(frameX, frameY, frameW, frameH):Rad(6):Color(Color(25, 28, 35, 240)):Draw()
        local bottomOffset = framePadding - 8
        local actionBarY = frameY + frameH - bottomOffset - barHeight
        local actionBarX = frameX + 8
        local actionBarW = frameW - 16
        lia.derma.rect(actionBarX, actionBarY, actionBarW, barHeight):Rad(6):Color(lia.color.theme.panel and lia.color.theme.panel[2] or Color(20, 20, 20, 120)):Draw()
        if fillWidth > 0 then
            local actionFillWidth = actionBarW * frac
            lia.derma.rect(actionBarX, actionBarY, actionFillWidth, barHeight):Rad(6):Color(self.BarColor):Draw()
            if self.GradientMat then lia.derma.rect(actionBarX, actionBarY, actionFillWidth, barHeight):Rad(6):Material(self.GradientMat):Color(Color(255, 255, 255, 25)):Draw() end
        end

        if self.Text and self.Text ~= "" then
            local font = "LiliaFont.20"
            local textX = actionBarX + actionBarW * 0.5
            local textY = actionBarY - (textBarSpacing - 16) - textHeight * 0.5
            draw.SimpleText(self.Text, font, textX + 1, textY + 1, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(self.Text, font, textX, textY, lia.color.theme.text or Color(240, 240, 240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    else
        lia.derma.rect(8, barY, w - 16, barHeight):Rad(6):Color(lia.color.theme.panel and lia.color.theme.panel[2] or Color(20, 20, 20, 120)):Draw()
        if fillWidth > 0 then
            lia.derma.rect(8, barY, fillWidth, barHeight):Rad(6):Color(self.BarColor):Draw()
            if self.GradientMat then lia.derma.rect(8, barY, fillWidth, barHeight):Rad(6):Material(self.GradientMat):Color(Color(255, 255, 255, 25)):Draw() end
        end
    end

    if not self.IsActionBar and self.Text and self.Text ~= "" then
        local font = self.Font
        local cx = w * 0.5
        local cy = h * 0.5
        draw.SimpleText(self.Text, font, cx + 1, cy + 1, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(self.Text, font, cx, cy, lia.color.theme.text or Color(240, 240, 240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("liaProgressBar", PANEL, "DPanel")
