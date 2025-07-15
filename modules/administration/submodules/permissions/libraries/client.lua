local ESP_DrawnEntities = {
    lia_bodygrouper = true,
    lia_vendor = true,
}

function MODULE:PrePlayerDraw(client)
    if not IsValid(client) then return end
    if client:isNoClipping() then return true end
end

function MODULE:HUDPaint()
    if not lia.option.get("espActive") then return end
    local client = LocalPlayer()
    if not client:getChar() or not client:IsValid() or not client:IsPlayer() then return end
    if not client:isNoClipping() and not client:hasValidVehicle() then return end
    if not (client:hasPrivilege("Staff Permissions - No Clip ESP Outside Staff Character") or client:isStaffOnDuty()) then return end
    local marginx, marginy = ScrW() * 0.1, ScrH() * 0.1
    local maxDistanceSq = 4096
    for _, ent in ents.Iterator() do
        if not IsValid(ent) or ent == client then continue end
        local entityType, label
        if ent:IsPlayer() and lia.option.get("espPlayers") then
            entityType, label = "Players", ent:Name():gsub("#", "\226\128\139#")
        elseif ent.isItem and ent:isItem() and lia.option.get("espItems") then
            entityType = "Items"
            local itemTable = ent.getItemTable and ent:getItemTable()
            label = L("itemESPLabel", itemTable and itemTable.name or L("unknown"))
        elseif ent.isProp and ent:isProp() and lia.option.get("espProps") then
            entityType = "Props"
            label = L("propModelESPLabel", ent:GetModel() or L("unknown"))
        elseif ESP_DrawnEntities[ent:GetClass()] and lia.option.get("espEntities") then
            entityType = "Entities"
            label = L("entityClassESPLabel", ent:GetClass() or L("unknown"))
        end

        if not entityType then continue end
        local vPos, clientPos = ent:GetPos(), client:GetPos()
        if not vPos or not clientPos then continue end
        local scrPos = vPos:ToScreen()
        if not scrPos.visible then continue end
        local distanceSq = clientPos:DistToSqr(vPos)
        local factor = 1 - math.Clamp(distanceSq / maxDistanceSq, 0, 1)
        local size = math.max(20, 48 * factor)
        local alpha = math.Clamp(255 * factor, 120, 255)
        local colorToUse = ColorAlpha(lia.config.get("esp" .. entityType .. "Color") or Color(255, 255, 255), alpha)
        local x, y = math.Clamp(scrPos.x, marginx, ScrW() - marginx), math.Clamp(scrPos.y, marginy, ScrH() - marginy)
        surface.SetDrawColor(colorToUse.r, colorToUse.g, colorToUse.b, colorToUse.a)
        surface.DrawRect(x - size / 2, y - size / 2, size, size)
        draw.SimpleTextOutlined(label, "liaMediumFont", x, y - size, ColorAlpha(colorToUse, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200))
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
        {name = "ID", field = "ID"},
        {name = "Name", field = "Name"},
        {name = "Desc", field = "Desc"},
        {name = "Faction", field = "Faction"},
        {name = "Banned", field = "Banned"},
        {name = "BanningAdminName", field = "BanningAdminName"},
        {name = "BanningAdminSteamID", field = "BanningAdminSteamID"},
        {name = "BanningAdminRank", field = "BanningAdminRank"},
        {name = "CharMoney", field = "Money"}
    }
    for _, name in ipairs(extraOrder) do
        table.insert(columns, {name = name, field = name})
    end

    local _, listView = lia.util.CreateTableUI("Charlist for SteamID64: " .. targetSteamIDsafe, columns, sendData)

    if IsValid(listView) then
        for _, line in ipairs(listView:GetLines()) do
            local dataIndex = line:GetID()
            local rowData = sendData[dataIndex]
            if rowData and rowData.Banned == "Yes" then
                line.DoPaint = line.Paint
                line.Paint = function(pnl, w, h)
                    surface.SetDrawColor(200, 100, 100)
                    surface.DrawRect(0, 0, w, h)
                    pnl:DoPaint(w, h)
                end
            end
            line.CharID = rowData and rowData.ID
            if rowData and rowData.extraDetails then
                local colIndex = 10
                for _, name in ipairs(extraOrder) do
                    line:SetColumnText(colIndex, tostring(rowData.extraDetails[name] or ""))
                    colIndex = colIndex + 1
                end
            end
        end

        listView.OnRowRightClick = function(_, _, ln)
            if ln and ln.CharID and (LocalPlayer():hasPrivilege("Commands - Unban Offline") or LocalPlayer():hasPrivilege("Commands - Ban Offline")) then
                local dMenu = DermaMenu()
                if LocalPlayer():hasPrivilege("Commands - Unban Offline") then
                    local opt1 = dMenu:AddOption("Ban Character", function()
                        LocalPlayer():ConCommand([[say "/charbanoffline ]] .. ln.CharID .. [["]])
                    end)
                    opt1:SetIcon("icon16/cancel.png")
                end

                if LocalPlayer():hasPrivilege("Commands - Ban Offline") then
                    local opt2 = dMenu:AddOption("Unban Character", function()
                        LocalPlayer():ConCommand([[say "/charunbanoffline ]] .. ln.CharID .. [["]])
                    end)
                    opt2:SetIcon("icon16/accept.png")
                end

                dMenu:Open()
            end
        end
    end
end)
