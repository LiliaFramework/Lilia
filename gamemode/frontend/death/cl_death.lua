--------------------------------------------------------------------------------------------------------
local owner, w, h, ceil, ft, clmp
ceil = math.ceil
clmp = math.Clamp
local aprg, aprg2 = 0, 0
w, h = ScrW(), ScrH()

-------------------------------------------------------------------------------------------------------------------------
hook.Add("HUDPaint", "HUDPaintDeath", function()
    owner = LocalPlayer()
    ft = FrameTime()

    if owner:getChar() then
        if owner:Alive() then
            if aprg ~= 0 then
                aprg2 = clmp(aprg2 - ft * 1.3, 0, 1)

                if aprg2 == 0 then
                    aprg = clmp(aprg - ft * .7, 0, 1)
                end
            end
        else
            if aprg2 ~= 1 then
                aprg = clmp(aprg + ft * .5, 0, 1)

                if aprg == 1 then
                    aprg2 = clmp(aprg2 + ft * .4, 0, 1)
                end
            end
        end
    end

    if IsValid(lia.char.gui) and lia.gui.char:IsVisible() or not owner:getChar() then return end

    if aprg > 0.01 then
        surface.SetDrawColor(0, 0, 0, ceil((aprg ^ .5) * 255))
        surface.DrawRect(-1, -1, w + 2, h + 2)
        local tx, ty = lia.util.drawText(L"youreDead", w / 2, h / 2, ColorAlpha(color_white, aprg2 * 255), 1, 1, "liaDynFontMedium", aprg2 * 255)
    end
end)
--------------------------------------------------------------------------------------------------------