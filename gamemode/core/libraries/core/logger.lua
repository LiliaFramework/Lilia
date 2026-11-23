lia.log = lia.log or {}
lia.log.types = lia.log.types or {}
function lia.log.getString(client, logType, ...)
    local logData = lia.log.types[logType]
    if not logData then return end
    if isfunction(logData.func) then
        local success, result = pcall(logData.func, client, ...)
        if success then return result, logData.category end
    end
end

function lia.log.addType(logType, func, category)
    lia.log.types[logType] = {
        func = func,
        category = category,
    }
end

function lia.log.add(client, logType, ...)
    local logString, category = lia.log.getString(client, logType, ...)
    if not isstring(category) then category = "Uncategorized" end
    if not isstring(logString) then return end
    hook.Run("OnServerLog", client, logType, logString, category)
    MsgC(Color(83, 143, 239), "[LOG] ")
    MsgC(Color(0, 255, 0), "[" .. "Category(" .. "): " .. tostring(category) .. "] ")
    MsgC(Color(255, 255, 255), tostring(logString) .. "\n")
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local charID
    local steamID
    if IsValid(client) then
        local char = client:getChar()
        charID = char and char:getID() or nil
        steamID = client:SteamID()
    end

    lia.db.insertTable({
        timestamp = timestamp,
        gamemode = engine.ActiveGamemode(),
        category = category,
        message = logString,
        charID = charID,
        steamID = steamID
    }, nil, "logs")
end