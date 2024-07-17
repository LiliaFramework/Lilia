util.AddNetworkString("PlayPickupAnimation")

function MODULE:OnPlayerInteractItem(client, action, item)
    if action == "take" and not table.HasValue(self.VManipTakeBlacklist, itemID) then
        net.Start("PlayPickupAnimation")
        net.WriteString(item.uniqueID)
        net.Send(client)
    end
end