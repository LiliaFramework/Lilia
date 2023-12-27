--------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSwitchFlashlight(client, enabled)
    if not (lia.config.flashlightenabled or client:getChar()) then return false end
    if lia.config.FlashlightItemRequired ~= nil and not client:getChar():getInv():hasItem(lia.config.FlashlightItemRequired) then return false end
    return true
end
--------------------------------------------------------------------------------------------------------------------------
