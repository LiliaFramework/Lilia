--------------------------------------------------------------------------------------------------------
net.Receive("liaNotifyL", function()
    local message = net.ReadString()
    local length = net.ReadUInt(8)
    if length == 0 then return lia.util.notifyLocalized(message) end
    local args = {}

    for i = 1, length do
        args[i] = net.ReadString()
    end

    lia.util.notifyLocalized(message, unpack(args))
end)
--------------------------------------------------------------------------------------------------------
net.Receive("liaStringReq", function()
    local id = net.ReadUInt(32)
    local title = net.ReadString()
    local subTitle = net.ReadString()
    local default = net.ReadString()

    if title:sub(1, 1) == "@" then
        title = L(title:sub(2))
    end

    if subTitle:sub(1, 1) == "@" then
        subTitle = L(subTitle:sub(2))
    end

    Derma_StringRequest(title, subTitle, default, function(text)
        net.Start("liaStringReq")
        net.WriteUInt(id, 32)
        net.WriteString(text)
        net.SendToServer()
    end)
end)
--------------------------------------------------------------------------------------------------------
net.Receive("liaNotify", function()
    local message = net.ReadString()

    lia.util.notify(message)
end)
--------------------------------------------------------------------------------------------------------
netstream.Hook("liaSyncGesture", function(entity, a, b, c)
    if IsValid(entity) then
        entity:AnimRestartGesture(a, b, c)
    end
end)
--------------------------------------------------------------------------------------------------------