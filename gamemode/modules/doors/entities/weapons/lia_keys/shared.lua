SWEP.Author = "Samael"
SWEP.Contact = "@liliaplayer"
SWEP.Instructions = L("keysInstructions")
SWEP.Purpose = L("keysPurpose")
SWEP.Drop = false
SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false
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
ACT_VM_FISTS_HOLSTER = 2
function SWEP:Deploy()
    if not IsValid(self:GetOwner()) then return end
    return true
end

function SWEP:Holster()
    if not IsValid(self:GetOwner()) then return end
    local viewModel = self:GetOwner():GetViewModel()
    if IsValid(viewModel) then
        viewModel:SetPlaybackRate(1)
        viewModel:ResetSequence(ACT_VM_FISTS_HOLSTER)
    end
    return true
end

function SWEP:Precache()
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    local time = lia.config.get("DoorLockTime", 0.5)
    local time2 = math.max(time, 1)
    local owner = self:GetOwner()
    local data = {}
    data.start = owner:GetShootPos()
    data.endpos = data.start + owner:GetAimVector() * 96
    data.filter = owner
    local entity = util.TraceLine(data).Entity
    self:SetNextPrimaryFire(CurTime() + time2)
    self:SetNextSecondaryFire(CurTime() + time2)
    if not IsFirstTimePredicted() then return end
    if not IsValid(entity) then return end
    hook.Run("KeyLock", owner, entity, time)
end

function SWEP:SecondaryAttack()
    local time = lia.config.get("DoorLockTime", 0.5)
    local time2 = math.max(time, 1)
    local owner = self:GetOwner()
    local data = {}
    data.start = owner:GetShootPos()
    data.endpos = data.start + owner:GetAimVector() * 96
    data.filter = owner
    local entity = util.TraceLine(data).Entity
    self:SetNextPrimaryFire(CurTime() + time2)
    self:SetNextSecondaryFire(CurTime() + time2)
    if not IsFirstTimePredicted() then return end
    if not IsValid(entity) then return end
    hook.Run("KeyUnlock", owner, entity, time)
end