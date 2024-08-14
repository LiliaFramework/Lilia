function MODULE:PostPlayerInitialSpawn(client)
    timer.Simple(1, function() client:syncParts() end)
end

function MODULE:PlayerLoadout(client)
    client:resetParts()
end

function MODULE:ModuleLoaded()
    game.ConsoleCommand("sv_pac_webcontent_limit 35840\n")
end