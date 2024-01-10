------------------
function MODULE:PlayerSwitchFlashlight(client, isEnabled)
    local hasFlashlight = false
    local itemNeeded = self.FlashlightItems
    if self.FlashlightEnabled then
        if self.FlashlightNeedsItem then
            if istable(itemNeeded) then
                for _, item in ipairs(itemNeeded) do
                    if client:getChar():getInv():hasItem(item) then
                        hasFlashlight = true
                        break
                    end
                end
            else
                if client:getChar():getInv():hasItem(itemNeeded) then hasFlashlight = true end
            end
        else
            hasFlashlight = true
        end

        client:SendLua(Format("RunConsoleCommand('r_shadows', %s)", isEnabled and "\"1\"" or "\"0\""))
        return hasFlashlight
    end
    return false
end
------------------
