--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")

--------------------------------------------------------------------------------------------------------
function playerMeta:getLiliaData(key, default)
    local data = lia.localData and lia.localData[key]

    if data == nil then
        return default
    else
        return data
    end
end

--------------------------------------------------------------------------------------------------------+
function playerMeta:CanOverrideView()
    local ragdoll = Entity(self:getLocalVar("ragdoll", 0))
    if IsValid(lia.gui.char) and lia.gui.char:IsVisible() then return false end

    return CreateClientConVar("lia_tp_enabled", "0", true):GetBool() and not IsValid(self:GetVehicle()) and IsValid(self) and self:getChar() and not self:getNetVar("actAng") and not IsValid(ragdoll) and LocalPlayer():Alive()
end
--------------------------------------------------------------------------------------------------------+