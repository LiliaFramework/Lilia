local PLUGIN = PLUGIN

lia.command.add("textadd", {
    adminOnly = true,
    syntax = "<string text> [number scale]",
    onRun = function(client, arguments)
        -- Get the position and angles of the text.
        local trace = client:GetEyeTrace()
        local position = trace.HitPos
        local angles = trace.HitNormal:Angle()
        angles:RotateAroundAxis(angles:Up(), 90)
        angles:RotateAroundAxis(angles:Forward(), 90)
        -- Add the text.
        PLUGIN:addText(position + angles:Up() * 0.1, angles, arguments[1], tonumber(arguments[2]))

        -- Tell the player the text was added.
        return L("textAdded", client)
    end
})

lia.command.add("textremove", {
    adminOnly = true,
    syntax = "[number radius]",
    onRun = function(client, arguments)
        -- Get the origin to remove text.
        local trace = client:GetEyeTrace()
        local position = trace.HitPos + trace.HitNormal * 2
        -- Remove the text(s) and get the amount removed.
        local amount = PLUGIN:removeText(position, tonumber(arguments[1]))

        -- Tell the player how many texts got removed.
        return L("textRemoved", client, amount)
    end
})