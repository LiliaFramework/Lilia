--------------------------------------------------------------------------------------------------------
ACT_VM_FISTS_DRAW = 3
ACT_VM_FISTS_HOLSTER = 2
--------------------------------------------------------------------------------------------------------
SWEP.Author = "Chessnut"
SWEP.Instructions = "Primary Fire: Lock\nSecondary Fire: Unlock"
SWEP.Purpose = "Hitting things and knocking on doors."
SWEP.Drop = false
SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "passive"
SWEP.ViewTranslation = 4
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 5
SWEP.Primary.Delay = 0.75
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.ViewModel = Model("models/weapons/c_arms_animations.mdl")
SWEP.WorldModel = ""
SWEP.UseHands = false
SWEP.LowerAngles = Angle(0, 5, -14)
SWEP.LowerAngles2 = Angle(0, 5, -22)
SWEP.IsAlwaysLowered = true
SWEP.FireWhenLowered = true
SWEP.HoldType = "normal"
--------------------------------------------------------------------------------------------------------
function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end
--------------------------------------------------------------------------------------------------------
function SWEP:Deploy()
	if not IsValid(self.Owner) then return end
	local viewModel = self.Owner:GetViewModel()
	if IsValid(viewModel) then end

	return true
end
--------------------------------------------------------------------------------------------------------
function SWEP:Holster()
	if not IsValid(self.Owner) then return end
	local viewModel = self.Owner:GetViewModel()
	if IsValid(viewModel) then
		viewModel:SetPlaybackRate(1)
		viewModel:ResetSequence(ACT_VM_FISTS_HOLSTER)
	end

	return true
end
--------------------------------------------------------------------------------------------------------