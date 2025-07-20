function MODULE:SaveData()
    self:setData({
        bans = self.OOCBans
    })
end

function MODULE:LoadData()
    local data = self:getData()
    self.OOCBans = {}

    if istable(data) and istable(data.bans) then
        -- convert old key/value format into a sequential list
        if data.bans[1] then
            self.OOCBans = data.bans
        else
            for id, banned in pairs(data.bans) do
                if banned then
                    table.insert(self.OOCBans, id)
                end
            end
        end
    end
end

function MODULE:InitializedModules()
    SetGlobalBool("oocblocked", false)
end