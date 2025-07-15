local MODULE = MODULE
function SWEP:PrimaryAttack()
    local target = self:GetTarget()
    local client = LocalPlayer()
    if IsValid(target) then
        client.AdminStickTarget = target
        MODULE:OpenAdminStickUI(target)
    end
end

function SWEP:SecondaryAttack()
    local client = LocalPlayer()
    if not IsFirstTimePredicted() then return end
    local target = self:GetTarget()
    if IsValid(target) and target:IsPlayer() and target ~= client then
        local action = target:IsFrozen() and "unfreeze" or "freeze"
        local victim = target:IsBot() and target:Name() or target
        if not hook.Run("RunAdminSystemCommand", action, client, victim) then
            local cmd = sam and "sam " .. action or ulx and "ulx " .. action
            if cmd then client:ConCommand(cmd .. " " .. target:SteamID()) end
        end
    else
        client:notifyLocalized("cantFreezeTarget")
    end
end

function SWEP:GetTarget()
    local client = LocalPlayer()
    local target = IsValid(client.AdminStickTarget) and client.AdminStickTarget or client:GetEyeTrace().Entity
    return target
end

function SWEP:DrawHUD()
    local client = LocalPlayer()
    local x, y = ScrW() / 2, ScrH() / 2
    local target = IsValid(client.AdminStickTarget) and client.AdminStickTarget or client:GetEyeTrace().Entity
    local crossColor = Color(0, 255, 0)
    local information = {}
    if IsValid(target) then
        if not target:IsPlayer() then
            if target.GetCreator and IsValid(target:GetCreator()) then table.Add(information, {L("entityClassESPLabel", target:GetClass()), L("entityCreatorESPLabel", tostring(target:GetCreator()))}) end
            if target:IsVehicle() and IsValid(target:GetDriver()) then target = target:GetDriver() end
        end

        if target:IsPlayer() then
            information = {L("nicknameLabel", target:Nick()), L("steamNameLabel", target.SteamName and target:SteamName() or target:Name()), L("steamIDLabel", target:SteamID()), L("steamID64Label", target:SteamID64()), L("healthLabel", target:Health()), L("armorLabel", target:Armor()), L("usergroupLabel", target:GetUserGroup())}
            if target:getChar() then
                local char = target:getChar()
                local faction = lia.faction.indices[target:Team()]
                table.Add(information, {L("charNameIs", char:getName()), L("characterFactionLabel", faction.name)})
            else
                table.insert(information, L("noLoadedCharacter"))
            end
        end
    end

    local length, thickness = 20, 1
    surface.SetDrawColor(crossColor)
    surface.DrawRect(x - length / 2, y - thickness / 2, length, thickness)
    surface.DrawRect(x - thickness / 2, y - length / 2, thickness, length)
    local startPosX, startPosY, buffer = x - 250, y + 10, 0
    for _, v in pairs(information) do
        surface.SetFont("DebugFixed")
        surface.SetTextColor(color_black)
        surface.SetTextPos(startPosX + 1, startPosY + buffer + 1)
        surface.DrawText(v)
        surface.SetTextColor(crossColor)
        surface.SetTextPos(startPosX, startPosY + buffer)
        surface.DrawText(v)
        local _, t_h = surface.GetTextSize(v)
        buffer = buffer + t_h + 4
    end
end

function SWEP:Reload()
    if self.NextReload and self.NextReload > SysTime() then return end
    self.NextReload = SysTime() + 0.5
    local client = LocalPlayer()
    if client:KeyDown(IN_SPEED) then
        client.AdminStickTarget = client
        MODULE:OpenAdminStickUI(client)
    end
end