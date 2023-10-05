--------------------------------------------------------------------------------------------------------
lia.config.KnownExploits = lia.config.KnownExploits or {}
--------------------------------------------------------------------------------------------------------
util.AddNetworkString("BanMeAmHack")
--------------------------------------------------------------------------------------------------------
net.Receive(
    "BanMeAmHack",
    function(len, ply)
        local kickReason = "Kicked for cheating."
        ply:Kick(kickReason)
        local banDuration = 0
        local banReason = "You have easily detectable hacks and should be ashamed. Banned for cheating."
        ply:Ban(banDuration, banReason)
    end
)

--------------------------------------------------------------------------------------------------------
for k, v in pairs(lia.config.KnownExploits) do
    net.Receive(
        k,
        function(len, ply)
            ply.nextExploitNotify = ply.nextExploitNotify or 0
            if ply.nextExploitNotify > CurTime() then return end
            ply.nextExploitNotify = CurTime() + 2
            for _, p in pairs(player.GetAll()) do
                if p:IsAdmin() then
                    p:notify(ply:Name() .. " (" .. ply:SteamID() .. (v and ") may be attempting to crash the server!" or ") may be attempting to run exploits!"))
                end
            end
        end
    )
end
--------------------------------------------------------------------------------------------------------