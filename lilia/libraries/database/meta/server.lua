
local playerMeta = FindMetaTable("Player")

function playerMeta:loadLiliaData(callback)
    local name = self:steamName()
    local steamID64 = self:SteamID64()
    local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
    lia.db.query("SELECT _data, _firstJoin, _lastJoin FROM lia_players WHERE _steamID = " .. steamID64, function(data)
        if IsValid(self) and data and data[1] and data[1]._data then
            lia.db.updateTable({
                _lastJoin = timeStamp,
            }, nil, "players", "_steamID = " .. steamID64)

            self.firstJoin = data[1]._firstJoin or timeStamp
            self.lastJoin = data[1]._lastJoin or timeStamp
            self.liaData = util.JSONToTable(data[1]._data)
            if callback then callback(self.liaData) end
        else
            lia.db.insertTable({
                _steamID = steamID64,
                _steamName = name,
                _firstJoin = timeStamp,
                _lastJoin = timeStamp,
                _data = {}
            }, nil, "players")

            if callback then callback({}) end
        end
    end)
end


function playerMeta:saveLiliaData()
    local name = self:steamName()
    local steamID64 = self:SteamID64()
    local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
    lia.db.updateTable({
        _steamName = name,
        _lastJoin = timeStamp,
        _data = self.liaData
    }, nil, "players", "_steamID = " .. steamID64)
end


function playerMeta:setLiliaData(key, value, noNetworking)
    self.liaData = self.liaData or {}
    self.liaData[key] = value
    if not noNetworking then netstream.Start(self, "liaData", key, value) end
end


function playerMeta:getLiliaData(key, default)
    if key == true then return self.liaData end
    local data = self.liaData and self.liaData[key]
    if data == nil then
        return default
    else
        return data
    end
end

