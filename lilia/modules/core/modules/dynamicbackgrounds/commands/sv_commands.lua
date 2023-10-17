--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "mapsceneadd",
    {
        privilege = "Add Map Scene",
        adminOnly = true,
        syntax = "[bool isPair]",
        onRun = function(client, arguments)
            local position, angles = client:EyePos(), client:EyeAngles()
            if tobool(arguments[1]) and not client.liaScnPair then
                client.liaScnPair = {position, angles}

                return L("mapRepeat", client)
            else
                if client.liaScnPair then
                    MODULE:addScene(client.liaScnPair[1], client.liaScnPair[2], position, angles)
                    client.liaScnPair = nil
                else
                    MODULE:addScene(position, angles)
                end

                return L("mapAdd", client)
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "mapsceneremove",
    {
        privilege = "DeleteMap Scene",
        adminOnly = true,
        syntax = "[number radius]",
        onRun = function(client, arguments)
            local radius = tonumber(arguments[1]) or 280
            local position = client:GetPos()
            local i = 0
            for k, v in pairs(MODULE.scenes) do
                local delete = false
                if type(k) == "Vector" then
                    if k:Distance(position) <= radius or v[1]:Distance(position) <= radius then
                        delete = true
                    end
                elseif v[1]:Distance(position) <= radius then
                    delete = true
                end

                if delete then
                    netstream.Start(nil, "mapScnDel", k)
                    MODULE.scenes[k] = nil
                    i = i + 1
                end
            end

            if i > 0 then
                MODULE:SaveScenes()
            end

            return L("mapDel", client, i)
        end
    }
)
--------------------------------------------------------------------------------------------------------------------------