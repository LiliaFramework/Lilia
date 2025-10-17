function SWEP:PrimaryAttack()
    local target = self:GetTarget()
    if IsValid(target) then lia.module.get("administration"):OpenAdminStickUI(target) end
end

function SWEP:SecondaryAttack()
    local client = LocalPlayer()
    if not IsFirstTimePredicted() then return end
    local target = self:GetTarget()
    if IsValid(target) and target:IsPlayer() and target ~= client then
        local action = target:IsFrozen() and "unfreeze" or "freeze"
        local victim = target:IsBot() and target:Name() or target:SteamID()
        hook.Run("RunAdminSystemCommand", action, client, victim)
    else
        client:notifyErrorLocalized("cantFreezeTarget")
    end
end

function SWEP:GetTarget()
    local client = LocalPlayer()
    -- Clear target if weapon is not active
    if not IsValid(self) or self ~= client:GetActiveWeapon() then
        client.AdminStickTarget = nil
        return client:GetEyeTrace().Entity
    end

    local target = IsValid(client.AdminStickTarget) and client.AdminStickTarget or client:GetEyeTrace().Entity
    return target
end

function SWEP:DrawHUD()
    local client = LocalPlayer()
    -- Don't draw HUD if we're in self-targeting mode and the admin menu isn't open
    if client.AdminStickTarget == client and not AdminStickIsOpen then return end
    local x, y = ScrW() / 2, ScrH() / 2
    local target = IsValid(client.AdminStickTarget) and client.AdminStickTarget or client:GetEyeTrace().Entity
    local themeColors = lia.color.returnMainAdjustedColors()
    local themeAccent = lia.color.theme.theme
    local information = {}
    if IsValid(target) then
        if not target:IsPlayer() then
            if target.GetCreator and IsValid(target:GetCreator()) then
                table.insert(information, L("entity") .. " " .. L("class") .. ": " .. target:GetClass())
                table.insert(information, L("creator") .. ": " .. tostring(target:GetCreator()))
            end

            if target.isItem and target:isItem() then
                local itemTable = target.getItemTable and target:getItemTable()
                if itemTable then
                    table.insert(information, L("item") .. ": " .. L(itemTable.getName and itemTable:getName() or itemTable.name))
                    table.insert(information, L("item") .. " " .. L("size") .. ": " .. itemTable:getWidth() .. "x" .. itemTable:getHeight())
                end
            end

            if target:IsVehicle() and IsValid(target:GetDriver()) then target = target:GetDriver() end
        else
            -- Generic entity information for entities that don't match specific cases
            table.insert(information, L("entity") .. " " .. L("class") .. ": " .. target:GetClass())
            table.insert(information, L("model") .. ": " .. target:GetModel())
            -- Basic position information
            local pos = target:GetPos()
            table.insert(information, L("position") .. ": " .. string.format("%.1f, %.1f, %.1f", pos.x, pos.y, pos.z))
            -- Health if the entity has it
            if target.Health and target:Health() > 0 then table.insert(information, L("health") .. ": " .. target:Health()) end
            -- Owner if available
            if target.GetOwner and IsValid(target:GetOwner()) then table.insert(information, L("owner") .. ": " .. tostring(target:GetOwner())) end
            -- Entity ID for identification
            table.insert(information, L("entity") .. " " .. L("id") .. ": " .. target:EntIndex())
        end

        if target:IsPlayer() then
            information = {L("nickname") .. ": " .. target:Nick(), L("steamName") .. ": " .. (target.SteamName and target:SteamName() or target:Name()), L("steamID") .. ": " .. target:SteamID(), L("health") .. ": " .. target:Health(), L("armor") .. ": " .. target:Armor(), L("usergroup") .. ": " .. target:GetUserGroup()}
            if target:getChar() then
                local char = target:getChar()
                local faction = lia.faction.indices[target:Team()]
                table.Add(information, {L("charNameIs", char:getName()), L("character") .. " " .. L("faction") .. ": " .. faction.name})
            else
                table.insert(information, L("noLoadedCharacter"))
            end
        end
    end

    hook.Run("AddToAdminStickHUD", client, target, information)
    local length, thickness = 15, 0.5
    lia.derma.rect(x - length / 2, y - thickness / 2, length, thickness):Color(themeColors.text):Draw()
    lia.derma.rect(x - thickness / 2, y - length / 2, thickness, length):Color(themeColors.text):Draw()
    if #information > 0 then
        local maxWidth, totalHeight = 0, 0
        surface.SetFont("LiliaFont.16")
        for _, v in pairs(information) do
            local t_w, t_h = surface.GetTextSize(v)
            maxWidth = math.max(maxWidth, t_w)
            totalHeight = totalHeight + t_h + 4
        end

        local boxWidth = maxWidth + 80
        local boxHeight = totalHeight + 20
        local boxX = (ScrW() - boxWidth) / 2
        local boxY = ScrH() - boxHeight - 20
        lia.util.drawBlurAt(boxX, boxY, boxWidth, boxHeight, 3, 3, 0.9)
        lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Color(Color(0, 0, 0, 150)):Rad(8):Draw()
        lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Color(themeAccent):Rad(8):Outline(2):Draw()
        local startPosY, buffer = boxY + 10, 0
        for _, v in pairs(information) do
            local t_w, t_h = surface.GetTextSize(v)
            local centeredX = boxX + (boxWidth - t_w) / 2
            lia.derma.drawText(v, centeredX, startPosY + buffer, Color(255, 255, 255), 0, 0, "LiliaFont.16")
            buffer = buffer + t_h + 4
        end
    end

    local instructions = {L("adminStickInstructions1", "Left Click: Open admin menu for target"), L("adminStickInstructions2", "Right Click: Freeze/unfreeze player"), L("adminStickInstructions3", "Reload + Shift: Open admin menu for yourself"), L("adminStickInstructions4", "Reload: Clear target selection")}
    local instMaxWidth, instTotalHeight = 0, 0
    surface.SetFont("LiliaFont.14")
    for _, v in pairs(instructions) do
        local t_w, t_h = surface.GetTextSize(v)
        instMaxWidth = math.max(instMaxWidth, t_w)
        instTotalHeight = instTotalHeight + t_h + 2
    end

    local instBoxWidth = instMaxWidth + 40
    local instBoxHeight = instTotalHeight + 20
    local instBoxX = ScrW() - instBoxWidth - 20
    local instBoxY = 20
    lia.util.drawBlurAt(instBoxX, instBoxY, instBoxWidth, instBoxHeight, 2, 2, 0.8)
    lia.derma.rect(instBoxX, instBoxY, instBoxWidth, instBoxHeight):Color(Color(0, 0, 0, 150)):Rad(6):Draw()
    local accentColor = themeAccent or Color(255, 255, 255)
    lia.derma.rect(instBoxX, instBoxY, instBoxWidth, instBoxHeight):Color(accentColor):Rad(6):Outline(1):Draw()
    local textColor = Color(255, 255, 255)
    local instStartY, instBuffer = instBoxY + 10, 0
    for _, v in pairs(instructions) do
        local _, t_h = surface.GetTextSize(v)
        lia.derma.drawText(v, instBoxX + 20, instStartY + instBuffer, textColor, 0, 0, "LiliaFont.14", 255)
        instBuffer = instBuffer + t_h + 2
    end
end

function SWEP:Reload()
    if self.NextReload and self.NextReload > SysTime() then return end
    self.NextReload = SysTime() + 0.5
    local client = LocalPlayer()
    if client:KeyDown(IN_SPEED) then
        client.AdminStickTarget = client
        lia.module.get("administration"):OpenAdminStickUI(client)
    else
        -- Clear target selection when R is pressed without Shift
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