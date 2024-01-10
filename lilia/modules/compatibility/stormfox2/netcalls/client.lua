net.Receive(
    "StormFox2.lightstyle",
    function()
        local c_var = net.ReadUInt(7)
        if last_sv and last_sv == c_var then return end
        last_sv = c_var
        timer.Simple(1, function() render.RedownloadAllLightmaps(true) end)
    end
)
