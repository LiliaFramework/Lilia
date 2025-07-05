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

concommand.Add("dev_GetCameraOrigin", function(client)
    if client:isStaff() then
        lia.information(L("originLabel", math.ceil(client:GetPos().x), math.ceil(client:GetPos().y), math.ceil(client:GetPos().z)))
        lia.information(L("anglesLabel", math.ceil(client:GetAngles().x), math.ceil(client:GetAngles().y), math.ceil(client:GetAngles().z)))
    end
end)

concommand.Add("vgui_cleanup", function()
    for _, v in pairs(vgui.GetWorldPanel():GetChildren()) do
        if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then v:Remove() end
    end
end, nil, "Removes every panel that you have left over (like that errored DFrame filling up your screen)")

concommand.Add("weighpoint_stop", function() hook.Add("HUDPaint", "WeighPoint", function() end) end)
concommand.Add("dev_GetEntPos", function(client) if client:isStaff() then lia.information(client:getTracedEntity():GetPos().x, client:getTracedEntity():GetPos().y, client:getTracedEntity():GetPos().z) end end)
concommand.Add("dev_GetEntAngles", function(client) if client:isStaff() then lia.information(math.ceil(client:getTracedEntity():GetAngles().x) .. ", " .. math.ceil(client:getTracedEntity():GetAngles().y) .. ", " .. math.ceil(client:getTracedEntity():GetAngles().z)) end end)
concommand.Add("dev_GetRoundEntPos", function(client) if client:isStaff() then lia.information(math.ceil(client:getTracedEntity():GetPos().x) .. ", " .. math.ceil(client:getTracedEntity():GetPos().y) .. ", " .. math.ceil(client:getTracedEntity():GetPos().z)) end end)
concommand.Add("dev_GetPos", function(client) if client:isStaff() then lia.information(math.ceil(client:GetPos().x) .. ", " .. math.ceil(client:GetPos().y) .. ", " .. math.ceil(client:GetPos().z)) end end)
