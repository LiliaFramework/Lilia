
function lia.util.notify(message, recipient)
    net.Start("liaNotify")
    net.WriteString(message)
    if recipient == nil then
        net.Broadcast()
    else
        net.Send(recipient)
    end
end

function lia.util.notifyLocalized(message, recipient, ...)
    local args = {...}
    if recipient ~= nil and type(recipient) ~= "table" and type(recipient) ~= "Player" then
        table.insert(args, 1, recipient)
        recipient = nil
    end

    net.Start("liaNotifyL")
    net.WriteString(message)
    net.WriteUInt(#args, 8)
    for i = 1, #args do
        net.WriteString(tostring(args[i]))
    end

    if recipient == nil then
        net.Broadcast()
    else
        net.Send(recipient)
    end
end

function lia.util.findEmptySpace(entity, filter, spacing, size, height, tolerance)
    spacing = spacing or 32
    size = size or 3
    height = height or 36
    tolerance = tolerance or 5
    local position = entity:GetPos()
    local mins = Vector(-spacing * 0.5, -spacing * 0.5, 0)
    local maxs = Vector(spacing * 0.5, spacing * 0.5, height)
    local output = {}
    for x = -size, size do
        for y = -size, size do
            local origin = position + Vector(x * spacing, y * spacing, 0)
            local data = {}
            data.start = origin + mins + Vector(0, 0, tolerance)
            data.endpos = origin + maxs
            data.filter = filter or entity
            local trace = util.TraceLine(data)
            data.start = origin + Vector(-maxs.x, -maxs.y, tolerance)
            data.endpos = origin + Vector(mins.x, mins.y, height)
            local trace2 = util.TraceLine(data)
            if trace.StartSolid or trace.Hit or trace2.StartSolid or trace2.Hit or not util.IsInWorld(origin) then continue end
            output[#output + 1] = origin
        end
    end

    table.sort(output, function(a, b) return a:Distance(position) < b:Distance(position) end)

    return output
end
