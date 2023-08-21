--------------------------------------------------------------------------------------------------------
local b = vgui.GetControlTable("DButton")

--------------------------------------------------------------------------------------------------------
function b:SetColorAcc(col)
    self.defaultColor = col or Color(255, 0, 0)
    self.color = col or Color(255, 0, 0)
    AccessorFunc(self, "color", "Color")
end

--------------------------------------------------------------------------------------------------------
function b:SetupHover(hoverCol)
    if not self.GetColor or not self.SetColor or not self.color then
        self:SetColorAcc()
    end

    self.hoverCol = hoverCol

    function self:OnCursorEntered()
        self:ColorTo(hoverCol, 0.15)
    end

    function self:OnCursorExited()
        self:ColorTo(self.defaultColor, 0.15)
    end
end

--------------------------------------------------------------------------------------------------------
function b:Flash(text, color, time, noAdjust, callback)
    noAdjust = noAdjust or false
    time = time or 1
    if self.flashing and self.flashing == true then return end
    local ogText = self:GetText()
    local ogPaint = self.Paint
    local ogSizeW, ogSizeH = self:GetSize()
    self:SetText(text) --Changing to temp text
    self.flashing = true

    --Justify new width
    if not noAdjust then
        local cw, ch = self:GetContentSize()
        self:SizeTo(cw + 15, self:GetTall(), 0.2, 0, -1)
    end

    --Has Smooth functions
    if self.GetColor and self.SetColor then
        self.ogCol = self:GetColor() --Getting previous button color
        self:ColorTo(color, 0.3, 0)
        --Saving previous button state
        self.ogOCEn = self.OnCursorEntered
        self.ogOCEx = self.OnCursorExited
        self.OnCursorEntered = nil
        self.OnCursorExited = nil
    else
        function b:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, color)
        end
    end

    --Revert back to original button after timer
    timer.Simple(time, function()
        if not self or not IsValid(self) then return end
        self:SetText(ogText)
        self.Paint = ogPaint

        self:SizeTo(ogSizeW, ogSizeH, 0.2, 0, -1, function()
            self.flashing = false
        end)

        if self.ogOCEn and self.ogOCEx and self.ogCol then
            self.OnCursorEntered = self.ogOCEn
            self.OnCursorExited = self.ogOCEx
            self:ColorTo(self.ogCol, 0.3, 0)
        end

        --Call callback
        if callback then
            callback()
        end
    end)
end

--------------------------------------------------------------------------------------------------------
function b:GInflate(color, over)
    if not self.GetColor then
        Error("Panel deosn't have '.GetColor()'")
    end

    color = color or Color(250, 250, 250, 50)
    over = over or false
    self.animStart = CurTime()
    self.animDur = 0.25
    self.fadeoutStart = CurTime() + self.animDur
    local ogPaint = self.Paint

    function self:Paint(w, h)
        local dt = math.TimeFraction(self.animStart, self.animStart + self.animDur, CurTime())
        local r = Lerp(dt, 0, w / 1.5)

        --The end of the expansion animation
        if CurTime() >= (self.animStart + self.animDur) then
            --Start Fade out animation
            local dtfo = math.TimeFraction(self.fadeoutStart, self.fadeoutStart + 0.8, CurTime()) --New DT
            local curAlpha = Lerp(dtfo, color.a, 0)
            color.a = math.Round(curAlpha)

            if CurTime() >= self.fadeoutStart + 3.8 then
                self.Paint = ogPaint
            end
        end

        if over then
            ogPaint(self, self:GetSize())
        end

        draw.NoTexture()
        surface.SetDrawColor(color)
        draw.Circle(w / 2, h / 2, r, 360)
    end
end

--------------------------------------------------------------------------------------------------------
local te = vgui.GetControlTable("DTextEntry")

--------------------------------------------------------------------------------------------------------
function te:SetPlaceholder(text)
    local ogThink = self.Think
    self.placeholder = text
    self:SetText(text)

    function self:Think()
        if self:IsEditing() and self:GetText() == self.placeholder then
            self:SetText("")
        end

        if not self:IsEditing() and self:GetText() == "" then
            self:SetText(self.placeholder)
        end

        ogThink(self) --Call original think method.
    end
end

--------------------------------------------------------------------------------------------------------
function te:SetError(err, ogCol)
    AccessorFunc(self, "color", "Color") --Create getters/setters
    self:SetEditable(false)
    --Set error text
    local ogText = self:GetText()
    self:SetText(err)

    --Reset text
    timer.Simple(1, function()
        if self and IsValid(self) then
            self:SetText(ogText)
            self:SetEditable(true)
        end
    end)

    --Color flash
    self.color = Color(255, 0, 0)
    self:ColorTo(ogCol, 0.5, 0)

    --Draw outline
    function self:PaintOver(w, h)
        surface.SetDrawColor(255, 0, 0)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
end

--------------------------------------------------------------------------------------------------------
local mps = {"DPanel", "DButton", "DLabel", "DFrame", "DTextEntry", "WButton", "WLabel", "WScrollList"}

--------------------------------------------------------------------------------------------------------
for k, v in pairs(mps) do
    local m = vgui.GetControlTable(v)

    function m:GetX()
        local x, y = self:GetPos()

        return x
    end

    function m:GetY()
        local x, y = self:GetPos()

        return y
    end

    function m:Debug()
        function self:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0))
        end
    end

    function m:FadeOutRem(time, callback)
        time = time or 0.2

        self:AlphaTo(0, time, 0, function()
            self:Remove()

            if callback then
                callback()
            end
        end)
    end
end

--------------------------------------------------------------------------------------------------------
function WB.GetWorkPanel(panel, paddingTop, paddingLeft, paddingRight, paddingBottom, center)
    center = center or false

    if paddingTop ~= nil and not paddingLeft and not paddingRight and not paddingBottom then
        paddingLeft = paddingTop
        paddingRight = paddingTop
        paddingBottom = paddingTop
    end

    local wp = panel:Add("DPanel")
    wp:SetSize(panel:GetWide() - (paddingLeft + paddingRight), panel:GetTall() - (paddingTop + paddingBottom))

    if center then
        wp:Center()
    else
        wp:SetPos(paddingLeft, paddingTop)
    end

    return wp
end
--------------------------------------------------------------------------------------------------------