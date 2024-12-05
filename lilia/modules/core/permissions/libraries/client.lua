local ESP_Active = CreateClientConVar("lilia_esp", 0, true)
local ESP_Players = CreateClientConVar("lilia_esp_players", 0, true)
local ESP_Items = CreateClientConVar("lilia_esp_items", 0, true)
local ESP_Props = CreateClientConVar("lilia_esp_prop", 0, true)
local ESP_Entities = CreateClientConVar("lilia_esp_entities", 0, true)
function MODULE:SetupQuickMenu(menu)
    menu:addCategory("ESP")
    local client = LocalPlayer()
    if client:getChar() and (client:HasPrivilege("Staff Permissions - No Clip ESP Outside Staff Character") or client:isStaffOnDuty()) then
        menu:addCheck("Toggle ESP", function(_, state) ESP_Active:SetBool(state) end, ESP_Active:GetBool())
        menu:addCheck("ESP Players", function(_, state) ESP_Players:SetBool(state) end, ESP_Players:GetBool())
        menu:addCheck("ESP Items", function(_, state) ESP_Items:SetBool(state) end, ESP_Items:GetBool())
        menu:addCheck("ESP Props", function(_, state) ESP_Props:SetBool(state) end, ESP_Props:GetBool())
        menu:addCheck("ESP Entities", function(_, state) ESP_Entities:SetBool(state) end, ESP_Entities:GetBool())
    end
end

function MODULE:HUDPaint()
    if not ESP_Active:GetBool() then return end
    local client = LocalPlayer()
    if not client:getChar() then return end
    local hasPrivilege = client:HasPrivilege("Staff Permissions - No Clip ESP Outside Staff Character")
    local isStaffOnDuty = client:isStaffOnDuty()
    if not (hasPrivilege or isStaffOnDuty) then return end
    if not client:IsNoClipping() or client:hasValidVehicle() then return end
    local sx, sy = ScrW(), ScrH()
    local marginx, marginy = sx * 0.1, sy * 0.1
    for _, ent in ipairs(ents.GetAll()) do
        if not IsValid(ent) or ent == client then continue end
        local isItem = ent:isItem() and ESP_Items:GetBool()
        local isPlayer = ent:IsPlayer() and ESP_Players:GetBool()
        local isProp = ent:isProp() and ESP_Props:GetBool()
        local isSpecialEntity = table.HasValue(self.NoClipESPEntities or {}, ent:GetClass()) and ESP_Entities:GetBool()
        -- Skip if none of the conditions match
        if not (isItem or isPlayer or isProp or isSpecialEntity) then continue end
        local vPos = ent:GetPos()
        local clientPos = client:GetPos()
        if not (vPos and clientPos) then continue end
        local scrPos = vPos:ToScreen()
        if not scrPos.visible then continue end
        local x = math.Clamp(scrPos.x, marginx, sx - marginx)
        local y = math.Clamp(scrPos.y, marginy, sy - marginy)
        local distanceSq = clientPos:DistToSqr(vPos)
        local maxDistanceSq = 4096
        local factor = 1 - math.Clamp(distanceSq / maxDistanceSq, 0, 1)
        local size = math.max(20, 48 * factor)
        local alpha = math.Clamp(255 * factor, 120, 255)
        local colorToUse = Color(255, 255, 255, alpha)
        if isPlayer then
            colorToUse = ColorAlpha(self.ESPColors["Players"] or Color(0, 0, 0), alpha)
        elseif isProp then
            colorToUse = ColorAlpha(self.ESPColors["Props"] or Color(0, 0, 0), alpha)
        elseif isSpecialEntity then
            colorToUse = ColorAlpha(self.ESPColors["Entities"] or Color(0, 0, 0), alpha)
        elseif isItem then
            colorToUse = ColorAlpha(self.ESPColors["Items"] or Color(0, 0, 0), alpha)
        end

        surface.SetDrawColor(colorToUse.r, colorToUse.g, colorToUse.b, colorToUse.a)
        surface.DrawRect(x - size / 2, y - size / 2, size, size)
        local textColor = ColorAlpha(colorToUse, 255)
        local fontSize = "liaMediumFont"
        if isPlayer then
            local playerName = ent:Name():gsub("#", "\226\128\139#")
            draw.SimpleTextOutlined(playerName, fontSize, x, y - size, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200))
        end

        if isProp then
            local modelName = ent:GetModel() or "Unknown"
            draw.SimpleTextOutlined("Prop Model: " .. modelName, fontSize, x, y - size, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200))
        end

        if isSpecialEntity then
            local className = ent:GetClass() or "Unknown"
            draw.SimpleTextOutlined("Entity Class: " .. className, fontSize, x, y - size, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200))
        end

        if isItem then
            local itemTable = ent.getItemTable and ent:getItemTable()
            local itemName = (itemTable and itemTable.name) or "invalid"
            draw.SimpleTextOutlined("Item: " .. itemName, fontSize, x, y - size, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200))
        end
    end
end

function MODULE:SpawnMenuOpen()
    local client = LocalPlayer()
    if self.SpawnMenuLimit then return client:getChar():hasFlags("pet") or client:isStaffOnDuty() or client:HasPrivilege("Spawn Permissions - Can Spawn Props") end
end

concommand.Add("dev_GetCameraOrigin", function(client)
    if client:isStaff() then
        LiliaInformation("origin = (" .. math.ceil(client:GetPos().x) .. ", " .. math.ceil(client:GetPos().y) .. ", " .. math.ceil(client:GetPos().z) .. ")")
        LiliaInformation("angles = (" .. math.ceil(client:GetAngles().x) .. ", " .. math.ceil(client:GetAngles().y) .. ", " .. math.ceil(client:GetAngles().z) .. ")")
    end
end)

concommand.Add("vgui_cleanup", function()
    for _, v in pairs(vgui.GetWorldPanel():GetChildren()) do
        if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then v:Remove() end
    end
end, nil, "Removes every panel that you have left over (like that errored DFrame filling up your screen)")

concommand.Add("weighpoint_stop", function() hook.Add("HUDPaint", "WeighPoint", function() end) end)
concommand.Add("dev_GetEntPos", function(client) if client:isStaff() then LiliaInformation(client:GetTracedEntity():GetPos().x, client:GetTracedEntity():GetPos().y, client:GetTracedEntity():GetPos().z) end end)
concommand.Add("dev_GetEntAngles", function(client) if client:isStaff() then LiliaInformation(math.ceil(client:GetTracedEntity():GetAngles().x) .. ", " .. math.ceil(client:GetTracedEntity():GetAngles().y) .. ", " .. math.ceil(client:GetTracedEntity():GetAngles().z)) end end)
concommand.Add("dev_GetRoundEntPos", function(client) if client:isStaff() then LiliaInformation(math.ceil(client:GetTracedEntity():GetPos().x) .. ", " .. math.ceil(client:GetTracedEntity():GetPos().y) .. ", " .. math.ceil(client:GetTracedEntity():GetPos().z)) end end)
concommand.Add("dev_GetPos", function(client) if client:isStaff() then LiliaInformation(math.ceil(client:GetPos().x) .. ", " .. math.ceil(client:GetPos().y) .. ", " .. math.ceil(client:GetPos().z)) end end)