util.AddNetworkString("net_ReceiveLogs")
util.AddNetworkString("net_RequestLogs")
local logs = {}

local function Init()
    if not file.Exists("netmessagelogsdir", "DATA") then
        file.CreateDir("netmessagelogsdir")
    end
end

Init()

local function loadLogs()
    local data = file.Read("netmessagelogs.txt")
    if not data then return end
    logs = util.JSONToTable(data)
end

local function saveLogs()
    local json = util.TableToJSON(logs)
    file.Write("netmessagelogs.txt", json)
end

loadLogs()

function net.Incoming(len, ply)
    local i = net.ReadHeader()
    local strName = util.NetworkIDToString(i)
    if not strName then return end
    local func = net.Receivers[strName:lower()]
    if not func then return end
    len = len - 16
    local debugInfo = debug.getinfo(func, "S")
    local timeString = os.date("%d/%m/%Y - %H:%M:%S", os.time())

    local logEntry = {
        ["time"] = timeString,
        ["name"] = strName,
        ["ply"] = ply:Nick(),
        ["steamID"] = ply:SteamID(),
        ["len"] = len,
        ["source"] = debugInfo.short_src .. " @ Line " .. debugInfo.linedefined,
        ["ip"] = ply:IPAddress()
    }

    --Empty the logs table and save the logs to file
    if #logs >= 5000 then
        local files = file.Find("netmessagelogsdir/*.txt", "DATA", "dateasc")
        local count = #files + 1

        if count > 50 then
            file.Delete("netmessagelogsdir/" .. files[1])
        end

        file.Write("netmessagelogsdir/" .. os.date("%d-%m-%Y_%H-%M-%S", os.time()) .. "_netmessagelogs.txt", util.TableToJSON(logs))
        logs = {}
    end

    table.insert(logs, 1, logEntry)
    func(len, ply)
end

hook.Add("ShutDown", "SaveNetMessageLogs", saveLogs)

local function sendData(page, ply)
    if not ply:IsSuperAdmin() then return end
    local dataTable = {}
    local start = ((page - 1) * 128) + 1
    local finish = math.min(start + 127, #logs)

    for i = start, finish do
        table.insert(dataTable, logs[i])
    end

    local data = util.TableToJSON(dataTable)
    data = util.Compress(data)
    net.Start("net_ReceiveLogs")
    net.WriteUInt(#data, 32)
    net.WriteData(data, #data)
    net.WriteInt(math.ceil(#logs / 128), 32)
    net.Send(ply)
end

net.Receive("net_RequestLogs", function(len, ply)
    local page = net.ReadInt(32)
    sendData(page, ply)
end)