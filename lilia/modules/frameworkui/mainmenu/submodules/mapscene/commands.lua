lia.command.add("mapsceneadd", {
    adminOnly = true,
    privilege = "Manage Map Scenes",
    syntax = "[bool]",
    onRun = function(client, arguments)
        local position, angles = client:EyePos(), client:EyeAngles()
        if tobool(arguments[1]) and not client.ScnPair then
            client.ScnPair = {position, angles}
            return L("mapRepeat", client)
        else
            if client.ScnPair then
                MODULE:addScene(client.ScnPair[1], client.ScnPair[2], position, angles)
                client.ScnPair = nil
            else
                MODULE:addScene(position, angles)
            end
            return L("mapAdd", client)
        end
    end
})

lia.command.add("mapsceneremove", {
    adminOnly = true,
    privilege = "Manage Map Scenes",
    syntax = "[number radius]",
    onRun = function(client, arguments)
        local radius = tonumber(arguments[1]) or 280
        local position = client:GetPos()
        local i = 0
        for k, v in pairs(MODULE.scenes) do
            local delete = false
            if isvector(k) then
                if k:Distance(position) <= radius or v[1]:Distance(position) <= radius then delete = true end
            elseif v[1]:Distance(position) <= radius then
                delete = true
            end

            if delete then
                netstream.Start(nil, "mapScnDel", k)
                MODULE.scenes[k] = nil
                i = i + 1
            end
        end

        if i > 0 then MODULE:SaveScenes() end
        return L("mapDel", client, i)
    end
})