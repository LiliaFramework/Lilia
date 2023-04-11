util.AddNetworkString("liaStringReq")
local playerMeta = FindMetaTable("Player")

-- Sends a Derma string request to the client.
function playerMeta:requestString(title, subTitle, callback, default)
    -- Overload with requestString(title, subTitle, default)
    local d

    if type(callback) ~= "function" and default == nil then
        default = callback
        d = deferred.new()

        callback = function(value)
            d:resolve(value)
        end
    end

    self.liaStrReqs = self.liaStrReqs or {}
    local id = table.insert(self.liaStrReqs, callback)
    net.Start("liaStringReq")
    net.WriteUInt(id, 32)
    net.WriteString(title)
    net.WriteString(subTitle)
    net.WriteString(default or "")
    net.Send(self)

    return d
end

net.Receive("liaStringReq", function(_, client)
    local id = net.ReadUInt(32)
    local value = net.ReadString()

    if client.liaStrReqs and client.liaStrReqs[id] then
        client.liaStrReqs[id](value)
        client.liaStrReqs[id] = nil
    end
end)