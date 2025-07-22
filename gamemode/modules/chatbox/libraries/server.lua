local TABLE = "chatbox"
local function buildCondition(folder, map)
    return "_schema = " .. lia.db.convertDataType(folder) .. " AND _map = " .. lia.db.convertDataType(map)
end

function MODULE:SaveData()
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    lia.db.upsert({
        _schema = folder,
        _map = map,
        _data = lia.data.serialize({
            bans = self.OOCBans
        })
    }, TABLE)
end

function MODULE:LoadData()
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local map = game.GetMap()
    local condition = buildCondition(folder, map)
    lia.db.selectOne({"_data"}, TABLE, condition):next(function(res)
        local data = res and lia.data.deserialize(res._data) or {}
        self.OOCBans = {}
        if istable(data) and istable(data.bans) then
            if data.bans[1] then
                self.OOCBans = data.bans
            else
                for id, banned in pairs(data.bans) do
                    if banned then table.insert(self.OOCBans, id) end
                end
            end
        end
    end)
end

function MODULE:InitializedModules()
    SetGlobalBool("oocblocked", false)
end
