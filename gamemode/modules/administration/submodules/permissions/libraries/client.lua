function MODULE:PrePlayerDraw(client)
    if not IsValid(client) then return end
    if client:isNoClipping() then return true end
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if not client:IsValid() or not client:IsPlayer() or not client:getChar() then return end
    if not client:isNoClipping() then return end
    if not (client:hasPrivilege("noClipESPOffsetStaff") or client:isStaffOnDuty()) then return end
    if not lia.option.get("espEnabled", false) then return end
    for _, ent in ents.Iterator() do
        if not IsValid(ent) or ent == client or ent:IsWeapon() then continue end
        local pos = ent:GetPos()
        if not pos then continue end
        local kind, label, subLabel, baseColor
        if ent:IsPlayer() then
            kind = L("players")
            subLabel = ent:Name():gsub("#", "\226\128\139#")
            if ent:getNetVar("cheater", false) then
                label = string.upper(L("cheater"))
                baseColor = Color(255, 0, 0)
            else
                label = subLabel
                baseColor = lia.option.get("espPlayersColor")
            end
        elseif ent.isItem and ent:isItem() and lia.option.get("espItems", false) then
            kind = L("items")
            local item = ent.getItemTable and ent:getItemTable()
            label = item and item.getName and item:getName() or L("unknown")
            baseColor = lia.option.get("espItemsColor")
        elseif lia.option.get("espEntities", false) and ent:GetClass():StartWith("lia_") then
            kind = L("entities")
            label = ent.PrintName or ent:GetClass()
            baseColor = lia.option.get("espEntitiesColor")
        elseif lia.option.get("espUnconfiguredDoors", false) and ent:isDoor() then
            local factions = ent:getNetVar("factions", "[]")
            local classes = ent:getNetVar("classes", "[]")
            local name = ent:getNetVar("name")
            local title = ent:getNetVar("title")
            local price = ent:getNetVar("price", 0)
            local locked = ent:getNetVar("locked", false)
            local disabled = ent:getNetVar("disabled", false)
            local hidden = ent:getNetVar("hidden", false)
            local noSell = ent:getNetVar("noSell", false)
            local isUnconfigured = (not factions or factions == "[]") and (not classes or classes == "[]") and (not name or name == "") and (not title or title == "") and price == 0 and not locked and not disabled and not hidden and not noSell
            if isUnconfigured then
                kind = L("doorUnconfigured")
                label = L("doorUnconfigured")
                baseColor = lia.option.get("espUnconfiguredDoorsColor")
            end
        end

        if not kind then continue end
        local screenPos = pos:ToScreen()
        if not screenPos.visible then continue end
        surface.SetFont("liaMediumFont")
        local _, textHeight = surface.GetTextSize("W")
        draw.SimpleTextOutlined(label, "liaMediumFont", screenPos.x, screenPos.y, Color(baseColor.r, baseColor.g, baseColor.b, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200))
        if subLabel and subLabel ~= label then draw.SimpleTextOutlined(subLabel, "liaMediumFont", screenPos.x, screenPos.y + textHeight, Color(baseColor.r, baseColor.g, baseColor.b, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200)) end
        if kind == L("players") then
            local barW, barH = 100, 22
            local barX = screenPos.x - barW / 2
            local barY = screenPos.y + textHeight + 5
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(barX, barY, barW, barH)
            local hpFrac = math.Clamp(ent:Health() / ent:GetMaxHealth(), 0, 1)
            surface.SetDrawColor(183, 8, 0, 255)
            surface.DrawRect(barX + 2, barY + 2, (barW - 4) * hpFrac, barH - 4)
            surface.SetFont("liaSmallFont")
            local healthX = barX + barW / 2
            local healthY = barY + barH / 2
            draw.SimpleTextOutlined(ent:Health(), "liaSmallFont", healthX, healthY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
            if ent:Armor() > 0 then
                barY = barY + barH + 5
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawRect(barX, barY, barW, barH)
                local armorFrac = math.Clamp(ent:Armor() / 100, 0, 1)
                surface.SetDrawColor(0, 0, 255, 255)
                surface.DrawRect(barX + 2, barY + 2, (barW - 4) * armorFrac, barH - 4)
                local armorX = barX + barW / 2
                local armorY = barY + barH / 2
                draw.SimpleTextOutlined(ent:Armor(), "liaSmallFont", armorX, armorY, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
            end

            local wep = ent:GetActiveWeapon()
            if IsValid(wep) then
                local ammo, reserve = wep:Clip1(), ent:GetAmmoCount(wep:GetPrimaryAmmoType())
                local wepName = language.GetPhrase(wep:GetPrintName())
                if ammo >= 0 and reserve >= 0 then wepName = wepName .. " [" .. ammo .. "/" .. reserve .. "]" end
                draw.SimpleTextOutlined(wepName, "liaSmallFont", screenPos.x, barY + barH + 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255))
            end
        end
    end
end

net.Receive("DisplayCharList", function()
    local sendData = net.ReadTable()
    local targetSteamIDsafe = net.ReadString()
    local extraColumns, extraOrder = {}, {}
    for _, v in pairs(sendData or {}) do
        if istable(v.extraDetails) then
            for k in pairs(v.extraDetails) do
                if not extraColumns[k] then
                    extraColumns[k] = true
                    table.insert(extraOrder, k)
                end
            end
        end
    end

    local columns = {
        {
            name = "name",
            field = L("name")
        },
        {
            name = "description",
            field = "Desc"
        },
        {
            name = "faction",
            field = L("faction")
        },
        {
            name = "banned",
            field = L("banned")
        },
        {
            name = "banningAdminName",
            field = "BanningAdminName"
        },
        {
            name = "banningAdminSteamID",
            field = "BanningAdminSteamID"
        },
        {
            name = "banningAdminRank",
            field = "BanningAdminRank"
        },
        {
            name = "charMoney",
            field = L("money")
        },
        {
            name = "lastUsed",
            field = "LastUsed"
        }
    }

    for _, name in ipairs(extraOrder) do
        table.insert(columns, {
            name = name,
            field = name
        })
    end

    local _, listView = lia.util.CreateTableUI(L("charlistTitle", targetSteamIDsafe), columns, sendData)
    if IsValid(listView) then
        for _, line in ipairs(listView:GetLines()) do
            local dataIndex = line:GetID()
            local rowData = sendData[dataIndex]
            if rowData and rowData.Banned == L("yes") then
                line.DoPaint = line.Paint
                line.Paint = function(pnl, w, h)
                    surface.SetDrawColor(200, 100, 100)
                    surface.DrawRect(0, 0, w, h)
                    pnl:DoPaint(w, h)
                end
            end

            line.CharID = rowData and rowData.ID
            line.SteamID = targetSteamIDsafe
            if rowData and rowData.extraDetails then
                local colIndex = 10
                for _, name in ipairs(extraOrder) do
                    line:SetColumnText(colIndex, tostring(rowData.extraDetails[name] or ""))
                    colIndex = colIndex + 1
                end
            end
        end

        listView.OnRowRightClick = function(_, _, ln)
            if not (ln and ln.CharID) then return end
            if not (lia.command.hasAccess(LocalPlayer(), "charban") or lia.command.hasAccess(LocalPlayer(), "charwipe") or lia.command.hasAccess(LocalPlayer(), "charunban") or lia.command.hasAccess(LocalPlayer(), "charbanoffline") or lia.command.hasAccess(LocalPlayer(), "charwipeoffline") or lia.command.hasAccess(LocalPlayer(), "charunbanoffline")) then return end
            local owner = ln.SteamID and lia.util.getBySteamID(ln.SteamID)
            local dMenu = DermaMenu()
            if IsValid(owner) then
                if lia.command.hasAccess(LocalPlayer(), "charban") then
                    local opt1 = dMenu:AddOption(L("banCharacter"), function() LocalPlayer():ConCommand('say "/charban ' .. ln.CharID .. '"') end)
                    opt1:SetIcon("icon16/cancel.png")
                end

                if lia.command.hasAccess(LocalPlayer(), "charwipe") then
                    local opt1_5 = dMenu:AddOption(L("wipeCharacter"), function() LocalPlayer():ConCommand('say "/charwipe ' .. ln.CharID .. '"') end)
                    opt1_5:SetIcon("icon16/user_delete.png")
                end

                if lia.command.hasAccess(LocalPlayer(), "charunban") then
                    local opt2 = dMenu:AddOption(L("unbanCharacter"), function() LocalPlayer():ConCommand('say "/charunban ' .. ln.CharID .. '"') end)
                    opt2:SetIcon("icon16/accept.png")
                end
            else
                if lia.command.hasAccess(LocalPlayer(), "charbanoffline") then
                    local opt3 = dMenu:AddOption(L("banCharacterOffline"), function() LocalPlayer():ConCommand('say "/charbanoffline ' .. ln.CharID .. '"') end)
                    opt3:SetIcon("icon16/cancel.png")
                end

                if lia.command.hasAccess(LocalPlayer(), "charwipeoffline") then
                    local opt3_5 = dMenu:AddOption(L("wipeCharacterOffline"), function() LocalPlayer():ConCommand('say "/charwipeoffline ' .. ln.CharID .. '"') end)
                    opt3_5:SetIcon("icon16/user_delete.png")
                end

                if lia.command.hasAccess(LocalPlayer(), "charunbanoffline") then
                    local opt4 = dMenu:AddOption(L("unbanCharacterOffline"), function() LocalPlayer():ConCommand('say "/charunbanoffline ' .. ln.CharID .. '"') end)
                    opt4:SetIcon("icon16/accept.png")
                end
            end

            dMenu:Open()
        end
    end
end)