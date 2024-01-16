concommand.Add(
    "play_music",
    function(ply, cmd, args)
        if not ply:IsSuperAdmin() then return end
        net.Start("MusicPlayer")
        net.WriteString(tostring(args[1]))
        net.Broadcast()
    end
)

concommand.Add(
    "stop_music",
    function(ply, cmd, args)
        if not ply:IsSuperAdmin() then return end
        net.Start("MusicPlayerStop")
        net.Broadcast()
    end
)

concommand.Add(
    "set_volume",
    function(ply, cmd, args)
        if not ply:IsSuperAdmin() then return end
        net.Start("MusicPlayerSetVolume")
        net.WriteString(args[1])
        net.Broadcast()
    end
)