
lia.data = lia.data or {}

lia.data.stored = lia.data.stored or {}
--
function lia.data.get(key, default, global, ignoreMap, refresh)
    if not refresh then
        local stored = lia.data.stored[key]
        if stored ~= nil then return stored end
    end

    local folder = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local path = "lilia/" .. (global and "" or folder .. "/") .. (ignoreMap and "" or game.GetMap() .. "/")
    local contents = file.Read(path .. key .. ".txt", "DATA")
    if contents and contents ~= "" then
        local status, decoded = pcall(pon.decode, contents)
        if status and decoded then
            local value = decoded[1]
            lia.data.stored[key] = value
            if value ~= nil then
                return value
            else
                return default
            end
        else
            return default
        end
    else
        return default
    end
end
---------
