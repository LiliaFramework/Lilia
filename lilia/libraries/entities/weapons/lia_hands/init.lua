AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function SWEP:Grab()
    local client = self:GetOwner()
    client:LagCompensation(true)
    local trace = client:GetEyeTraceNoCursor()
    local ent = trace.Entity
    local physObj = IsValid(ent) and ent:GetPhysicsObject() or NULL
    if self:CanPickup(ent, physObj) then
        client:PickupObject(ent)
        client.Grabbed = ent
    end

    client:LagCompensation(false)
    self.ReadyToPickup = false
end

function SWEP:SecondaryAttack()
    local client = self:GetOwner()
    if IsValid(client:GetParent()) then return end
    if IsValid(client.Grabbed) then
        client:DropObject(client.Grabbed)
        client.Grabbed = NULL
    else
        self.ReadyToPickup = true
    end
end
