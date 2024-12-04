local FPSDraw = CreateClientConVar("fps_draw_enabled", 0, true)
function MODULE:ShouldDrawFPS()
    return FPSDraw:GetInt() == 1
end

function MODULE:SetupQuickMenu(menu)
    menu:addCheck("Toggle FPS Draw", function(_, state)
        if state then
            RunConsoleCommand("fps_draw_enabled", "1")
        else
            RunConsoleCommand("fps_draw_enabled", "0")
        end
    end, FPSDraw:GetBool())
end

function MODULE:DrawFPS()
    local curFPS = math.Round(1 / FrameTime())
    local minFPS = self.minFPS or 60
    local maxFPS = self.maxFPS or 100
    if not self.barH then self.barH = 1 end
    self.barH = math.Approach(self.barH, (curFPS / maxFPS) * 100, 0.5)
    local barH = self.barH
    if curFPS > maxFPS then self.maxFPS = curFPS end
    if curFPS < minFPS then self.minFPS = curFPS end
    draw.SimpleText(curFPS .. " FPS", "FPSFont", ScrW() - 10, ScrH() / 2 + 20, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT, 1)
    draw.RoundedBox(0, ScrW() - 30, (ScrH() / 2) - barH, 20, barH, Color(255, 255, 255, 255))
    draw.SimpleText("Max : " .. maxFPS, "FPSFont", ScrW() - 10, ScrH() / 2 + 40, Color(150, 255, 150, 255), TEXT_ALIGN_RIGHT, 1)
    draw.SimpleText("Min : " .. minFPS, "FPSFont", ScrW() - 10, ScrH() / 2 + 55, Color(255, 150, 150, 255), TEXT_ALIGN_RIGHT, 1)
end