function MODULE:HUDPaint()
    local client = LocalPlayer()
    if not client:HasDeathTimer() then return end
    local xPos = ScrW() / 2
    local yPos = ScrH() / 2
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    draw.DrawText("You have died", "liaHugeFont", xPos, yPos, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end