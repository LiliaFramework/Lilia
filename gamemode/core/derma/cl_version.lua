local SCHEMA = SCHEMA

hook.Add("HUDPaint", "HUDPaintSchemaVersion", function()
    if SCHEMA.version then
        local w, h = 45, 45
        surface.SetFont("liaSmallChatFont")
        local tw, th = surface.GetTextSize(SCHEMA.version)
        surface.SetTextPos(5, ScrH() - 20, w, h)
        surface.DrawText("Server Current Version: " .. SCHEMA.version)
    end
end)