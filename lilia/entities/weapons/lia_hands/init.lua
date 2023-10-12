--------------------------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------------------------
local ent_diff = vector_origin
local ent_diff_time = CurTime()
local stand_time = 0
--------------------------------------------------------------------------------------------------------------------------
function SWEP:Think()
    if not self:checkValidity() then return end
    local curTime = CurTime()
    if curTime > ent_diff_time then
        ent_diff = self:GetPos() - self.holdingEntity:GetPos()
        if ent_diff:Dot(ent_diff) > 40000 then
            self:reset()

            return
        end

        ent_diff_time = curTime + 1
    end

    if curTime > stand_time then
        if self:isPlayerStandsOn(self.holdingEntity) then
            self:reset()

            return
        end

        stand_time = curTime + 0.1
    end

    local owner = self:GetOwner()
    local obb = math.abs(self.holdingEntity:GetModelBounds():Length2D())
    self.carryHack:SetPos(owner:EyePos() + owner:GetAimVector() * (35 + obb))
    local targetAng = owner:GetAngles()
    if self.carryHack.preferedAngle then
        targetAng.p = 0
    end

    self.carryHack:SetAngles(targetAng)
    self.holdingEntity:PhysWake()
end
--------------------------------------------------------------------------------------------------------------------------