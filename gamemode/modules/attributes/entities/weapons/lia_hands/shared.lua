SWEP.PrintName = L("handsWeaponName")
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Author = "Samael"
SWEP.Contact = "@liliaplayer"
SWEP.Instructions = L("handsInstructions")
SWEP.Purpose = L("handsPurpose")
SWEP.Drop = false
SWEP.ViewModelFOV = 45
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"
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
SWEP.Secondary.Delay = 0.5
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""
SWEP.UseHands = true
SWEP.LowerAngles = Angle(0, 5, -14)
SWEP.LowerAngles2 = Angle(0, 5, -19)
SWEP.KnockViewPunchAngle = Angle(-1.3, 1.8, 0)
SWEP.FireWhenLowered = true
SWEP.HoldType = "normal"
SWEP.holdDistance = 64
SWEP.maxHoldDistance = 96
SWEP.maxHoldStress = 4000
ACT_VM_FISTS_DRAW = 2
ACT_VM_FISTS_HOLSTER = 1
function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self.lastHand = 0
    self.maxHoldDistanceSquared = self.maxHoldDistance ^ 2
    self.heldObjectAngle = Angle(angle_zero)
    self.lastPunchTime = 0
    self.isFistHold = false
end

function SWEP:Deploy()
    if not IsValid(self:GetOwner()) then return end
    local viewModel = self:GetOwner():GetViewModel()
    if IsValid(viewModel) then
        viewModel:SetPlaybackRate(1)
        viewModel:ResetSequence(ACT_VM_FISTS_DRAW)
        if CLIENT then self.NextAllowedPlayRateChange = CurTime() + viewModel:SequenceDuration() end
    end

    self:DropObject()
    return true
end

function SWEP:Precache()
    util.PrecacheSound("npc/vort/claw_swing1.wav")
    util.PrecacheSound("npc/vort/claw_swing2.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard1.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard2.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard3.wav")
    util.PrecacheSound("physics/plastic/plastic_box_impact_hard4.wav")
    util.PrecacheSound("physics/wood/wood_crate_impact_hard2.wav")
    util.PrecacheSound("physics/wood/wood_crate_impact_hard3.wav")
end

function SWEP:OnReloaded()
    self.maxHoldDistanceSquared = self.maxHoldDistance ^ 2
    self:DropObject()
end

function SWEP:Think()
    if not IsValid(self:GetOwner()) then return end
    if CLIENT then
        local viewModel = self:GetOwner():GetViewModel()
        if IsValid(viewModel) and self.NextAllowedPlayRateChange < CurTime() then viewModel:SetPlaybackRate(1) end
    else
        if self.isFistHold and CurTime() - (self.lastPunchTime or 0) > 5 then
            self:SetHoldType("normal")
            self.isFistHold = false
        end

        if self:IsHoldingObject() then
            local physics = self:GetHeldPhysicsObject()
            local bIsRagdoll = self.heldEntity:IsRagdoll()
            local holdDistance = bIsRagdoll and self.holdDistance * 0.5 or self.holdDistance
            local targetLocation = self:GetOwner():GetShootPos() + self:GetOwner():GetForward() * holdDistance
            if bIsRagdoll then targetLocation.z = math.min(targetLocation.z, self:GetOwner():GetShootPos().z - 32) end
            if not IsValid(physics) then
                self:DropObject()
                return
            end

            if physics:GetPos():DistToSqr(targetLocation) > self.maxHoldDistanceSquared then
                self:DropObject()
            else
                local physicsObject = self.holdEntity:GetPhysicsObject()
                local currentPlayerAngles = self:GetOwner():EyeAngles()
                local client = self:GetOwner()
                if client:KeyDown(IN_ATTACK2) then
                    local cmd = client:GetCurrentCommand()
                    self.heldObjectAngle:RotateAroundAxis(currentPlayerAngles:Forward(), cmd:GetMouseX() / 15)
                    self.heldObjectAngle:RotateAroundAxis(currentPlayerAngles:Right(), cmd:GetMouseY() / 15)
                end

                self.lastPlayerAngles = self.lastPlayerAngles or currentPlayerAngles
                self.heldObjectAngle.y = self.heldObjectAngle.y - math.AngleDifference(self.lastPlayerAngles.y, currentPlayerAngles.y)
                self.lastPlayerAngles = currentPlayerAngles
                physicsObject:Wake()
                physicsObject:ComputeShadowControl({
                    secondstoarrive = 0.01,
                    pos = targetLocation,
                    angle = self.heldObjectAngle,
                    maxangular = 256,
                    maxangulardamp = 10000,
                    maxspeed = 256,
                    maxspeeddamp = 10000,
                    dampfactor = 0.8,
                    teleportdistance = self.maxHoldDistance * 0.75,
                    deltatime = FrameTime()
                })

                if physics:GetStress() > self.maxHoldStress then self:DropObject() end
            end
        end

        if not IsValid(self.heldEntity) and self:GetOwner():getLocalVar("IsHoldingObject", true) then self:GetOwner():setLocalVar("IsHoldingObject", false) end
    end
