--------------------------------------------------------------------------------------------------------------------------
local entityMeta = FindMetaTable("Entity")
--------------------------------------------------------------------------------------------------------------------------
function entityMeta:removeDoorAccessData()
    if IsValid(self) then
        for k, v in pairs(self.liaAccess or {}) do
            netstream.Start(k, "doorMenu")
        end

        self.liaAccess = {}
        self:SetDTEntity(0, nil)
    end
end
--------------------------------------------------------------------------------------------------------------------------