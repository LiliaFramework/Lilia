function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    local owner = self:GetOwner()
    local tr = owner:GetEyeTrace()
    if not self.StartPos then
        self.StartPos = tr.HitPos
        surface.PlaySound("buttons/button17.wav")
        owner:ChatPrint(L("distanceMeasureStartPoint"))
    else
        local distance = self.StartPos:distance(tr.HitPos)
        surface.PlaySound("buttons/button17.wav")
        owner:ChatPrint(L("distanceMeasureDistance", math.Round(distance)))
    end
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    surface.PlaySound("buttons/button16.wav")
    self.StartPos = nil
    self:GetOwner():ChatPrint(L("distanceMeasureCancelled"))
end

function SWEP:Reload()
    if not IsFirstTimePredicted() then return end
    if not self.StartPos then return end
    local owner = self:GetOwner()
    local tr = owner:GetEyeTrace()
    local distance = self.StartPos:distance(tr.HitPos)
    surface.PlaySound("buttons/button17.wav")
    owner:ChatPrint(L("distanceMeasureDistance", math.Round(distance)))
end

function SWEP:DrawHUD()
    local owner = self:GetOwner()
    local scrW = ScrW()
    local instructionsText = self.StartPos and L("distanceMeasureInstructionsMeasuring") or L("distanceMeasureInstructions")
    local instructionsWidth = 250
    local instructionsHeight = 80
    local instructionsX = scrW - instructionsWidth - 50
    local instructionsY = 10
    lia.util.drawBlurAt(instructionsX, instructionsY, instructionsWidth, instructionsHeight, 3, 3, 0.9)
    lia.derma.rect(instructionsX, instructionsY, instructionsWidth, instructionsHeight):Color(Color(0, 0, 0, 150)):Rad(8):Draw()
    lia.derma.rect(instructionsX, instructionsY, instructionsWidth, instructionsHeight):Color(lia.color.theme.theme):Rad(8):Outline(2):Draw()
    local centerX = scrW - instructionsWidth / 2 - 50
    local startY = 25
    local lines = string.Split(instructionsText, "\n")
    for i, line in ipairs(lines) do
        draw.SimpleText(line, "liaSmallFont", centerX, startY + (i - 1) * 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    if not self.StartPos then return end
    local tr = owner:GetEyeTrace()
    local start = self.StartPos:ToScreen()
    local endpos = tr.HitPos:ToScreen()
    surface.SetDrawColor(lia.color.theme.theme)
    surface.DrawLine(start.x, start.y, endpos.x, endpos.y)
    surface.DrawCircle(start.x, start.y, 5, lia.color.theme.theme.r, lia.color.theme.theme.g, lia.color.theme.theme.b, lia.color.theme.theme.a)
    local distance = self.StartPos:distance(tr.HitPos)
    local distanceText = L("distanceMeasureDistance", math.Round(distance))
    local distanceBoxWidth = 200
    local distanceBoxHeight = 40
    local distanceBoxX = scrW / 2 - distanceBoxWidth / 2
    local distanceBoxY = 10
    lia.util.drawBlurAt(distanceBoxX, distanceBoxY, distanceBoxWidth, distanceBoxHeight, 3, 3, 0.9)
    lia.derma.rect(distanceBoxX, distanceBoxY, distanceBoxWidth, distanceBoxHeight):Color(Color(0, 0, 0, 150)):Rad(8):Draw()
    lia.derma.rect(distanceBoxX, distanceBoxY, distanceBoxWidth, distanceBoxHeight):Color(lia.color.theme.theme):Rad(8):Outline(2):Draw()
    draw.SimpleText(distanceText, "liaSmallFont", scrW / 2, 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
