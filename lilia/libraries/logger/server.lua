lia.log.types = lia.log.types or {}
function lia.log.loadTables()
    file.CreateDir("lilia/logs")
end

function lia.log.resetTables()
end

function lia.log.addType(logType, func)
    lia.log.types[logType] = func
end

function lia.log.getString(client, logType, _)
    local text = lia.log.types[logType]
    if isfunction(text) then
        local success, result = pcall(text, client, _)
        if success then return result end
    end
end

function lia.log.addRaw(logString, shouldNotify, flag)
    if shouldNotify then lia.log.send(lia.util.getAdmins(), logString, flag) end
    Msg("[LOG] ", logString .. "\n")
    if not noSave then file.Append("lilia/logs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. logString .. "\r\n") end
end

function lia.log.add(client, logType, _)
    local logString = lia.log.getString(client, logType, _)
    if not isstring(logString) then return end
    hook.Run("OnServerLog", client, logType, logString, _)
    Msg("[LOG] ", logString .. "\n")
    if noSave then return end
    file.Append("lilia/logs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. logString .. "\r\n")
end

function lia.log.open(client)
    local logData = {}
    netstream.Hook(client, "liaLogView", logData)
end

function lia.log.send(client, logString, flag)
    netstream.Start(client, "liaLogStream", logString, flag)
end
