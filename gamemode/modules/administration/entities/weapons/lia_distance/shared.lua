SWEP.Base = "weapon_base"
SWEP.PrintName = L("distanceTool")
SWEP.Author = "liliaplayer"
SWEP.Contact = "@liliaplayer"
SWEP.Instructions = L("distanceInstructions")
SWEP.Category = "Lilia"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
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

function SWEP:Deploy()
    self.StartPos = nil
    return true
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

function SWEP:Reload()
    if not IsFirstTimePredicted() then return end
    return true
end
