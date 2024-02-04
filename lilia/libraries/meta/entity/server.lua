---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local entityMeta = FindMetaTable("Entity")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:isDoor()
    local class = self:GetClass():lower()
    local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_",}
    for _, prefix in ipairs(doorPrefixes) do
        if class:find(prefix) then return true end
    end
    return false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:getDoorPartner()
    return self.liaPartner
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:isLocked()
    if self:IsVehicle() then
        local datatable = self:GetSaveTable()
        if datatable then return datatable.VehicleLocked end
    else
        local datatable = self:GetSaveTable()
        if datatable then return datatable.m_bLocked end
    end
    return
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:sendNetVar(key, receiver)
    netstream.Start(receiver, "nVar", self:EntIndex(), key, lia.net[self] and lia.net[self][key])
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:AssignCreator(client)
    self:SetCreator(client)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:clearNetVars(receiver)
    lia.net[self] = nil
    netstream.Start(receiver, "nDel", self:EntIndex())
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:setNetVar(key, value, receiver)
    if checkBadType(key, value) then return end
    lia.net[self] = lia.net[self] or {}
    if lia.net[self][key] ~= value then lia.net[self][key] = value end
    self:sendNetVar(key, receiver)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:getNetVar(key, default)
    if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end
    return default
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
FindMetaTable("Player").getLocalVar = entityMeta.getNetVar
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
