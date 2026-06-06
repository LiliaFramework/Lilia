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
