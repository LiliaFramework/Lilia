net.Receive("PlayPickupAnimation", function()
    if not VManip then return end
    local itemID = net.ReadString()
    local item = lia.item.list[itemID]
    local isDisabled = item.VManipDisabled
    if item and VManip.PlayAnim and not isDisabled then VManip:PlayAnim("interactslower") end
end)
