function MODULE:PlayerDeath(client)
    net.Start("removeF1")
    net.Send(client)
end
function MODULE:ShowHelp()
    return false
end
