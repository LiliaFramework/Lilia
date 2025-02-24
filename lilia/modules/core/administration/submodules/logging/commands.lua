local MODULE = MODULE
local function sendLogsInChunks(client, categorizedLogs)
    local jsonData = util.TableToJSON(categorizedLogs)
    local compressedData = util.Compress(jsonData)
    local totalLen = #compressedData
    local chunkSize = 60000
    local numChunks = math.ceil(totalLen / chunkSize)
    for i = 1, numChunks do
        local startPos = (i - 1) * chunkSize + 1
        local chunk = string.sub(compressedData, startPos, startPos + chunkSize - 1)
        net.Start("send_logs_chunk")
        net.WriteUInt(i, 16)
        net.WriteUInt(numChunks, 16)
        net.WriteUInt(#chunk, 16)
        net.WriteData(chunk, #chunk)
        net.Send(client)
    end
end

lia.command.add("logs", {
    privilege = "See Logs",
    adminOnly = true,
    onRun = function(client)
        local categorizedLogs = {}
        for _, logData in pairs(lia.log.types) do
            local category = logData.category or "Uncategorized"
            if not categorizedLogs[category] then categorizedLogs[category] = {} end
            local logs = MODULE:ReadLogFiles(category)
            for _, log in ipairs(logs) do
                table.insert(categorizedLogs[category], log)
            end
        end

        sendLogsInChunks(client, categorizedLogs)
    end
})
