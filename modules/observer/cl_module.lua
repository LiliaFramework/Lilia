LIA_CVAR_OBSTPBACK = CreateClientConVar("lia_obstpback", 0, true, true)
LIA_CVAR_ADMINESP = CreateClientConVar("lia_obsesp", 1, true, true)
LIA_CVAR_ADMINESPAVANCED = CreateClientConVar("lia_obsespadvanced", 1, true, true)
LIA_CVAR_ITEMESP = CreateClientConVar("lia_obsitemesp", 1, true, true)
local playerLocal, screenWidth, screenHeight, screenPos, marginX, marginY, screenX, screenY, teamColor, playerDistance, factor, playerSize, playerAlpha
local dimDistance = 1024
function MODULE:HUDPaint()
    playerLocal = LocalPlayer()
    if playerLocal:IsAdmin() and playerLocal:IsNoClipping() and not playerLocal:InVehicle() and LIA_CVAR_ADMINESP:GetBool() and LIA_CVAR_ITEMESP:GetBool() then
        screenWidth, screenHeight = ScrW(), ScrH()
        for _, ent in ipairs(ents.GetAll()) do
            if ent:GetClass() == "lia_item" then
                screenPos = ent:GetPos():ToScreen()
                marginX, marginY = screenHeight * 0.1, screenHeight * 0.1
                screenX, screenY = math.Clamp(screenPos.x, marginX, screenWidth - marginX), math.Clamp(screenPos.y, marginY, screenHeight - marginY)
                playerDistance = playerLocal:GetPos():Distance(ent:GetPos())
                factor = 1 - math.Clamp(playerDistance / 1024, 0, 1)
                playerSize = math.max(10, 32 * factor)
                playerAlpha = math.Clamp(255 * factor, 80, 255)
                surface.SetDrawColor(30, 30, 30, playerAlpha)
                surface.DrawRect(screenX - playerSize / 2, screenY - playerSize / 2, playerSize, playerSize)
                local name = "invalid"
                if ent.getItemTable and ent:getItemTable() then
                    name = ent:getItemTable().name
                end

                lia.util.drawText("item: " .. name, screenX, screenY - playerSize, ColorAlpha(Color(220, 220, 220, 255), playerAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, playerAlpha)
            end
        end
    end

    if playerLocal:IsAdmin() and playerLocal:IsNoClipping() and not playerLocal:InVehicle() and LIA_CVAR_ADMINESP:GetBool() then
        screenWidth, screenHeight = ScrW(), ScrH()
        for _, otherPlayer in ipairs(player.GetAll()) do
            if otherPlayer == playerLocal then continue end
            screenPos = otherPlayer:GetPos():ToScreen()
            marginX, marginY = screenHeight * 0.1, screenHeight * 0.1
            screenX, screenY = math.Clamp(screenPos.x, marginX, screenWidth - marginX), math.Clamp(screenPos.y, marginY, screenHeight - marginY)
            teamColor = team.GetColor(otherPlayer:Team())
            playerDistance = playerLocal:GetPos():Distance(otherPlayer:GetPos())
            factor = 1 - math.Clamp(playerDistance / dimDistance, 0, 1)
            playerSize = math.max(10, 32 * factor)
            playerAlpha = math.Clamp(255 * factor, 80, 255)
            surface.SetDrawColor(teamColor.r, teamColor.g, teamColor.b, playerAlpha)
            if LIA_CVAR_ADMINESPAVANCED:GetBool() then
                surface.DrawLine(screenWidth * 0.5, screenHeight * 0.5, screenX, screenY)
                surface.DrawRect(screenX - playerSize / 2, screenY - playerSize / 2, playerSize, playerSize)
            end

            lia.util.drawText(otherPlayer:Name():gsub("#", "\226\128\139#"), screenX, screenY - playerSize, ColorAlpha(teamColor, playerAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, playerAlpha)
        end
    end
end

--------------------------------------------------------------------------------------------------------
function MODULE:SetupQuickMenu(menu)
    if LocalPlayer():IsAdmin() then
        menu:addCheck(
            L"toggleESP",
            function(_, outerState)
                menu:addCheck(
                    "Toggle Item ESP",
                    function(_, innerState)
                        if innerState then
                            RunConsoleCommand("lia_obsitemesp", "1")
                        else
                            RunConsoleCommand("lia_obsitemesp", "0")
                        end
                    end, LIA_CVAR_ITEMESP:GetBool()
                )

                menu:addSpacer()
                if outerState then
                    RunConsoleCommand("lia_obsesp", "1")
                else
                    RunConsoleCommand("lia_obsesp", "0")
                end
            end, LIA_CVAR_ADMINESP:GetBool()
        )

        menu:addCheck(
            L"toggleESPAdvanced",
            function(_, state)
                if state then
                    RunConsoleCommand("lia_obsespadvanced", "1")
                else
                    RunConsoleCommand("lia_obsespadvanced", "0")
                end
            end, LIA_CVAR_ADMINESPAVANCED:GetBool()
        )

        menu:addCheck(
            L"toggleObserverTP",
            function(_, state)
                if state then
                    RunConsoleCommand("lia_obstpback", "1")
                else
                    RunConsoleCommand("lia_obstpback", "0")
                end
            end, LIA_CVAR_OBSTPBACK:GetBool()
        )

        menu:addSpacer()
    end
end

--------------------------------------------------------------------------------------------------------
function MODULE:ShouldDrawEntityInfo(entity)
    if IsValid(entity) and entity:IsPlayer() or IsValid(entity:getNetVar("player")) and entity.IsAdmin and entity:IsAdmin() and entity:IsNoClipping() then return false end
end
--------------------------------------------------------------------------------------------------------