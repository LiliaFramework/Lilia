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
        local victim = target:IsBot() and target:Name() or target:SteamID()
        hook.Run("RunAdminSystemCommand", action, client, victim)
    else
        client:notifyErrorLocalized("cantFreezeTarget")
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
    local themeColors = lia.color.ReturnMainAdjustedColors()
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
    -- Draw crosshair using liapanels
    local length, thickness = 20, 1
    lia.derma.rect(x - length / 2, y - thickness / 2, length, thickness):Color(themeColors.text):Draw()
    lia.derma.rect(x - thickness / 2, y - length / 2, thickness, length):Color(themeColors.text):Draw()
    -- Draw information box using liapanels with theme colors
    if #information > 0 then
        local maxWidth, totalHeight = 0, 0
        surface.SetFont("liaMediumFont")
        for _, v in pairs(information) do
            local t_w, t_h = surface.GetTextSize(v)
            maxWidth = math.max(maxWidth, t_w)
            totalHeight = totalHeight + t_h + 8
        end

        local boxWidth = maxWidth + 40
        local boxHeight = totalHeight + 40
        local boxX = (ScrW() - boxWidth) / 2
        local boxY = ScrH() - boxHeight - 40
        -- Draw background with blur effect and theme colors
        lia.util.drawBlurAt(boxX, boxY, boxWidth, boxHeight, 3, 3, 0.9)
        -- Draw background
        lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Color(themeColors.background):Rad(8):Draw()
        -- Draw border with accent color
        lia.derma.rect(boxX, boxY, boxWidth, boxHeight):Color(themeColors.accent):Rad(8):Outline(2):Draw()
        -- Draw information text with theme colors
        local startPosX, startPosY, buffer = boxX + 20, boxY + 20, 0
        for _, v in pairs(information) do
            lia.derma.drawText(v, startPosX, startPosY + buffer, themeColors.text, 0, 0, "liaMediumFont")
            local _, t_h = surface.GetTextSize(v)
            buffer = buffer + t_h + 8
        end
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

function SWEP:Holster()
    local client = LocalPlayer()
    if IsValid(client) then client.AdminStickTarget = nil end
    return true
end
