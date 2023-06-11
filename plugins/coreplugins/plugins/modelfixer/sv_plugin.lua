util.AddNetworkString("TPoseFixerSync")

function PLUGIN:PlayerInitialSpawn(client)
    net.Start("TPoseFixerSync")
    net.WriteTable(self.cached)
    net.Send(client)
end