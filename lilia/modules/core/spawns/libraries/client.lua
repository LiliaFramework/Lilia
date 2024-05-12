function MODULE:PlayerButtonDown(client, button)
    if client:Alive() or client:GetNW2Int("deathTime", 0) > os.time() then return end
    if button == KEY_SPACE and IsFirstTimePredicted() then
        net.Start("RespawnButtonPress")
        net.SendToServer()
    end
end

function MODULE:HUDPaint()
    if LocalPlayer():Alive() or LocalPlayer():GetNW2Int("deathTime", 0) > os.time() then return end
    local xPos = ScrW() / 2
    local yPos = ScrH() / 2
    draw.DrawText(self.RespawnMessage, "liaHugeFont", xPos, yPos, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end