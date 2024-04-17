local sx, sy = ScrW(), ScrH()
local halfSx, halfSy = sx * 0.5, sy * 0.5
local marginx, marginy = sy * 0.1, sy * 0.1
local scrPos, x, y, teamColor, distance, factor, size, alpha
function MODULE:HUDPaint()
    local client = LocalPlayer()
    if (CAMI.PlayerHasAccess(client, "Staff Permissions - No Clip ESP Outside Staff Character", nil) or client:isStaffOnDuty()) and client:IsNoClipping() and not client:InVehicle() then
        for _, v in ipairs(ents.GetAll()) do
            if IsValid(v) and IsValid(client) and (v:isItem() or v:IsPlayer()) and v ~= LocalPlayer() then
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
                    if v:IsPlayer() and v ~= client then
                        teamColor = team.GetColor(v:Team())
                        surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, alpha)
                        surface.DrawLine(halfSx, halfSy, x, y)
                        lia.util.drawText(v:Name():gsub("#", "\226\128\139#"), x, y - size, ColorAlpha(teamColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)
                    end

                    if v:isItem() then
                        surface.SetDrawColor(30, 30, 30, alpha)
                        local name = "invalid"
                        if v.getItemTable and v:getItemTable() then name = v:getItemTable().name end
                        lia.util.drawText("item: " .. name, x, y - size, ColorAlpha(Color(220, 220, 220, 255), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)
                    end
                end
            end
        end
    end
end
