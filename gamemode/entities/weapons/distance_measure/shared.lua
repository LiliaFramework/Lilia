SWEP.PrintName = L("distanceMeasureTool")
SWEP.Author = "Samael"
SWEP.Contact = "@liliaplayer"
SWEP.Purpose = L("measureDistanceBetweenTwoPoints")
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
    else
        self.StartPos = nil
    end
end
function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    self.StartPos = nil
end