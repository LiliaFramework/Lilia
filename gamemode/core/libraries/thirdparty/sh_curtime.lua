local SyncDelay = 30
local SyncType = "net"
if SyncType == "NW2" then
    if SERVER then
        timer.Create("CurTime-Sync", SyncDelay, -1, function() Entity(0):SetNW2Float("CurTime-Sync", CurTime()) end)
    else
        hook.Add("InitPostEntity", "CurTime-Sync", function()
            local SyncTime = 0
            Entity(0):SetNW2VarProxy("CurTime-Sync", function(_, _, _, ServerCurTime) SyncTime = OldCurTime() - ServerCurTime end)
            OldCurTime = OldCurTime or CurTime
            function CurTime()
                return OldCurTime() - SyncTime
            end
        end)
    end
elseif SyncType == "net" then
    if SERVER then
        timer.Create("CurTime-Sync", SyncDelay, -1, function()
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
end