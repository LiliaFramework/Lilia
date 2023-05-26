local PLUGIN = PLUGIN

function PLUGIN:SaveData()
    self:setData(self.oocBans)
end

function PLUGIN:LoadData()
    self.oocBans = self:getData()
end

function PLUGIN:InitializedPlugins()
    SetGlobalBool("oocblocked", false)
end