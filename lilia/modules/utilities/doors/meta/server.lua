﻿local entityMeta = FindMetaTable("Entity")
function entityMeta:removeDoorAccessData()
    if IsValid(self) then
        for k, _ in pairs(self.liaAccess or {}) do
            netstream.Start(k, "doorMenu")
        end

        self.liaAccess = {}
        self:SetDTEntity(0, nil)
    end
end

function entityMeta:SetLocked(state)
    self.isLocked = state
end
