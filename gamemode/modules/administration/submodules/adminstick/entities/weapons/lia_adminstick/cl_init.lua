local function closeAdminStickMenu()
    if AdminStickIsOpen and IsValid(AdminStickMenu) then AdminStickMenu:Remove() end
end

local function isSelfSelectHeld(client)
    return IsValid(client) and (client:KeyDown(IN_SPEED) or input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT))
end

local function openAdminStickTarget(client, target)
    if not IsValid(client) or not IsValid(target) then return end
    closeAdminStickMenu()
    client.AdminStickTarget = target
    hook.Run("OpenAdminStickUI", target)
end

local function getAdminStickHUDTitle(target)
    if not IsValid(target) then return L("adminStick") end
    if target:IsPlayer() then
        local character = target.getChar and target:getChar()
        return character and character:getName() or target:Nick()
    end

    if target.IsVendor and target.getName then
        local vendorName = target:getName()
        if vendorName and vendorName ~= "" then return vendorName end
    end

    if target.GetName then
        local name = target:GetName()
        if name and name ~= "" then return name end
    end

    return target.PrintName or target:GetClass() or L("unknown")
end

local function normalizeAdminStickHUDRows(information)
    local rows = {}
    for _, entry in ipairs(information or {}) do
        if istable(entry) then
            rows[#rows + 1] = table.Copy(entry)
        elseif isstring(entry) then
            local text = string.Trim(entry)
            if text == "" then
                rows[#rows + 1] = {
                    divider = true
                }
            else
                local label, value = text:match("^([^:]+):%s*(.+)$")
                if label and value then
                    rows[#rows + 1] = {
                        label = string.Trim(label),
                        value = string.Trim(value)
                    }
                else
                    rows[#rows + 1] = {
                        text = text
                    }
                end
            end
        end
    end
    return rows
end

local function buildAdminStickHUDRows(client, target)
    local information = {}
    hook.Run("AddToAdminStickHUD", client, target, information)
    return normalizeAdminStickHUDRows(information)
end

function SWEP:DrawHUD()
    local client = LocalPlayer()
    if not IsValid(client) or client:GetActiveWeapon() ~= self then return end
    local target = self:GetTarget()
    if not IsValid(target) then return end
    if target:IsPlayer() then return end
    local rows = buildAdminStickHUDRows(client, target)
    if #rows == 0 then return end
    local worldPosition = target.WorldSpaceCenter and target:WorldSpaceCenter() or target:GetPos()
    local screenPosition = worldPosition:ToScreen()
    if not screenPosition.visible then return end
    lia.derma.drawBoxWithText(nil, screenPosition.x + 24, screenPosition.y, {
        title = getAdminStickHUDTitle(target),
        rows = rows,
        textAlignX = TEXT_ALIGN_LEFT,
        textAlignY = TEXT_ALIGN_CENTER,
        minWidth = 320,
        maxWidth = 520,
        rowDividers = false
    })
end

function SWEP:PrimaryAttack()
    local client = LocalPlayer()
    if not IsFirstTimePredicted() then return end
    if isSelfSelectHeld(client) then
        openAdminStickTarget(client, client)
        return
    end

    openAdminStickTarget(client, client:GetEyeTrace().Entity)
end

function SWEP:SecondaryAttack()
    local client = LocalPlayer()
    if not IsFirstTimePredicted() then return end
    local target = self:GetTarget()
    if IsValid(target) and target:IsPlayer() and target ~= client then
        local action = target:IsFrozen() and "unfreeze" or "freeze"
        local victim = target:IsBot() and target:Name() or target:SteamID()
        lia.admin.execCommand(action, victim)
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
    if isSelfSelectHeld(client) then
        openAdminStickTarget(client, client)
    else
        closeAdminStickMenu()
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
