net.Receive("DoorKickView", function()
    LocalPlayer().KickingInDoor = true

    timer.Simple(1.4, function()
        LocalPlayer().KickingInDoor = false
    end)
end)

local function KickView(client, pos, ang)
    if client.KickingInDoor then
        local origin = pos + client:GetAngles():Forward() * -10
        local angles = (pos - origin):Angle()

        local view = {
            ["origin"] = origin,
            ["angles"] = angles
        }

        return view
    end
end

hook.Add("CalcView", "doorkick_view", KickView)