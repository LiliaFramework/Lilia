function MODULE:PlayerSwitchWeapon(client, _, newWeapon)
    if self.WepAlwaysRaised then return end
    if IsValid(client) and IsValid(newWeapon) then
        local weaponClass = newWeapon:GetClass()
        if weaponClass ~= "lia_hands" and weaponClass ~= "lia_keys" then timer.Simple(1, function() if IsValid(client) then client:setWepRaised(true, false) end end) end
    end
end

function MODULE:KeyRelease(client, key)
    if key == IN_RELOAD then timer.Remove("WeaponHolstering" .. client:SteamID64()) end
end

function MODULE:KeyPress(client, key)
    if key == IN_RELOAD then timer.Create("WeaponHolstering" .. client:SteamID64(), 1, 1, function() if IsValid(client) then client:toggleWepRaised() end end) end
end