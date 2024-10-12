local sx, sy = ScrW(), ScrH()
local halfSx, halfSy = sx * 0.5, sy * 0.5
local marginx, marginy = sy * 0.1, sy * 0.1
local scrPos, x, y, teamColor, distance, factor, size, alpha
local ESP_Active = CreateClientConVar("lilia_esp", 0, true)
local ESP_Players = CreateClientConVar("lilia_esp_players", 0, true)
local ESP_Items = CreateClientConVar("lilia_esp_items", 0, true)
local ESP_Props = CreateClientConVar("lilia_esp_prop", 0, true)
local ESP_Entities = CreateClientConVar("lilia_esp_entities", 0, true)
function MODULE:SetupQuickMenu(menu)
    local client = LocalPlayer()
    if client:getChar() and (client:HasPrivilege("Staff Permissions - No Clip ESP Outside Staff Character") or client:isStaffOnDuty()) then
        menu:addCheck("ESP", function(_, state) ESP_Active:SetBool(state) end, ESP_Active:GetBool())
        menu:addCheck("ESP Players", function(_, state) ESP_Players:SetBool(state) end, ESP_Players:GetBool())
        menu:addCheck("ESP Items", function(_, state) ESP_Items:SetBool(state) end, ESP_Items:GetBool())
        menu:addCheck("ESP Props", function(_, state) ESP_Props:SetBool(state) end, ESP_Props:GetBool())
        menu:addCheck("ESP Entities", function(_, state) ESP_Entities:SetBool(state) end, ESP_Entities:GetBool())
    end
end

function MODULE:HUDPaint()
    if not ESP_Active:GetBool() then return end
    local client = LocalPlayer()
    if client:getChar() and (client:HasPrivilege("Staff Permissions - No Clip ESP Outside Staff Character") or client:isStaffOnDuty()) and client:IsNoClipping() and not client:hasValidVehicle() then
        for _, v in ents.Iterator() do
            if IsValid(v) and (v:isItem() or v:IsPlayer() or v:isProp() or table.HasValue(self.NoClipESPEntities, v:GetClass())) and v ~= LocalPlayer() then
                local vPos = v:GetPos()
                local clientPos = client:GetPos()
                if vPos ~= nil and clientPos then
                    scrPos = vPos:ToScreen()
                    x, y = math.Clamp(scrPos.x, marginx, sx - marginx), math.Clamp(scrPos.y, marginy, sy - marginy)
                    distance = clientPos:DistToSqr(vPos)
                    factor = 1 - math.Clamp(distance / 1024, 0, 1)
                    size = math.max(10, 32 * factor)
                    alpha = math.Clamp(255 * factor, 80, 255)
                    surface.DrawRect(x - size / 2, y - size / 2, size, size)
                    if v:IsPlayer() and v ~= client and ESP_Players:GetBool() then
                        teamColor = team.GetColor(v:Team())
                        surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, alpha)
                        surface.DrawLine(halfSx, halfSy, x, y)
                        lia.util.drawText(v:Name():gsub("#", "\226\128\139#"), x, y - size, ColorAlpha(teamColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)
                    end

                    if v:isProp() and ESP_Props:GetBool() then
                        surface.SetDrawColor(30, 30, 30, alpha)
                        local name = v:GetModel()
                        lia.util.drawText("Prop Model: " .. name, x, y - size, ColorAlpha(Color(255, 255, 255, 255), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)
                    end

                    if table.HasValue(self.NoClipESPEntities, v:GetClass()) and ESP_Entities:GetBool() then
                        surface.SetDrawColor(30, 30, 30, alpha)
                        local name = v:GetClass()
                        lia.util.drawText("Entity Class: " .. name, x, y - size, ColorAlpha(Color(255, 255, 255, 255), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)
                    end

                    if v:isItem() and ESP_Items:GetBool() then
                        surface.SetDrawColor(30, 30, 30, alpha)
                        local name = ((v.getItemTable and v:getItemTable()) and v:getItemTable().name) or "invalid"
                        lia.util.drawText("item: " .. name, x, y - size, ColorAlpha(Color(255, 255, 255, 255), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)
                    end
                end
            end
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