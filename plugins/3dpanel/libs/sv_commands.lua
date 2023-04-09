local PLUGIN = PLUGIN

lia.command.add("paneladd", {
    adminOnly = true,
    syntax = "<string url> [number w] [number h] [number scale]",
    onRun = function(client, arguments)
        if not arguments[1] then return L("invalidArg", client, 1) end
        -- Get the position and angles of the panel.
        local trace = client:GetEyeTrace()
        local position = trace.HitPos
        local angles = trace.HitNormal:Angle()
        angles:RotateAroundAxis(angles:Up(), 90)
        angles:RotateAroundAxis(angles:Forward(), 90)
        -- Add the panel.
        PLUGIN:addPanel(position + angles:Up() * 0.1, angles, arguments[1], tonumber(arguments[2]), tonumber(arguments[3]), tonumber(arguments[4]))

        -- Tell the player the panel was added.
        return L("panelAdded", client)
    end
})

lia.command.add("panelremove", {
    adminOnly = true,
    syntax = "[number radius]",
    onRun = function(client, arguments)
        -- Get the origin to remove panel.
        local trace = client:GetEyeTrace()
        local position = trace.HitPos
        -- Remove the panel(s) and get the amount removed.
        local amount = PLUGIN:removePanel(position, tonumber(arguments[1]))

        -- Tell the player how many panels got removed.
        return L("panelRemoved", client, amount)
    end
})