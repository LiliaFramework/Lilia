
function MODULE:SanitizeSteamID(sid)
    for _, character in ipairs(string.Explode("", sid, false)) do
        if not tonumber(character) then return false end
    end
    return sid
end


function MODULE:GenerateReport(steamID64)
    steamID64 = self:SanitizeSteamID(steamID64)
    if not steamID64 then return {} end
    local characters = {}
    local fields = "_id, _name, _desc, _model, _attribs, _data, _money, _faction"
    local condition = "_schema = '" .. lia.db.escape(SCHEMA.folder) .. "' AND _steamID = " .. steamID64
    lia.db.query("SELECT " .. fields .. " FROM lia_characters WHERE " .. condition, function(data)
        for _, v in ipairs(data or {}) do
            local id = tonumber(v._id)
            if id then
                characters[id] = {}
                local data = {}
                for k2, v2 in pairs(lia.character.vars) do
                    if v2.field and v[v2.field] then
                        local value = tostring(v[v2.field])
                        if type(v2.default) == "number" then
                            value = tonumber(value) or v2.default
                        elseif type(v2.default) == "boolean" then
                            value = tobool(value)
                        elseif type(v2.default) == "table" then
                            value = util.JSONToTable(value)
                        end

                        data[k2] = value
                    end
                end

                characters[id].data = data
                lia.db.query("SELECT _invID FROM lia_inventories WHERE _charID = " .. id, function(data)
                    if data and #data > 0 then
                        for _, y in pairs(data) do
                            characters[id].invID = y._invID
                        end
                    end
                end)

                lia.db.query("SELECT _uniqueID FROM lia_items WHERE _invID = " .. characters[id].invID, function(data)
                    if data and #data > 0 then
                        local items = {}
                        for _, y in pairs(data) do
                            items[#items + 1] = y._uniqueID
                        end

                        characters[id].inv = items
                    end
                end)
            end
        end
    end)
    return characters
end


function MODULE:SendReport(reportPly, receiver)
    netstream.Start(receiver, "liaReport", self:GenerateReport(reportPly:SteamID64()))
end

