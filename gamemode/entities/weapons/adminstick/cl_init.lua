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

function SWEP:DrawHUD()
    local client = LocalPlayer()
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
            table.insert(information, L("entity") .. " " .. L("class") .. ": " .. target:GetClass())
            table.insert(information, L("model") .. ": " .. target:GetModel())
            local pos = target:GetPos()
            table.insert(information, L("position") .. ": " .. string.format("%.1f, %.1f, %.1f", pos.x, pos.y, pos.z))
            if target.Health and target:Health() > 0 then table.insert(information, L("health") .. ": " .. target:Health()) end
            if target.GetOwner and IsValid(target:GetOwner()) then table.insert(information, L("owner") .. ": " .. tostring(target:GetOwner())) end
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
        local boxX = ScrW() / 2
        local boxY = ScrH() - 20
        lia.derma.drawBoxWithText(information, boxX, boxY, {
            font = "LiliaFont.16",
            textColor = Color(255, 255, 255),
            backgroundColor = Color(0, 0, 0, 150),
            borderColor = themeAccent,
            borderRadius = 8,
            borderThickness = 2,
            padding = 40,
            textAlignX = TEXT_ALIGN_CENTER,
            textAlignY = TEXT_ALIGN_BOTTOM,
            lineSpacing = 4
        })
    end

    local instructions = {L"adminStickInstructions1", L"adminStickInstructions2", L"adminStickInstructions3", L"adminStickInstructions4"}
    local instBoxX = ScrW() - 20
    local instBoxY = 20
    lia.derma.drawBoxWithText(instructions, instBoxX, instBoxY, {
        font = "LiliaFont.14",
        textColor = Color(255, 255, 255),
        backgroundColor = Color(0, 0, 0, 150),
        borderColor = themeAccent or Color(255, 255, 255),
        borderRadius = 6,
        borderThickness = 1,
        padding = 20,
        textAlignX = TEXT_ALIGN_RIGHT,
        textAlignY = TEXT_ALIGN_TOP,
        lineSpacing = 2,
        blur = {
            enabled = true,
            amount = 2,
            passes = 2,
            alpha = 0.8
        }
    })
end

function SWEP:Reload()
    if self.NextReload and self.NextReload > SysTime() then return end
    self.NextReload = SysTime() + 0.5
    local client = LocalPlayer()
    if client:KeyDown(IN_SPEED) then
        client.AdminStickTarget = client
        lia.module.get("administration"):OpenAdminStickUI(client)
    else
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