end

function SWEP:GetHeldPhysicsObject()
    return IsValid(self.heldEntity) and IsValid(self.heldEntity.ixHeldOwner) and self.heldEntity.ixHeldOwner == self:GetOwner() and self.heldEntity:GetPhysicsObject() or nil
end

function SWEP:CanHoldObject(entity)
    local physics = entity:GetPhysicsObject()
    return IsValid(physics) and physics:GetMass() <= lia.config.get("MaxHoldWeight", 100) and physics:IsMoveable() and not self:IsHoldingObject() and not IsValid(entity.ixHeldOwner) and hook.Run("CanPlayerHoldObject", self:GetOwner(), entity)
end

function SWEP:IsHoldingObject()
    return IsValid(self.heldEntity) and IsValid(self.heldEntity.ixHeldOwner) and self.heldEntity.ixHeldOwner == self:GetOwner()
end

function SWEP:PickupObject(entity)
    if self:IsHoldingObject() or not IsValid(entity) or not IsValid(entity:GetPhysicsObject()) then return end
    local physics = entity:GetPhysicsObject()
    physics:EnableGravity(false)
    physics:AddGameFlag(FVPHYSICS_PLAYER_HELD)
    entity.ixHeldOwner = self:GetOwner()
    entity.ixCollisionGroup = entity:GetCollisionGroup()
    entity:StartMotionController()
    entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self.heldObjectAngle = entity:GetAngles()
    self.heldEntity = entity
    self.holdEntity = ents.Create("prop_physics")
    self.holdEntity:SetPos(self.heldEntity:LocalToWorld(self.heldEntity:OBBCenter()))
    self.holdEntity:SetAngles(self.heldEntity:GetAngles())
    self.holdEntity:SetModel("models/weapons/w_bugbait.mdl")
    self.holdEntity:SetOwner(self:GetOwner())
    self.holdEntity:SetNoDraw(true)
    self.holdEntity:SetNotSolid(true)
    self.holdEntity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self.holdEntity:DrawShadow(false)
    self.holdEntity:Spawn()
    local trace = self:GetOwner():GetEyeTrace()
    local physicsObject = self.holdEntity:GetPhysicsObject()
    if IsValid(physicsObject) then
        physicsObject:SetMass(2048)
        physicsObject:SetDamping(0, 1000)
        physicsObject:EnableGravity(false)
        physicsObject:EnableCollisions(false)
        physicsObject:EnableMotion(false)
    end

    if trace.Entity:IsRagdoll() then
        local tracedEnt = trace.Entity
        self.holdEntity:SetPos(tracedEnt:GetBonePosition(tracedEnt:TranslatePhysBoneToBone(trace.PhysicsBone)))
    end

    self.constraint = constraint.Weld(self.holdEntity, self.heldEntity, 0, trace.Entity:IsRagdoll() and trace.PhysicsBone or 0, 0, true, true)
end

function SWEP:DropObject(bThrow)
    if not IsValid(self.heldEntity) or self.heldEntity.ixHeldOwner ~= self:GetOwner() then return end
    self.lastPlayerAngles = nil
    self:GetOwner():setLocalVar("IsHoldingObject", false)
    SafeRemoveEntity(self.constraint)
    SafeRemoveEntity(self.holdEntity)
    self.heldEntity:StopMotionController()
    self.heldEntity:SetCollisionGroup(self.heldEntity.ixCollisionGroup or COLLISION_GROUP_NONE)
    local physics = self:GetHeldPhysicsObject()
    physics:EnableGravity(true)
    physics:Wake()
    physics:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
    if bThrow then
        timer.Simple(0, function()
            if IsValid(physics) and IsValid(self:GetOwner()) then
                physics:AddGameFlag(FVPHYSICS_WAS_THROWN)
                physics:ApplyForceCenter(self:GetOwner():GetAimVector() * lia.config.get("ThrowForce", 732))
            end
        end)
    end

    self:SetHoldType("normal")
    self.heldEntity.ixHeldOwner = nil
    self.heldEntity.ixCollisionGroup = nil
    self.heldEntity = nil
end

function SWEP:PlayPickupSound(surfaceProperty)
    local result = "Flesh.ImpactSoft"
    if surfaceProperty ~= nil then
        local surfaceName = util.GetSurfacePropName(surfaceProperty)
        local soundName = surfaceName:gsub("^metal$", "SolidMetal") .. ".ImpactSoft"
        if sound.GetProperties(soundName) then result = soundName end
    end

    self:GetOwner():EmitSound(result, 75, 100, 40)
end

