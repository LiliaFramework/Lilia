local MODULE = MODULE
net.Receive("PlayPickupAnimation", function()
    local itemID = net.ReadString()
    if itemID and VManip.PlayAnim and not table.HasValue(MODULE.VManipTakeBlacklist, itemID) then VManip:PlayAnim("interactslower") end
end)
