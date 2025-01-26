local MODULE = MODULE
lia.command.add("logs", {
    privilege = "See Logs",
    adminOnly = true,
    onRun = function(client)
        local categorizedLogs = {}
        for _, logData in pairs(lia.log.types) do
            local category = logData.category
            if not categorizedLogs[category] then categorizedLogs[category] = {} end
            local logs = MODULE:ReadLogFiles(category, 1000)
            for _, log in ipairs(logs) do
                table.insert(categorizedLogs[category], log)
            end
        end

        local jsonData = util.TableToJSON(categorizedLogs)
        local compressedData = util.Compress(jsonData)
        print("[Logs Command] Data size (compressed): " .. #compressedData .. " bytes")
        print("[Logs Command] Garry's Mod limit: 65536 bytes (64 KB)")
        if #compressedData > 65536 then
            print("[Logs Command] WARNING: Data size exceeds GMod's 64 KB limit. Consider reducing the log limit.")
            return
        end

        net.Start("send_logs")
        net.WriteUInt(#compressedData, 32)
        net.WriteData(compressedData, #compressedData)
        net.Send(client)
    end
})