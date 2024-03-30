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
-- @param func format callback function(client, ...)
-- @param category Log category
-- @param color Log color (optional, defaults to Color(52, 152, 219))
-- @usage function(client, ...) log format callback
function lia.log.addType(logType, func, category, color)
    color = color or Color(52, 152, 219)
    lia.log.types[logType] = {
        func = func,
        category = category,
        color = color
    }
end

function lia.log.getString(client, logType, ...)
    local logData = lia.log.types[logType]
    if isfunction(logData.func) then
        local success, result = pcall(logData.func, client, ...)
        if success then return result, logData.category, logData.color end
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
    local logString, category, color = lia.log.getString(client, logType, ...)
    if not isstring(logString) or not isstring(category) or not IsColor(color) then return end
    hook.Run("OnServerLog", client, logType, logString, category, color)
    Msg("[LOG] ", logString .. "\n")
    if noSave then return end
    file.Append("lilia/logs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. logString .. "\r\n")
end

function lia.log.send(client, logString, flag)
    netstream.Start(client, "liaLogStream", logString, flag)
end