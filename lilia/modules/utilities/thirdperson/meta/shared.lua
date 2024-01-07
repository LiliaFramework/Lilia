--------------------------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
--------------------------------------------------------------------------------------------------------------------------
function playerMeta:CanOverrideView()
    local ragdoll = Entity(self:getLocalVar("ragdoll", 0))
    if IsValid(lia.gui.char) and lia.gui.char:IsVisible() then return false end
    return ThirdPerson:GetBool() and not IsValid(self:GetVehicle()) and self.ThirdPersonEnabled and IsValid(self) and self:getChar() and not IsValid(ragdoll) and LocalPlayer():Alive()
end
--------------------------------------------------------------------------------------------------------------------------
