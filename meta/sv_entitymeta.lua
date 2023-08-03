--------------------------------------------------------------------------------------------------------
local entityMeta = FindMetaTable("Entity")
--------------------------------------------------------------------------------------------------------
function entityMeta:isDoor()
    return self:GetClass():find("door")
end
--------------------------------------------------------------------------------------------------------
function entityMeta:getDoorPartner()
    return self.liaPartner
end
--------------------------------------------------------------------------------------------------------
function entityMeta:isLocked()
    if self:IsVehicle() then
        local datatable = self:GetSaveTable()
        if datatable then
            return datatable.VehicleLocked
        end
    else
        local datatable = self:GetSaveTable()
        if datatable then
            return datatable.m_bLocked
        end
    end

    return
end
--------------------------------------------------------------------------------------------------------