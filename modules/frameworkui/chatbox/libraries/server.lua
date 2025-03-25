function MODULE:SaveData()
    self:setData(self.OOCBans)
end

function MODULE:LoadData()
    self.OOCBans = self:getData()
end

function MODULE:InitializedModules()
    SetGlobalBool("oocblocked", false)
end
