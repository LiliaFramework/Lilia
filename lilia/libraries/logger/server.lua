--[[--
Logging helper functions.

Predefined flags:
	FLAG_NORMAL
	FLAG_SUCCESS
	FLAG_WARNING
	FLAG_DANGER
	FLAG_SERVER
	FLAG_DEV
]]
-- @module lia.log
function lia.log.loadTables()
    file.CreateDir("lilia/logs")
    file.CreateDir("lilia/netlogs")
    file.CreateDir("lilia/concommandlogs")
end

function lia.log.resetTables()
end

--- Adds a log type.
-- @realm server
-- @string logType Log category
-- @function (client, ...) log format callback
function lia.log.addType(logType, func)
    lia.log.types[logType] = func
end

function lia.log.getString(client, logType, ...)
    local text = lia.log.types[logType]
    if isfunction(text) then
        local success, result = pcall(text, client, ...)
        if success then return result end
    end
end

function lia.log.addRaw(logString, shouldNotify, flag)
    if shouldNotify then lia.log.send(lia.util.getAdmins(), logString, flag) end
    Msg("[LOG] ", logString .. "\n")
    if not noSave then file.Append("lilia/logs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. logString .. "\r\n") end
end

--- Add a log message.
-- @realm server
-- @player client Player who instigated the log
-- @string logType Log category
-- @param ... Arguments to pass to the log
function lia.log.add(client, logType, ...)
    local logString = lia.log.getString(client, logType, ...)
    if not isstring(logString) then return end
    if mLogs then lia.log.mLogsLoad(logString) end
    hook.Run("OnServerLog", client, logType, ...)
    Msg("[LOG] ", logString .. "\n")
    if noSave then return end
    file.Append("lilia/logs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. logString .. "\r\n")
end

function lia.log.send(client, logString, flag)
    netstream.Start(client, "liaLogStream", logString, flag)
end

function lia.log.mLogsLoad(str)
    mLogs.log("LiliaLog", "lia", {
        log = str
    })
end
