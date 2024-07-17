local sx, sy = ScrW(), ScrH()
local halfSx, halfSy = sx * 0.5, sy * 0.5
local marginx, marginy = sy * 0.1, sy * 0.1
local scrPos, x, y, teamColor, distance, factor, size, alpha
local ESP_Active = CreateClientConVar("esp", 0, true)
local ESP_Players = CreateClientConVar("esp_players", 0, true)
local ESP_Items = CreateClientConVar("esp_items", 0, true)
local ESP_Props = CreateClientConVar("esp_prop", 0, true)
local ESP_Entities = CreateClientConVar("esp_entities", 0, true)
function MODULE:SetupQuickMenu(menu)
    menu:addCheck("ESP", function(_, state) ESP_Active:SetBool(state) end, ESP_Active:GetBool())
    menu:addCheck("ESP Players", function(_, state) ESP_Players:SetBool(state) end, ESP_Players:GetBool())
    menu:addCheck("ESP Items", function(_, state) ESP_Items:SetBool(state) end, ESP_Items:GetBool())
    menu:addCheck("ESP Props", function(_, state) ESP_Props:SetBool(state) end, ESP_Props:GetBool())
    menu:addCheck("ESP Entities", function(_, state) ESP_Entities:SetBool(state) end, ESP_Entities:GetBool())
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