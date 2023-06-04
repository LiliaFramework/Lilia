util.AddNetworkString("TPoseFixerSync")

function GM:PlayerInitialSpawn(client)
    net.Start("TPoseFixerSync")
    net.WriteTable(CachedModels)
    net.Send(client)
end