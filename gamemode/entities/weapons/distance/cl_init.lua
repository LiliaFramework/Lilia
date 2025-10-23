function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    local owner = self:GetOwner()
    local tr = owner:GetEyeTrace()
    if not self.StartPos then
        self.StartPos = tr.HitPos
        lia.websound.playButtonSound("buttons/button17.wav")
        owner:ChatPrint(L("distanceMeasureStartPoint"))
    else
        local distance = self.StartPos:Distance(tr.HitPos)
        lia.websound.playButtonSound("buttons/button17.wav")
        owner:ChatPrint(L("distanceMeasureDistance", math.Round(distance)))
    end
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    lia.websound.playButtonSound("buttons/button16.wav")
    self.StartPos = nil
    self:GetOwner():ChatPrint(L("distanceMeasureCancelled"))
end

function SWEP:Reload()
    if not IsFirstTimePredicted() then return end
    if not self.StartPos then return end
    local owner = self:GetOwner()
    local tr = owner:GetEyeTrace()
    local distance = self.StartPos:Distance(tr.HitPos)
    lia.websound.playButtonSound("buttons/button17.wav")
    owner:ChatPrint(L("distanceMeasureDistance", math.Round(distance)))
end

function SWEP:DrawHUD()
    local owner = self:GetOwner()
    local scrW = ScrW()
    local instructionsText = self.StartPos and L("distanceMeasureInstructionsMeasuring") or L("distanceMeasureInstructions")
    local lines = string.Split(instructionsText, "\n")
    local instructionsX = scrW - 50
    local instructionsY = 10
    lia.derma.drawBoxWithText(lines, instructionsX, instructionsY, {
        font = "liaSmallFont",
        textColor = Color(255, 255, 255),
        backgroundColor = Color(0, 0, 0, 150),
        borderColor = lia.color.theme.theme,
        borderRadius = 8,
        borderThickness = 2,
        padding = 20,
        textAlignX = TEXT_ALIGN_RIGHT,
        textAlignY = TEXT_ALIGN_TOP,
        lineSpacing = 4,
        width = 250,
        height = 80,
        autoSize = false
    })

    if not self.StartPos then return end
    local tr = owner:GetEyeTrace()
    local start = self.StartPos:ToScreen()
    local endpos = tr.HitPos:ToScreen()
    surface.SetDrawColor(lia.color.theme.theme)
    surface.DrawLine(start.x, start.y, endpos.x, endpos.y)
    surface.DrawCircle(start.x, start.y, 5, lia.color.theme.theme.r, lia.color.theme.theme.g, lia.color.theme.theme.b, lia.color.theme.theme.a)
    local distance = self.StartPos:Distance(tr.HitPos)
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
