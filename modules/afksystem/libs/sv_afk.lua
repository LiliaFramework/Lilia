--------------------------------------------------------------------------------------------------------
function MODULE:InitializedSchema(client, bool)
    client:setNetVar("afk", bool)
    hook.Run("AFKMonChanged", client, bool)
end
--------------------------------------------------------------------------------------------------------
function MODULE:ServerAFK(client, afk, id, len)
    if afk then
        timer.Create("AFK" .. client:SteamID64(), lia.config.AFKForTooLongTimer, 1, function() hook.Run("OnPlayerAFKLong", client) end)
    else
        timer.Remove("AFK" .. client:SteamID64())
    end
end
--------------------------------------------------------------------------------------------------------