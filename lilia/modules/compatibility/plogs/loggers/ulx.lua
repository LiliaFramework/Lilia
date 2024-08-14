plogs.Register("ULX", false)
plogs.AddHook(ULib.HOOK_COMMAND_CALLED, function(client, cmd, arguments)
    if client:IsPlayer() then
        plogs.PlayerLog(client, "ULX", client:NameID() .. " has ran command '" .. cmd .. "' with arguments '" .. table.concat(arguments, " ") .. "'", {
            ["Name"] = client:Name(),
            ["SteamID"] = client:SteamID(),
        })
    end
end)
