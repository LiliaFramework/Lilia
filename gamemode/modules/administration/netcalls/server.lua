net.Receive("cfgSet", function(_, client)
    local key = net.ReadString()
    local name = net.ReadString()
    local value = net.ReadType()
    if type(lia.config.stored[key].default) == type(value) and hook.Run("CanPlayerModifyConfig", client, key) ~= false then
        local oldValue = lia.config.stored[key].value
        lia.config.set(key, value)
        hook.Run("ConfigChanged", key, value, oldValue, client)
        if istable(value) then
            local value2 = "["
            local count = table.Count(value)
            local i = 1
            for _, v in SortedPairs(value) do
                value2 = value2 .. v .. (i == count and "]" or ", ")
                i = i + 1
            end

            value = value2
        end

        client:notifyLocalized("cfgSet", client:Name(), name, tostring(value))
        lia.log.add(client, "configChange", name, tostring(oldValue), tostring(value))
    end
end)

net.Receive("lia_managesitrooms_action", function(_, client)
    if not client:hasPrivilege("Manage SitRooms") then return end
    local action = net.ReadUInt(2)
    local name = net.ReadString()
    local mapName = game.GetMap()
    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local baseCondition = "_folder = " .. lia.db.convertDataType(folder) .. " AND _map = " .. lia.db.convertDataType(mapName)
    if action == 1 then
        local condition = baseCondition .. " AND _name = " .. lia.db.convertDataType(name)
        lia.db.selectOne({"_pos"}, "sitrooms", condition):next(function(row)
            local targetPos = row and lia.data.decodeVector(row._pos)
            if targetPos then
                client:SetNW2Vector("previousSitroomPos", client:GetPos())
                client:SetPos(targetPos)
                client:notifyLocalized("sitroomTeleport", name)
                lia.log.add(client, "sendToSitRoom", client:Name(), name)
            end
        end)
    elseif action == 2 then
        local newName = net.ReadString()
        if newName ~= "" then
            local newCondition = baseCondition .. " AND _name = " .. lia.db.convertDataType(newName)
            lia.db.exists("sitrooms", newCondition):next(function(exists)
                if exists then return end
                local condition = baseCondition .. " AND _name = " .. lia.db.convertDataType(name)
                lia.db.updateTable({
                    _name = newName
                }, nil, "sitrooms", condition)

                client:notifyLocalized("sitroomRenamed")
                lia.log.add(client, "sitRoomRenamed", string.format("Map: %s | Old: %s | New: %s", mapName, name, newName), L("logRenamedSitroom"))
            end)
        end
    elseif action == 3 then
        local condition = baseCondition .. " AND _name = " .. lia.db.convertDataType(name)
        lia.db.updateTable({
            _pos = lia.data.serialize(client:GetPos())
        }, nil, "sitrooms", condition)

        client:notifyLocalized("sitroomRepositioned")
        lia.log.add(client, "sitRoomRepositioned", string.format("Map: %s | Name: %s | New Position: %s", mapName, name, tostring(client:GetPos())), L("logRepositionedSitroom"))
    end
end)
