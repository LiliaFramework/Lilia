--- The Player Meta for the Third Person Module.
-- @playermeta ThirdPerson
local playerMeta = FindMetaTable("Player")

--- Checks if a player can override the view to third-person.
-- This function checks various conditions to determine if the player can switch to a third-person view.
-- @realm shared
-- @treturn boolean True if the player can override the view to third-person, false otherwise.
function playerMeta:CanOverrideView()
    local ragdoll = Entity(self:getLocalVar("ragdoll", 0))
    local isInVehicle = self:hasValidVehicle()
    if IsValid(lia.gui.char) then return false end
    if isInVehicle then return false end
    if not F1MenuCore.F1ThirdPersonEnabled and IsValid(lia.gui.menu) then return false end
    if hook.Run("ShouldDisableThirdperson", self) == true then return false end
    return ThirdPerson:GetBool() and ThirdPersonCore.ThirdPersonEnabled and (IsValid(self) and self:getChar() and not IsValid(ragdoll))
end