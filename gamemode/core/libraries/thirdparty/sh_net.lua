local NetworkStringToIDCache = {}
local function NetworkStringToID(str)
    local id = NetworkStringToIDCache[str]
    if id then return id end
    id = util.NetworkStringToID(str)
    if SERVER and id == 0 then id = util.AddNetworkString(str) end
    if id ~= 0 then
        NetworkStringToIDCache[str] = id
        return id
    end
end

local NetReceiverByID = {}
function net.Receive(name, func)
    local id = NetworkStringToID(name)
    if id then NetReceiverByID[id] = func end
    net.Receivers[name:lower()] = func
end

function net.Incoming(len, client)
    local i = net.ReadHeader()
    local func = NetReceiverByID[i]
    if not func then
        local str = util.NetworkIDToString(i)
        if not str then return end
        func = net.Receivers[str:lower()]
        if not func then return end
        NetReceiverByID[i] = func
    end

    func(len - 16, client)
end

if SERVER then
    local BaseNetStart = net.Start
    function net.Start(messageName, unreliable)
        NetworkStringToID(messageName)
        return BaseNetStart(messageName, unreliable)
    end
end