--------------------------------------------------------------------------------------------------------------------------
local w, h = ScrW(), ScrH()
--------------------------------------------------------------------------------------------------------------------------
function MODULE:HUDPaint()
    local ply = LocalPlayer()
    if not IsValid(ply:getChar()) then return end
    if CAMI.PlayerHasAccess(ply, "Lilia - Staff Permissions - Development HUD", nil) then
        draw.SimpleText("| " .. ply:SteamID64() .. " | " .. ply:SteamID() .. " | " .. os.date("%m/%d/%Y | %X", os.time()) .. " | ", "DevHudText", w / 5.25, h / 1.12, Color(210, 210, 210, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    if CAMI.PlayerHasAccess(ply, "Lilia - Staff Permissions - Staff HUD", nil) then
        local trace = ply:GetEyeTraceNoCursor()
        local entTrace = trace.Entity
        draw.SimpleText("| Pos: " .. math.Round(ply:GetPos().x, 2) .. "," .. math.Round(ply:GetPos().y, 2) .. "," .. math.Round(ply:GetPos().z, 2) .. " | Angle: " .. math.Round(ply:GetAngles().x, 2) .. "," .. math.Round(ply:GetAngles().y, 2) .. "," .. math.Round(ply:GetAngles().z, 2) .. " | FPS: " .. math.Round(1 / FrameTime(), 0) .. " | Trace Dis: " .. math.Round(ply:GetPos():Distance(trace.HitPos), 2) .. " | ", "DevHudText", w / 5.25, h / 1.10, Color(210, 210, 210, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("| Trace Pos: " .. math.Round(trace.HitPos.x, 2) .. "," .. math.Round(trace.HitPos.y, 2) .. "," .. math.Round(trace.HitPos.z, 2) .. " | Cur Health: " .. math.Round(ply:Health(), 2) .. " | FrameTime: " .. FrameTime() .. " | PING: " .. ply:Ping() .. " | ", "DevHudText", w / 5.25, h / 1.08, Color(210, 210, 210, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if IsValid(entTrace) then
            draw.SimpleText("| Cur Trace: " .. entTrace:GetClass() .. " | Trace Model: " .. entTrace:GetModel() .. " | ", "DevHudText", w / 5.25, h / 1.06, Color(210, 210, 210, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------