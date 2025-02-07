local ceil = math.ceil
local clmp = math.Clamp
local w, h = ScrW(), ScrH()
local aprg, aprg2 = 0, 0
local respawnRequested = false
function MODULE:HUDPaint()
    local client = LocalPlayer()
    local respawnTime = lia.config.get("SpawnTime", 5)
    local lastDeathTime = client:getNetVar("lastDeathTime", os.time())
    local timePassed = os.time() - lastDeathTime
    local timeLeft = clmp(respawnTime - timePassed, 0, respawnTime)
    local ft = FrameTime()
    print("[DEBUG] Respawn Time:", respawnTime)
    print("[DEBUG] Last Death Time:", lastDeathTime)
    print("[DEBUG] Time Passed:", timePassed)
    print("[DEBUG] Time Left:", timeLeft)
    print("[DEBUG] Frame Time:", ft)
    if client:getChar() then
        if client:Alive() then
            print("[DEBUG] Client is alive.")
            if aprg ~= 0 then
                aprg2 = clmp(aprg2 - ft * (1 / respawnTime * 2), 0, 1)
                if aprg2 == 0 then aprg = clmp(aprg - ft * (1 / respawnTime), 0, 1) end
            end
        else
            print("[DEBUG] Client is dead.")
            if aprg2 ~= 1 then
                aprg = clmp(aprg + ft * (1 / respawnTime * 0.8), 0, 1)
                if aprg >= 0.6 then aprg2 = clmp(aprg2 + ft * (1 / respawnTime * 0.6), 0, 1) end
            end
        end
    end

    if IsValid(lia.char.gui) and lia.gui.char:IsVisible() or not client:getChar() then
        print("[DEBUG] Character GUI is visible or client has no character. Exiting HUDPaint.")
        return
    end

    if aprg > 0.01 then
        print("[DEBUG] Drawing death screen overlay. aprg:", aprg, " aprg2:", aprg2)
        surface.SetDrawColor(0, 0, 0, ceil(aprg ^ 0.5 * 255))
        surface.DrawRect(-1, -1, w + 2, h + 2)
        local text = L("youHaveDied")
        surface.SetFont("liaDynFontMedium")
        local textW, textH = surface.GetTextSize(text)
        lia.util.drawText(text, w / 2 - textW / 2, h / 2 - textH / 2, ColorAlpha(color_white, aprg2 * 255), 0, 0, "liaDynFontMedium", aprg2 * 255)
        local displayText = timeLeft > 0 and L("respawnIn", timeLeft) or L("respawnKey", input.GetKeyName(KEY_SPACE))
        surface.SetFont("liaBigFont")
        local displayW, _ = surface.GetTextSize(displayText)
        lia.util.drawText(displayText, w / 2 - displayW / 2, h - 50, Color(255, 255, 255), 0, 1, "liaBigFont")
        if timeLeft <= 0 and input.IsKeyDown(KEY_SPACE) then
            if not respawnRequested then
                print("[DEBUG] Respawn requested. Sending request to server.")
                respawnRequested = true
                net.Start("request_respawn")
                net.SendToServer()
            end
        else
            if respawnRequested then print("[DEBUG] Respawn request reset.") end
            respawnRequested = false
        end
    end
end