function SWEP:DoPunchAnimation()
    self.lastHand = math.abs(1 - self.lastHand)
    local sequence = 3 + self.lastHand
    local viewModel = self:GetOwner():GetViewModel()
    if IsValid(viewModel) then
        viewModel:SetPlaybackRate(0.5)
        viewModel:SetSequence(sequence)
        if CLIENT then self.NextAllowedPlayRateChange = CurTime() + viewModel:SequenceDuration() * 2 end
    end
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    if SERVER and self:IsHoldingObject() then
        self:DropObject(true)
        return
    end

    if not self.isFistHold then
        self:SetHoldType("fist")
        self.isFistHold = true
    end

    local canPunch, reason = hook.Run("CanPlayerThrowPunch", self:GetOwner())
    if canPunch == false then
        if SERVER and reason and isstring(reason) then self:GetOwner():notify(reason) end
        return
    end

    local staminaUse = lia.config.get("PunchStamina", 0)
    if staminaUse > 0 and SERVER then self:GetOwner():consumeStamina(staminaUse) end
    local defaultDelay = self.Primary.Delay
    local scaledDelay = hook.Run("GetHandsAttackSpeed", self:GetOwner(), defaultDelay)
    self:SetNextPrimaryFire(CurTime() + (isnumber(scaledDelay) and scaledDelay or defaultDelay))
    if SERVER then self:GetOwner():EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav") end
    timer.Simple(0.1, function()
        self:DoPunchAnimation()
        self:GetOwner():SetAnimation(PLAYER_ATTACK1)
        self:GetOwner():ViewPunch(Angle(self.lastHand + 2, self.lastHand + 5, 0.125))
    end)

    self.lastPunchTime = CurTime()
    timer.Simple(0.055, function()
        if not IsValid(self) or not IsValid(self:GetOwner()) then return end
        local damage = self.Primary.Damage
        local context = {
            damage = damage
        }

        local result = hook.Run("GetPlayerPunchDamage", self:GetOwner(), damage, context)
        damage = result ~= nil and result or context.damage
        self:GetOwner():LagCompensation(true)
        local startPos = self:GetOwner():GetShootPos()
        local endPos = startPos + self:GetOwner():GetAimVector() * 96
        local trace = util.TraceLine({
            start = startPos,
            endpos = endPos,
            filter = self:GetOwner()
        })

        if SERVER and trace.Hit and IsValid(trace.Entity) then
            local dmgInfo = DamageInfo()
            dmgInfo:SetAttacker(self:GetOwner())
            dmgInfo:SetInflictor(self)
            dmgInfo:SetDamage(damage)
            dmgInfo:SetDamageType(DMG_GENERIC)
            dmgInfo:SetDamagePosition(trace.HitPos)
            dmgInfo:SetDamageForce(self:GetOwner():GetAimVector() * 1024)
            trace.Entity:DispatchTraceAttack(dmgInfo, startPos, endPos)
            self:GetOwner():EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 80)
        end

        hook.Run("PlayerThrowPunch", self:GetOwner(), trace)
        self:GetOwner():LagCompensation(false)
    end)
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    local data = {}
    data.start = self:GetOwner():GetShootPos()
    data.endpos = data.start + self:GetOwner():GetAimVector() * 84
    data.filter = {self, self:GetOwner()}
    local trace = util.TraceLine(data)
    local entity = trace.Entity
    if CLIENT then
        local viewModel = self:GetOwner():GetViewModel()
        if IsValid(viewModel) then
            viewModel:SetPlaybackRate(0.5)
            self.NextAllowedPlayRateChange = CurTime() + viewModel:SequenceDuration() * 2
        end
    end

    if SERVER and IsValid(entity) then
        if entity:isDoor() then
            if hook.Run("CanPlayerKnock", self:GetOwner(), entity) == false then return end
            self:GetOwner():ViewPunch(self.KnockViewPunchAngle)
            self:GetOwner():EmitSound("physics/wood/wood_crate_impact_hard" .. math.random(2, 3) .. ".wav")
            self:GetOwner():SetAnimation(PLAYER_ATTACK1)
            self:DoPunchAnimation()
            self:SetNextSecondaryFire(CurTime() + 0.4)
            self:SetNextPrimaryFire(CurTime() + 1)
        elseif entity:IsPlayer() and lia.config.get("AllowPush", true) then
            local direction = self:GetOwner():GetAimVector() * 300
            direction.z = 0
            entity:SetVelocity(direction)
            self:GetOwner():EmitSound("Weapon_Crossbow.BoltHitBody")
            self:SetNextSecondaryFire(CurTime() + 1.5)
            self:SetNextPrimaryFire(CurTime() + 1.5)
        elseif not entity:IsNPC() and self:CanHoldObject(entity) then
            self:GetOwner():setLocalVar("IsHoldingObject", true)
            self:PickupObject(entity)
            self:PlayPickupSound(trace.SurfaceProps)
            self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
            self:SetHoldType("pistol")
        end
    end
end

function SWEP:Reload()
    if not IsFirstTimePredicted() then return end
    if SERVER and IsValid(self.heldEntity) then self:DropObject() end
end
