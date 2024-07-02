function MODULE:PlayerButtonDown(client, button)
    if client:Alive() or client:GetNW2Int("deathTime", 0) > os.time() then return end
    if button == KEY_SPACE and IsFirstTimePredicted() then
        net.Start("RespawnButtonPress")
        net.SendToServer()
    end
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if client:Alive() or client:GetNW2Int("deathTime", 0) > os.time() then return end
    local xPos = ScrW() / 2
    local yPos = ScrH() / 2
    draw.DrawText(self.RespawnMessage, "liaHugeFont", xPos, yPos, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end

function MODULE:RenderScreenspaceEffects()
    local client = LocalPlayer()
    if client:Alive() or client:GetNW2Int("deathTime", 0) > os.time() then return end
    surface.SetDrawColor(Color(0, 0, 0, 255))
    surface.DrawRect(0, 0, ScrW(), ScrH())
end