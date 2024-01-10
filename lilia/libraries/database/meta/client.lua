local playerMeta = FindMetaTable("Player")
function playerMeta:getLiliaData(key, default)
    local data = lia.localData and lia.localData[key]
    if data == nil then
        return default
    else
        return data
    end
end
