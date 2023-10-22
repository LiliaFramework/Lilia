--------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerSwitchFlashlight(client, enabled)
    if not (lia.config.flashlightenabled and client:getChar())  then return false end
    if lia.config.FlashlightItemRequired ~= nil then
        if not client:getChar():getInv():hasItem(lia.config.FlashlightItemRequired) then
            return false
        else
            if (client.FlashlightEnable or 0) > CurTime() and enabled then
                return false
            else
                client.FlashlightEnable = CurTime() + lia.config.FlashlightToggleCooldown

                return true
            end
        end
    else
        if (client.FlashlightEnable or 0) > CurTime() and enabled then
            return false
        else
            client.FlashlightEnable = CurTime() + lia.config.FlashlightToggleCooldown

            return true
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------