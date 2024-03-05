
local MODULE = MODULE

util.AddNetworkString("liaDrawLogs")

util.AddNetworkString("liaRequestLogsClient")

util.AddNetworkString("liaRequestLogsServer")

net.Receive("liaRequestLogsServer", function(_, client)
    if not CAMI.PlayerHasAccess(client, "Commands - View Logs", nil) then
        client:notify(":|")
        return
    end

    local logtype = net.ReadString()
    local selectedDate = net.ReadString()
    local logs = MODULE:ReadLogsFromFile(logtype, selectedDate)
    net.Start("liaDrawLogs")
    net.WriteTable(logs)
    net.Send(client)
end)

