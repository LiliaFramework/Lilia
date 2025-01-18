local MODULE = MODULE
lia.command.add("logs", {
  privilege = "See Logs",
  adminOnly = true,
  onRun = function(client)
    local categorizedLogs = {}
    for _, logData in pairs(lia.log.types) do
      local category = logData.category
      if not categorizedLogs[category] then categorizedLogs[category] = {} end
      local logs = MODULE:ReadLogFiles(category, 200)
      for _, log in ipairs(logs) do
        table.insert(categorizedLogs[category], log)
      end
    end

    local jsonData = util.TableToJSON(categorizedLogs)
    local compressedData = util.Compress(jsonData)
    net.Start("send_logs")
    net.WriteUInt(#compressedData, 32)
    net.WriteData(compressedData, #compressedData)
    net.Send(client)
  end
})
