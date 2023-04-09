-- Create a setting to see if the player will teleport back after noclipping.
LIA_CVAR_OBSTPBACK = CreateClientConVar("lia_obstpback", 0, true, true)
LIA_CVAR_ADMINESP = CreateClientConVar("lia_obsesp", 1, true, true)
LIA_CVAR_ADMINESPAVANCED = CreateClientConVar("lia_obsespadvanced", 1, true, true)
LIA_CVAR_ITEMESP = CreateClientConVar("lia_obsitemesp", 1, true, true)
local client, sx, sy, scrPos, marginx, marginy, x, y, teamColor, distance, factor, size, alpha
local dimDistance = 1024

function PLUGIN:HUDPaint()
    client = LocalPlayer()

    if client:IsAdmin() and client:GetMoveType() == MOVETYPE_NOCLIP and not client:InVehicle() and LIA_CVAR_ADMINESP:GetBool() and LIA_CVAR_ITEMESP:GetBool() then
        local sx, sy = surface.ScreenWidth(), surface.ScreenHeight()

        for k, v in ipairs(ents.GetAll()) do
            if v:GetClass() == "lia_item" then
                local scrPos = v:GetPos():ToScreen()
                local marginx, marginy = sy * .1, sy * .1
                local x, y = math.Clamp(scrPos.x, marginx, sx - marginx), math.Clamp(scrPos.y, marginy, sy - marginy)
                local distance = client:GetPos():Distance(v:GetPos())
                local factor = 1 - math.Clamp(distance / 1024, 0, 1)
                local size = math.max(10, 32 * factor)
                local alpha = math.Clamp(255 * factor, 80, 255)
                surface.SetDrawColor(30, 30, 30, alpha)
                surface.DrawRect(x - size / 2, y - size / 2, size, size)
                local name = "invalid"

                if v.getItemTable and v:getItemTable() then
                    name = v:getItemTable().name
                end

                lia.util.drawText("item: " .. name, x, y - size, ColorAlpha(Color(220, 220, 220, 255), alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)
            end
        end
    end

    if client:IsAdmin() and client:GetMoveType() == MOVETYPE_NOCLIP and not client:InVehicle() and LIA_CVAR_ADMINESP:GetBool() then
        sx, sy = ScrW(), ScrH()

        for k, v in ipairs(player.GetAll()) do
            if v == client then continue end
            scrPos = v:GetPos():ToScreen()
            marginx, marginy = sy * .1, sy * .1
            x, y = math.Clamp(scrPos.x, marginx, sx - marginx), math.Clamp(scrPos.y, marginy, sy - marginy)
            teamColor = team.GetColor(v:Team())
            distance = client:GetPos():Distance(v:GetPos())
            factor = 1 - math.Clamp(distance / dimDistance, 0, 1)
            size = math.max(10, 32 * factor)
            alpha = math.Clamp(255 * factor, 80, 255)
            surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, alpha)

            if LIA_CVAR_ADMINESPAVANCED:GetBool() then
                surface.DrawLine(sx * 0.5, sy * 0.5, x, y)
                surface.DrawRect(x - size / 2, y - size / 2, size, size)
            end

            lia.util.drawText(v:Name():gsub("#", "\226\128\139#"), x, y - size, ColorAlpha(teamColor, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, alpha)
        end
    end
end

function PLUGIN:SetupQuickMenu(menu)
    if LocalPlayer():IsAdmin() then
        local buttonESP = menu:addCheck(L"toggleESP", function(panel, state)
            local buttonItem = menu:addCheck("Toggle Item ESP", function(panel, state)
                if state then
                    RunConsoleCommand("lia_obsitemesp", "1")
                else
                    RunConsoleCommand("lia_obsitemesp", "0")
                end
            end, LIA_CVAR_ITEMESP:GetBool())

            menu:addSpacer()

            if state then
                RunConsoleCommand("lia_obsesp", "1")
            else
                RunConsoleCommand("lia_obsesp", "0")
            end
        end, LIA_CVAR_ADMINESP:GetBool())

        local buttonESPAdvanced = menu:addCheck(L"toggleESPAdvanced", function(panel, state)
            if state then
                RunConsoleCommand("lia_obsespadvanced", "1")
            else
                RunConsoleCommand("lia_obsespadvanced", "0")
            end
        end, LIA_CVAR_ADMINESPAVANCED:GetBool())

        local buttonTP = menu:addCheck(L"toggleObserverTP", function(panel, state)
            if state then
                RunConsoleCommand("lia_obstpback", "1")
            else
                RunConsoleCommand("lia_obstpback", "0")
            end
        end, LIA_CVAR_OBSTPBACK:GetBool())

        menu:addSpacer()
    end
end

function PLUGIN:ShouldDrawEntityInfo(entity)
    if IsValid(entity) then
        if entity:IsPlayer() or IsValid(entity:getNetVar("player")) then
            if entity.IsAdmin and entity:IsAdmin() and entity:GetMoveType() == MOVETYPE_NOCLIP then return false end
        end
    end
end