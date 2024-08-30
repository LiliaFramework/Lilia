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
-- @library lia.log
lia.log = lia.log or {}
lia.log.types = lia.log.types or {}
FLAG_NORMAL = 0
FLAG_SUCCESS = 1
FLAG_WARNING = 2
FLAG_DANGER = 3
FLAG_SERVER = 4
FLAG_DEV = 5
lia.log.color = {
    [FLAG_NORMAL] = Color(200, 200, 200),
    [FLAG_SUCCESS] = Color(50, 200, 50),
    [FLAG_WARNING] = Color(255, 255, 0),
    [FLAG_DANGER] = Color(255, 50, 50),
    [FLAG_SERVER] = Color(200, 200, 220),
    [FLAG_DEV] = Color(200, 200, 220),
}

if SERVER then
    --- Creates directories for storing logs.
    -- @realm server
    -- @internal
    function lia.log.loadTables()
        sql.Query("CREATE TABLE IF NOT EXISTS lilia_logs ( id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT NOT NULL, log TEXT NOT NULL, time INTEGER NOT NULL )")
        file.CreateDir("lilia/logs")
    end

    --- Adds a log type.
    -- @realm server
    -- @string logType Log category
    -- @func func format callback function(client, ...)
    -- @string category Log category
    -- @color[opt] color Log color
    -- @string PLogs PLogs PLogs compatibility category
    -- @usage function(client, ...) log format callback
    function lia.log.addType(logType, func, category, color, PLogs)
        color = color or Color(52, 152, 219)
        lia.log.types[logType] = {
            func = func,
            category = category,
            color = color,
            PLogs = PLogs or category
        }
    end

    --- Retrieves a formatted log string based on the specified log type and additional arguments.
    -- @client client The client for which the log is generated
    -- @string logType The type of log to generate
    -- @param ... Additional arguments to be passed to the log generation function
    -- @return The formatted log string, its category, and color
    -- @realm server
    -- @internal
    function lia.log.getString(client, logType, ...)
        local logData = lia.log.types[logType]
        if logData and isfunction(logData.func) then
            local success, result = pcall(logData.func, client, ...)
            if success then return result, logData.category, logData.color end
        end
    end

    --- Adds a raw log string to the log system and optionally notifies admins.
    -- @string logString The raw log string to add
    -- @bool shouldNotify Whether to notify admins about this log (default: false)
    -- @string[opt] flag The flag associated with the log
    -- @realm server
    function lia.log.addRaw(logString, shouldNotify, flag)
        if shouldNotify then lia.log.send(lia.util.getAdmins(), logString, flag) end
        Msg("[LOG] ", logString .. "\n")
        if not noSave then file.Append("lilia/logs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. logString .. "\r\n") end
    end

    --- Add a log message.
    -- @realm server
    -- @client client Player who instigated the log
    -- @string logType Log category
    -- @param ... Arguments to pass to the log
    function lia.log.add(client, logType, ...)
        local logString, category, color = lia.log.getString(client, logType, ...)
        if not isstring(logString) or not isstring(category) or not IsColor(color) then return end
        hook.Run("OnServerLog", client, logType, logString, category, color)
        if not noSave then file.Append("lilia/logs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. logString .. "\r\n") end
    end

    --- Sends a log message to a specified client.
    -- @client client The client to whom the log message will be sent.
    -- @string logString The log message to be sent.
    -- @string[opt] flag A flag associated with the log message.
    -- @realm server
    -- @internal
    function lia.log.send(client, logString, flag)
        netstream.Start(client, "liaLogStream", logString, flag)
    end
else
    netstream.Hook("liaLogStream", function(logString, flag) MsgC(Color(50, 200, 50), "[SERVER] ", lia.log.color[flag] or color_white, tostring(logString) .. "\n") end)
end
