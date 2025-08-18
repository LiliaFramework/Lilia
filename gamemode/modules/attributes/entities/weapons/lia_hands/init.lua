AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function SWEP:Holster()
    if not IsFirstTimePredicted() then return end
    self:DropObject()
    return true
end

function SWEP:OnRemove()
    self:DropObject()
end

function SWEP:OwnerChanged()
    self:DropObject()
end