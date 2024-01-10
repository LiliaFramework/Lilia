
function WSCore:StartCommand(client, cmd)
    if not IsValid(client.doWeaponSwitch) then return end
    cmd:SelectWeapon(client.doWeaponSwitch)
    if client:GetActiveWeapon() == client.doWeaponSwitch then client.doWeaponSwitch = nil end
end

