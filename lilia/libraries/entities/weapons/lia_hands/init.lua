
AddCSLuaFile("cl_init.lua")

AddCSLuaFile("shared.lua")

include("shared.lua")

function SWEP:Grab()
    local client = self:GetOwner()
    client:LagCompensation(true)
    local trace = client:GetEyeTraceNoCursor()
    local entity = trace.Entity
    local physObj = IsValid(entity) and entity:GetPhysicsObject() or NULL
    if self:CanPickup(entity, physObj) then
        client:PickupObject(entity)
        client.Grabbed = entity
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

