-------------------------------------------------------------------------------------------------------------------------~
local stmBlurAlpha = 0
local stmBlurAmount = 0

-- Called whenever the HUD should be drawn.
function PLUGIN:HUDPaintBackground()
    local frametime = RealFrameTime()

    -- Account for blurring effects when the player stamina is depleted
    if LocalPlayer():getLocalVar("stm", 50) <= 5 then
        stmBlurAlpha = Lerp(frametime / 2, stmBlurAlpha, 255)
        stmBlurAmount = Lerp(frametime / 2, stmBlurAmount, 5)
        lia.util.drawBlurAt(0, 0, ScrW(), ScrH(), stmBlurAmount, 0.2, stmBlurAlpha)
    end
end

-------------------------------------------------------------------------------------------------------------------------~
if lia.bar then
    lia.bar.add(function()
        return LocalPlayer():getLocalVar("stm", 0) / lia.config.get("defaultStamina", 100)
    end, Color(200, 200, 40), nil, "stm")
end