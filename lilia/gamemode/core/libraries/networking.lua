lia.net = lia.net or {}
lia.net.globals = lia.net.globals or {}
local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
if SERVER then
    function checkBadType(name, object)
        if isfunction(object) then
            ErrorNoHalt("Net var '" .. name .. "' contains a bad object type!")
            return true
        elseif istable(object) then
            for k, v in pairs(object) do
                if checkBadType(name, k) or checkBadType(name, v) then return true end
            end
        end
    end

    function setNetVar(key, value, receiver)
        if checkBadType(key, value) then return end
        if getNetVar(key) == value then return end
        lia.net.globals[key] = value
        netstream.Start(receiver, "gVar", key, value)
    end

    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    hook.Add("EntityRemoved", "nCleanUp", function(entity) entity:clearNetVars() end)
    hook.Add("PlayerInitialSpawn", "nSync", function(client) client:syncVars() end)
    hook.Add("CharDeleted", "liaCharRemoveName", function(client, character)
        lia.char.names[character:getID()] = nil
        netstream.Start(client, "liaCharFetchNames", lia.char.names)
    end)

    hook.Add("OnCharCreated", "liaCharAddName", function(client, character, data)
        lia.char.names[character:getID()] = data.name
        netstream.Start(client, "liaCharFetchNames", lia.char.names)
    end)
else
    function getNetVar(key, default)
        local value = lia.net.globals[key]
        return value ~= nil and value or default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
end

function net.WriteBigTable(tbl)
    local jsonData = util.TableToJSON(tbl)
    local compressedData = util.Compress(jsonData)
    local totalLen = #compressedData
    local numChunks = math.ceil(totalLen / 60000)
    net.WriteUInt(numChunks, 16)
    for i = 1, numChunks do
        local startPos = (i - 1) * 60000 + 1
        local chunk = string.sub(compressedData, startPos, startPos + 60000 - 1)
        net.WriteUInt(#chunk, 16)
        net.WriteData(chunk, #chunk)
    end
end

function net.ReadBigTable()
    local numChunks = net.ReadUInt(16)
    local compressedData = ""
    for i = 1, numChunks do
        local chunkLen = net.ReadUInt(16)
        compressedData = compressedData .. net.ReadData(chunkLen)
    end

    local jsonData = util.Decompress(compressedData)
    if not jsonData then return nil, "Decompression failed" end
    local tbl = util.JSONToTable(jsonData)
    if not tbl then return nil, "JSON parsing failed" end
    return tbl
end