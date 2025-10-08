function MODULE:PlayerDeath(client)
    net.Start("liaRemoveFOne")
    net.Send(client)
end
function MODULE:ShowHelp()
    return false
end