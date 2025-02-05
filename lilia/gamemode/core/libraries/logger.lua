lia.log = lia.log or {}
lia.log.types = lia.log.types or {}
if SERVER then
    function lia.log.loadTables()
        file.CreateDir("lilia/logs/" .. engine.ActiveGamemode())
    end

    function lia.log.addType(logType, func, category)
        lia.log.types[logType] = {
            func = func,
            category = category,
        }
    end

    function lia.log.getString(client, logType, ...)
        local logData = lia.log.types[logType]
        if logData and isfunction(logData.func) then
            local success, result = pcall(logData.func, client, ...)
            if success then return result, logData.category, logData.color end
        end
    end

    function lia.log.add(client, logType, ...)
        local logString, category, color = lia.log.getString(client, logType, ...)
        if not isstring(category) then
            category = "Uncategorized"
            color = Color(128, 128, 128)
        end

        if not isstring(logString) or not IsColor(color) then return end
        hook.Run("OnServerLog", client, logType, logString, category, color)
        if not file.Exists("lilia/logs/" .. engine.ActiveGamemode(), "DATA") then file.CreateDir("lilia/logs/" .. engine.ActiveGamemode()) end
        local logFilePath = "lilia/logs/" .. engine.ActiveGamemode() .. "/" .. category .. ".txt"
        file.Append(logFilePath, "[" .. os.date("%Y-%m-%d %H:%M:%S") .. "]\t" .. logString .. "\r\n")
    end

    function lia.log.send(client, logString)
        netstream.Start(client, "liaLogStream", logString)
    end
else
    netstream.Hook("liaLogStream", function(logString) LiliaInformation(logString) end)
end
