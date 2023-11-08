--------------------------------------------------------------------------------------------------------------------------
local phys_pushscale = GetConVar("phys_pushscale")
--------------------------------------------------------------------------------------------------------------------------
SWEP.PrintName = "Hands"
--------------------------------------------------------------------------------------------------------------------------
SWEP.Author = "liliaplayer"
--------------------------------------------------------------------------------------------------------------------------
SWEP.Slot = 0
--------------------------------------------------------------------------------------------------------------------------
SWEP.SlotPos = 4
--------------------------------------------------------------------------------------------------------------------------
SWEP.Instructions = "Primary Fire: Attack\nSecondary Fire: Grab"
--------------------------------------------------------------------------------------------------------------------------
SWEP.Spawnable = true
--------------------------------------------------------------------------------------------------------------------------
SWEP.Category = "Lilia"
--------------------------------------------------------------------------------------------------------------------------
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
--------------------------------------------------------------------------------------------------------------------------
SWEP.WorldModel = ""
--------------------------------------------------------------------------------------------------------------------------
SWEP.ViewModelFOV = 54
--------------------------------------------------------------------------------------------------------------------------
SWEP.UseHands = false
--------------------------------------------------------------------------------------------------------------------------
SWEP.HoldType = "fist"
--------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.Automatic = true
--------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.ClipSize = -1
--------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.DefaultClip = 1
--------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.Ammo = "none"
--------------------------------------------------------------------------------------------------------------------------
SWEP.Secondary.Automatic = false
--------------------------------------------------------------------------------------------------------------------------
SWEP.Secondary.ClipSize = -1
--------------------------------------------------------------------------------------------------------------------------
SWEP.Secondary.DefaultClip = 1
--------------------------------------------------------------------------------------------------------------------------
SWEP.Secondary.Ammo = "none"
--------------------------------------------------------------------------------------------------------------------------
SWEP.DrawAmmo = false
--------------------------------------------------------------------------------------------------------------------------
SWEP.DrawCrosshair = false
--------------------------------------------------------------------------------------------------------------------------
SWEP.GrabRange = 100
--------------------------------------------------------------------------------------------------------------------------
SWEP.HitDistance = 48
--------------------------------------------------------------------------------------------------------------------------
SWEP.FireWhenLowered = true
--------------------------------------------------------------------------------------------------------------------------
SWEP.LowerAngles = Angle(0, 5, -14)
--------------------------------------------------------------------------------------------------------------------------
SWEP.LowerAngles2 = Angle(0, 5, -22)
--------------------------------------------------------------------------------------------------------------------------
SWEP.SwingSound = Sound("WeaponFrag.Throw")
--------------------------------------------------------------------------------------------------------------------------
SWEP.HitSound = Sound("Flesh.ImpactHard")
--------------------------------------------------------------------------------------------------------------------------
SWEP.IsHands = true
--------------------------------------------------------------------------------------------------------------------------
function SWEP:Initialize()
    self:SetHoldType("fist")
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextMeleeAttack")
    self:NetworkVar("Float", 1, "NextIdle")
    self:NetworkVar("Int", 2, "Combo")
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:UpdateNextIdle()
    local vm = self:GetOwner():GetViewModel()
    self:SetNextIdle(CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate())
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttack()
    if hook.Run("CanPlayerThrowPunch", self:GetOwner()) == false then return false end
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    local anim
    if self:GetCombo() >= 2 then
        anim = "fists_uppercut"
    else
        if math.random() < 0.5 then
            anim = "fists_right"
        else
            anim = "fists_left"
        end
    end

    local vm = self:GetOwner():GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
    self:EmitSound(self.SwingSound)
    self:UpdateNextIdle()
    self:SetNextMeleeAttack(CurTime() + 0.2)
    self:SetNextPrimaryFire(CurTime() + 0.9)
    self:SetNextSecondaryFire(CurTime() + 0.9)
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:DealDamage()
    local anim = self:GetSequenceName(self:GetOwner():GetViewModel():GetSequence())
    self:GetOwner():LagCompensation(true)
    local tr = util.TraceLine(
        {
            start = self:GetOwner():GetShootPos(),
            endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDistance,
            filter = self:GetOwner(),
            mask = MASK_SHOT_HULL
        }
    )

    if not IsValid(tr.Entity) then
        tr = util.TraceHull(
            {
                start = self:GetOwner():GetShootPos(),
                endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * self.HitDistance,
                filter = self:GetOwner(),
                mins = Vector(-10, -10, -8),
                maxs = Vector(10, 10, 8),
                mask = MASK_SHOT_HULL
            }
        )
    end

    if tr.Hit and not (game.SinglePlayer() and CLIENT) then self:EmitSound(self.HitSound) end
    local hit = false
    local scale = phys_pushscale:GetFloat()
    if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
        local dmginfo = DamageInfo()
        local attacker = self:GetOwner()
        if not IsValid(attacker) then attacker = self end
        dmginfo:SetAttacker(attacker)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamage(math.random(5, 8))
        if anim == "fists_left" then
            dmginfo:SetDamageForce(self:GetOwner():GetRight() * 4912 * scale + self:GetOwner():GetForward() * 9998 * scale) -- Yes we need those specific numbers
        elseif anim == "fists_right" then
            dmginfo:SetDamageForce(self:GetOwner():GetRight() * -4912 * scale + self:GetOwner():GetForward() * 9989 * scale)
        elseif anim == "fists_uppercut" then
            dmginfo:SetDamageForce(self:GetOwner():GetUp() * 5158 * scale + self:GetOwner():GetForward() * 10012 * scale)
            dmginfo:SetDamage(math.random(12, 24))
        end

        SuppressHostEvents(NULL) -- Let the breakable gibs spawn in multiplayer on client
        tr.Entity:TakeDamageInfo(dmginfo)
        SuppressHostEvents(self:GetOwner())
        hit = true
    end

    if IsValid(tr.Entity) then
        local phys = tr.Entity:GetPhysicsObject()
        if IsValid(phys) then phys:ApplyForceOffset(self:GetOwner():GetAimVector() * 80 * phys:GetMass() * scale, tr.HitPos) end
    end

    if SERVER then
        if hit and anim ~= "fists_uppercut" then
            self:SetCombo(self:GetCombo() + 1)
        else
            self:SetCombo(0)
        end
    end

    self:GetOwner():LagCompensation(false)
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:OnDrop()
    self:Remove()
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:Deploy()
    local vm = self:GetOwner():GetViewModel()
    vm:SetModel("models/weapons/c_arms_citizen.mdl")
    vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
    self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration())
    self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration())
    self:UpdateNextIdle()
    if SERVER then self:SetCombo(0) end
    return true
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:Holster()
    self:SetNextMeleeAttack(0)
    return true
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:Think()
    local vm = self:GetOwner():GetViewModel()
    local idletime = self:GetNextIdle()
    if idletime > 0 and CurTime() > idletime then
        vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_idle_0" .. math.random(1, 2)))
        self:UpdateNextIdle()
    end

    local meleetime = self:GetNextMeleeAttack()
    if meleetime > 0 and CurTime() > meleetime then
        self:DealDamage()
        self:SetNextMeleeAttack(0)
    end

    if SERVER and CurTime() > self:GetNextPrimaryFire() + 0.1 then self:SetCombo(0) end
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:CanPickup(ent, physObj)
    if not IsValid(ent) or not IsValid(physObj) then return false end
    return ent ~= game.GetWorld() and ent:GetPos():Distance(self:GetOwner():GetPos()) < self.GrabRange and physObj:IsMotionEnabled() and physObj:GetMass() < 200 and not ent:IsPlayerHolding() and hook.Run("PlayerCanPickupItem", self:GetOwner(), ent)
end
--------------------------------------------------------------------------------------------------------------------------
