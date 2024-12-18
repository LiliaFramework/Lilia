--- Logging helper functions.
-- @library lia.log
lia.log = lia.log or {}
lia.log.types = lia.log.types or {}
if SERVER then
    --- Creates directories for storing logs.
    -- @realm server
    -- @internal
    function lia.log.loadTables()
        file.CreateDir("lilia/logs")
    end

    --- Adds a log type.
    -- @realm server
    -- @string logType Log category
    -- @func func format callback function(client, ...)
    -- @string category Log category
    -- @color[opt] color Log color
    -- @usage function(client, ...) log format callback
    function lia.log.addType(logType, func, category, color)
        color = color or Color(52, 152, 219)
        lia.log.types[logType] = {
            func = func,
            category = category,
            color = color,
        }
    end

    --- Retrieves a formatted log string based on the specified log type and additional arguments.
    -- @client client The client for which the log is generated
    -- @string logType The type of log to generate
    -- @argGroup ... Additional arguments to be passed to the log generation function
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
    -- @string[opt] flag The flag associated with the log
    -- @realm server
    function lia.log.addRaw(logString)
        Msg("[LOG] ", logString .. "\n")
        local logType = "Raw"
        local logDir = "lilia/logs" .. logType
        if not file.Exists(logDir, "DATA") then file.CreateDir(logDir) end
        local logFilePath = logDir .. "/" .. os.date("%x"):gsub("/", "-") .. ".txt"
        lia.log.send(lia.util.getAdmins(), logString, flag)
        file.Append(logFilePath, "[" .. os.date("%X") .. "]\t" .. logString .. "\r\n")
    end

    --- Add a log message.
    -- @realm server
    -- @client client Player who instigated the log
    -- @string logType Log category
    -- @argGroup ... Arguments to pass to the log
    function lia.log.add(client, logType, ...)
        local logString, category, color = lia.log.getString(client, logType, ...)
        if not isstring(category) then
            category = "Uncategorized"
            color = Color(128, 128, 128)
        end

        if not isstring(logString) or not IsColor(color) then return end
        hook.Run("OnServerLog", client, logType, logString, category, color)
        local logDir = "lilia/logs/" .. category
        if not file.Exists(logDir, "DATA") then file.CreateDir(logDir) end
        local logFilePath = logDir .. "/" .. os.date("%Y-%m-%d") .. ".txt"
        file.Append(logFilePath, "[" .. os.date("%H:%M:%S") .. "]\t" .. logString .. "\r\n")
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
    netstream.Hook("liaLogStream", function(logString) LiliaInformation(logString) end)
end