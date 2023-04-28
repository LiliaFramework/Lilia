local IsValid, tonumber, FrameTime, Lerp, ScrW, ScrH, CurTime, ipairs = IsValid, tonumber, FrameTime, Lerp, ScrW, ScrH, CurTime, ipairs
local RunConsoleCommand, LocalPlayer, math, color_white, surface = RunConsoleCommand, LocalPlayer, math, color_white, surface
local meta = FindMetaTable("Player")

function meta:SelectWeapon(class)
    if not self:HasWeapon(class) then return end
    self.doWeaponSwitch = self:GetWeapon(class)
end

function PLUGIN:StartCommand(client, cmd)
    if not IsValid(client.doWeaponSwitch) then return end
    cmd:SelectWeapon(client.doWeaponSwitch)

    if client:GetActiveWeapon() == client.doWeaponSwitch then
        client.doWeaponSwitch = nil
    end
end