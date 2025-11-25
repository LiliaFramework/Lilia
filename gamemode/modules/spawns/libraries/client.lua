local ceil, clamp = math.ceil, math.Clamp
local fade, shadowFade = 0, 0
local hideKey = false
local fastFade = false
function MODULE:HUDPaint()
    local ply, ft = LocalPlayer(), FrameTime()
    if not ply:getChar() then return end
    local baseTime = lia.config.get("SpawnTime", 5)
    baseTime = hook.Run("OverrideSpawnTime", ply, baseTime) or baseTime
    local lastDeath = ply:getNetVar("lastDeathTime", os.time())
    local left = clamp(baseTime - (os.time() - lastDeath), 0, baseTime)
    if left >= baseTime and not ply:Alive() then left = baseTime end
    if not ply:Alive() and lastDeath > 0 and (os.time() - lastDeath) > (baseTime + 10) then
        net.Start("liaPlayerRespawn")
        net.SendToServer()
        return
    end

    if hook.Run("ShouldRespawnScreenAppear") == false then return end
    if ply:getChar() and ply:Alive() then
        if fade > 0 then
            shadowFade = clamp(shadowFade - ft * 2 / baseTime, 0, 1)
            local fadeSpeed = fastFade and (ft * 4) or (ft / baseTime)
            if shadowFade == 0 then fade = clamp(fade - fadeSpeed, 0, 1) end
            if fade <= 0 then fastFade = false end
            hideKey = true
        end
    else
        hideKey = false
        if shadowFade < 1 then
            fade = clamp(fade + ft * 4.0 / baseTime, 0, 1)
            if fade >= 0.1 then shadowFade = clamp(shadowFade + ft * 2.0 / baseTime, 0, 1) end
        end
    end

    if IsValid(lia.char.gui) and lia.gui.char:IsVisible() or not ply:getChar() then return end
    if fade <= 0.01 then return end
    surface.SetDrawColor(0, 0, 0, ceil(fade ^ 0.5 * 255))
    surface.DrawRect(-1, -1, ScrW() + 2, ScrH() + 2)
    local txtKey = "youHaveDied"
    surface.SetFont("LiliaFont.72")
    local w, h = surface.GetTextSize(L(txtKey))
    local x, y = (ScrW() - w) / 2, (ScrH() - h) / 2
    lia.util.drawText(L(txtKey), x + 2, y + 2, Color(0, 0, 0, ceil(shadowFade * 255)), 0, 0, "LiliaFont.72")
    lia.util.drawText(L(txtKey), x, y, Color(255, 255, 255, ceil(shadowFade * 255)), 0, 0, "LiliaFont.72")
    if not hideKey then
        surface.SetFont("LiliaFont.25")
        local text
        if left <= 0 then
            text = L("pressAnyKeyToRespawn")
        else
            text = L("respawnIn", left)
        end

        local dw = select(1, surface.GetTextSize(text))
        local dx, dy = (ScrW() - dw) / 2, y + h + 10
        lia.util.drawText(text, dx + 1, dy + 1, Color(0, 0, 0, 255), 0, 0, "LiliaFont.25")
        lia.util.drawText(text, dx, dy, Color(255, 255, 255, 255), 0, 0, "LiliaFont.25")
        local timePassed = os.time() - lastDeath
        if timePassed >= (baseTime * 1.25) then
            surface.SetFont("LiliaFont.17")
            local hintText = L("forceRespawnHint")
            local hw = select(1, surface.GetTextSize(hintText))
            local hx, hy = (ScrW() - hw) / 2, dy + 50
            lia.util.drawText(hintText, hx + 1, hy + 1, Color(0, 0, 0, 200), 0, 0, "LiliaFont.17")
            lia.util.drawText(hintText, hx, hy, Color(255, 255, 0, 200), 0, 0, "LiliaFont.17")
        end
    end
end

function MODULE:PlayerButtonDown(client, key)
    local ply = LocalPlayer()
    local char = ply:getChar()
    if key ~= KEY_SPACE or not IsFirstTimePredicted() or not IsValid(ply) or ply ~= client or ply:Alive() or not char then return end
    local baseTime = lia.config.get("SpawnTime", 5)
    baseTime = hook.Run("OverrideSpawnTime", ply, baseTime) or baseTime
    local lastDeath = ply:getNetVar("lastDeathTime", os.time())
    local left = math.Clamp(baseTime - (os.time() - lastDeath), 0, baseTime)
    if left > 0 then return end
    fastFade = true
    net.Start("liaPlayerRespawn")
    net.SendToServer()
end
