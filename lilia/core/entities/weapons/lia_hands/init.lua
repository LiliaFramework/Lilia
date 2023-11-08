--------------------------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------------------------
function SWEP:Grab()
    local ply = self:GetOwner()
    ply:LagCompensation(true)
    local trace = ply:GetEyeTraceNoCursor()
    local ent = trace.Entity
    local physObj = IsValid(ent) and ent:GetPhysicsObject() or NULL
    if self:CanPickup(ent, physObj) then
        ply:PickupObject(ent)
        ply.Grabbed = ent
    end

    ply:LagCompensation(false)
    self.ReadyToPickup = false
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:SecondaryAttack()
    local ply = self:GetOwner()
    if IsValid(ply:GetParent()) then return end
    if IsValid(ply.Grabbed) then
        ply:DropObject(ply.Grabbed)
        ply.Grabbed = NULL
    else
        self.ReadyToPickup = true
    end
end
--------------------------------------------------------------------------------------------------------------------------
