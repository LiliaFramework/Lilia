SWEP.PrintName = L("distanceMeasureTool")
SWEP.Author = "Samael"
SWEP.Contact = "liliaplayer"
SWEP.Purpose = L("distanceMeasurePurpose")
SWEP.Category = "Lilia"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.StartPos = nil
function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    local owner = self:GetOwner()
    local tr = owner:GetEyeTrace()
    if not self.StartPos then
        self.StartPos = tr.HitPos
        if CLIENT then
            surface.PlaySound("buttons/button17.wav")
            owner:ChatPrint(L("distanceMeasureStartPoint"))
        end
    else
        local distance = self.StartPos:Distance(tr.HitPos)
        if CLIENT then
            surface.PlaySound("buttons/button17.wav")
            owner:ChatPrint(L("distanceMeasureDistance", math.Round(distance)))
        end

        self.StartPos = nil
    end
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    self.StartPos = nil
    if CLIENT then
        surface.PlaySound("buttons/button16.wav")
        self:GetOwner():ChatPrint(L("distanceMeasureCancelled"))
    end
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
