function MODULE:DoPlayerDeath(client)
    if client:IsProne() then prone.Exit(client) end
end

function MODULE:PlayerLoadedChar(client)
    if client:IsProne() then prone.Exit(client) end
end
