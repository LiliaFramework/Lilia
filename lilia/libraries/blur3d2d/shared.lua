
lia.blur3d2d = lia.blur3d2d or {}

lia.blur3d2d.list = {}

function lia.blur3d2d.add(id, pos, ang, scale, callback)
    if id and pos and ang and scale and callback then
        lia.blur3d2d.list[id] = {
            pos = pos,
            ang = ang,
            scale = scale,
            callback = callback,
            draw = true,
        }
    end
end


function lia.blur3d2d.remove(id)
    if id and lia.blur3d2d.list[id] then lia.blur3d2d.list[id] = nil end
end


function lia.blur3d2d.pause(id)
    if id and lia.blur3d2d.list[id] then lia.blur3d2d.list[id].draw = false end
end


function lia.blur3d2d.resume(id)
    if id and lia.blur3d2d.list[id] then lia.blur3d2d.list[id].draw = true end
end

