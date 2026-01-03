function SWEP:PrimaryAttack()
    local client = LocalPlayer()
    local target = client:GetEyeTrace().Entity
    if IsValid(target) then
        client.AdminStickTarget = target
        lia.module.get("administration"):OpenAdminStickUI(target)
    end
end

function SWEP:SecondaryAttack()
    local client = LocalPlayer()
    if not IsFirstTimePredicted() then return end
    local target = self:GetTarget()
    if IsValid(target) and target:IsPlayer() and target ~= client then
        local action = target:IsFrozen() and "unfreeze" or "freeze"
        local victim = target:IsBot() and target:Name() or target:SteamID()
        lia.administrator.execCommand(action, victim)
    else
        client:notifyErrorLocalized("cantFreezeTarget")
    end
end

function SWEP:GetTarget()
    local client = LocalPlayer()
    if not IsValid(self) or self ~= client:GetActiveWeapon() then
        client.AdminStickTarget = nil
        return client:GetEyeTrace().Entity
    end

    local target = IsValid(client.AdminStickTarget) and client.AdminStickTarget or client:GetEyeTrace().Entity
    return target
end

function SWEP:Reload()
    if self.NextReload and self.NextReload > SysTime() then return end
    self.NextReload = SysTime() + 0.5
    local client = LocalPlayer()
    if client:KeyDown(IN_SPEED) then
        if AdminStickIsOpen and IsValid(AdminStickMenu) then AdminStickMenu:Remove() end
        client.AdminStickTarget = client
        lia.module.get("administration"):OpenAdminStickUI(client)
    else
        if AdminStickIsOpen and IsValid(AdminStickMenu) then AdminStickMenu:Remove() end
        client.AdminStickTarget = nil
    end
end

function SWEP:Holster()
    local client = LocalPlayer()
    if IsValid(client) then client.AdminStickTarget = nil end
    return true
end

hook.Add("OnAdminStickMenuClosed", "ClearAdminStickTarget", function()
    local client = LocalPlayer()
    if IsValid(client) and client.AdminStickTarget == client then client.AdminStickTarget = nil end
end)
