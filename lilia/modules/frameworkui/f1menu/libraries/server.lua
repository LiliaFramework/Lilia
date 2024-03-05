
function MODULE:PlayerDeath(client)
    netstream.Start(client, "removeF1")
end

