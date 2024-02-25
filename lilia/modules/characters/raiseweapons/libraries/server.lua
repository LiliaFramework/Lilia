---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerSwitchWeapon(ply, _, newWeapon)
    if self.WepAlwaysRaised then return end
    if IsValid(ply) and IsValid(newWeapon) then
        local weaponClass = newWeapon:GetClass()
        if weaponClass ~= "lia_hands" and weaponClass ~= "lia_keys" then timer.Simple(1, function() ply:setWepRaised(true) end) end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:KeyPress(client, key)
    if key == IN_RELOAD then client:toggleWepRaised() end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
