local SCHEMA = SCHEMA

function PLUGIN:HUDPaint()
    if lia.config.get("ServerVersionDisplayerEnabled", true) then
        local w, h = 45, 45
        surface.SetFont("liaSmallChatFont")
        local tw, th = surface.GetTextSize(SCHEMA.version or "1")
        surface.SetTextPos(5, ScrH() - 20, w, h)
        surface.DrawText("Server Current Version: " .. SCHEMA.version or "1")
    end
end