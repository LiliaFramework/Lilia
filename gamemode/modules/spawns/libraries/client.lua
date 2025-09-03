﻿local ceil, clamp = math.ceil, math.Clamp
local fade, shadowFade = 0, 0
local respawnReq, hideKey = false, false
function MODULE:HUDPaint()
    local ply, ft = LocalPlayer(), FrameTime()
    if not ply:getChar() then return end
    local baseTime = lia.config.get("SpawnTime", 5)
    baseTime = hook.Run("OverrideSpawnTime", ply, baseTime) or baseTime
    local lastDeath = ply:getNetVar("lastDeathTime", os.time())
    local left = clamp(baseTime - (os.time() - lastDeath), 0, baseTime)
    if hook.Run("ShouldRespawnScreenAppear") == false then return end
    if ply:getChar() and ply:Alive() then
        if fade > 0 then
            shadowFade = clamp(shadowFade - ft * 2 / baseTime, 0, 1)
            if shadowFade == 0 then fade = clamp(fade - ft / baseTime, 0, 1) end
            hideKey = true
        end
    else
        if shadowFade < 1 then
            fade = clamp(fade + ft * 0.8 / baseTime, 0, 1)
            if fade >= 0.6 then shadowFade = clamp(shadowFade + ft * 0.6 / baseTime, 0, 1) end
        end
    end

    if IsValid(lia.char.gui) and lia.gui.char:IsVisible() or not ply:getChar() then return end
    if fade <= 0.01 then return end
    surface.SetDrawColor(0, 0, 0, ceil(fade ^ 0.5 * 255))
    surface.DrawRect(-1, -1, ScrW() + 2, ScrH() + 2)
    local txtKey = "youHaveDied"
    surface.SetFont("liaHugeFont")
    local w, h = surface.GetTextSize(L(txtKey))
    local x, y = (ScrW() - w) / 2, (ScrH() - h) / 2
    lia.util.drawText(L(txtKey), x + 2, y + 2, Color(0, 0, 0, ceil(shadowFade * 255)), 0, 0, "liaHugeFont")
    lia.util.drawText(L(txtKey), x, y, Color(255, 255, 255, ceil(shadowFade * 255)), 0, 0, "liaHugeFont")
    if not hideKey then
        surface.SetFont("liaMediumFont")
        local dw = select(1, surface.GetTextSize(left > 0 and L("respawnIn", left) or L("respawnKey", input.GetKeyName(KEY_SPACE))))
        local dx, dy = (ScrW() - dw) / 2, y + h + 10
        lia.util.drawText(left > 0 and L("respawnIn", left) or L("respawnKey", input.GetKeyName(KEY_SPACE)), dx + 1, dy + 1, Color(0, 0, 0, 255), 0, 0, "liaMediumFont")
        lia.util.drawText(left > 0 and L("respawnIn", left) or L("respawnKey", input.GetKeyName(KEY_SPACE)), dx, dy, Color(255, 255, 255, 255), 0, 0, "liaMediumFont")
    end

    if left <= 0 and input.IsKeyDown(KEY_SPACE) then
        if not respawnReq then
            respawnReq = true
            net.Start("request_respawn")
            net.SendToServer()
        end
    else
        respawnReq = false
    end
end