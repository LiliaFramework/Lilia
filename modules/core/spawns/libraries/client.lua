local ceil = math.ceil
local clmp = math.Clamp
local aprg, aprg2 = 0, 0
local respawnRequested = false
local hideRespawnKey = false
function MODULE:HUDPaint()
    local client = LocalPlayer()
    local respawnTime = lia.config.get("SpawnTime", 5)
    local spawnTimeOverride = hook.Run("OverrideSpawnTime", client, respawnTime)
    if spawnTimeOverride then respawnTime = spawnTimeOverride end
    local lastDeathTime = client:getNetVar("lastDeathTime", os.time())
    local timePassed = os.time() - lastDeathTime
    local timeLeft = clmp(respawnTime - timePassed, 0, respawnTime)
    local ft = FrameTime()
    if hook.Run("ShouldRespawnScreenAppear") == false then return end
    if client:getChar() then
        if client:Alive() then
            if aprg ~= 0 then
                aprg2 = clmp(aprg2 - ft * 1 / respawnTime * 2, 0, 1)
                if aprg2 == 0 then aprg = clmp(aprg - ft * 1 / respawnTime, 0, 1) end
                hideRespawnKey = true
            end
        else
            if aprg2 ~= 1 then
                aprg = clmp(aprg + ft * 1 / respawnTime * 0.8, 0, 1)
                if aprg >= 0.6 then aprg2 = clmp(aprg2 + ft * 1 / respawnTime * 0.6, 0, 1) end
            end
        end
    end

    if IsValid(lia.char.gui) and lia.gui.char:IsVisible() or not client:getChar() then return end
    if aprg > 0.01 then
        surface.SetDrawColor(0, 0, 0, ceil(aprg ^ 0.5 * 255))
        surface.DrawRect(-1, -1, ScrW() + 2, ScrH() + 2)
        local text = L("youHaveDied")
        surface.SetFont("liaHugeFont")
        local textW, textH = surface.GetTextSize(text)
        lia.util.drawText(text, ScrW() / 2 - textW / 2, ScrH() / 2 - textH / 2, ColorAlpha(color_white, aprg2 * 255), 0, 0, "liaHugeFont", aprg2 * 255)
        if not hideRespawnKey then
            local displayText = timeLeft > 0 and L("respawnIn", timeLeft) or L("respawnKey", input.GetKeyName(KEY_SPACE))
            surface.SetFont("liaHugeFont")
            local displayW, _ = surface.GetTextSize(displayText)
            lia.util.drawText(displayText, ScrW() / 2 - displayW / 2, ScrH() - 50, Color(255, 255, 255), 0, 1, "liaHugeFont")
        end

        if timeLeft <= 0 and input.IsKeyDown(KEY_SPACE) then
            if not respawnRequested then
                respawnRequested = true
                net.Start("request_respawn")
                net.SendToServer()
            end
        else
            respawnRequested = false
        end
    end
end
