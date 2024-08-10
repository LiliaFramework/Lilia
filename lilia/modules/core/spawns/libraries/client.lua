function MODULE:PlayerButtonDown(client, button)
    if client:hasDeathTimer() then return end
    if button == KEY_SPACE and IsFirstTimePredicted() then
        net.Start("RespawnButtonPress")
        net.SendToServer()
    end
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if client:hasDeathTimer() then return end
    local xPos = ScrW() / 2
    local yPos = ScrH() / 2
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    draw.DrawText(self.RespawnMessage, "liaHugeFont", xPos, yPos, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end