function MODULE:HUDPaint()
    local ceil = math.ceil
    local clmp = math.Clamp
    local client = LocalPlayer()
    local ft = FrameTime()
    local w, h = ScrW(), ScrH()
    local aprg, aprg2 = 0, 0
    if client:getChar() then
        if client:Alive() then
            if aprg ~= 0 then
                aprg2 = clmp(aprg2 - ft * 1.3, 0, 1)
                if aprg2 == 0 then aprg = clmp(aprg - ft * .7, 0, 1) end
            end
        else
            if aprg2 ~= 1 then
                aprg = clmp(aprg + ft * .5, 0, 1)
                if aprg == 1 then aprg2 = clmp(aprg2 + ft * .4, 0, 1) end
            end
        end
    end

    if IsValid(lia.char.gui) and lia.gui.char:IsVisible() or not client:getChar() then return end
    if aprg > 0.01 then
        surface.SetDrawColor(0, 0, 0, ceil((aprg ^ .5) * 255))
        surface.DrawRect(-1, -1, w + 2, h + 2)
        lia.util.drawText("You have died", w / 2, h / 2, ColorAlpha(color_white, aprg2 * 255), 1, 1, "liaDynFontMedium", aprg2 * 255)
    end
end