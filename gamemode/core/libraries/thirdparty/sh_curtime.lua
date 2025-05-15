if SERVER then
    timer.Create("CurTime-Sync", 30, -1, function()
        net.Start("CurTime-Sync", true)
        net.WriteFloat(CurTime())
        net.Broadcast()
    end)
else
    hook.Add("InitPostEntity", "CurTime-Sync", function()
        local SyncTime = 0
        net.Receive("CurTime-Sync", function()
            local ServerCurTime = net.ReadFloat()
            if not ServerCurTime then return end
            SyncTime = OldCurTime() - ServerCurTime
        end)

        OldCurTime = OldCurTime or CurTime
        function CurTime()
            return OldCurTime() - SyncTime
        end
    end)
end
