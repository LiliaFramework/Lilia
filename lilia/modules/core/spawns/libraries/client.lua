function MODULE:PlayerButtonDown(client, button)
    if client:Alive()  then return end
    if button == KEY_SPACE and IsFirstTimePredicted() then
        net.Start("RespawnButtonPress")
        net.SendToServer()
    end
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if client:Alive()  then return end
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    local xPos = ScrW() / 2
    local yPos = ScrH() / 2
    draw.DrawText(self.RespawnMessage, "liaHugeFont", xPos, yPos, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end