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
        local cmd = target:IsFrozen() and (sam and "sam unfreeze" or ulx and "ulx unfreeze") or sam and "sam freeze" or ulx and "ulx freeze"
        client:ConCommand(cmd .. " " .. target:SteamID())
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
            if target.GetCreator and IsValid(target:GetCreator()) then table.Add(information, {"Entity Class: " .. target:GetClass(), "Creator: " .. tostring(target:GetCreator())}) end
            if target:IsVehicle() and IsValid(target:GetDriver()) then target = target:GetDriver() end
        end

        if target:IsPlayer() then
            information = {"Nickname: " .. target:Nick(), "Steam Name: " .. (target.SteamName and target:SteamName() or target:Name()), "Steam ID: " .. target:SteamID(), "SteamID64: " .. target:SteamID64(), "Health: " .. target:Health(), "Armor: " .. target:Armor(), "Usergroup: " .. target:GetUserGroup()}
            if target:getChar() then
                local char = target:getChar()
                local faction = lia.faction.indices[target:Team()]
                table.Add(information, {"Character Name: " .. char:getName(), "Character Faction: " .. faction.name})
            else
                table.insert(information, "No Loaded Character")
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
