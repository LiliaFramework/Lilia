plogs.Register("AWarn", true, Color(153, 51, 102))
plogs.AddHook("AWarnPlayerWarned", function(targ, admin, reason)
    plogs.PlayerLog(targ, "AWarn", targ:NameID() .. " was warned by " .. admin:NameID() .. " for " .. reason, {
        ["Name"] = targ:Name(),
        ["SteamID"] = targ:SteamID(),
        ["Admin Name"] = admin:Name(),
        ["Admin SteamID"] = admin:SteamID(),
        ["Reason"] = reason,
    })
end)

plogs.AddHook("AWarnPlayerIDWarned", function(steamid, admin, reason)
    local targ = plogs.FindPlayer(steamid)
    if IsValid(targ) then
        plogs.PlayerLog(targ, "AWarn", targ:NameID() .. " was warned by " .. admin:NameID() .. " for " .. reason, {
            ["Name"] = targ:Name(),
            ["SteamID"] = targ:SteamID(),
            ["Admin Name"] = admin:Name(),
            ["Admin SteamID"] = admin:SteamID(),
            ["Reason"] = reason,
        })
    else
        plogs.Log("AWarn", steamid .. " was warned by " .. admin:NameID() .. " for " .. reason, {
            ["SteamID"] = steamid,
            ["Admin Name"] = admin:Name(),
            ["Admin SteamID"] = admin:SteamID(),
            ["Reason"] = reason,
        })
    end
end)

plogs.AddHook("AWarnLimitKick", function(client)
    plogs.PlayerLog(client, "AWarn", client:NameID() .. " was kicked for too many warnings", {
        ["Name"] = client:Name(),
        ["SteamID"] = client:SteamID(),
    })
end)

plogs.AddHook("AWarnLimitBan", function(client)
    plogs.PlayerLog(client, "AWarn", client:NameID() .. " was banned for too many warnings", {
        ["Name"] = client:Name(),
        ["SteamID"] = client:SteamID(),
    })
end)
