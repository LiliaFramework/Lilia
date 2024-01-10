﻿
function RaisedWeaponCore:PlayerSwitchWeapon(client, _, _)
    client:setWepRaised(false)
end


function RaisedWeaponCore:KeyPress(client, key)
    if key == IN_RELOAD then timer.Create("liaToggleRaise" .. client:SteamID(), 1, 1, function() if IsValid(client) then client:toggleWepRaised() end end) end
end


function RaisedWeaponCore:KeyRelease(client, key)
    if key == IN_RELOAD then timer.Remove("liaToggleRaise" .. client:SteamID()) end
end

