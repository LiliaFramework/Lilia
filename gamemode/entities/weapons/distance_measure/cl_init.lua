function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    local owner = self:GetOwner()
    local tr = owner:GetEyeTrace()
    if not self.StartPos then
        self.StartPos = tr.HitPos
        surface.PlaySound("buttons/button17.wav")
        owner:ChatPrint(L("distanceMeasureStartPoint"))
    else
        local distance = self.StartPos:Distance(tr.HitPos)
        surface.PlaySound("buttons/button17.wav")
        owner:ChatPrint(L("distanceMeasureDistance", math.Round(distance)))
    end
end
function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    surface.PlaySound("buttons/button16.wav")
    self:GetOwner():ChatPrint(L("distanceMeasureCancelled"))
end
function SWEP:DrawHUD()
    if not self.StartPos then return end
    local owner = self:GetOwner()
    local tr = owner:GetEyeTrace()
    local start = self.StartPos:ToScreen()
    local endpos = tr.HitPos:ToScreen()
    surface.SetDrawColor(255, 255, 0, 255)
    surface.DrawLine(start.x, start.y, endpos.x, endpos.y)
    surface.DrawCircle(start.x, start.y, 5, 255, 255, 0, 255)
end