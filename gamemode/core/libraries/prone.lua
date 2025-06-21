--[[
    DoPlayerDeath hook

    Description:
        Exits the player's prone state when they die.

    Parameters:
        client (Player) – Player entity that died.

    Realm:
        Server

    Returns:
        None
]]
hook.Add("DoPlayerDeath", "PRONE_DoPlayerDeath", function(client)
    if client:IsProne() then
        prone.Exit(client)
    end
end)

--[[
    PlayerLoadedChar hook

    Description:
        Ensures the player is no longer prone when their character loads.

    Parameters:
        client (Player) – Player entity whose character finished loading.

    Realm:
        Server

    Returns:
        None
]]
hook.Add("PlayerLoadedChar", "PRONE_PlayerLoadedChar", function(client)
    if client:IsProne() then
        prone.Exit(client)
    end
end)
