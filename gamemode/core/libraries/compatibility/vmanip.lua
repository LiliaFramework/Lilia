hook.Add("OnPlayerInteractItem", "PlayPickupAnimationOnTake", function(client, action, item)
    if action ~= "take" or not item or item.VManipDisabled then return end
    if not VManip or not VManip.PlayAnim then return end
    VManip:PlayAnim("interactslower")
end)