util.AddNetworkString("LiliaResetVariablesNew")
util.AddNetworkString("LiliaResetVariables2")
util.AddNetworkString("SpawnMenuWarn")

net.Receive("LiliaResetVariables2", function(len, client)
    local uniqueID = client:GetUserGroup()

    if not client:IsSuperAdmin()then
        client:notify("Your rank is not high enough to use this command.")

        return false
    end

    local name = net.ReadString()

    for k, v in pairs(lia.item.list) do
        if v.name == name then
            lia.item.spawn(v.uniqueID, client:getItemDropPos())
            lia.log.add(client:getChar():getName(), "has spawned ", v.name)
        end
    end
end)

lia.command.add("adminspawnmenu", {
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not client:IsSuperAdmin()then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        net.Start("LiliaResetVariablesNew")
        net.Send(client)
    end
})